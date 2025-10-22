# -*- coding: utf-8 -*-

# Copyright: (c) 2023, Daniel Schmidt <danischm@cisco.com>

import json
import os
import subprocess


CWD = "../"

IMPORT_TF_FILENAME = "import.tf"
IMPORT_TF_PATH = os.path.join(CWD, IMPORT_TF_FILENAME)
IMPORT_PLAN_FILENAME = "import_plan.tfplan"
IMPORT_PLAN_PATH = os.path.join(CWD, IMPORT_PLAN_FILENAME)
IMPORT_PLAN_JSON_FILENAME = "import_plan.json"
IMPORT_PLAN_JSON_PATH = os.path.join(CWD, IMPORT_PLAN_JSON_FILENAME)

def tf_import():
    if os.path.exists(IMPORT_TF_PATH):
        os.remove(IMPORT_TF_PATH)

    # terraform init
    subprocess.run(["terraform", "init"], cwd=CWD)

    # terraform plan
    subprocess.run(
        ["terraform", "plan", "-out="+IMPORT_PLAN_FILENAME, "-input=false"], cwd=CWD
    )
    with open(IMPORT_PLAN_JSON_PATH, "w") as f:
        subprocess.run(
            ["terraform", "show", "-json", IMPORT_PLAN_FILENAME],
            stdout=f,
            cwd=CWD,
        )

    tf_plan = None
    with open(IMPORT_PLAN_JSON_PATH) as file:
        tf_plan = json.load(file)

    imports = (
        "terraform {\n"
        '  required_version = ">= 1.5.0"\n'
        "\n"
        "  required_providers {\n"
        "    aci = {\n"
        '      source  = "CiscoDevNet/aci"\n'
        "    }\n"
        "  }\n"
        "}\n"
        "\n"
    )
    for change in tf_plan.get("resource_changes", []):
        if change.get("type") == "aci_rest_managed":
            if "create" in change["change"].get("actions", []):
                child_string = ""
                if len(change["change"].get("after", {}).get("child")) > 0:
                    children = []
                    for child in change["change"]["after"]["child"]:
                        children.append(child["rn"])
                    child_string = ":{}".format(",".join(children))
                imp = 'import {{\n  to = {}\n  id = "{}"\n}}\n\n'.format(
                    change["address"],
                    change["change"].get("after", {}).get("dn")+child_string,
                )
                imp.replace('"', '\\"')
                imports += imp

    with open(IMPORT_TF_PATH, "w") as file:
        file.write(imports)

    # cleanup
    if os.path.exists(IMPORT_PLAN_PATH):
        os.remove(IMPORT_PLAN_PATH)
    if os.path.exists(IMPORT_PLAN_JSON_PATH):
        os.remove(IMPORT_PLAN_JSON_PATH)


if __name__ == "__main__":
    tf_import()
