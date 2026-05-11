# -*- coding: utf-8 -*-

# Copyright: (c) 2022, Daniel Schmidt <danischm@cisco.com>

import os
import shutil
import subprocess
import tempfile
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

        # Move prioritized templates to the front
        for filename in PRIORITIZED_TEMPLATES:
            if filename in sorted_files:
                sorted_files.remove(filename)
                sorted_files.insert(0, filename)

        # Handle vxlan templates ordering - vxlan_vrf_stretch.j2 must come before bridge_domain.j2 (which contains BD stretch logic)
        vxlan_vrf = "vxlan_vrf_stretch.j2"
        bridge_domain = "bridge_domain.j2"
        if vxlan_vrf in sorted_files and bridge_domain in sorted_files:
            # Remove both from their current positions
            sorted_files.remove(vxlan_vrf)
            sorted_files.remove(bridge_domain)
            # Add them at the end in the correct order: VRF -> VXLAN VRF Stretch -> BD
            sorted_files.append(vxlan_vrf)
            sorted_files.append(bridge_domain)

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
    if error:
        pytest.fail(error)
    os.environ["ACI_URL"] = apic_url
    try:
        exit_code = nac_test.pabot.run_pabot(output_path)
    except SystemExit as e:
        # nac-test <= 1.2.1 called sys.exit(), capture the exit code
        exit_code = e.code
    if exit_code != 0:
        return "Robot testing failed."
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

    revert_snapshot(vm_name, snapshot_name)

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
    revert_snapshot(vm_name, snapshot_name)

    os.environ["ACI_URL"] = apic_url
    os.environ["ACI_RETRIES"] = "4"

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


def get_version_specific_data_folders(version_tag):
    """
    Clone nac-aci repo at specific version tag and copy data folders to temporary location.
    Returns tuple of (data_path, temp_dir_path) for data access and cleanup.
    """
    # Create temporary directory for version-specific data
    temp_dir = tempfile.mkdtemp(prefix=f"nac-aci-{version_tag}-")

    try:
        # Clone nac-aci repository at specific tag
        clone_path = os.path.join(temp_dir, "nac-aci-clone")
        subprocess.run(
            [
                "git",
                "clone",
                "--depth",
                "1",
                "--branch",
                version_tag,
                "https://wwwin-github.cisco.com/netascode/nac-aci.git",
                clone_path,
            ],
            capture_output=True,
            text=True,
            check=True,
        )

        # Copy data folders from the cloned repository
        source_fixtures_path = os.path.join(
            clone_path, "tests", "integration", "fixtures", "apic"
        )
        target_data_path = os.path.join(temp_dir, "data")
        os.makedirs(target_data_path, exist_ok=True)

        # Copy the standard data folders that are used in main.tf
        data_folders = ["standard", "standard_52", "standard_60"]
        for folder in data_folders:
            source_folder = os.path.join(source_fixtures_path, folder)
            if os.path.exists(source_folder):
                target_folder = os.path.join(target_data_path, folder)
                shutil.copytree(source_folder, target_folder)
            else:
                print(
                    f"Warning: Data folder '{folder}' not found in version {version_tag}"
                )

        return target_data_path, temp_dir

    except subprocess.CalledProcessError as e:
        # Cleanup temp directory on error
        shutil.rmtree(temp_dir, ignore_errors=True)
        raise Exception(f"Failed to clone nac-aci repository at tag {version_tag}: {e}")
    except Exception as e:
        # Cleanup temp directory on error
        shutil.rmtree(temp_dir, ignore_errors=True)
        raise e


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

    # Create isolated temporary data directories for version-specific and current data
    print(f"Creating isolated temporary data for version {latest_version}...")

    # Create version-specific data in tmpdir
    version_data_dir = tmpdir.join("version-data")
    version_data_dir.mkdir()

    version_data_path, temp_dir_to_cleanup = get_version_specific_data_folders(
        latest_version
    )

    # Copy version-specific data to tmpdir
    data_folders = ["standard", "standard_52", "standard_60"]
    for folder in data_folders:
        source_folder = os.path.join(version_data_path, folder)
        if os.path.exists(source_folder):
            target_folder = version_data_dir.join(folder)
            shutil.copytree(source_folder, str(target_folder))
            print(f"Copied version-specific {folder} to tmpdir")

    # Create current data directory in tmpdir
    current_data_dir = tmpdir.join("current-data")
    current_data_dir.mkdir()

    # Copy current data folders to tmpdir
    current_data_base = os.path.dirname(
        terraform_path
    )  # tests/integration/fixtures/apic/
    for folder in data_folders:
        source_folder = os.path.join(current_data_base, folder)
        if os.path.exists(source_folder):
            target_folder = current_data_dir.join(folder)
            shutil.copytree(source_folder, str(target_folder))
            print(f"Copied current {folder} to tmpdir")

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

    # Update yaml_directories to point to version-specific data in tmpdir
    version_rel_path = os.path.relpath(str(version_data_dir), terraform_path)
    version_yaml_dirs = [
        f"{version_rel_path}/standard",
        f"{version_rel_path}/standard_52",
        f"{version_rel_path}/standard_60",
    ]
    version_yaml_dirs_str = '", "'.join(version_yaml_dirs)
    content = re.sub(
        r"^(\s*)yaml_directories\s*=\s*\[.*?\]",
        rf'\1yaml_directories = ["{version_yaml_dirs_str}"]',
        content,
        flags=re.MULTILINE | re.DOTALL,
    )
    print(f"Set yaml_directories to version-specific data: {version_yaml_dirs}")

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

        # Run Terraform plan before upgrade to capture baseline and pipe plan output to a txt file
        plan_command = (
            f"{terraform_binary} plan -no-color | tee plan_before_upgrade.txt"
        )
        r = subprocess.run(
            plan_command, cwd=terraform_path, capture_output=True, text=True, shell=True
        )
        terraform_post_process("TERRAFORM PLAN BEFORE UPGRADE", r, ignore_errors=True)

        shutil.copy(
            os.path.join(terraform_path, "plan_before_upgrade.txt"),
            "apic_tf_upgrade_plan_before.txt",
        )

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

        # Update yaml_directories to point to current data in tmpdir for upgrade phase
        current_rel_path = os.path.relpath(str(current_data_dir), terraform_path)
        current_yaml_dirs = [
            f"{current_rel_path}/standard",
            f"{current_rel_path}/standard_52",
            f"{current_rel_path}/standard_60",
        ]
        current_yaml_dirs_str = '", "'.join(current_yaml_dirs)
        content = re.sub(
            r"^(\s*)yaml_directories\s*=\s*\[.*?\]",
            rf'\1yaml_directories = ["{current_yaml_dirs_str}"]',
            content,
            flags=re.MULTILINE | re.DOTALL,
        )
        print(f"Switched yaml_directories to current data: {current_yaml_dirs}")

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
        plan_command = f"{terraform_binary} plan -no-color | tee plan_after_upgrade.txt"
        r = subprocess.run(
            plan_command, cwd=terraform_path, capture_output=True, text=True, shell=True
        )
        terraform_post_process("TERRAFORM PLAN AFTER UPGRADE", r, ignore_errors=True)

        shutil.copy(
            os.path.join(terraform_path, "plan_after_upgrade.txt"),
            "apic_tf_upgrade_plan_after.txt",
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
        # Clean up temporary directory with version-specific data folders
        if "temp_dir_to_cleanup" in locals():
            shutil.rmtree(temp_dir_to_cleanup, ignore_errors=True)

        # tmpdir cleanup is automatic - no manual cleanup needed for isolated temporary folders

        state_path = os.path.join(terraform_path, "terraform.tfstate")
        state_backup_path = os.path.join(terraform_path, "terraform.tfstate.backup")
        plan_before_path = os.path.join(terraform_path, "plan_before_upgrade.txt")
        plan_after_path = os.path.join(terraform_path, "plan_after_upgrade.txt")
        if os.path.exists(state_path):
            os.remove(state_path)
        if os.path.exists(state_backup_path):
            os.remove(state_backup_path)
        if os.path.exists(plan_before_path):
            os.remove(plan_before_path)
        if os.path.exists(plan_after_path):
            os.remove(plan_after_path)


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
                "tests/integration/fixtures/apic/standard_61/",
                "defaults/",
            ],
            "nac-ci-vapic1-6.1.5e",
            "Clean",
            "https://10.50.202.15",
            "6.1",
        ),
    ],
)
def test_apic_61(data_paths, vm_name, snapshot_name, apic_url, version, tmpdir):
    full_apic_test(data_paths, vm_name, snapshot_name, apic_url, version, tmpdir)


@pytest.mark.apic_62
@pytest.mark.parametrize(
    "data_paths, vm_name, snapshot_name, apic_url, version",
    [
        (
            [
                "tests/integration/fixtures/apic/standard/",
                "tests/integration/fixtures/apic/standard_52/",
                "tests/integration/fixtures/apic/standard_60/",
                "tests/integration/fixtures/apic/standard_61/",
                #     "tests/integration/fixtures/apic/standard_62/",
                "defaults/",
            ],
            "nac-ci-apic1-6.2.1g",
            "Clean",
            "https://10.50.202.10",
            "6.2",
        ),
    ],
)
def test_apic_62(data_paths, vm_name, snapshot_name, apic_url, version, tmpdir):
    full_apic_test(data_paths, vm_name, snapshot_name, apic_url, version, tmpdir)


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
    "data_paths, terraform_path, vm_name, snapshot_name, apic_url, version, terraform_binary",
    [
        (
            [
                "tests/integration/fixtures/apic/standard/",
                "tests/integration/fixtures/apic/standard_52/",
                "tests/integration/fixtures/apic/standard_60/",
                "tests/integration/fixtures/apic/standard_61/",
            ],
            "tests/integration/fixtures/apic/terraform_61",
            "nac-ci-vapic1-6.1.5e",
            "Clean",
            "https://10.50.202.15",
            "6.1",
            "tofu",
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
        terraform_binary,
    )


@pytest.mark.apic_62
@pytest.mark.terraform
@pytest.mark.parametrize(
    "data_paths, terraform_path, vm_name, snapshot_name, apic_url, version",
    [
        (
            [
                "tests/integration/fixtures/apic/standard/",
                "tests/integration/fixtures/apic/standard_52/",
                "tests/integration/fixtures/apic/standard_60/",
                "tests/integration/fixtures/apic/standard_61/",
            ],
            "tests/integration/fixtures/apic/terraform_62",
            "nac-ci-apic1-6.2.1g",
            "Clean",
            "https://10.50.202.10",
            "6.2",
        ),
    ],
)
def test_apic_terraform_62(
    data_paths, terraform_path, vm_name, snapshot_name, apic_url, version, tmpdir
):
    full_apic_terraform_test(
        data_paths, terraform_path, vm_name, snapshot_name, apic_url, version, tmpdir
    )


@pytest.mark.apic_60
@pytest.mark.terraform
@pytest.mark.provider
@pytest.mark.parametrize(
    "data_paths, terraform_path, vm_name, snapshot_name, apic_url, version",
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
            "6.0_provider",
        ),
    ],
)
def test_apic_terraform_60_provider(
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
                "tests/integration/fixtures/apic/standard_61/",
            ],
            "tests/integration/fixtures/apic/terraform_upgrade",
            "nac-ci-apic1-6.1.5e",
            "Clean",
            "https://10.50.202.15",
            "6.1",
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
