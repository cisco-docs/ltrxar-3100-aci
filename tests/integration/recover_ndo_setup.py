# -*- coding: utf-8 -*-

# Copyright: (c) 2024, Justyna Chowaniec <juchowan@cisco.com>

"""Recovery script for failed NDO CI setups.

Automates the full recovery pipeline for NDO + APIC simulator pairs:
1. Reset APIC simulator in vCenter
2. Run APIC initial setup wizard via KVM keystrokes
3. Wait for APIC to become reachable over API
4. Configure APIC with Ansible playbooks (bootstrap + deploy)
5. Re-register site on NDO

Usage:
    python recover_ndo_setup.py --version 4.2
    python recover_ndo_setup.py --version all
"""

import argparse
import json
import os
import shutil
import subprocess
import ssl
import sys
import tempfile
import time
import urllib.request
import urllib.error

sys.path.insert(0, os.path.dirname(__file__))
from vmware import Vsphere

# -- Constants ----------------------------------------------------------------

ANSIBLE_REPO_URL = "https://wwwin-github.cisco.com/netascode/nac-aci-ansible.git"
ANSIBLE_REPO_BRANCH = "master"
ANSIBLE_VAULT_PASSWORD = "dummy_value"

APIC_WAIT_TIMEOUT = 600  # seconds
APIC_WAIT_INTERVAL = 30  # seconds
APIC_BOOT_WAIT = 600  # seconds to wait for APIC to boot to setup wizard
APIC_SETUP_STEP_DELAY = 15  # seconds between setup wizard answers
BOOTSTRAP_MAX_RETRIES = 3
APIC_ADMIN_PASSWORD = "C1sco123"
NDO_SITE_NAME = "APIC1"

# NDO + APIC setup pairs keyed by version label
SETUPS = {
    "4.2": {
        "label": "NDO 4.2",
        "ndo": {"name": "nac-ci-nd1-3.0.1i", "ip": "10.50.202.17"},
        "apic": {
            "name": "nac-ci-apic3-6.0.5h",
            "ip": "10.50.202.16",
            "oob_ip": "10.50.202.16/25",
            "oob_gateway": "10.50.202.1",
        },
    },
    "4.3": {
        "label": "NDO 4.3",
        "ndo": {"name": "nac-ci-nd1-3.1.1l", "ip": "10.50.202.14"},
        "apic": {
            "name": "nac-ci-apic2-6.0.5h",
            "ip": "10.50.202.13",
            "oob_ip": "10.50.202.13/25",
            "oob_gateway": "10.50.202.1",
        },
    },
    "4.4": {
        "label": "NDO 4.4",
        "ndo": {"name": "nac-ci-nd1-3.2.1i", "ip": "10.50.202.107"},
        "apic": {
            "name": "nac-ci-apic5-6.0.5h",
            "ip": "10.50.202.106",
            "oob_ip": "10.50.202.106/25",
            "oob_gateway": "10.50.202.1",
        },
    },
    "4.1": {
        "label": "ND 4.1",
        "ndo": {"name": "nac-ci-nd1-4.1.1.g", "ip": "10.48.161.120"},
        "apic": {
            "name": "nac-ci-vapic2-6.1.5e",
            "ip": "10.48.161.121",
            "oob_ip": "10.48.161.121/25",
            "oob_gateway": "10.48.161.1",
        },
        "skip_kvm": True,
    },
}


# -- Logging helpers ----------------------------------------------------------


def log_info(msg):
    print(f"[INFO]  {msg}")


def log_ok(msg):
    print(f"[OK]    {msg}")


def log_warn(msg):
    print(f"[WARN]  {msg}", file=sys.stderr)


def log_fail(msg):
    print(f"[FAIL]  {msg}", file=sys.stderr)


def log_step(step_num, total, msg):
    print(f"\n{'=' * 60}")
    print(f"  Step {step_num}/{total}: {msg}")
    print(f"{'=' * 60}")


# -- Step 1: vCenter reset ----------------------------------------------------


def get_vsphere_connection():
    """Create a vSphere connection from environment variables."""
    host = os.environ.get("VMWARE_HOST")
    user = os.environ.get("VMWARE_USER")
    password = os.environ.get("VMWARE_PASSWORD")
    port = os.environ.get("VMWARE_PORT")

    if not all([host, user, password]):
        log_fail(
            "VMWARE_HOST, VMWARE_USER, and VMWARE_PASSWORD environment "
            "variables must be set for vCenter operations."
        )
        sys.exit(1)

    log_info(f"Connecting to vCenter {host} ...")
    if port:
        return Vsphere(host, user, password, int(port))
    return Vsphere(host, user, password)


def reset_apic_in_vcenter(vsphere, setup):
    """Reset APIC simulator VM in vCenter (power off + power on)."""
    apic_name = setup["apic"]["name"]
    log_info(f"Resetting APIC VM '{apic_name}' ...")
    vsphere.vmware_reset_vm(apic_name)
    log_ok(f"APIC VM '{apic_name}' has been reset.")


# -- Step 2: APIC initial setup via KVM --------------------------------------


def configure_apic_initial_setup(vsphere, setup):
    """Run through the APIC initial setup wizard by sending keystrokes.

    Sends answers to each setup wizard prompt via USB scan codes.
    Most prompts accept the default (just Enter), except for the
    OOB IP, gateway, strong passwords, and admin password.
    """
    vm_name = setup["apic"]["name"]
    oob_ip = setup["apic"]["oob_ip"]
    oob_gateway = setup["apic"]["oob_gateway"]

    log_info(f"Waiting {APIC_BOOT_WAIT}s for APIC to boot to setup wizard ...")
    time.sleep(APIC_BOOT_WAIT)

    # Each entry: (description, text to type before Enter)
    # Empty string = just press Enter to accept default
    setup_steps = [
        ("Fabric name", ""),
        ("Fabric ID", ""),
        ("Number of controllers", ""),
        ("Standby controller", ""),
        ("Controller ID", ""),
        ("L3 network", ""),
        ("POD ID", ""),
        ("Controller name", ""),
        ("TEP address pool", ""),
        ("Infra VLAN ID", ""),
        ("BD multicast pool", ""),
        ("IPv6 OOB mgmt", ""),
        ("IPv4 address", oob_ip),
        ("IPv4 gateway", oob_gateway),
        ("Interface speed", ""),
        ("Strong passwords", "N"),
        ("Admin password", APIC_ADMIN_PASSWORD),
        ("Confirm admin password", APIC_ADMIN_PASSWORD),
        ("Edit configuration", ""),
    ]

    for i, (desc, text) in enumerate(setup_steps):
        if text:
            log_info(f'  [{i + 1}/{len(setup_steps)}] {desc}: "{text}"')
            vsphere.vmware_type_text(vm_name, text + "\n")
        else:
            log_info(f"  [{i + 1}/{len(setup_steps)}] {desc}: <default>")
            vsphere.vmware_type_text(vm_name, "\n")
        # Extra delay after gateway (step 15) — the interface speed prompt
        # can be slow to appear, and we must not send the password too early
        if desc == "IPv4 gateway":
            time.sleep(APIC_SETUP_STEP_DELAY + 10)
        else:
            time.sleep(APIC_SETUP_STEP_DELAY)

    log_ok("APIC initial setup wizard completed.")


# -- Step 3: Wait for APIC ---------------------------------------------------


def wait_for_apic(ip, timeout=APIC_WAIT_TIMEOUT, interval=APIC_WAIT_INTERVAL):
    """Poll APIC API until it becomes reachable.

    Args:
        ip: APIC management IP address.
        timeout: Maximum seconds to wait.
        interval: Seconds between retries.

    Raises:
        SystemExit: If APIC is not reachable within the timeout.
    """
    url = f"https://{ip}/api/aaaLogin.json"
    # Disable TLS verification for lab simulators
    ctx = ssl.create_default_context()
    ctx.check_hostname = False
    ctx.verify_mode = ssl.CERT_NONE

    log_info(f"Waiting for APIC at {ip} to become reachable (timeout={timeout}s) ...")

    deadline = time.time() + timeout
    attempt = 0
    while time.time() < deadline:
        attempt += 1
        try:
            req = urllib.request.Request(url, method="GET")
            urllib.request.urlopen(req, timeout=10, context=ctx)
            log_ok(f"APIC at {ip} is reachable (attempt {attempt}).")
            return
        except urllib.error.HTTPError:
            # Any HTTP response (even 400) means the API is up
            log_ok(f"APIC at {ip} is reachable (attempt {attempt}).")
            return
        except (urllib.error.URLError, OSError):
            remaining = int(deadline - time.time())
            log_info(
                f"APIC not reachable yet (attempt {attempt}). "
                f"Retrying in {interval}s ... ({remaining}s remaining)"
            )
            time.sleep(interval)

    log_fail(f"APIC at {ip} did not become reachable within {timeout}s.")
    sys.exit(1)


# -- Step 4: Configure APIC with Ansible -------------------------------------


def _run_command(cmd, cwd, env=None):
    """Run a subprocess command and stream output.

    Args:
        cmd: Command as a list of strings.
        cwd: Working directory.
        env: Optional environment dict (merged with os.environ).

    Returns:
        subprocess.CompletedProcess
    """
    run_env = os.environ.copy()
    if env:
        run_env.update(env)

    log_info(f"Running: {' '.join(cmd)}")
    result = subprocess.run(
        cmd,
        cwd=cwd,
        env=run_env,
        capture_output=False,
    )
    return result


def configure_apic_with_ansible(apic_ip):
    """Clone the Ansible repo and run bootstrap + deploy playbooks.

    Args:
        apic_ip: APIC management IP address.

    Raises:
        SystemExit: If any step fails.
    """
    work_dir = tempfile.mkdtemp(prefix="nac-recover-")
    repo_dir = os.path.join(work_dir, "nac-aci-ansible")

    try:
        # Clone repo
        log_info(f"Cloning {ANSIBLE_REPO_URL} (branch {ANSIBLE_REPO_BRANCH}) ...")
        result = _run_command(
            [
                "git",
                "clone",
                "--branch",
                ANSIBLE_REPO_BRANCH,
                "--depth",
                "1",
                ANSIBLE_REPO_URL,
                repo_dir,
            ],
            cwd=work_dir,
        )
        if result.returncode != 0:
            log_fail("Failed to clone Ansible repository.")
            sys.exit(1)
        log_ok("Repository cloned successfully.")

        # Install Ansible collection from requirements.yml
        log_info("Installing Ansible collections from requirements.yml ...")
        result = _run_command(
            [
                "ansible-galaxy",
                "collection",
                "install",
                "-r",
                "requirements.yml",
                "--force",
            ],
            cwd=repo_dir,
        )
        if result.returncode != 0:
            log_fail("Failed to install Ansible collections.")
            sys.exit(1)
        log_ok("Ansible collections installed successfully.")

        # Environment variables for playbooks
        playbook_env = {
            "ANSIBLE_VAULT_PASSWORD": ANSIBLE_VAULT_PASSWORD,
            "APIC_HOST": apic_ip,
        }

        # Run apic_bootstrap.yaml with retries
        log_info(
            f"Running apic_bootstrap.yaml (max {BOOTSTRAP_MAX_RETRIES} attempts) ..."
        )
        bootstrap_success = False
        for attempt in range(1, BOOTSTRAP_MAX_RETRIES + 1):
            log_info(f"Bootstrap attempt {attempt}/{BOOTSTRAP_MAX_RETRIES} ...")
            result = _run_command(
                [
                    "ansible-playbook",
                    "-i",
                    "data/lab/hosts.yaml",
                    "apic_bootstrap.yaml",
                ],
                cwd=repo_dir,
                env=playbook_env,
            )
            if result.returncode == 0:
                bootstrap_success = True
                log_ok(f"apic_bootstrap.yaml succeeded on attempt {attempt}.")
                break
            else:
                log_warn(f"apic_bootstrap.yaml failed on attempt {attempt}.")

        if not bootstrap_success:
            log_fail(
                f"apic_bootstrap.yaml failed after {BOOTSTRAP_MAX_RETRIES} "
                "attempts. The APIC API may not be fully ready."
            )
            sys.exit(1)

        # Run apic_deploy.yaml (no retries)
        log_info("Running apic_deploy.yaml ...")
        result = _run_command(
            [
                "ansible-playbook",
                "-i",
                "data/lab/hosts.yaml",
                "apic_deploy.yaml",
            ],
            cwd=repo_dir,
            env=playbook_env,
        )
        if result.returncode != 0:
            log_fail("apic_deploy.yaml failed.")
            sys.exit(1)
        log_ok("apic_deploy.yaml succeeded.")

    finally:
        # Clean up temp directory
        log_info(f"Cleaning up temporary directory: {work_dir}")
        shutil.rmtree(work_dir, ignore_errors=True)


# -- Step 5: NDO site re-registration -----------------------------------------


def _ndo_request(ndo_ip, method, path, payload=None, token=None):
    """Send a request to an NDO API endpoint.

    Args:
        ndo_ip: NDO management IP address.
        method: HTTP method (GET, POST, etc.).
        path: API path (e.g. /api/config/acipreboard/).
        payload: Optional dict to send as JSON body.
        token: Optional Bearer token for authorization.

    Returns:
        (status_code, response_body) tuple.

    Raises:
        SystemExit: On connection failure.
    """
    url = f"https://{ndo_ip}{path}"
    data = json.dumps(payload).encode("utf-8") if payload else None

    ctx = ssl.create_default_context()
    ctx.check_hostname = False
    ctx.verify_mode = ssl.CERT_NONE

    headers = {"Content-Type": "application/json"}
    if token:
        headers["Authorization"] = f"Bearer {token}"

    req = urllib.request.Request(url, data=data, method=method, headers=headers)

    try:
        resp = urllib.request.urlopen(req, timeout=30, context=ctx)
        body = resp.read().decode("utf-8")
        return resp.status, body
    except urllib.error.HTTPError as e:
        body = e.read().decode("utf-8") if e.fp else ""
        return e.code, body
    except (urllib.error.URLError, OSError) as e:
        log_fail(f"Failed to connect to NDO at {ndo_ip}: {e}")
        sys.exit(1)


def _ndo_login(ndo_ip):
    """Authenticate to NDO and return a Bearer token.

    Args:
        ndo_ip: NDO management IP address.

    Returns:
        Bearer token string.

    Raises:
        SystemExit: If login fails.
    """
    log_info(f"Logging in to NDO at {ndo_ip} ...")
    credentials = {
        "userName": "admin",
        "userPasswd": APIC_ADMIN_PASSWORD,
        "domain": "DefaultAuth",
    }
    status, body = _ndo_request(ndo_ip, "POST", "/login", credentials)
    if status >= 400:
        log_fail(f"NDO login failed (HTTP {status}): {body}")
        sys.exit(1)
    token = json.loads(body)["token"]
    log_ok("NDO login successful.")
    return token


def reregister_site_on_ndo(setup):
    """Re-register the APIC site on NDO.

    Logs in to NDO, then sends two POST requests:
    1. acipreboard — pre-board the APIC credentials
    2. addsite — register the site on NDO
    """
    ndo_ip = setup["ndo"]["ip"]
    apic_ip = setup["apic"]["ip"]
    label = setup["label"]

    log_info(f"Re-registering site on NDO at {ndo_ip} ...")

    # Login to NDO
    token = _ndo_login(ndo_ip)

    # Step 1: Pre-board APIC credentials
    log_info(f"POST /api/config/acipreboard/ (APIC {apic_ip}) ...")
    preboard_payload = {
        "url": apic_ip,
        "loginDomain": "",
        "userName": "admin",
        "password": APIC_ADMIN_PASSWORD,
    }
    status, body = _ndo_request(
        ndo_ip, "POST", "/api/config/acipreboard/", preboard_payload, token
    )
    if status >= 400:
        log_fail(f"acipreboard failed (HTTP {status}): {body}")
        sys.exit(1)
    log_ok(f"acipreboard succeeded (HTTP {status}).")

    # Step 2: Add site
    log_info(f"POST /api/config/v2/addsite/ (site '{NDO_SITE_NAME}') ...")
    addsite_payload = {
        "name": NDO_SITE_NAME,
        "url": apic_ip,
        "siteType": "ACI",
        "verifySecure": False,
        "forceAdd": True,
        "securityDomains": [],
        "aci": {
            "userName": "admin",
            "password": APIC_ADMIN_PASSWORD,
            "loginDomain": "",
        },
        "latitude": "",
        "longitude": "",
    }
    status, body = _ndo_request(
        ndo_ip, "POST", "/api/config/v2/addsite/", addsite_payload, token
    )
    if status >= 400:
        log_fail(f"addsite failed (HTTP {status}): {body}")
        sys.exit(1)
    log_ok(f"addsite succeeded (HTTP {status}).")
    log_ok(f"Site re-registered on NDO ({label}).")


# -- Recovery pipeline --------------------------------------------------------


def recover_setup(version, setup):
    """Run the full recovery pipeline for one NDO+APIC pair."""
    label = setup["label"]
    apic_ip = setup["apic"]["ip"]

    print(f"\n{'#' * 60}")
    print(f"  Recovering {label} (version key: {version})")
    print(f"  NDO:  {setup['ndo']['name']} @ {setup['ndo']['ip']}")
    print(f"  APIC: {setup['apic']['name']} @ {apic_ip}")
    print(f"{'#' * 60}")

    total_steps = 5

    # vCenter connection (shared across steps 1 and 2)
    vsphere = get_vsphere_connection()

    # Step 1: vCenter reset
    log_step(1, total_steps, "Reset APIC in vCenter")
    if setup.get("skip_kvm"):
        log_info("vCenter reset skipped for this version.")
    else:
        reset_apic_in_vcenter(vsphere, setup)

    # Step 2: APIC initial setup via KVM
    log_step(2, total_steps, "APIC initial setup via KVM")
    if setup.get("skip_kvm"):
        log_info("KVM setup skipped for this version.")
    else:
        configure_apic_initial_setup(vsphere, setup)

    # Step 3: Wait for APIC API
    log_step(3, total_steps, "Wait for APIC to become reachable")
    wait_for_apic(apic_ip)

    # Step 4: Configure APIC
    log_step(4, total_steps, "Configure APIC with Ansible")
    configure_apic_with_ansible(apic_ip)

    # Step 5: NDO re-registration
    log_step(5, total_steps, "Re-register site on NDO")
    reregister_site_on_ndo(setup)

    log_ok(f"Recovery pipeline completed for {label}.\n")


# -- CLI entry point ----------------------------------------------------------


def parse_args():
    parser = argparse.ArgumentParser(
        description="Recover failed NDO CI setups (APIC reset + Ansible config + NDO re-registration).",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=(
            "Available versions:\n"
            + "\n".join(
                f"  {k:6s}  {v['label']:10s}  "
                f"NDO={v['ndo']['name']}  APIC={v['apic']['name']}"
                for k, v in SETUPS.items()
            )
            + "\n\nExamples:\n"
            "  python recover_ndo_setup.py --version 4.2\n"
            "  python recover_ndo_setup.py --version all\n"
        ),
    )
    parser.add_argument(
        "--version",
        required=True,
        choices=list(SETUPS.keys()) + ["all"],
        help="Which setup version to recover, or 'all' for every setup.",
    )
    return parser.parse_args()


def main():
    args = parse_args()

    if args.version == "all":
        versions_to_recover = list(SETUPS.keys())
    else:
        versions_to_recover = [args.version]

    log_info(f"Setups to recover: {', '.join(versions_to_recover)}")

    failed = []
    for version in versions_to_recover:
        setup = SETUPS[version]
        try:
            recover_setup(version, setup)
        except SystemExit:
            log_fail(f"Recovery failed for {setup['label']} (version {version}).")
            failed.append(version)
            if args.version != "all":
                sys.exit(1)
            # When recovering all, continue to next setup
            continue

    # Summary
    print(f"\n{'=' * 60}")
    print("  Recovery Summary")
    print(f"{'=' * 60}")
    succeeded = [v for v in versions_to_recover if v not in failed]
    if succeeded:
        log_ok(f"Succeeded: {', '.join(succeeded)}")
    if failed:
        log_fail(f"Failed:    {', '.join(failed)}")
        sys.exit(1)
    else:
        log_ok("All setups recovered successfully.")


if __name__ == "__main__":
    main()
