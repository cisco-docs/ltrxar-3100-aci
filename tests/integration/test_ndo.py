# -*- coding: utf-8 -*-

# Copyright: (c) 2022, Daniel Schmidt <danischm@cisco.com>

import os
import shutil
import subprocess
import time

import errorhandler
import nac_test.pabot
import pytest
import re

from aci import Apic
from ndo import Ndo
from util import (
    validate_json,
    render_templates,
    terraform_post_process,
    get_latest_git_tag,
)
from pathlib import Path

pytestmark = pytest.mark.integration
pytestmark = pytest.mark.ndo

error_handler = errorhandler.ErrorHandler()

FILTERS_PATH = "jinja_filters/"
TESTS_PATH = "jinja_tests/"
NDO_DEPLOY_TEMPLATES_PATH = "templates/ndo/deploy/"
NDO_TEST_TEMPLATES_PATH = "templates/ndo/test/"

TEMPLATE_MAPPINGS = {
    "system_config": {
        "api_path": "platform/systemConfig",
    },
    "remote_location": {
        "api_path": "platform/remote-locations",
    },
    "site": {
        "api_path": "sites/manage",
    },
    "fabric_connectivity": {
        "api_path": "sites/fabric-connectivity",
    },
    "tenant": {
        "api_path": "tenants",
    },
    "schema": {
        "api_path": "schemas",
    },
    "dhcp_relay": {
        "api_path": "policies/dhcp/relay",
    },
    "dhcp_option": {
        "api_path": "policies/dhcp/option",
    },
}


def apic_revert(apic_url, snapshot):
    """Revert APIC to snapshot"""
    username = os.getenv("ACI_USERNAME")
    password = os.getenv("ACI_PASSWORD")
    if not username:
        return "APIC username must be specified with ACI_USERNAME environment variable."
    if not password:
        return "APIC password must be specified with ACI_PASSWORD environment variable."
    apic = Apic(apic_url, username, password)
    r = apic.login()
    if r:
        return "APIC login failed: {}.".format(r)
    payload = (
        '{"configImportP":{"attributes":{"dn":"uni/fabric/configimp-default","name":"default","snapshot":"true","adminSt":"triggered","fileName":"'
        + snapshot
        + '","importType":"replace","importMode":"atomic","rn":"configimp-default","status":"created,modified"},"children":[]}}'
    )
    r = apic.post(payload, url="/api/node/mo/uni/fabric/configimp-default.json")
    if r:
        return "Reverting to APIC snapshot failed."
    return None


def ndo_login(ndo_url):
    """Login to NDO and return instance"""
    username = os.getenv("MSO_USERNAME")
    password = os.getenv("MSO_PASSWORD")
    ndo_inst = Ndo(ndo_url, str(username), str(password))
    r = ndo_inst.login()
    if r:
        return r, None
    return "", ndo_inst


def ndo_deploy_config(ndo_inst, config_path, version):
    """Deploy config via a set of json files"""
    for template, params in TEMPLATE_MAPPINGS.items():
        if not version.startswith("3.") and template in ["dhcp_relay", "dhcp_option"]:
            continue
        file_path = os.path.join(config_path, template + ".j2")
        folder_path = os.path.join(config_path, template)
        if os.path.exists(file_path):
            with open(file_path, "r") as file:
                data = file.read()
                r = ndo_inst.post_or_put(params["api_path"], data)
                if r:
                    return "Deployment of {} failed: {}.".format(file_path, r)
        elif os.path.exists(folder_path):
            for filename in os.listdir(folder_path):
                if ".j2" not in filename:
                    continue
                with open(os.path.join(folder_path, filename), "r") as file:
                    data = file.read()
                    r = ndo_inst.post_or_put(params["api_path"], data)
                    if r:
                        return "Deployment of {} failed: {}.".format(file_path, r)
    return None


def ndo_render_run_tests(ndo_url, data_paths, output_path):
    """Render NDO test suites and run them using nac-test"""

    error = render_templates(
        data_paths,
        output_path,
        NDO_TEST_TEMPLATES_PATH,
        filters_path=FILTERS_PATH,
        tests_path=TESTS_PATH,
    )
    if error:
        pytest.fail(error)

    os.environ["MSO_URL"] = ndo_url
    try:
        nac_test.pabot.run_pabot(output_path)
    except SystemExit as e:
        if e.code != 0:
            return "Robot testing failed."
    return None


def full_ndo_test(
    data_paths, apic_url, snapshot_name, ndo_url, ndo_backup_id, version, tmpdir
):
    """Deploy config to NDO instance and run tests"""

    # Render templates
    error = render_templates(
        data_paths,
        tmpdir.strpath,
        NDO_DEPLOY_TEMPLATES_PATH,
        filters_path=FILTERS_PATH,
        tests_path=TESTS_PATH,
    )
    if error:
        pytest.fail(error)

    # Validate rendered templates
    error = validate_json(tmpdir.strpath)
    if error:
        pytest.fail(error)

    # Revert APIC snapshot
    # error = apic_revert(apic_url, snapshot_name)
    # if error:
    #     pytest.fail(error)

    # NDO login
    error, ndo_inst = ndo_login(ndo_url)
    if error:
        pytest.fail(error)

    # Revert NDO config
    if version.startswith("3."):
        error = ndo_inst.post_or_put(
            "backups/{}/restore".format(ndo_backup_id), "", "PUT"
        )
    elif version.startswith(("4.2", "4.3")):
        error = ndo_inst.post_or_put(
            "backups/{}/restore".format(ndo_backup_id), "", "POST"
        )
    elif version.startswith("4.4"):
        error = ndo_inst.backup_restore("abcdefg123", ndo_backup_id)
    if error:
        if "Fail to block deployment" not in error:
            pytest.fail(error)

    # CSCwh37399
    if version.startswith("4.1") or version.startswith("4.2"):
        time.sleep(30)

    if version.startswith("4.3"):
        time.sleep(60)

    # Enable retries
    # ndo_inst.enable_retries()

    # Configure NDO
    error = ndo_deploy_config(ndo_inst, tmpdir.strpath, version)
    if error:
        pytest.fail(error)

    # Render and run tests
    error = ndo_render_run_tests(ndo_url, data_paths, os.path.join(tmpdir, "results/"))
    shutil.copy(
        os.path.join(tmpdir, "results/", "log.html"), "ndo_{}_log.html".format(version)
    )
    shutil.copy(
        os.path.join(tmpdir, "results/", "report.html"),
        "ndo_{}_report.html".format(version),
    )
    shutil.copy(
        os.path.join(tmpdir, "results/", "output.xml"),
        "ndo_{}_output.xml".format(version),
    )
    shutil.copy(
        os.path.join(tmpdir, "results/", "xunit.xml"),
        "ndo_{}_xunit.xml".format(version),
    )
    if error:
        pytest.fail(error)


def full_ndo_terraform(
    data_paths,
    terraform_path,
    apic_url,
    snapshot_name,
    ndo_url,
    ndo_backup_id,
    version,
    tmpdir,
    terraform_binary="terraform",
):
    """Deploy config to NDO instance and run tests"""

    # Revert APIC snapshot
    # error = apic_revert(apic_url, snapshot_name)
    # if error:
    #     pytest.fail(error)

    # NDO login
    error, ndo_inst = ndo_login(ndo_url)
    if error:
        pytest.fail(error)

    # Revert NDO config
    if version.startswith("3."):
        error = ndo_inst.post_or_put(
            "backups/{}/restore".format(ndo_backup_id), "", "PUT"
        )
    elif version.startswith(("4.2", "4.3")):
        error = ndo_inst.post_or_put(
            "backups/{}/restore".format(ndo_backup_id), "", "POST"
        )
    elif version.startswith("4.4"):
        error = ndo_inst.backup_restore("abcdefg123", ndo_backup_id)
    if error:
        if "Fail to block deployment" not in error:
            pytest.fail(error)

    # CSCwh37399
    if version.startswith("4.1") or version.startswith("4.2"):
        time.sleep(30)

    if version.startswith("4.3"):
        time.sleep(60)

    os.environ["MSO_URL"] = ndo_url

    try:
        r = subprocess.run(
            [terraform_binary, "init", "-upgrade", "-no-color"],
            cwd=terraform_path,
            capture_output=True,
            text=True,
        )
        terraform_post_process("TERRAFORM INIT", r)

        r = subprocess.run(
            [terraform_binary, "apply", "-auto-approve", "-no-color", "-parallelism=1"],
            cwd=terraform_path,
            capture_output=True,
            text=True,
        )
        terraform_post_process("FIRST TERRAFORM APPLY", r, ignore_errors=True)

        # second apply to work around NDO API quirks
        r = subprocess.run(
            [terraform_binary, "apply", "-auto-approve", "-no-color", "-parallelism=1"],
            cwd=terraform_path,
            capture_output=True,
            text=True,
        )
        terraform_post_process("SECOND TERRAFORM APPLY", r)

        data_paths.append(Path(os.path.join(terraform_path, "defaults.yaml")))
        # Render and run tests
        error = ndo_render_run_tests(
            ndo_url, data_paths, os.path.join(tmpdir, "results/")
        )
        shutil.copy(
            os.path.join(tmpdir, "results/", "log.html"),
            "ndo_tf_{}_log.html".format(version),
        )
        shutil.copy(
            os.path.join(tmpdir, "results/", "report.html"),
            "ndo_tf_{}_report.html".format(version),
        )
        shutil.copy(
            os.path.join(tmpdir, "results/", "output.xml"),
            "ndo_tf_{}_output.xml".format(version),
        )
        shutil.copy(
            os.path.join(tmpdir, "results/", "xunit.xml"),
            "ndo_tf_{}_xunit.xml".format(version),
        )
        if error:
            pytest.fail(error)

        r = subprocess.run(
            [
                terraform_binary,
                "destroy",
                "-auto-approve",
                "-no-color",
                "-parallelism=1",
            ],
            cwd=terraform_path,
            capture_output=True,
            text=True,
        )
        terraform_post_process("FIRST TERRAFORM DESTROY", r, ignore_errors=True)
        r = subprocess.run(
            [
                terraform_binary,
                "destroy",
                "-auto-approve",
                "-no-color",
                "-parallelism=1",
            ],
            cwd=terraform_path,
            capture_output=True,
            text=True,
        )
        terraform_post_process("SECOND TERRAFORM DESTROY", r)
    finally:
        pass
        state_path = os.path.join(terraform_path, "terraform.tfstate")
        state_backup_path = os.path.join(terraform_path, "terraform.tfstate.backup")
        if os.path.exists(state_path):
            os.remove(state_path)
        if os.path.exists(state_backup_path):
            os.remove(state_backup_path)


def full_ndo_terraform_upgrade_test(
    data_paths,
    terraform_path,
    apic_url,
    snapshot_name,
    ndo_url,
    ndo_backup_id,
    version,
    tmpdir,
    terraform_binary="terraform",
):
    """Deploy config to NDO instance and run tests"""

    # NDO login
    error, ndo_inst = ndo_login(ndo_url)
    if error:
        pytest.fail(error)

    # Revert NDO config
    error = ndo_inst.backup_restore("abcdefg123", ndo_backup_id)
    if error:
        if "Fail to block deployment" not in error:
            pytest.fail(error)

    os.environ["MSO_URL"] = ndo_url

    # Get the latest version tag dynamically and update main.tf before terraform init
    main_tf_path = os.path.join(terraform_path, "main.tf")
    latest_version = get_latest_git_tag()

    with open(main_tf_path, "r") as f:
        content = f.read()

    # Ensure main.tf is in the correct initial state before terraform init
    # Match lines that start with 'source = "github...' and replace with '#source = "github...'
    content = re.sub(
        r'^(\s*)source\s*=\s*"github\.com/netascode/terraform-mso-nac-ndo\.git\?ref=main"',
        r'\1#source = "github.com/netascode/terraform-mso-nac-ndo.git?ref=main"',
        content,
        flags=re.MULTILINE,
    )

    # Match lines that start with '#source = "netascode...' and replace with 'source = "netascode...'
    content = re.sub(
        r'^(\s*)#source\s*=\s*"netascode/nac-ndo/mso"',
        r'\1source  = "netascode/nac-ndo/mso"',
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
            r'^(\s*)#source\s*=\s*"github\.com/netascode/terraform-mso-nac-ndo\.git\?ref=main"',
            r'\1source = "github.com/netascode/terraform-mso-nac-ndo.git?ref=main"',
            content,
            flags=re.MULTILINE,
        )
        # Match lines that start with 'source = "netascode...' and replace with '#source = "netascode...'
        content = re.sub(
            r'^(\s*)source\s*=\s*"netascode/nac-ndo/mso"',
            r'\1#source  = "netascode/nac-ndo/mso"',
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
            "ndo_tf_upgrade_plan.txt",
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
        error = ndo_render_run_tests(
            ndo_url, data_paths, os.path.join(tmpdir, "results/")
        )
        shutil.copy(
            os.path.join(tmpdir, "results/", "log.html"),
            "ndo_tf_upgrade_log.html",
        )
        shutil.copy(
            os.path.join(tmpdir, "results/", "report.html"),
            "ndo_tf_upgrade_report.html",
        )
        shutil.copy(
            os.path.join(tmpdir, "results/", "output.xml"),
            "ndo_tf_upgrade_output.xml",
        )
        shutil.copy(
            os.path.join(tmpdir, "results/", "xunit.xml"),
            "ndo_tf_upgrade_xunit.xml",
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


@pytest.mark.ndo_42
@pytest.mark.parametrize(
    "data_paths, apic_url, snapshot_name, ndo_url, ndo_backup_id, version",
    [
        (
            [
                "tests/integration/fixtures/ndo/standard/",
                "tests/integration/fixtures/ndo/standard_42/",
                "defaults/",
            ],
            "https://10.50.202.16",
            "ce2_defaultOneTime-2023-12-18T06-15-42.tar.gz",
            "https://10.50.202.17",
            "65a465703e4f4ce7cdf63cb0",
            "4.2",
        )
    ],
)
def test_ndo_42(
    data_paths, apic_url, snapshot_name, ndo_url, ndo_backup_id, version, tmpdir
):
    full_ndo_test(
        data_paths, apic_url, snapshot_name, ndo_url, ndo_backup_id, version, tmpdir
    )


@pytest.mark.ndo_43
@pytest.mark.parametrize(
    "data_paths, apic_url, snapshot_name, ndo_url, ndo_backup_id, version",
    [
        (
            [
                "tests/integration/fixtures/ndo/standard/",
                "tests/integration/fixtures/ndo/standard_43/",
                "defaults/",
            ],
            "https://10.50.202.13",
            "ce2_defaultOneTime-2023-12-18T06-15-28.tar.gz",
            "https://10.50.202.14",
            "67eeb5e47d2ddd8e06216deb",
            "4.3",
        )
    ],
)
def test_ndo_43(
    data_paths, apic_url, snapshot_name, ndo_url, ndo_backup_id, version, tmpdir
):
    full_ndo_test(
        data_paths, apic_url, snapshot_name, ndo_url, ndo_backup_id, version, tmpdir
    )


@pytest.mark.ndo_44
@pytest.mark.parametrize(
    "data_paths, apic_url, snapshot_name, ndo_url, ndo_backup_id, version",
    [
        (
            [
                "tests/integration/fixtures/ndo/standard/",
                "tests/integration/fixtures/ndo/standard_44/",
                "defaults/",
            ],
            "https://10.50.202.106",
            "ce2_defaultOneTime-2023-12-18T06-15-42.tar.gz",
            "https://10.50.202.107",
            "clean-202503251544",
            "4.4",
        )
    ],
)
def test_ndo_44(
    data_paths, apic_url, snapshot_name, ndo_url, ndo_backup_id, version, tmpdir
):
    full_ndo_test(
        data_paths, apic_url, snapshot_name, ndo_url, ndo_backup_id, version, tmpdir
    )


@pytest.mark.ndo_42
@pytest.mark.terraform
@pytest.mark.parametrize(
    "data_paths, terraform_path, apic_url, snapshot_name, ndo_url, ndo_backup_id, version",
    [
        (
            [
                "tests/integration/fixtures/ndo/standard/",
                "tests/integration/fixtures/ndo/standard_42/",
            ],
            "tests/integration/fixtures/ndo/terraform_42",
            "https://10.50.202.16",
            "ce2_defaultOneTime-2023-12-18T06-15-42.tar.gz",
            "https://10.50.202.17",
            "65a465703e4f4ce7cdf63cb0",
            "4.2",
        )
    ],
)
def test_ndo_terraform_42(
    data_paths,
    terraform_path,
    apic_url,
    snapshot_name,
    ndo_url,
    ndo_backup_id,
    version,
    tmpdir,
):
    full_ndo_terraform(
        data_paths,
        terraform_path,
        apic_url,
        snapshot_name,
        ndo_url,
        ndo_backup_id,
        version,
        tmpdir,
    )


@pytest.mark.ndo_43
@pytest.mark.terraform
@pytest.mark.parametrize(
    "data_paths, terraform_path, apic_url, snapshot_name, ndo_url, ndo_backup_id, version",
    [
        (
            [
                "tests/integration/fixtures/ndo/standard/",
                "tests/integration/fixtures/ndo/standard_43/",
            ],
            "tests/integration/fixtures/ndo/terraform_43",
            "https://10.50.202.13",
            "ce2_defaultOneTime-2023-12-18T06-15-28.tar.gz",
            "https://10.50.202.14",
            "67eeb5e47d2ddd8e06216deb",
            "4.3",
        )
    ],
)
def test_ndo_terraform_43(
    data_paths,
    terraform_path,
    apic_url,
    snapshot_name,
    ndo_url,
    ndo_backup_id,
    version,
    tmpdir,
):
    full_ndo_terraform(
        data_paths,
        terraform_path,
        apic_url,
        snapshot_name,
        ndo_url,
        ndo_backup_id,
        version,
        tmpdir,
    )


@pytest.mark.ndo_44
@pytest.mark.terraform
@pytest.mark.parametrize(
    "data_paths, terraform_path, apic_url, snapshot_name, ndo_url, ndo_backup_id, version",
    [
        (
            [
                "tests/integration/fixtures/ndo/standard/",
                "tests/integration/fixtures/ndo/standard_44/",
            ],
            "tests/integration/fixtures/ndo/terraform_44",
            "https://10.50.202.106",
            "ce2_defaultOneTime-2023-12-18T06-15-42.tar.gz",
            "https://10.50.202.107",
            "clean-202503251544",
            "4.4",
        )
    ],
)
def test_ndo_terraform_44(
    data_paths,
    terraform_path,
    apic_url,
    snapshot_name,
    ndo_url,
    ndo_backup_id,
    version,
    tmpdir,
):
    full_ndo_terraform(
        data_paths,
        terraform_path,
        apic_url,
        snapshot_name,
        ndo_url,
        ndo_backup_id,
        version,
        tmpdir,
    )


@pytest.mark.ndo_upgrade
@pytest.mark.terraform
@pytest.mark.parametrize(
    "data_paths, terraform_path, apic_url, snapshot_name, ndo_url, ndo_backup_id, version",
    [
        (
            [
                "tests/integration/fixtures/ndo/standard/",
                "tests/integration/fixtures/ndo/standard_44/",
            ],
            "tests/integration/fixtures/ndo/terraform_upgrade",
            "https://10.50.202.106",
            "ce2_defaultOneTime-2023-12-18T06-15-42.tar.gz",
            "https://10.50.202.107",
            "clean-202503251544",
            "4.4",
        )
    ],
)
def test_ndo_terraform_upgrade(
    data_paths,
    terraform_path,
    apic_url,
    snapshot_name,
    ndo_url,
    ndo_backup_id,
    version,
    tmpdir,
):
    full_ndo_terraform_upgrade_test(
        data_paths,
        terraform_path,
        apic_url,
        snapshot_name,
        ndo_url,
        ndo_backup_id,
        version,
        tmpdir,
    )
