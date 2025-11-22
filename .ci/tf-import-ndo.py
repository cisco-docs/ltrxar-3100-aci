# -*- coding: utf-8 -*-

# Copyright: (c) 2023, Daniel Schmidt <danischm@cisco.com>

import json
import os
import subprocess
import re

CWD = os.getcwd()
if os.path.basename(CWD) == ".ci":
    CWD = os.chdir("../")
    CWD = os.getcwd()

IMPORT_TF_FILENAME = "import.tf"
IMPORT_TF_PATH = os.path.join(CWD, IMPORT_TF_FILENAME)
IMPORT_PLAN_FILENAME = "import_plan.tfplan"
IMPORT_PLAN_PATH = os.path.join(CWD, IMPORT_PLAN_FILENAME)
IMPORT_PLAN_JSON_FILENAME = "import_plan.json"
IMPORT_PLAN_JSON_PATH = os.path.join(CWD, IMPORT_PLAN_JSON_FILENAME)
NAC_COLLETOR_FILE = "./ndo.json"
NAC_COLLETOR_FILE_PATH = os.path.join(CWD, NAC_COLLETOR_FILE)

# Pre-compiled regex patterns for performance
IDENTIFIER_PATTERN = re.compile(r"^[a-zA-Z0-9_\-\.\/ ]+$")
NUMERIC_PATTERN = re.compile(r"^\d+$")


# Security validation functions
def validate_identifier(value, field_name):
    """Validate network identifier for security against code injection.

    Args:
        value: The identifier value to validate
        field_name: Name of the field for error messages

    Returns:
        The validated value

    Raises:
        ValueError: If validation fails
    """
    if not value:
        raise ValueError(f"Empty value for {field_name}")

    # Allow alphanumeric, underscore, hyphen, dot, and forward slash (for CIDR notation)
    if not IDENTIFIER_PATTERN.match(value):
        raise ValueError(f"Invalid characters in {field_name}: '{value}'")

    # Prevent path traversal attacks
    if ".." in value:
        raise ValueError(f"Path traversal attempt in {field_name}: '{value}'")

    # Prevent leading slashes (except for valid CIDR or paths)
    if value.startswith("/") and not NUMERIC_PATTERN.match(value.lstrip("/")):
        # Allow numeric values after slash (for CIDR masks)
        if "/" in value[1:]:
            raise ValueError(f"Path traversal attempt in {field_name}: '{value}'")

    # Reasonable length limit to prevent DoS
    if len(value) > 256:
        raise ValueError(f"Identifier too long in {field_name}: max 256 characters")

    return value


def safe_unpack_index(index_str, expected_count, handler_name):
    """Safely unpack index string with validation.

    Args:
        index_str: The index string to unpack (e.g., "schema/template/vrf")
        expected_count: Expected number of parts after split
        handler_name: Name of the handler for error messages

    Returns:
        List of validated parts

    Raises:
        ValueError: If unpacking or validation fails
    """
    if not index_str:
        raise ValueError(f"{handler_name}: Empty index string")

    parts = index_str.split("/")

    if len(parts) != expected_count:
        raise ValueError(
            f"{handler_name}: Expected {expected_count} parts in index, "
            f"got {len(parts)}. Index: '{index_str}'"
        )

    # Validate each part
    validated_parts = []
    for i, part in enumerate(parts):
        try:
            validated_part = validate_identifier(part, f"{handler_name}_part_{i}")
            validated_parts.append(validated_part)
        except ValueError as e:
            raise ValueError(f"{handler_name}: Validation failed for part {i}: {e}")

    return validated_parts


def safe_lookup_mapping(mapping_dict, search_value, mapping_name):
    """Safely lookup value in mapping dictionary with null checks.

    Args:
        mapping_dict: Dictionary to search (e.g., nac_data_mapping["schemas"])
        search_value: Value to search for
        mapping_name: Name of the mapping for error messages

    Returns:
        The found key or None if not found

    Raises:
        ValueError: If mapping_dict is None or invalid
    """
    if mapping_dict is None:
        raise ValueError(f"{mapping_name}: Mapping dictionary is None")

    if not isinstance(mapping_dict, dict):
        raise ValueError(f"{mapping_name}: Expected dict, got {type(mapping_dict)}")

    # Search for the value in the mapping
    result = next((k for k, v in mapping_dict.items() if v == search_value), None)

    if result is None:
        # Log warning but don't fail - allow None to be handled by caller
        print(f"Warning: {mapping_name}: No mapping found for value '{search_value}'")

    return result


def escape_terraform_string(value):
    """Escape special characters in strings for Terraform import statements.

    Args:
        value: String value to escape

    Returns:
        Escaped string safe for Terraform
    """
    if not value:
        return ""

    # Escape backslashes first, then quotes, then newlines
    escaped = value.replace("\\", "\\\\")
    escaped = escaped.replace('"', '\\"')
    escaped = escaped.replace("\n", "\\n")
    escaped = escaped.replace("\r", "\\r")
    escaped = escaped.replace("\t", "\\t")

    return escaped


api_value_mapping = {
    "tenants": {"key": "name"},
    "site_details": {"key": "name", "id_field": "id"},
    "remoteLocations": {"key": "name", "id_field": "id"},
    # "sites": {"key": "name"},
    # "fabric_connectivity/sites": {"key": "name"},
    "templates": {
        "key": "displayName",
        "id_field": "templateId",
        "children": {
            "tenantPolicyTemplate": {
                "children": {
                    "template": {
                        "children": {
                            "dhcpRelayPolicies": {
                                "key": "name",
                                "id_field": "uuid",
                            },
                            "dhcpOptionPolicies": {
                                "key": "name",
                                "id_field": "uuid",
                            },
                        }
                    }
                }
            }
        },
    },
    "users": {"key": "loginID", "id_field": "userID"},
    "schemas": {
        "key": "displayName",
        "children": {
            "templates": {
                "key": "displayName",
                "id_field": "templateID",
                "children": {
                    "bds": {"key": "name", "id_field": "uuid"},
                    "vrfs": {"key": "name", "id_field": "uuid"},
                    "contracts": {"key": "name", "id_field": "uuid"},
                    "filters": {"key": "name", "id_field": "uuid"},
                    "intersiteL3outs": {"key": "name", "id_field": "uuid"},
                    "externalEpgs": {"key": "name", "id_field": "uuid"},
                    "anps": {
                        "key": "name",
                        "id_field": "uuid",
                        "children": {"epgs": {"key": "name", "id_field": "uuid"}},
                    },
                    "serviceGraphs": {
                        "key": "name",
                        "id_field": "serviceGraphRef",
                        "children": {
                            "serviceNodes": {
                                "key": "index",
                                "id_field": "serviceNodeRef",
                            }
                        },
                    },
                },
            }
        },
    },
}


# From NAC-Tool
class NDO:
    def __init__(self, nac_collector_json):
        self.mappings = {}
        self.ndo = nac_collector_json
        self._get_mappings(api_value_mapping)

    def _get_mappings(self, mapping, node=None):
        node = self.ndo if node is None else node

        for k, v in mapping.items():
            slash_present = False
            if not isinstance(v, dict):
                break
            o_node = node.copy()
            if "/" in k:
                slash_present = True
                _k = k.split("/")
                for i in _k[:-1]:
                    node = node.get(i, {})
                k = _k[-1]
            if k not in node:
                if slash_present:
                    node = o_node
                continue

            if isinstance(node[k], list):
                n_node = node[k]
                new_dict = {}
                for i in n_node:
                    new_dict.update(
                        {i.get(v.get("id_field", "id")): i.get(v.get("key"))}
                    )

                old_dict = self.mappings.setdefault(k, {})
                self.mappings.update({k: {**old_dict, **new_dict}})

                if "children" in v:
                    for k1 in v["children"]:
                        if isinstance(n_node, list):
                            new_dict = {}
                            for j in n_node:
                                self._get_mappings(v["children"], node=j)
                            old_dict = self.mappings.setdefault(k1, {})
                            self.mappings.update({k1: {**old_dict, **new_dict}})
                node = o_node
            else:
                if "children" in v:
                    self._get_mappings(v["children"], node=node[k])


def generate_uuid_from_import_string(index, import_string, mappings):
    import_string = import_string.replace("{", "").replace("}", "").split("/")
    for i, j in enumerate(import_string):
        if "_id" in j:
            import_string[i] = next(
                (k for k, v in mappings.get(f"{j.split('_id')[0]}s").items() if v == j),
                None,
            )
    return "/".join(import_string)


def tf_import():
    if os.path.exists(IMPORT_TF_PATH):
        os.remove(IMPORT_TF_PATH)

    subprocess.run(["terraform", "init"], cwd=CWD)
    subprocess.run(
        ["terraform", "plan", "-out=" + IMPORT_PLAN_FILENAME, "-input=false"]
    )  # noqa
    with open(IMPORT_PLAN_JSON_FILENAME, "w") as f:
        subprocess.run(["terraform", "show", "-json", IMPORT_PLAN_FILENAME], stdout=f)  # noqa

    tf_plan = None
    nac_data = None
    with open(IMPORT_PLAN_JSON_FILENAME) as f:
        tf_plan = json.load(f)

    with open(NAC_COLLETOR_FILE_PATH) as f:
        nac_data = json.load(f)

    nac_data_mapping = NDO(nac_data).mappings

    imports = ""

    # Failure tracking
    failed_imports = []
    success_count = 0
    total_resources = 0

    # imports = (
    #     "terraform {\n"
    #     '  required_version = ">= 1.5.0"\n'
    #     "\n"
    #     "  required_providers {\n"
    #     "    mso = {\n"
    #     '      source  = "CiscoDevNet/mso"\n'
    #     "    }\n"
    #     "  }\n"
    #     "}\n"
    #     'provider "mso" {\n'
    #     '  platform = "nd"\n'
    #     "}\n"
    #     "\n"
    # )

    to_dir_ = {}
    for change in tf_plan.get("resource_changes", []):
        if "create" in change.get("change", {}).get("actions", []):
            # Skip resource types that should not be imported
            resource_type = change.get("type")
            if resource_type in [
                "local_sensitive_file",
                "mso_schema_template_deploy_ndo",
                "terraform_data",
            ]:
                continue

            total_resources += 1
            to_ = ".".join(
                [change.get("module_address"), change.get("type"), change.get("name")]
            )

            uuid = None
            data = []
            d_field = "name"
            if change.get("type") == "mso_tenant":
                data = nac_data.get("tenants", [])
            elif change.get("type") == "mso_site":
                data = nac_data.get("site_details", [])
            elif change.get("type") == "mso_schema_template_vrf":
                # terraform import mso_schema_template_vrf.vrf1 {schema_id}/template/{template_name}/vrf/{vrf_name}
                _schema, _template, _vrf = tuple(change.get("index").split("/"))
                _schema_id = next(
                    (k for k, v in nac_data_mapping["schemas"].items() if v == _schema),
                    None,
                )
                uuid = f"{_schema_id}/template/{_template}/vrf/{_vrf}"
            elif change.get("type") == "mso_schema_template_vrf_contract":
                # terraform import mso_schema_template_vrf_contract.demovrf01 {schema_id}/template/{template_name}/vrf/{vrf_name}/contract/{contract_name}/type/{relationship_type}
                _schema, _template, _vrf, _contract, _type = tuple(
                    change.get("index").split("/")
                )
                _schema_id = next(
                    (k for k, v in nac_data_mapping["schemas"].items() if v == _schema),
                    None,
                )
                uuid = f"{_schema_id}/template/{_template}/vrf/{_vrf}/contract/{_contract}/type/{_type}"
            elif change.get("type") == "mso_schema_template_l3out":
                # terraform import mso_schema_template_l3out.template_l3out {schema_id}/template/{template_name}/l3out/{l3out_name}
                _schema, _template, _l3out = tuple(change.get("index").split("/"))
                _schema_id = next(
                    (k for k, v in nac_data_mapping["schemas"].items() if v == _schema),
                    None,
                )
                uuid = f"{_schema_id}/template/{_template}/l3out/{_l3out}"
            elif change.get("type") == "mso_schema_template_filter_entry":
                # terraform import mso_schema_template_filter_entry.filter_entry {schema_id}/template/{template_name}/filter/{name}/entry/{entry_name}
                _schema, _template, _filter, _entry = tuple(
                    change.get("index").split("/")
                )
                _schema_id = next(
                    (k for k, v in nac_data_mapping["schemas"].items() if v == _schema),
                    None,
                )
                uuid = (
                    f"{_schema_id}/template/{_template}/filter/{_filter}/entry/{_entry}"
                )

            # Added by Morten
            elif change.get("type") == "mso_schema_site_external_epg":
                # terraform import mso_schema_site_external_epg.extepg1 {schema_id}/site/{site_id}/externalEPG/{external_epg_name}
                if change.get("index").count("/") == 3:
                    _schema, _template, _external_epg, _site = tuple(
                        change.get("index").split("/")
                    )
                elif change.get("index").count("/") == 4:
                    _schema, _template, _external_epg, _site, _l3out = tuple(
                        change.get("index").split("/")
                    )
                _schema_id = next(
                    (k for k, v in nac_data_mapping["schemas"].items() if v == _schema),
                    None,
                )
                _site_id = next(
                    (
                        k
                        for k, v in nac_data_mapping["site_details"].items()
                        if v == _site
                    ),
                    None,
                )
                uuid = f"{_schema_id}/site/{_site_id}/externalEPG/{_external_epg}"

            elif change.get("type") == "mso_schema_template_external_epg_subnet":
                # terraform import mso_schema_template_external_epg_subnet.subnet1 {schema_id}/template/{template_name}/externalEPG/{external_epg_name}/ip/{ip}
                _schema, _template, _external_epg, _ip, _mask = tuple(
                    change.get("index").split("/")
                )
                _schema_id = next(
                    (k for k, v in nac_data_mapping["schemas"].items() if v == _schema),
                    None,
                )
                uuid = f"{_schema_id}/template/{_template}/externalEPG/{_external_epg}/ip/{_ip}/{_mask}"
            elif change.get("type") == "mso_schema_template_external_epg_contract":
                # terraform import mso_schema_template_external_epg_contract.c1 {schema_id}/templates/{template_name}/externalEpgs/{external_epg_name}/contractRelationships/{contract_name}/{relationship_type}
                _schema, _template, _external_epg, _contract, _type = tuple(
                    change.get("index").split("/")
                )
                _schema_id = next(
                    (k for k, v in nac_data_mapping["schemas"].items() if v == _schema),
                    None,
                )
                uuid = f"{_schema_id}/templates/{_template}/externalEpgs/{_external_epg}/contractRelationships/{_contract}/{_type}"
            elif change.get("type") == "mso_schema_template_external_epg":
                # terraform import mso_schema_template_external_epg.template_externalepg {schema_id}/template/{template_name}/externalEPG/{external_epg_name}
                _schema, _template, _external_epg = tuple(
                    change.get("index").split("/")
                )
                _schema_id = next(
                    (k for k, v in nac_data_mapping["schemas"].items() if v == _schema),
                    None,
                )
                uuid = f"{_schema_id}/template/{_template}/externalEPG/{_external_epg}"
            elif change.get("type") == "mso_schema_template_external_epg_selector":
                # terraform import mso_schema_template_external_epg_selector.selector1 {schema_id}/template/{template_name}/externalEPG/{external_epg_name}/selector/{name}
                _schema, _template, _external_epg, _selector = tuple(
                    change.get("index").split("/")
                )
                _schema_id = next(
                    (k for k, v in nac_data_mapping["schemas"].items() if v == _schema),
                    None,
                )
                uuid = f"{_schema_id}/template/{_template}/externalEPG/{_external_epg}/selector/{_selector}"
            elif change.get("type") == "mso_schema_template_contract":
                # terraform import mso_schema_template_contract.example {schema_id}/templates/{template_name}/contracts/{contract_name}
                _schema, _template, _contract = tuple(change.get("index").split("/"))
                _schema_id = next(
                    (k for k, v in nac_data_mapping["schemas"].items() if v == _schema),
                    None,
                )
                uuid = f"{_schema_id}/templates/{_template}/contracts/{_contract}"

            # Added by Morten
            elif change.get("type") == "mso_schema_template_contract_service_graph":
                # terraform import mso_schema_template_contract_service_graph.example {schema_id}/templates/{template_name}/contracts/{contract_name}
                _schema, _template, _contract, _sg = tuple(
                    change.get("index").split("/")
                )
                _schema_id = next(
                    (k for k, v in nac_data_mapping["schemas"].items() if v == _schema),
                    None,
                )
                uuid = f"{_schema_id}/templates/{_template}/contracts/{_contract}"

            elif change.get("type") == "mso_schema_template_bd_subnet":
                # terraform import mso_schema_template_bd_subnet.bdsub1 {schema_id}/template/{template_name}/bd/{bd_name}/subnet/{ip} <--- This is incorrect
                # terraform import mso_schema_template_bd_subnet.bdsub1 {schema_id}/template/{template_name}/bd/{bd_name}/ip/{ip} <--- Has been corrected in the provider
                _schema, _template, _bd, _ip, _mask = tuple(
                    change.get("index").split("/")
                )
                _schema_id = next(
                    (k for k, v in nac_data_mapping["schemas"].items() if v == _schema),
                    None,
                )
                # 65fd6d168cf32cae066c9671/template/tpl_mvanklei_test1/bd/BD_WEB/subnet/100.78.2.1/24
                uuid = f"{_schema_id}/template/{_template}/bd/{_bd}/ip/{_ip}/{_mask}"

            elif change.get("type") == "mso_schema_site_bd_subnet":
                # terraform import mso_schema_site_bd_subnet.sub1 {schema_id}/site/{site_id}/template/{template_name}/bd/{bd_name}/ip/{ip}
                _schema, _template, _bd, _site, _ip, _mask = tuple(
                    change.get("index").split("/")
                )
                _schema_id = next(
                    (k for k, v in nac_data_mapping["schemas"].items() if v == _schema),
                    None,
                )
                _site_id = next(
                    (
                        k
                        for k, v in nac_data_mapping["site_details"].items()
                        if v == _site
                    ),
                    None,
                )
                # 65fd6d168cf32cae066c9671/template/tpl_mvanklei_test1/bd/BD_WEB/subnet/100.78.2.1/24
                uuid = f"{_schema_id}/site/{_site_id}/template/{_template}/bd/{_bd}/ip/{_ip}/{_mask}"

            elif change.get("type") == "mso_schema_site_bd":
                # terraform import mso_schema_site_bd.bd1 {schema_id}/site/{site_id}/template/{template_name}/bd/{bd_name}
                _schema, _template, _bd, _site = tuple(change.get("index").split("/"))
                _schema_id = next(
                    (k for k, v in nac_data_mapping["schemas"].items() if v == _schema),
                    None,
                )
                _site_id = next(
                    (
                        k
                        for k, v in nac_data_mapping["site_details"].items()
                        if v == _site
                    ),
                    None,
                )
                uuid = f"{_schema_id}/{_site_id}/{_template}/{_bd}"
            elif change.get("type") == "mso_schema_site_bd_l3out":
                # terraform import mso_schema_site_bd_l3out.bdL3out {schema_id}/site/{site_id}/bd/{bd_name}/l3out/{l3out_name}
                _schema, _template, _bd, _site, _l3out = tuple(
                    change.get("index").split("/")
                )
                _schema_id = next(
                    (k for k, v in nac_data_mapping["schemas"].items() if v == _schema),
                    None,
                )
                _site_id = next(
                    (
                        k
                        for k, v in nac_data_mapping["site_details"].items()
                        if v == _site
                    ),
                    None,
                )
                uuid = f"{_schema_id}/site/{_site_id}/bd/{_bd}/l3out/{_l3out}"

            elif change.get("type") == "mso_schema_site_vrf":
                # terraform import mso_schema_site_vrf.vrf1 {schema_id}/site/{site_id}/vrf/{vrf_name}
                _schema, _template, _vrf, _site = tuple(change.get("index").split("/"))
                _schema_id = next(
                    (k for k, v in nac_data_mapping["schemas"].items() if v == _schema),
                    None,
                )
                _site_id = next(
                    (
                        k
                        for k, v in nac_data_mapping["site_details"].items()
                        if v == _site
                    ),
                    None,
                )
                uuid = f"{_schema_id}/site/{_site_id}/vrf/{_vrf}"
            elif change.get("type") == "mso_schema_template_anp":
                # terraform import mso_schema_template_anp.anp1 {schema_id}/template/{template}/anp/{name}
                _schema, _template, _anp = tuple(change.get("index").split("/"))
                _schema_id = next(
                    (k for k, v in nac_data_mapping["schemas"].items() if v == _schema),
                    None,
                )
                uuid = f"{_schema_id}/template/{_template}/anp/{_anp}"
            elif change.get("type") == "mso_schema_template_anp_epg":
                # terraform import mso_schema_template_anp_epg.anp_epg {schema_id}/template/{template_name}/anp/{anp_name}/epg/{epg_name}
                _schema, _template, _anp, _epg = tuple(change.get("index").split("/"))
                _schema_id = next(
                    (k for k, v in nac_data_mapping["schemas"].items() if v == _schema),
                    None,
                )
                uuid = f"{_schema_id}/template/{_template}/anp/{_anp}/epg/{_epg}"

            # Added by Morten
            elif change.get("type") == "mso_schema_template_anp_epg_subnet":
                # terraform import mso_schema_template_anp_epg_subnet.subnet1 {schema_id}/template/{template_name}/anp/{anp_name}/epg/{epg_name}/ip/{ip}
                _schema, _template, _anp, _epg, _ip, _mask = tuple(
                    change.get("index").split("/")
                )
                _schema_id = next(
                    (k for k, v in nac_data_mapping["schemas"].items() if v == _schema),
                    None,
                )
                uuid = f"{_schema_id}/template/{_template}/anp/{_anp}/epg/{_epg}/ip/{_ip}/{_mask}"

            # Modified by Justyna to address provider fix
            elif change.get("type") == "mso_schema_template_anp_epg_contract":
                # terraform import mso_schema_template_anp_epg_contract.contract1 {schema_id}/template/{template_name}/anp/{anp_name}/epg/{epg_name}/contract/{contract_name}
                # Fixed: terraform import mso_schema_template_anp_epg_contract.contract1 {schema_id}/template/{template_name}/anp/{anp_name}/epg/{epg_name}/contract/{contract_name}/relationshipType/{consumer|provider}
                _schema, _template, _anp, _epg, _contract, _consumer_provider = tuple(
                    change.get("index").split("/")
                )
                _schema_id = next(
                    (k for k, v in nac_data_mapping["schemas"].items() if v == _schema),
                    None,
                )
                uuid = f"{_schema_id}/template/{_template}/anp/{_anp}/epg/{_epg}/contract/{_contract}/relationshipType/{_consumer_provider}"

            elif change.get("type") == "mso_schema_template_bd":
                # terraform import mso_schema_template_bd.bridge_domain {schema_id}/template/{template_name}/bd/{name}
                _schema, _template, _bd = tuple(change.get("index").split("/"))
                _schema_id = next(
                    (k for k, v in nac_data_mapping["schemas"].items() if v == _schema),
                    None,
                )
                uuid = f"{_schema_id}/template/{_template}/bd/{_bd}"
            elif change.get("type") == "mso_schema_template_anp_epg_contract":
                # terraform import mso_schema_template_anp_epg_contract.contract1 {schema_id}/template/{template_name}/anp/{anp_name}/epg/{epg_name}/contract/{contract_name}
                _schema, _template, _anp, _epg, _contract, _ = tuple(
                    change.get("index").split("/")
                )
                _schema_id = next(
                    (k for k, v in nac_data_mapping["schemas"].items() if v == _schema),
                    None,
                )
                uuid = f"{_schema_id}/template/{_template}/anp/{_anp}/epg/{_epg}/contract/{_contract}"

            elif change.get("type") == "mso_schema_site_anp":
                # terraform import mso_schema_site_anp.anp1 {schema_id}/site/{site_id}/template/{template_name}/anp/{anp_name}
                _schema, _template, _anp, _site = tuple(change.get("index").split("/"))
                _schema_id = next(
                    (k for k, v in nac_data_mapping["schemas"].items() if v == _schema),
                    None,
                )
                _site_id = next(
                    (
                        k
                        for k, v in nac_data_mapping["site_details"].items()
                        if v == _site
                    ),
                    None,
                )
                uuid = f"{_schema_id}/site/{_site_id}/template/{_template}/anp/{_anp}"

            elif change.get("type") == "mso_schema_site_anp_epg":
                # terraform import mso_schema_site_anp_epg.site_anp_epg {schema_id}/site/{site_id}/template/{template_name}/anp/{anp_name}/epg/{epg_name}
                _schema, _template, _anp, _epg, _site = tuple(
                    change.get("index").split("/")
                )
                _schema_id = next(
                    (k for k, v in nac_data_mapping["schemas"].items() if v == _schema),
                    None,
                )
                _site_id = next(
                    (
                        k
                        for k, v in nac_data_mapping["site_details"].items()
                        if v == _site
                    ),
                    None,
                )
                uuid = f"{_schema_id}/site/{_site_id}/template/{_template}/anp/{_anp}/epg/{_epg}"
            elif change.get("type") == "mso_schema_site_bd":
                # terraform import mso_schema_site_bd.bd1 {schema_id}/site/{site_id}/template/{template_name}/bd/{bd_name}
                _schema, _template, _bd, _site = tuple(change.get("index").split("/"))
                _schema_id = next(
                    (k for k, v in nac_data_mapping["schemas"].items() if v == _schema),
                    None,
                )
                _site_id = next(
                    (
                        k
                        for k, v in nac_data_mapping["site_details"].items()
                        if v == _site
                    ),
                    None,
                )
                uuid = f"{_schema_id}/site/{_site_id}/template/{_template}/bd/{_bd}"

            # Added by Justyna
            elif change.get("type") == "mso_schema_site_bd_l3out":
                # terraform import mso_schema_site_bd_l3out.bdL3out {schema_id}/site/{site_id}/bd/{bd_name}/l3out/{l3out_name}
                _schema, _template, _bd, _site, _l3out = tuple(
                    change.get("index").split("/")
                )
                _schema_id = next(
                    (k for k, v in nac_data_mapping["schemas"].items() if v == _schema),
                    None,
                )
                _site_id = next(
                    (
                        k
                        for k, v in nac_data_mapping["site_details"].items()
                        if v == _site
                    ),
                    None,
                )
                uuid = f"{_schema_id}/site/{_site_id}/bd/{_bd}/l3out/{_l3out}"
            elif change.get("type") == "mso_schema_site_service_graph":
                # terraform import mso_schema_site_service_graph.example "{schema_id}/sites/{site_id}/template/{template_name}/serviceGraphs/{service_graph_name}"
                _schema, _template, _service_graph, _site = tuple(
                    change.get("index").split("/")
                )
                _schema_id = next(
                    (k for k, v in nac_data_mapping["schemas"].items() if v == _schema),
                    None,
                )
                _site_id = next(
                    (
                        k
                        for k, v in nac_data_mapping["site_details"].items()
                        if v == _site
                    ),
                    None,
                )
                uuid = f"{_schema_id}/sites/{_site_id}/template/{_template}/serviceGraphs/{_service_graph}"
            elif change.get("type") == "mso_schema_template_service_graph":
                # terraform import mso_schema_template_service_graph.test_sg {schema_id}/template/{template_name}/serviceGraph/{service_graph_name}
                _schema, _template, _service_graph = tuple(
                    change.get("index").split("/")
                )
                _schema_id = next(
                    (k for k, v in nac_data_mapping["schemas"].items() if v == _schema),
                    None,
                )
                uuid = (
                    f"{_schema_id}/template/{_template}/serviceGraph/{_service_graph}"
                )

            # Modified by Justyna to address provider fix
            elif change.get("type") == "mso_schema_site":
                # terraform import mso_schema_site.site1 {schema_id}/site/{site_name}
                # fixed: terraform import mso_schema_site.site1 {schema_id}/site/{site_name}/template/{template_name}

                # FIX: Looks weird from provider perspective probably need to change
                _schema, _template, _site = tuple(change.get("index").split("/"))
                _schema_id = next(
                    (k for k, v in nac_data_mapping["schemas"].items() if v == _schema),
                    None,
                )
                uuid = f"{_schema_id}/site/{_site}/template/{_template}/undeploy_on_destroy/true"
            elif change.get("type") == "mso_schema_site_anp_epg_bulk_staticport":
                # terraform import mso_schema_site_anp_epg_bulk_staticport.static_port {schema_id}/site/{site_id}/template/{template_name}/anp/{anp_name}/epg/{epg_name}
                _schema, _template, _anp, _epg, _site = tuple(
                    change.get("index").split("/")
                )
                _schema_id = next(
                    (k for k, v in nac_data_mapping["schemas"].items() if v == _schema),
                    None,
                )
                _site_id = next(
                    (
                        k
                        for k, v in nac_data_mapping["site_details"].items()
                        if v == _site
                    ),
                    None,
                )
                uuid = f"{_schema_id}/site/{_site_id}/template/{_template}/anp/{_anp}/epg/{_epg}"
            elif change.get("type") == "mso_schema_site_contract_service_graph":
                # terraform import mso_schema_site_contract_service_graph.example {schema_id}/sites/{site_id}/templates/{template_name}/contracts/{contract_name}
                _schema, _template, _contract, _service_graph, _site = tuple(
                    change.get("index").split("/")
                )
                _schema_id = next(
                    (k for k, v in nac_data_mapping["schemas"].items() if v == _schema),
                    None,
                )
                _site_id = next(
                    (
                        k
                        for k, v in nac_data_mapping["site_details"].items()
                        if v == _site
                    ),
                    None,
                )
                uuid = f"{_schema_id}/sites/{_site_id}/templates/{_template}/contracts/{_contract}"

            # Added by Justyna - Enhanced to support both Physical and VMware VMM domains
            elif change.get("type") == "mso_schema_site_anp_epg_domain":
                # terraform import mso_schema_site_anp_epg_domain.site_anp_epg_domain {schema_id}/sites/{site_id}-{template_name}/anps/{anp_name}/epgs/{epg_name}/domainAssociations/{domain_dn}
                # Supports: uni/phys-{domain} (Physical) and uni/vmmp-VMware/dom-{domain} (VMware VMM)
                try:
                    index_parts = change.get("index").split("/")

                    # Validate minimum required parts (schema/template/anp/epg/site/domain)
                    if len(index_parts) < 6:
                        raise ValueError(
                            f"Expected at least 6 parts, got {len(index_parts)}"
                        )

                    _schema, _template, _anp, _epg, _site = index_parts[0:5]
                    _domain = index_parts[5]
                    _domain_type = index_parts[6] if len(index_parts) > 6 else None

                    _schema_id = safe_lookup_mapping(
                        nac_data_mapping.get("schemas"), _schema, "schemas"
                    )
                    _site_id = safe_lookup_mapping(
                        nac_data_mapping.get("site_details"), _site, "site_details"
                    )

                    if not _schema_id or not _site_id:
                        raise ValueError(
                            f"Failed to resolve schema_id or site_id for schema='{_schema}', site='{_site}'"
                        )

                    # Construct domain DN based on explicitly specified domain type
                    # Validate domain type if provided
                    if _domain_type:
                        if _domain_type not in ["vmm", "physical", "phys"]:
                            raise ValueError(
                                f"Invalid domain_type '{_domain_type}', expected 'vmm', 'physical', or 'phys'"
                            )

                        if _domain_type == "vmm":
                            # VMware VMM domain: uni/vmmp-VMware/dom-{domain}
                            domain_dn = f"uni/vmmp-VMware/dom-{_domain}"
                        else:
                            # Physical domain: uni/phys-{domain}
                            domain_dn = f"uni/phys-{_domain}"
                    else:
                        # Default to physical domain for backward compatibility
                        domain_dn = f"uni/phys-{_domain}"

                    uuid = f"{_schema_id}/sites/{_site_id}-{_template}/anp/{_anp}/epgs/{_epg}/domainAssociations/{domain_dn}"
                except (ValueError, IndexError) as e:
                    error_msg = f"Error processing mso_schema_site_anp_epg_domain: {e}"
                    print(error_msg)
                    failed_imports.append(
                        {
                            "resource_type": change.get("type"),
                            "resource_name": change.get("name"),
                            "index": change.get("index"),
                            "error": str(e),
                        }
                    )
                    continue

            # Added by Justyna
            elif change.get("type") == "mso_schema_site_anp_epg_static_leaf":
                # terraform import mso_schema_site_anp_epg_static_leaf.staticleaf1 {schema_id}/site/{site_id}/template/{template_name}/anp/{anp_name}/epg/{epg_name}/path/{static_leaf_path}
                try:
                    parts = safe_unpack_index(
                        change.get("index"), 8, "mso_schema_site_anp_epg_static_leaf"
                    )
                    _schema, _template, _anp, _epg, _site, _pod, _node, _ = parts

                    _schema_id = safe_lookup_mapping(
                        nac_data_mapping.get("schemas"), _schema, "schemas"
                    )
                    _site_id = safe_lookup_mapping(
                        nac_data_mapping.get("site_details"), _site, "site_details"
                    )

                    if _schema_id and _site_id:
                        uuid = f"{_schema_id}/site/{_site_id}/template/{_template}/anp/{_anp}/epg/{_epg}/path/topology/pod-{_pod}/node-{_node}"
                except ValueError as e:
                    error_msg = (
                        f"Error processing mso_schema_site_anp_epg_static_leaf: {e}"
                    )
                    print(error_msg)
                    failed_imports.append(
                        {
                            "resource_type": change.get("type"),
                            "resource_name": change.get("name"),
                            "index": change.get("index"),
                            "error": str(e),
                        }
                    )
                    continue

            # Added for missing NDO import resources (resources 2-5 from analysis)
            elif change.get("type") == "mso_schema_site_anp_epg_subnet":
                # terraform import mso_schema_site_anp_epg_subnet.subnet1 {schema_id}/site/{site_id}/template/{template_name}/anp/{anp_name}/epg/{epg_name}/ip/{ip}/{mask}
                try:
                    parts = safe_unpack_index(
                        change.get("index"), 7, "mso_schema_site_anp_epg_subnet"
                    )
                    _schema, _template, _anp, _epg, _site, _ip, _mask = parts

                    _schema_id = safe_lookup_mapping(
                        nac_data_mapping.get("schemas"), _schema, "schemas"
                    )
                    _site_id = safe_lookup_mapping(
                        nac_data_mapping.get("site_details"), _site, "site_details"
                    )

                    if _schema_id and _site_id:
                        uuid = f"{_schema_id}/site/{_site_id}/template/{_template}/anp/{_anp}/epg/{_epg}/ip/{_ip}/{_mask}"
                except ValueError as e:
                    error_msg = f"Error processing mso_schema_site_anp_epg_subnet: {e}"
                    print(error_msg)
                    failed_imports.append(
                        {
                            "resource_type": change.get("type"),
                            "resource_name": change.get("name"),
                            "index": change.get("index"),
                            "error": str(e),
                        }
                    )
                    continue

            elif change.get("type") == "mso_schema_site_anp_epg_selector":
                # terraform import mso_schema_site_anp_epg_selector.selector1 {schema_id}/site/{site_id}/template/{template_name}/anp/{anp_name}/epg/{epg_name}/selector/{name}
                try:
                    parts = safe_unpack_index(
                        change.get("index"), 6, "mso_schema_site_anp_epg_selector"
                    )
                    _schema, _template, _anp, _epg, _site, _selector = parts

                    _schema_id = safe_lookup_mapping(
                        nac_data_mapping.get("schemas"), _schema, "schemas"
                    )
                    _site_id = safe_lookup_mapping(
                        nac_data_mapping.get("site_details"), _site, "site_details"
                    )

                    if _schema_id and _site_id:
                        uuid = f"{_schema_id}/site/{_site_id}/template/{_template}/anp/{_anp}/epg/{_epg}/selector/{_selector}"
                except ValueError as e:
                    error_msg = (
                        f"Error processing mso_schema_site_anp_epg_selector: {e}"
                    )
                    print(error_msg)
                    failed_imports.append(
                        {
                            "resource_type": change.get("type"),
                            "resource_name": change.get("name"),
                            "index": change.get("index"),
                            "error": str(e),
                        }
                    )
                    continue

            elif change.get("type") == "mso_schema_site_external_epg_selector":
                # terraform import mso_schema_site_external_epg_selector.selector1 {schema_id}/site/{site_id}/externalEPG/{external_epg_name}/selector/{selector_name}
                try:
                    parts = safe_unpack_index(
                        change.get("index"), 4, "mso_schema_site_external_epg_selector"
                    )
                    _schema, _external_epg, _site, _selector = parts

                    _schema_id = safe_lookup_mapping(
                        nac_data_mapping.get("schemas"), _schema, "schemas"
                    )
                    _site_id = safe_lookup_mapping(
                        nac_data_mapping.get("site_details"), _site, "site_details"
                    )

                    if _schema_id and _site_id:
                        uuid = f"{_schema_id}/site/{_site_id}/externalEPG/{_external_epg}/selector/{_selector}"
                except ValueError as e:
                    error_msg = (
                        f"Error processing mso_schema_site_external_epg_selector: {e}"
                    )
                    print(error_msg)
                    failed_imports.append(
                        {
                            "resource_type": change.get("type"),
                            "resource_name": change.get("name"),
                            "index": change.get("index"),
                            "error": str(e),
                        }
                    )
                    continue

            elif change.get("type") == "mso_remote_location":
                # terraform import mso_remote_location.remote_location1 {remote_location_name}
                try:
                    # Validate input for security
                    validate_identifier(change.get("index"), "remote_location_name")
                    data = nac_data.get("remoteLocations", [])
                    # d_field defaults to "name" - let generic fallback handle UUID lookup
                except ValueError as e:
                    error_msg = f"Error processing mso_remote_location: {e}"
                    print(error_msg)
                    failed_imports.append(
                        {
                            "resource_type": change.get("type"),
                            "resource_name": change.get("name"),
                            "index": change.get("index"),
                            "error": str(e),
                        }
                    )
                    continue
            elif change.get("type") == "mso_site":
                data = nac_data.get("site_details", [])
            elif change.get("type") == "mso_schema":
                data = nac_data.get("schemas", [])
                d_field = "displayName"
            else:
                pass
            if uuid is None:
                for t in data:
                    if change.get("index") == t.get(d_field):
                        uuid = t.get("id")
                        break
            if uuid:
                if to_dir_.get(to_):
                    to_dir_[to_].append((uuid, change.get("index")))
                else:
                    to_dir_[to_] = [(uuid, change.get("index"))]
                success_count += 1
            else:
                # Track resources where UUID could not be determined
                failed_imports.append(
                    {
                        "resource_type": change.get("type"),
                        "resource_name": change.get("name"),
                        "index": change.get("index"),
                        "error": "Failed to determine UUID (no mapping found)",
                    }
                )

    for k, v in to_dir_.items():
        for uuid, name in v:
            # Escape values to prevent injection attacks in Terraform
            uuid_safe = escape_terraform_string(uuid) if uuid else ""
            name_safe = escape_terraform_string(name) if name else ""
            k_safe = escape_terraform_string(k) if k else ""

            imp = f'import {{\n  to = {k_safe}["{name_safe}"]\n  id = "{uuid_safe}"\n}}\n\n'
            imports += imp

    with open(IMPORT_TF_PATH, "w") as file:
        file.write(imports)

    # Print import summary
    print("\n" + "=" * 80)
    print("IMPORT SUMMARY")
    print("=" * 80)
    print(f"Total resources: {total_resources}")
    print(f"Successfully processed: {success_count}")
    print(f"Failed: {len(failed_imports)}")
    print(
        f"Success rate: {(success_count / total_resources * 100):.1f}%"
        if total_resources > 0
        else "N/A"
    )

    if failed_imports:
        print("\n" + "=" * 80)
        print("FAILED IMPORTS")
        print("=" * 80)
        for idx, failure in enumerate(failed_imports, 1):
            print(f"\n{idx}. Resource Type: {failure['resource_type']}")
            print(f"   Resource Name: {failure['resource_name']}")
            print(f"   Index: {failure['index']}")
            print(f"   Error: {failure['error']}")

        # Write failures to JSON file for further analysis
        failures_file = os.path.join(CWD, "import_failures.json")
        with open(failures_file, "w") as f:
            json.dump(failed_imports, f, indent=2)
        print(f"\nDetailed failure information written to: {failures_file}")
    else:
        print("\nAll resources processed successfully!")

    print("=" * 80)

    # for change in tf_plan.get("resource_changes", []):
    #     if change.get("type") == "aci_rest_managed":
    #         if "create" in change["change"].get("actions", []):
    #             imp = 'import {{\n  to = {}\n  id = "{}:{}"\n}}\n\n'.format(
    #                 change["address"],
    #                 change["change"].get("after", {}).get("class_name"),
    #                 change["change"].get("after", {}).get("dn"),
    #             )
    #             imp.replace('"', '\\"')
    #             imports += imp

    # with open(IMPORT_TF_PATH, "w") as file:
    #     file.write(imports)

    # # cleanup
    # if os.path.exists(IMPORT_PLAN_PATH):
    #     os.remove(IMPORT_PLAN_PATH)
    # if os.path.exists(IMPORT_PLAN_JSON_PATH):
    #     os.remove(IMPORT_PLAN_JSON_PATH)


if __name__ == "__main__":
    tf_import()
