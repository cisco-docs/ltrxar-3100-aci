# -*- coding: utf-8 -*-

# Copyright: (c) 2022, Daniel Schmidt <danischm@cisco.com>

import os
import pytest
import subprocess
import re

import errorhandler
from nac_test.robot_writer import RobotWriter
import json
from vmware import Vsphere
from requests.adapters import HTTPAdapter

error_handler = errorhandler.ErrorHandler()


def validate_json(path):
    """Validate JSON files"""
    for dir, subdir, files in os.walk(path):
        for filename in files:
            with open(dir + os.path.sep + filename, "r") as file:
                try:
                    json.loads(file.read())
                except json.JSONDecodeError as e:
                    return "JSON file {} is invalid: {}".format(filename, e)
    return None


def render_templates(
    data_paths, output_path, templates_path, filters_path="", tests_path=""
):
    """Render templates using nac-test package"""
    writer = RobotWriter(data_paths, filters_path, tests_path)
    writer.write(templates_path, output_path)
    if error_handler.fired:
        return "Template rendering failed."
    return ""


def revert_snapshot(vm_name, snapshot_name):
    """Revert VMware VM snapshot"""
    host = os.getenv("VMWARE_HOST")
    user = os.getenv("VMWARE_USER")
    password = os.getenv("VMWARE_PASSWORD")
    port = os.getenv("VMWARE_PORT")
    if port:
        vpshere = Vsphere(host, user, password, int(port))
    else:
        vpshere = Vsphere(host, user, password)
    vpshere.vmware_revert_snapshot(vm_name, snapshot_name)


def terraform_post_process(message, completed_process, ignore_errors=False):
    print(
        "--------------------------------------------------------------------------------"
    )
    print(message)
    print("Return code: {}".format(completed_process.returncode))
    print(
        "--------------------------------------------------------------------------------"
    )
    print("stdout:")
    print(completed_process.stdout)
    print(
        "--------------------------------------------------------------------------------"
    )
    print("stderr:")
    print(completed_process.stderr)
    print(
        "--------------------------------------------------------------------------------"
    )
    if not ignore_errors:
        if completed_process.returncode != 0:
            pytest.fail(completed_process.stderr)


class TimeoutHTTPAdapter(HTTPAdapter):
    def __init__(self, *args, **kwargs):
        self.timeout = 60  # default timeout
        if "timeout" in kwargs:
            self.timeout = kwargs["timeout"]
            del kwargs["timeout"]
        super().__init__(*args, **kwargs)

    def send(self, request, **kwargs):
        timeout = kwargs.get("timeout")
        if timeout is None:
            kwargs["timeout"] = self.timeout
        return super().send(request, **kwargs)


def get_latest_git_tag():
    """Get the latest git tag from the terraform-aci-nac-aci repository"""
    try:
        # Get the latest tag from the GitHub repository
        result = subprocess.run(
            [
                "git",
                "ls-remote",
                "--tags",
                "--refs",
                "https://github.com/netascode/terraform-aci-nac-aci.git",
            ],
            capture_output=True,
            text=True,
            timeout=30,
        )

        if result.returncode != 0:
            print(f"Warning: Failed to fetch git tags: {result.stderr}")
            return "1.0.1"  # fallback version

        # Parse the output to find version tags
        tags = []
        for line in result.stdout.strip().split("\n"):
            if line.strip():
                # Extract tag name from "hash refs/tags/tagname"
                parts = line.split("/")
                if len(parts) >= 3:
                    tag = parts[-1]
                    # Only consider semantic version tags (e.g., v1.0.1, 1.0.1)
                    if re.match(r"^v?\d+\.\d+\.\d+", tag):
                        # Remove 'v' prefix if present
                        clean_tag = tag.lstrip("v")
                        tags.append(clean_tag)

        if not tags:
            print("Warning: No semantic version tags found, using fallback")
            return "1.0.1"

        # Sort tags by semantic version and get the latest
        def version_key(version):
            return tuple(map(int, version.split(".")))

        latest_tag = sorted(tags, key=version_key, reverse=True)[0]
        print(f"Using latest git tag: {latest_tag}")
        return latest_tag

    except subprocess.TimeoutExpired:
        print("Warning: Timeout while fetching git tags, using fallback")
        return "1.0.1"
    except Exception as e:
        print(f"Warning: Error fetching git tags: {e}, using fallback")
        return "1.0.1"
