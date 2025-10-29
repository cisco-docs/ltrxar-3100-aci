# -*- coding: utf-8 -*-

# Copyright: (c) 2022, Daniel Schmidt <danischm@cisco.com>

import os
import shutil
import subprocess
import time
import re

import errorhandler
import nac_test.pabot
import pytest
from aci import Apic
from util import (
    validate_json,
    render_templates,
    revert_snapshot,
    terraform_post_process,
    get_latest_git_tag,
)
from pathlib import Path

pytestmark = pytest.mark.integration
pytestmark = pytest.mark.apic

error_handler = errorhandler.ErrorHandler()

FILTERS_PATH = "jinja_filters/"
APIC_DEPLOY_TEMPLATES_PATH = "templates/apic/deploy/"
APIC_TEST_TEMPLATES_PATH = "templates/apic/test/"

PRIORITIZED_TEMPLATES = ["radius.j2"]


def apic_deploy_config(apic_url, config_path, version):
    """Deploy config via a set of json files"""
    username = os.getenv("ACI_USERNAME")
    if version == "6.1":
        password = os.getenv("ACI_PASSWORD_61")
    else:
        password = os.getenv("ACI_PASSWORD")
    if not username:
        return "APIC username must be specified with ACI_USERNAME environment variable."
    if not password:
        return "APIC password must be specified with ACI_PASSWORD environment variable."
    apic = Apic(apic_url, username, password)
    r = apic.login()
    if r:
        return "APIC login failed: {}.".format(r)
    for dir, subdir, files in sorted(os.walk(config_path)):
        sorted_files = sorted(files)
        for filename in PRIORITIZED_TEMPLATES:
            if filename in sorted_files:
                sorted_files.remove(filename)
                sorted_files.insert(0, filename)
        for filename in sorted_files:
            if ".j2" in filename:
                with open(dir + os.path.sep + filename, "r") as file:
                    data = file.read()
                    r = apic.post(data)
                    if r:
                        return "Deployment of {} failed: {}.".format(filename, r)
    return None


def apic_render_run_tests(apic_url, data_paths, output_path, version):
    """Render APIC test suites and run them using nac-test"""
    error = render_templates(
        data_paths, output_path, APIC_TEST_TEMPLATES_PATH, filters_path=FILTERS_PATH
    )
    if version == "6.1":
        os.environ["ACI_PASSWORD"] = os.getenv("ACI_PASSWORD_61")
    if error:
        pytest.fail(error)
    os.environ["ACI_URL"] = apic_url
    try:
        nac_test.pabot.run_pabot(output_path)
    except SystemExit as e:
        if e.code != 0:
            return "Robot testing failed."
    return None


def remove_multipod_config(apic):
    r = apic.get(
        url='/api/node/class/fabricNode.json?query-target-filter=eq(fabricNode.id, "2001")'
    )
    data = r.json()
    timer = False
    if data.get("totalCount", "0") != "0":
        timer = True
        payload = '{"fabricRsDecommissionNode":{"attributes":{"tDn":"topology/pod-2/node-2001","status":"created,modified","removeFromController":"true"},"children":[]}}'
        r = apic.post(payload, url="/api/node/mo/uni/fabric/outofsvc.json")
        if r:
            return "Removing Node 2001 config failed."

    r = apic.get(
        url='/api/node/class/fabricNode.json?query-target-filter=eq(fabricNode.id, "301")'
    )
    data = r.json()
    if data.get("totalCount", "0") != "0":
        timer = True
        payload = '{"fabricRsDecommissionNode":{"attributes":{"tDn":"topology/pod-1/node-301","status":"created,modified","removeFromController":"true"},"children":[]}}'
        r = apic.post(payload, url="/api/node/mo/uni/fabric/outofsvc.json")
        if r:
            return "Removing Node 301 config failed."

    r = apic.get(
        url='/api/node/class/fabricNode.json?query-target-filter=eq(fabricNode.id, "302")'
    )
    data = r.json()
    if data.get("totalCount", "0") != "0":
        timer = True
        payload = '{"fabricRsDecommissionNode":{"attributes":{"tDn":"topology/pod-1/node-302","status":"created,modified","removeFromController":"true"},"children":[]}}'
        r = apic.post(payload, url="/api/node/mo/uni/fabric/outofsvc.json")
        if r:
            return "Removing Node 302 config failed."
    if timer:
        time.sleep(600)

    r = apic.get(url="/api/mo/uni/controller/setuppol/setupp-2.json")
    data = r.json()
    timer = False
    if data.get("totalCount", "0") != "0":
        timer = True
        payload = '{"fabricSetupP":{"attributes":{"dn":"uni/controller/setuppol/setupp-2","status":"deleted"},"children":[]}}'
        r = apic.post(payload, url="/api/node/mo/uni/controller/setuppol/setupp-2.json")
        if r:
            return "Removing Pod 2 config failed."

    if timer:
        time.sleep(60)

    r = apic.get(url="/api/mo/uni/tn-infra/out-IPN.json")
    data = r.json()
    if data.get("totalCount", "0") != "0":
        payload = '{"l3extOut":{"attributes":{"dn":"uni/tn-infra/out-IPN","status":"deleted"},"children":[]}}'
        r = apic.post(payload, url="/api/node/mo/uni/tn-infra/out-IPN.json")
        if r:
            return "Removing IPN config failed."

    r = apic.get(url="/api/mo/uni/tn-infra/out-RL-L3OUT-BGP.json")
    data = r.json()
    if data.get("totalCount", "0") != "0":
        payload = '{"l3extOut":{"attributes":{"dn":"uni/tn-infra/out-RL-L3OUT-BGP","status":"deleted"},"children":[]}}'
        r = apic.post(payload, url="/api/node/mo/uni/tn-infra/out-RL-L3OUT-BGP.json")
        if r:
            return "Removing RL-L3OUT-BGP config failed."

    r = apic.get(url="/api/mo/uni/tn-infra/out-RL-L3OUT-OSPF.json")
    data = r.json()
    if data.get("totalCount", "0") != "0":
        payload = '{"l3extOut":{"attributes":{"dn":"uni/tn-infra/out-RL-L3OUT-OSPF","status":"deleted"},"children":[]}}'
        r = apic.post(payload, url="/api/node/mo/uni/tn-infra/out-RL-L3OUT-OSPF.json")
        if r:
            return "Removing RL-L3OUT-OSPF config failed."


def revert_snapshot_physical(apic_url, snapshot_name):
    """Revert physical APIC snapshot"""
    username = os.getenv("ACI_USERNAME")
    password = os.getenv("ACI_PASSWORD_61")
    if not username:
        return "APIC username must be specified with ACI_USERNAME environment variable."
    if not password:
        return "APIC password must be specified with ACI_PASSWORD environment variable."
    apic = Apic(apic_url, username, password)
    r = apic.login()
    if r:
        return "APIC login failed: {}.".format(r)

    remove_multipod_config(apic)

    payload = (
        '{"configImportP":{"attributes":{"dn":"uni/fabric/configimp-default","name":"default","snapshot":"true","adminSt":"triggered","fileName":"'
        + snapshot_name
        + '","importType":"replace","importMode":"atomic","rn":"configimp-default","status":"created,modified"},"children":[]}}'
    )
    r = apic.post(payload, url="/api/node/mo/uni/fabric/configimp-default.json")
    if r:
        return "Reverting to APIC snapshot failed."
    return None


def full_apic_test(data_paths, vm_name, snapshot_name, apic_url, version, tmpdir):
    """Deploy config to ACI simulator and run tests"""

    # Render templates
    error = render_templates(
        data_paths,
        tmpdir.strpath,
        APIC_DEPLOY_TEMPLATES_PATH,
        filters_path=FILTERS_PATH,
    )
    if error:
        pytest.fail(error)

    # Validate rendered templates
    error = validate_json(tmpdir.strpath)
    if error:
        pytest.fail(error)

    # Revert ACI simulator snapshot
    if version != "6.1":
        revert_snapshot(vm_name, snapshot_name)
    else:
        revert_snapshot_physical(apic_url, snapshot_name)

    if version.startswith("6.1"):
        time.sleep(60)

    # Configure ACI simulator
    error = apic_deploy_config(apic_url, tmpdir.strpath, version)
    if error:
        pytest.fail(error)

    # Fix issue with ACI 5.2 simulator
    if version.startswith("5.2"):
        time.sleep(60)

    # Run tests
    error = apic_render_run_tests(
        apic_url, data_paths, os.path.join(tmpdir, "results/"), version
    )
    shutil.copy(
        os.path.join(tmpdir, "results/", "log.html"), "apic_{}_log.html".format(version)
    )
    shutil.copy(
        os.path.join(tmpdir, "results/", "report.html"),
        "apic_{}_report.html".format(version),
    )
    shutil.copy(
        os.path.join(tmpdir, "results/", "output.xml"),
        "apic_{}_output.xml".format(version),
    )
    shutil.copy(
        os.path.join(tmpdir, "results/", "xunit.xml"),
        "apic_{}_xunit.xml".format(version),
    )
    if error:
        pytest.fail(error)


def full_apic_terraform_test(
    data_paths,
    terraform_path,
    vm_name,
    snapshot_name,
    apic_url,
    version,
    tmpdir,
    terraform_binary="terraform",
):
    """Deploy config to ACI simulator using Terraform"""

    # Revert ACI simulator snapshot
    if version != "6.1":
        revert_snapshot(vm_name, snapshot_name)
    else:
        revert_snapshot_physical(apic_url, snapshot_name)

    if version.startswith("6.1"):
        time.sleep(60)

    os.environ["ACI_URL"] = apic_url
    os.environ["ACI_RETRIES"] = "4"
    if version.startswith("6.1"):
        os.environ["ACI_PASSWORD"] = os.getenv("ACI_PASSWORD_61")

    try:
        r = subprocess.run(
            [terraform_binary, "init", "-upgrade", "-no-color"],
            cwd=terraform_path,
            capture_output=True,
            text=True,
        )
        terraform_post_process("TERRAFORM INIT", r)

        apply_args = [terraform_binary, "apply", "-auto-approve", "-no-color"]
        if version.startswith(("6.0", "6.1")):
            apply_args.append("-parallelism=3")
        r = subprocess.run(
            apply_args, cwd=terraform_path, capture_output=True, text=True
        )
        terraform_post_process("FIRST TERRAFORM APPLY", r, ignore_errors=True)

        # second apply to work around APIC API quirks
        r = subprocess.run(
            apply_args, cwd=terraform_path, capture_output=True, text=True
        )
        terraform_post_process("SECOND TERRAFORM APPLY", r)

        # check idempotency
        r = subprocess.run(
            apply_args, cwd=terraform_path, capture_output=True, text=True
        )
        terraform_post_process("THIRD TERRAFORM APPLY", r)
        if "Your infrastructure matches the configuration." not in r.stdout:
            pytest.fail("Idempotency check failed.")

        # Run tests
        data_paths.append(Path(os.path.join(terraform_path, "defaults.yaml")))
        error = apic_render_run_tests(
            apic_url, data_paths, os.path.join(tmpdir, "results/"), version
        )
        shutil.copy(
            os.path.join(tmpdir, "results/", "log.html"),
            "apic_tf_{}_log.html".format(version),
        )
        shutil.copy(
            os.path.join(tmpdir, "results/", "report.html"),
            "apic_tf_{}_report.html".format(version),
        )
        shutil.copy(
            os.path.join(tmpdir, "results/", "output.xml"),
            "apic_tf_{}_output.xml".format(version),
        )
        shutil.copy(
            os.path.join(tmpdir, "results/", "xunit.xml"),
            "apic_tf_{}_xunit.xml".format(version),
        )
        if error:
            pytest.fail(error)

        destroy_args = [terraform_binary, "destroy", "-auto-approve", "-no-color"]
        if version.startswith(("6.0", "6.1")):
            destroy_args.append("-parallelism=3")
        r = subprocess.run(
            destroy_args,
            cwd=terraform_path,
            capture_output=True,
            text=True,
        )
        terraform_post_process("FIRST TERRAFORM DESTROY", r, ignore_errors=True)
        r = subprocess.run(
            destroy_args,
            cwd=terraform_path,
            capture_output=True,
            text=True,
        )
        terraform_post_process("SECOND TERRAFORM DESTROY", r)
    finally:
        state_path = os.path.join(terraform_path, "terraform.tfstate")
        state_backup_path = os.path.join(terraform_path, "terraform.tfstate.backup")
        if os.path.exists(state_path):
            os.remove(state_path)
        if os.path.exists(state_backup_path):
            os.remove(state_backup_path)


def full_apic_terraform_upgrade_test(
    data_paths,
    terraform_path,
    vm_name,
    snapshot_name,
    apic_url,
    version,
    tmpdir,
    terraform_binary="terraform",
):
    """Deploy config to ACI simulator using Terraform"""

    # Revert ACI simulator snapshot
    revert_snapshot(vm_name, snapshot_name)

    os.environ["ACI_URL"] = apic_url
    os.environ["ACI_RETRIES"] = "4"

    # Get the latest version tag dynamically and update main.tf before terraform init
    main_tf_path = os.path.join(terraform_path, "main.tf")
    latest_version = get_latest_git_tag()

    with open(main_tf_path, "r") as f:
        content = f.read()

    # Ensure main.tf is in the correct initial state before terraform init
    # Match lines that start with 'source = "github...' and replace with '#source = "github...'
    content = re.sub(
        r'^(\s*)source\s*=\s*"github\.com/netascode/terraform-aci-nac-aci\.git\?ref=main"',
        r'\1#source = "github.com/netascode/terraform-aci-nac-aci.git?ref=main"',
        content,
        flags=re.MULTILINE,
    )

    # Match lines that start with '#source = "netascode...' and replace with 'source = "netascode...'
    content = re.sub(
        r'^(\s*)#source\s*=\s*"netascode/nac-aci/aci"',
        r'\1source  = "netascode/nac-aci/aci"',
        content,
        flags=re.MULTILINE,
    )

    # Ensure version is uncommented (handle both commented and uncommented states)
    content = re.sub(
        r'^(\s*)#version\s*=\s*"[^"]*"',
        rf'\1version = "{latest_version}"',
        content,
        flags=re.MULTILINE,
    )

    with open(main_tf_path, "w") as f:
        f.write(content)

    try:
        r = subprocess.run(
            [terraform_binary, "init", "-upgrade", "-no-color"],
            cwd=terraform_path,
            capture_output=True,
            text=True,
        )
        terraform_post_process("TERRAFORM INIT", r)

        apply_args = [
            terraform_binary,
            "apply",
            "-auto-approve",
            "-no-color",
            "-parallelism=3",
        ]
        r = subprocess.run(
            apply_args, cwd=terraform_path, capture_output=True, text=True
        )
        terraform_post_process("FIRST TERRAFORM APPLY", r, ignore_errors=True)

        # second apply to work around APIC API quirks
        r = subprocess.run(
            apply_args, cwd=terraform_path, capture_output=True, text=True
        )
        terraform_post_process("SECOND TERRAFORM APPLY", r)

        # Modify main.tf to switch from versioned source to git source to perform upgrade
        main_tf_path = os.path.join(terraform_path, "main.tf")
        with open(main_tf_path, "r") as f:
            content = f.read()

        # Comment out the versioned source and version lines, uncomment the git source
        # Match lines that start with '#source = "github...' and replace with 'source = "github...'
        content = re.sub(
            r'^(\s*)#source\s*=\s*"github\.com/netascode/terraform-aci-nac-aci\.git\?ref=main"',
            r'\1source = "github.com/netascode/terraform-aci-nac-aci.git?ref=main"',
            content,
            flags=re.MULTILINE,
        )
        # Match lines that start with 'source = "netascode...' and replace with '#source = "netascode...'
        content = re.sub(
            r'^(\s*)source\s*=\s*"netascode/nac-aci/aci"',
            r'\1#source  = "netascode/nac-aci/aci"',
            content,
            flags=re.MULTILINE,
        )
        # Use regex to replace any version line with the latest version (commented out)
        content = re.sub(
            r'^(\s*)version\s*=\s*"[^"]*"',
            rf'\1#version = "{latest_version}"',
            content,
            flags=re.MULTILINE,
        )

        with open(main_tf_path, "w") as f:
            f.write(content)

        # Reinitialize Terraform with the updated main.tf to upgrade module
        r = subprocess.run(
            [terraform_binary, "init", "-upgrade", "-no-color"],
            cwd=terraform_path,
            capture_output=True,
            text=True,
        )
        terraform_post_process("TERRAFORM INIT", r)

        # Run Terraform plan after upgrade to ensure no changes are needed and pipe plan output to a txt file
        plan_command = f"{terraform_binary} plan -no-color | tee plan.txt"
        r = subprocess.run(
            plan_command, cwd=terraform_path, capture_output=True, text=True, shell=True
        )
        terraform_post_process("TERRAFORM PLAN", r, ignore_errors=True)

        shutil.copy(
            os.path.join(terraform_path, "plan.txt"),
            "apic_tf_upgrade_plan.txt",
        )

        # Run Terraform apply after upgrade
        apply_args = [
            terraform_binary,
            "apply",
            "-auto-approve",
            "-no-color",
            "-parallelism=3",
        ]
        r = subprocess.run(
            apply_args, cwd=terraform_path, capture_output=True, text=True
        )
        terraform_post_process("TERRAFORM APPLY AFTER UPGRADE", r, ignore_errors=True)

        # Run tests
        data_paths.append(Path(os.path.join(terraform_path, "defaults.yaml")))
        error = apic_render_run_tests(
            apic_url, data_paths, os.path.join(tmpdir, "results/"), version
        )
        shutil.copy(
            os.path.join(tmpdir, "results/", "log.html"),
            "apic_tf_upgrade_log.html",
        )
        shutil.copy(
            os.path.join(tmpdir, "results/", "report.html"),
            "apic_tf_upgrade_report.html",
        )
        shutil.copy(
            os.path.join(tmpdir, "results/", "output.xml"),
            "apic_tf_upgrade_output.xml",
        )
        shutil.copy(
            os.path.join(tmpdir, "results/", "xunit.xml"),
            "apic_tf_upgrade_xunit.xml",
        )
        if error:
            pytest.fail(error)

    finally:
        state_path = os.path.join(terraform_path, "terraform.tfstate")
        state_backup_path = os.path.join(terraform_path, "terraform.tfstate.backup")
        plan_path = os.path.join(terraform_path, "plan.txt")
        if os.path.exists(state_path):
            os.remove(state_path)
        if os.path.exists(state_backup_path):
            os.remove(state_backup_path)
        if os.path.exists(plan_path):
            os.remove(plan_path)


@pytest.mark.apic_42
@pytest.mark.parametrize(
    "data_paths, vm_name, snapshot_name, apic_url, version",
    [
        (
            [
                "tests/integration/fixtures/apic/standard/",
                "tests/integration/fixtures/apic/standard_42/",
                "defaults/",
            ],
            "nac-ci-apic1-4.2.4i",
            "Clean",
            "https://10.50.202.10",
            "4.2",
        ),
    ],
)
def test_apic_42(data_paths, vm_name, snapshot_name, apic_url, version, tmpdir):
    full_apic_test(data_paths, vm_name, snapshot_name, apic_url, version, tmpdir)


@pytest.mark.apic_52
@pytest.mark.parametrize(
    "data_paths, vm_name, snapshot_name, apic_url, version",
    [
        (
            [
                "tests/integration/fixtures/apic/standard/",
                "tests/integration/fixtures/apic/standard_52/",
                "defaults/",
            ],
            "nac-ci-apic1-5.2.1g",
            "Clean",
            "https://10.50.202.11",
            "5.2",
        ),
    ],
)
def test_apic_52(data_paths, vm_name, snapshot_name, apic_url, version, tmpdir):
    full_apic_test(data_paths, vm_name, snapshot_name, apic_url, version, tmpdir)


@pytest.mark.apic_60
@pytest.mark.parametrize(
    "data_paths, vm_name, snapshot_name, apic_url, version",
    [
        (
            [
                "tests/integration/fixtures/apic/standard/",
                "tests/integration/fixtures/apic/standard_52/",
                "tests/integration/fixtures/apic/standard_60/",
                "defaults/",
            ],
            "nac-ci-apic1-6.0.4c",
            "Clean",
            "https://10.50.202.12",
            "6.0",
        ),
    ],
)
def test_apic_60(data_paths, vm_name, snapshot_name, apic_url, version, tmpdir):
    full_apic_test(data_paths, vm_name, snapshot_name, apic_url, version, tmpdir)


@pytest.mark.apic_61
@pytest.mark.parametrize(
    "data_paths, vm_name, snapshot_name, apic_url, version",
    [
        (
            [
                "tests/integration/fixtures/apic/standard/",
                "tests/integration/fixtures/apic/standard_52/",
                "tests/integration/fixtures/apic/standard_60/",
                "defaults/",
            ],
            "nac-ci-apic4-6.1.4h",
            "ce2_defaultOneTime-2025-10-28T15-26-59.tar.gz",
            "https://10.48.168.221",
            "6.1",
        ),
    ],
)
def test_apic_61(data_paths, vm_name, snapshot_name, apic_url, version, tmpdir):
    full_apic_test(data_paths, vm_name, snapshot_name, apic_url, version, tmpdir)


@pytest.mark.apic_42
@pytest.mark.terraform
@pytest.mark.parametrize(
    "data_paths, terraform_path, vm_name, snapshot_name, apic_url, version",
    [
        (
            [
                "tests/integration/fixtures/apic/standard/",
                "tests/integration/fixtures/apic/standard_42/",
            ],
            "tests/integration/fixtures/apic/terraform_42",
            "nac-ci-apic1-4.2.4i",
            "Clean",
            "https://10.50.202.10",
            "4.2",
        ),
    ],
)
def test_apic_terraform_42(
    data_paths, terraform_path, vm_name, snapshot_name, apic_url, version, tmpdir
):
    full_apic_terraform_test(
        data_paths, terraform_path, vm_name, snapshot_name, apic_url, version, tmpdir
    )


@pytest.mark.apic_52
@pytest.mark.terraform
@pytest.mark.parametrize(
    "data_paths, terraform_path, vm_name, snapshot_name, apic_url, version",
    [
        (
            [
                "tests/integration/fixtures/apic/standard/",
                "tests/integration/fixtures/apic/standard_52/",
            ],
            "tests/integration/fixtures/apic/terraform_52",
            "nac-ci-apic1-5.2.1g",
            "Clean",
            "https://10.50.202.11",
            "5.2",
        ),
    ],
)
def test_apic_terraform_52(
    data_paths, terraform_path, vm_name, snapshot_name, apic_url, version, tmpdir
):
    full_apic_terraform_test(
        data_paths, terraform_path, vm_name, snapshot_name, apic_url, version, tmpdir
    )


@pytest.mark.apic_60
@pytest.mark.terraform
@pytest.mark.parametrize(
    "data_paths, terraform_path, vm_name, snapshot_name, apic_url, version, terraform_binary",
    [
        (
            [
                "tests/integration/fixtures/apic/standard/",
                "tests/integration/fixtures/apic/standard_52/",
                "tests/integration/fixtures/apic/standard_60/",
            ],
            "tests/integration/fixtures/apic/terraform_60",
            "nac-ci-apic1-6.0.4c",
            "Clean",
            "https://10.50.202.12",
            "6.0",
            "tofu",
        ),
    ],
)
def test_apic_terraform_60(
    data_paths,
    terraform_path,
    vm_name,
    snapshot_name,
    apic_url,
    version,
    tmpdir,
    terraform_binary,
):
    full_apic_terraform_test(
        data_paths,
        terraform_path,
        vm_name,
        snapshot_name,
        apic_url,
        version,
        tmpdir,
        terraform_binary=terraform_binary,
    )


@pytest.mark.apic_61
@pytest.mark.terraform
@pytest.mark.parametrize(
    "data_paths, terraform_path, vm_name, snapshot_name, apic_url, version",
    [
        (
            [
                "tests/integration/fixtures/apic/standard/",
                "tests/integration/fixtures/apic/standard_52/",
                "tests/integration/fixtures/apic/standard_60/",
            ],
            "tests/integration/fixtures/apic/terraform_61",
            "nac-ci-apic4-6.1.4h",
            "ce2_defaultOneTime-2025-10-28T15-26-59.tar.gz",
            "https://10.48.168.221",
            "6.1",
        ),
    ],
)
def test_apic_terraform_61(
    data_paths,
    terraform_path,
    vm_name,
    snapshot_name,
    apic_url,
    version,
    tmpdir,
):
    full_apic_terraform_test(
        data_paths,
        terraform_path,
        vm_name,
        snapshot_name,
        apic_url,
        version,
        tmpdir,
    )


@pytest.mark.apic_upgrade
@pytest.mark.terraform
@pytest.mark.parametrize(
    "data_paths, terraform_path, vm_name, snapshot_name, apic_url, version",
    [
        (
            [
                "tests/integration/fixtures/apic/standard/",
                "tests/integration/fixtures/apic/standard_52/",
                "tests/integration/fixtures/apic/standard_60/",
            ],
            "tests/integration/fixtures/apic/terraform_upgrade",
            "nac-ci-apic1-6.0.4c",
            "Clean",
            "https://10.50.202.12",
            "6.0",
        ),
    ],
)
def test_apic_terraform_upgrade(
    data_paths,
    terraform_path,
    vm_name,
    snapshot_name,
    apic_url,
    version,
    tmpdir,
):
    full_apic_terraform_upgrade_test(
        data_paths,
        terraform_path,
        vm_name,
        snapshot_name,
        apic_url,
        version,
        tmpdir,
    )
