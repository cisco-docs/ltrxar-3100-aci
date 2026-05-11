# -*- coding: utf-8 -*-

# Copyright: (c) 2022, Daniel Schmidt <danischm@cisco.com>

import json
import re
import sys
import time
import os
from http import HTTPStatus

import yaml

import requests
import urllib3

from requests.packages.urllib3.util.retry import Retry
from util import TimeoutHTTPAdapter

API_ENDPOINT_MAPPINGS = {
    "platform/remote-locations": {
        "container": "remoteLocations",
        "key": "name",
        "has_id": True,
    },
    "auth/providers/radius": {
        "container": "radiusProviders",
        "key": "host",
        "has_id": True,
    },
    "auth/providers/tacacs": {
        "container": "tacacsProviders",
        "key": "host",
        "has_id": True,
    },
    "auth/providers/ldap": {
        "container": "ldapProviders",
        "key": "host",
        "has_id": True,
    },
    "auth/domains": {
        "container": "domains",
        "key": "name",
        "has_id": True,
    },
    "users": {
        "container": "users",
        "key": "username",
        "has_id": True,
    },
    "roles": {
        "container": "roles",
        "key": "name",
        "has_id": True,
    },
    "sites": {
        "container": "sites",
        "key": "name",
        "has_id": True,
    },
    "sites/manage": {
        "container": "sites",
        "key": "name",
        "has_id": True,
        "method": "post",
        "api_version": "v2",
        "api_prefix": "mso/",
    },
    "tenants": {
        "container": "tenants",
        "key": "name",
        "has_id": True,
    },
    "schemas": {
        "container": "schemas",
        "key": "displayName",
        "has_id": True,
    },
    "schemas/list-identity": {
        "container": "schemas",
        "key": "displayName",
        "has_id": True,
    },
    "auth/security/certificates": {
        "container": "caCertificates",
        "key": "name",
        "has_id": True,
    },
    "platform/systemConfig": {
        "container": "systemConfigs",
        "key": None,
        "has_id": True,
        "method": "patch",
        "api_prefix": "mso/",
    },
    "platform/security/keyrings": {
        "container": "keyrings",
        "key": "name",
        "has_id": True,
    },
    "sites/fabric-connectivity": {
        "container": None,
        "key": None,
        "has_id": False,
        "method": "put",
    },
    "tenants/allowed-users": {
        "container": None,
        "key": "domain_username",
        "has_id": True,
    },
    "templates": {
        "container": None,
        "key": "displayName",
        "has_id": True,
    },
    "templates/summaries": {
        "container": None,
        "key": "templateName",
        "id_key": "templateId",
    },
    "schemas/templates/anps/epgs": {
        "container": "epg",  # or whatever the API container is called
        "key": "name",  # assuming EPGs are looked up by name
        "has_id": True,
        "id_field": "uuid",  # Use uuid instead of id
    },
    "schemas/templates/externalEpgs": {
        "container": "externalEpg",  # or whatever the API container is called
        "key": "name",  # assuming external EPGs are looked up by name
        "has_id": True,
        "id_field": "uuid",  # Use uuid instead of id
    },
}


class Ndo:
    # Mapping of (defaults_key, api_key) for each tenant policy type.
    # Add new entries here when new tenant template policy types are introduced.
    TENANT_POLICY_TYPES = [
        ("dhcp_relay_policies", "dhcpRelayPolicies"),
        ("multicast_route_maps", "mcastRouteMapPolicies"),
        ("ip_sla_policies", "ipslaMonitoringPolicies"),
    ]

    def __init__(self, url: str, username: str, password: str):
        self.url = url
        self.username = username
        self.password = password
        urllib3.disable_warnings()
        self.session = requests.Session()
        self.session.verify = False
        self.session.headers["Content-Type"] = "application/json"
        self.lookup_cache = {}

    def enable_retries(self):
        retry_strategy = Retry(
            total=5,
            backoff_factor=5,
            status_forcelist=[400, 429, 500, 502, 503, 504],
            method_whitelist=["GET", "PUT", "POST", "DELETE"],
        )
        adapter = TimeoutHTTPAdapter(max_retries=retry_strategy)
        self.session.mount("https://", adapter)

    def login(self):
        """NDO login"""
        credentials = {
            "userName": self.username,
            "userPasswd": self.password,
            "domain": "DefaultAuth",
        }
        json_credentials = json.dumps(credentials)
        base_url = self.url + "/login"

        resp = self.session.post(base_url, data=json_credentials)

        if resp.status_code not in [200, 201]:
            return "NDO login failed, status code: {}, response: {}.".format(
                resp.status_code, resp.text
            )

        token = json.loads(resp.text)["token"]
        self.session.headers["Authorization"] = "Bearer " + token
        return None

    def logout(self):
        """NDO logout"""
        base_url = self.url + "/api/v1/auth/logout"
        resp = self.session.delete(base_url)
        if resp.status_code != 200:
            return "NDO logout failed, status code: {}".format(resp.status_code)
        return None

    def _load_defaults_from_paths(self, data_paths):
        """
        Load defaults configuration from data paths

        Args:
            data_paths (list): List of paths to search for defaults

        Returns:
            dict: Loaded defaults configuration, or empty dict if not found
        """
        if not data_paths:
            return {}

        # Look for defaults.yaml in each data path
        for path in data_paths:
            defaults_file = os.path.join(path, "defaults.yaml")
            if os.path.exists(defaults_file):
                try:
                    with open(defaults_file, "r") as f:
                        return yaml.safe_load(f) or {}
                except Exception as e:
                    print(f"Warning: Failed to load defaults from {defaults_file}: {e}")
                    continue

        # If no defaults.yaml found, look in common locations
        for path in data_paths:
            # Check for defaults in parent directories
            parent_path = os.path.dirname(path)
            defaults_file = os.path.join(parent_path, "defaults.yaml")
            if os.path.exists(defaults_file):
                try:
                    with open(defaults_file, "r") as f:
                        return yaml.safe_load(f) or {}
                except Exception as e:
                    print(f"Warning: Failed to load defaults from {defaults_file}: {e}")
                    continue

        print("Warning: No defaults.yaml found in data paths")
        return {}

    def _extract_tenant_policy_uuids(self, existing_template_data):
        """
        Extract UUIDs from existing tenant policy template for PUT operations

        Args:
            existing_template_data (dict): Full template data from NDO API

        Returns:
            dict: Extracted UUIDs organized by policy type and policy name
        """
        uuids = {key: {} for key, _ in self.TENANT_POLICY_TYPES}

        if (
            not existing_template_data
            or "tenantPolicyTemplate" not in existing_template_data
        ):
            return uuids

        template = existing_template_data.get("tenantPolicyTemplate", {}).get(
            "template", {}
        )

        for defaults_key, api_key in self.TENANT_POLICY_TYPES:
            for policy in template.get(api_key, []):
                name = policy.get("name", "")
                if name:
                    uuids[defaults_key][name] = policy.get("uuid")

        return uuids

    def _inject_tenant_policy_uuids(self, payload, uuids):
        """
        Inject UUIDs into tenant policy template payload for PUT operations

        Args:
            payload (dict): The template payload to modify
            uuids (dict): UUIDs organized by policy type and policy name

        Returns:
            None: Modifies payload in place
        """
        if not isinstance(payload, dict) or "tenantPolicyTemplate" not in payload:
            return

        template = payload.get("tenantPolicyTemplate", {}).get("template", {})

        for defaults_key, api_key in self.TENANT_POLICY_TYPES:
            for policy in template.get(api_key, []):
                uuid_value = uuids.get(defaults_key, {}).get(policy.get("name", ""))
                if uuid_value:
                    policy["uuid"] = uuid_value

    def _query_tenant_users(self):
        """Helper to handle allowed-users queries"""
        found = []
        domains = {}
        base_url = self.url + "/api/v1/tenants/allowed-users/domains"
        resp = self.session.get(base_url)
        for obj in json.loads(resp.text)["domains"]:
            domains[obj["id"]] = obj["name"]
        base_url = self.url + "/api/v1/tenants/allowed-users"
        resp = self.session.get(base_url)
        if json.loads(resp.text) is None:
            return found
        for obj in json.loads(resp.text)["users"]:
            if obj["domainId"] in domains:
                obj["domain_username"] = (
                    domains[obj["domainId"]] + "/" + obj["username"]
                )
                found.append(obj)
        return found

    def _query_objs(self, path, key=None, **kwargs):
        """Retrieve objects via REST GET and optionally filter by key"""

        if path == "schemas/templates/anps/epgs":
            # Handle EPG lookup: key format should be "schema_name/template_name/anp_name/epg_name"
            return self._query_nested_epg(key, path_type="epgs")
        elif path == "schemas/templates/externalEpgs":
            # Handle external EPG lookup: key format should be "schema_name/template_name/external_epg_name"
            return self._query_nested_epg(key, path_type="externalEpgs")
        if path == "schemas":
            path == "schemas/list-identity"
        if path == "tenants/allowed-users":
            return self._query_tenant_users()
        found = []
        if path == "platform/systemConfig":
            base_url = self.url + "/mso/api/v1/" + path
        else:
            base_url = self.url + "/api/v1/" + path
        resp = self.session.get(base_url)
        objs = json.loads(resp.text)

        if objs == {}:
            return found

        if key is not None and key not in objs:
            sys.exit("Key '{}' missing from data".format(key))

        if key is None:
            return [objs]
        if not isinstance(objs[key], list):
            return [objs[key]]
        for obj in objs[key]:
            for kw_key, kw_value in kwargs.items():
                if kw_value is None:
                    continue
                if obj[kw_key] != kw_value:
                    break
            else:
                found.append(obj)
        return found

    def _query_nested_epg(self, search_key, path_type="epgs"):
        """Handle nested EPG/external EPG queries"""
        if search_key is None:
            return []

        # Parse the composite key based on path type
        if path_type == "epgs":
            # Format: "schema_name/template_name/anp_name/epg_name"
            key_parts = search_key.split("/")
            if len(key_parts) != 4:
                sys.exit(
                    "EPG key must be in format 'schema_name/template_name/anp_name/epg_name', got: '{}'".format(
                        search_key
                    )
                )
            schema_name, template_name, anp_name, epg_name = key_parts
        elif path_type == "externalEpgs":
            # Format: "schema_name/template_name/external_epg_name"
            key_parts = search_key.split("/")
            if len(key_parts) != 3:
                sys.exit(
                    "External EPG key must be in format 'schema_name/template_name/external_epg_name', got: '{}'".format(
                        search_key
                    )
                )
            schema_name, template_name, external_epg_name = key_parts
        else:
            sys.exit("Unsupported path_type: '{}'".format(path_type))

        # First resolve schema_name to schema_id using existing lookup
        schema_obj = self._lookup("schemas", schema_name, use_cache=True)
        if not schema_obj or "id" not in schema_obj:
            sys.exit("Failed to resolve schema '{}' to ID".format(schema_name))
        schema_id = schema_obj["id"]

        # Construct the full API path
        if path_type == "epgs":
            api_path = "schemas/{}/templates/{}/anps/{}/epgs/{}".format(
                schema_id, template_name, anp_name, epg_name
            )
        else:  # externalEpgs
            api_path = "schemas/{}/templates/{}/externalEpgs/{}".format(
                schema_id, template_name, external_epg_name
            )

        # Make the API call
        base_url = self.url + "/api/v1/" + api_path
        resp = self.session.get(base_url)

        if resp.status_code != 200:
            sys.exit(
                "Failed to query {}: status {}, response: {}".format(
                    api_path, resp.status_code, resp.text
                )
            )

        result = json.loads(resp.text)

        # Return as a single-item list to match expected format
        # The response structure is {"epg": {...}} or {"externalEpg": {...}}
        container_key = "epg" if path_type == "epgs" else "externalEpg"
        if container_key in result:
            return [result[container_key]]
        else:
            return []

    def _lookup(self, path, search_key, use_cache=True):
        """Lookup object by key either from a cache or via REST GET"""

        def check_cache(key):
            for obj in self.lookup_cache.get(path, []):
                if search_key is None or obj.get(key) == search_key:
                    return obj
            return None

        # Handle EPG and external EPG lookups specially
        if path in ["schemas/templates/anps/epgs", "schemas/templates/externalEpgs"]:
            # For composite key lookups, call _query_objs with the actual search_key
            if use_cache and path in self.lookup_cache:
                # Check if we already have the result in cache
                for obj in self.lookup_cache[path]:
                    if (
                        obj.get("name") == search_key.split("/")[-1]
                    ):  # Match by final name part
                        return obj

            # Query for the specific composite key
            result = self._query_objs(path, key=search_key)
            if not self.lookup_cache.get(path):
                self.lookup_cache[path] = []
            if result:
                self.lookup_cache[path].extend(
                    result if isinstance(result, list) else [result]
                )
                return result[0] if isinstance(result, list) else result
            return {}

        # Original logic for non-composite lookups
        container = API_ENDPOINT_MAPPINGS.get(path, {}).get("container")
        key = API_ENDPOINT_MAPPINGS.get(path, {}).get("key")
        obj = check_cache(key)
        if obj and use_cache:
            return obj
        self.lookup_cache[path] = self._query_objs(path, key=container)
        obj = check_cache(key)
        if obj:
            return obj
        return {}

    def _update_references(self, payload):
        """Locate and resolve references (%%xxx%xxx%%) in payload"""
        if isinstance(payload, dict):
            match_regex = "%%.*?%.*?%%"
            for k, v in payload.items():
                if isinstance(v, list):
                    for o in v:
                        self._update_references(o)
                else:
                    # Only check string values for references
                    if isinstance(v, str):
                        m = re.search(match_regex, v)
                        if m is not None:
                            # Handle composite paths like "schemas/templates/anps/epgs"
                            # Pattern: %%path%key%%
                            full_match = m.group()[2:-2]  # Remove outer %%

                            # Find the separator % between path and key
                            # Look for known composite paths first
                            composite_paths = [
                                "schemas/templates/anps/epgs",
                                "schemas/templates/externalEpgs",
                            ]

                            path = None
                            key = None
                            for composite_path in composite_paths:
                                if full_match.startswith(composite_path + "%"):
                                    path = composite_path
                                    key = full_match[len(composite_path) + 1 :]
                                    break

                            # Fallback to original logic for simple paths
                            if path is None:
                                separator_pos = full_match.find("%")
                                if separator_pos != -1:
                                    path = full_match[:separator_pos]
                                    key = full_match[separator_pos + 1 :]
                                else:
                                    # No separator found, treat as simple reference
                                    continue
                            endpoint_config = API_ENDPOINT_MAPPINGS.get(path, {})
                            id_field = endpoint_config.get("id_field", "id")
                            id = self._lookup(path, key).get(id_field)
                            if path == "templates":
                                print("Found ID, " + id + " for key " + key)
                            if id is None:
                                sys.exit("Lookup failed for key '{}'".format(key))
                            # Keep as string, don't convert to str() - v is already a string
                            payload[k] = re.sub(match_regex, id, v)
                    elif isinstance(v, dict):
                        # Recursively process nested dictionaries
                        self._update_references(v)

    def post_or_put(self, path: str, data: str, method: str = ""):
        """NDO POST or PUT"""
        if data:
            payload = json.loads(data)
        else:
            payload = {}

        # replace names with IDs in references
        self._update_references(payload)
        if path == "templates":
            print("Updated payload: ", payload)

        # update references in path
        path_dict = {"path": path}
        self._update_references(path_dict)
        path = path_dict["path"]

        # Query for existing object(s)
        lookup_path = path
        lookup_value = None
        method = API_ENDPOINT_MAPPINGS.get(path, {}).get("method", method)
        api_version = API_ENDPOINT_MAPPINGS.get(path, {}).get("api_version", "v1")
        api_prefix = API_ENDPOINT_MAPPINGS.get(path, {}).get("api_prefix", "")
        if lookup_path in API_ENDPOINT_MAPPINGS and method in [
            "put",
            "post_or_put",
            "patch",
        ]:
            key = API_ENDPOINT_MAPPINGS.get(lookup_path, {}).get("key")
            has_id = API_ENDPOINT_MAPPINGS.get(lookup_path, {}).get("has_id")
            if key is not None:
                lookup_value = payload.get(key)
            existing_obj = self._lookup(lookup_path, lookup_value)
            if existing_obj and has_id:
                obj_id = existing_obj["id"]
                if method != "patch":
                    payload["id"] = obj_id
                path = path + "/{}".format(obj_id)
                if method == "post_or_put":
                    method = "put"

                    # Handle UUID injection for tenant policy templates on PUT
                    if (
                        path.startswith("templates")
                        and isinstance(payload, dict)
                        and payload.get("templateType") == "tenantPolicy"
                    ):
                        # Extract UUIDs from existing template
                        uuids = self._extract_tenant_policy_uuids(existing_obj)

                        # Inject UUIDs into payload for PUT operation
                        if uuids:
                            self._inject_tenant_policy_uuids(payload, uuids)
                            print(
                                f"Injected UUIDs for tenant policy template: {lookup_value}"
                            )

            elif method == "post_or_put":
                method = "post"
                # For POST operations, no UUIDs are needed - NDO will generate them

        base_url = "{}/{}api/{}/{}".format(self.url, api_prefix, api_version, path)
        if method.upper() == "PUT":
            resp = self.session.put(base_url, data=json.dumps(payload))
        elif method.upper() == "PATCH":
            resp = self.session.patch(base_url, data=json.dumps(payload))
        else:
            resp = self.session.post(base_url, data=json.dumps(payload))

        if resp.status_code not in [200, 201, 204]:
            if "Cannot run program" in resp.text and resp.status_code == 400:
                return ""
            if (
                "Site already managed" in resp.text
                or "Fabric already managed" in resp.text
            ) and resp.status_code == 400:
                return ""
            return "NDO {} failed, status code: {}, response: {}.".format(
                method, resp.status_code, resp.text
            )
        return ""

    def get(self, path: str) -> str:
        """NDO GET"""
        # update references in path
        path_dict = {"path": path}
        self._update_references(path_dict)
        path = path_dict["path"]

        base_url = self.url + "/mso/api/v1/" + path

        resp = self.session.get(base_url)

        if resp.status_code != 200:
            return "NDO GET failed, status code: {}, response: {}.".format(
                resp.status_code, resp.text
            )
        return ""

    def _wait_for_operation(self, status_url, timeout=1800, interval=60):
        """Poll the status endpoint until the async operation completes.

        Args:
            status_url: URL to poll for operation status.
            timeout: Maximum time to wait in seconds (default 30 minutes).
            interval: Time between polls in seconds (default 60).

        Returns:
            Tuple of (success: bool, error_message: str).
        """
        elapsed = 0
        while elapsed < timeout:
            resp = self.session.get(status_url)
            status = json.loads(resp.text)
            state = status.get("state")

            error = status.get("error", "")

            if state in ("complete", "completed", "ready"):
                return True, ""
            elif state in ("failed", "validationError") or error:
                return False, "Operation failed: {}".format(resp.text)

            time.sleep(interval)
            elapsed += interval

        return False, "Operation did not complete within {}s".format(timeout)

    def backup_restore(self, key: str, backup: str, version: str):
        """ND unified backup restore starting from ND 3.2.1 / NDO 4.4.1"""
        fileimport = {"encryptionKey": key, "name": backup, "path": ""}
        json_fileimport = json.dumps(fileimport)
        if version.startswith("4.4"):
            base_url = self.url + "/api/action/class/backuprestore"
        else:
            base_url = self.url + "/api/v1/infra/backups"

        status_url = base_url + "/status"
        resp = self.session.get(status_url)
        if (
            json.loads(resp.text).get("state") == "ready"
            and json.loads(resp.text).get("operation") == "restore"
        ):
            if version.startswith("4.4"):
                import_url = base_url + "/restore/file-import"
            else:
                import_url = base_url + "/actions/import"
            resp = self.session.delete(import_url)
            if resp.status_code == HTTPStatus.ACCEPTED:
                success, err = self._wait_for_operation(
                    status_url, timeout=300, interval=10
                )
                if not success:
                    return "Existing NDO import file clear fail: {}".format(err)
            elif resp.status_code not in (200, 201, 204):
                return "Existing NDO import file clear fail: {} {}".format(
                    resp.status_code, resp.text
                )

        if version.startswith("4.4"):
            import_url = base_url + "/restore/file-import"
        else:
            import_url = base_url + "/actions/import"
        resp = self.session.post(import_url, data=json_fileimport)
        if resp.status_code == HTTPStatus.ACCEPTED:
            success, err = self._wait_for_operation(
                status_url, timeout=300, interval=10
            )
            if not success:
                return "NDO Backup file import did not complete: {}".format(err)
        elif resp.status_code in (200, 201):
            success, err = self._wait_for_operation(
                status_url, timeout=300, interval=10
            )
            if not success:
                return "NDO Backup file import did not complete: {}".format(err)
        else:
            return (
                "NDO Backup file import failed, status code: {}, response: {}.".format(
                    resp.status_code, resp.text
                )
            )

        restore = {"type": "config-only", "ignorePersistentIPs": False}
        json_restore = json.dumps(restore)

        if version.startswith("4.4"):
            restore_url = base_url + "/restore"
        else:
            restore_url = base_url + "/actions/restore"
        resp = self.session.post(restore_url, data=json_restore)

        if resp.status_code == HTTPStatus.ACCEPTED:
            success, err = self._wait_for_operation(
                status_url, timeout=1800, interval=30
            )
            if not success:
                return "NDO Backup restore did not complete: {}".format(err)
        elif resp.status_code in (200, 201):
            success, err = self._wait_for_operation(
                status_url, timeout=1800, interval=60
            )
            if not success:
                return "NDO Backup restore did not complete: {}".format(err)
        else:
            return "NDO Backup restore failed, status code: {}, response: {}.".format(
                resp.status_code, resp.text
            )

        return ""

    def backup_restore_workaround(self):
        """Workaround for ND 4.1 backup restore issue.

        On ND 4.1, backup restore does not properly clean up deployed objects.
        This method manually undeploys and deletes all non-system tenant
        templates, schemas, and tenants in the correct dependency order.

        Order:
            0. Undeploy all deployed templates (POST /mso/api/v1/task)
            1. Delete tenant policy templates (DELETE /mso/api/v1/templates/<templateID>)
            2. Delete schemas (DELETE /mso/api/v1/schemas/<schemaID>)
            3. Delete tenants (DELETE /mso/api/v1/tenants/<tenantID>), skip 'common'
        """
        SYSTEM_TENANTS = {"common"}

        # Build site name -> ID mapping
        site_name_to_id = {}
        resp = self.session.get(self.url + "/api/v1/sites")
        if resp.status_code == HTTPStatus.OK:
            data = json.loads(resp.text)
            sites = data.get("sites", []) if isinstance(data, dict) else data
            for site in sites:
                site_name_to_id[site.get("name")] = site.get("id")

        # 0. Undeploy all deployed templates
        resp = self.session.get(self.url + "/mso/api/v1/templates/summaries")
        if resp.status_code != HTTPStatus.OK:
            return "Failed to query template summaries: {} {}".format(
                resp.status_code, resp.text
            )
        templates = json.loads(resp.text)
        if not isinstance(templates, list):
            templates = []

        DEPLOY_STATUSES = {"DEPLOYED", "DEPLOYING", "DEPLOYMENT_SUCCESSFUL"}

        undeployed_any = False
        for template in templates:
            if template.get("templateStatus") not in DEPLOY_STATUSES:
                continue
            schema_id = template.get("schemaId")
            template_name = template.get("templateName", "unknown")
            template_id = template.get("templateId")
            template_type = template.get("templateType")
            site_names = template.get("sites", [])
            site_ids = [
                site_name_to_id[name] for name in site_names if name in site_name_to_id
            ]
            if not site_ids:
                continue
            print(
                "Undeploying template '{}' from sites {}".format(
                    template_name, site_names
                )
            )
            if template_type == "tenantPolicy":
                payload = {
                    "schemaId": schema_id,
                    "templateId": template_id,
                    "undeploy": site_ids,
                }
            else:
                payload = {
                    "schemaId": schema_id,
                    "templateName": template_name,
                    "undeploy": site_ids,
                }
            undeploy_resp = self.session.post(
                self.url + "/mso/api/v1/task?enableVersionCheck=true",
                data=json.dumps(payload),
            )
            if undeploy_resp.status_code not in (
                HTTPStatus.OK,
                HTTPStatus.ACCEPTED,
            ):
                return "Failed to undeploy template '{}': {} {}".format(
                    template_name, undeploy_resp.status_code, undeploy_resp.text
                )
            undeployed_any = True

        # Poll until all templates are UNDEPLOYED
        if undeployed_any:
            elapsed = 0
            timeout = 600
            interval = 10
            while elapsed < timeout:
                time.sleep(interval)
                elapsed += interval
                resp = self.session.get(self.url + "/mso/api/v1/templates/summaries")
                if resp.status_code != HTTPStatus.OK:
                    continue
                summaries = json.loads(resp.text)
                if not isinstance(summaries, list):
                    continue
                pending = [
                    t.get("templateName")
                    for t in summaries
                    if t.get("templateStatus") != "UNDEPLOYED"
                ]
                if not pending:
                    print("All templates undeployed successfully")
                    break
                print(
                    "Waiting for undeploy ({}s): {} still pending".format(
                        elapsed, pending
                    )
                )
            else:
                return "Templates did not reach UNDEPLOYED status within {}s".format(
                    timeout
                )

        # 1. Delete all tenant policy templates
        resp = self.session.get(self.url + "/mso/api/v1/templates/summaries")
        if resp.status_code == HTTPStatus.OK:
            templates = json.loads(resp.text)
            if isinstance(templates, list):
                for template in templates:
                    if template.get("templateType") != "tenantPolicy":
                        continue
                    template_id = template.get("templateId") or template.get("id")
                    template_name = template.get("templateName", "unknown")
                    if template_id:
                        print(
                            "Deleting tenant template '{}' (id: {})".format(
                                template_name, template_id
                            )
                        )
                        del_resp = self.session.delete(
                            self.url + "/mso/api/v1/templates/{}".format(template_id)
                        )
                        if del_resp.status_code not in (
                            HTTPStatus.OK,
                            HTTPStatus.NO_CONTENT,
                        ):
                            return (
                                "Failed to delete tenant template '{}': {} {}".format(
                                    template_name, del_resp.status_code, del_resp.text
                                )
                            )

        # 2. Delete all schemas
        resp = self.session.get(self.url + "/mso/api/v1/schemas/list-identity")
        if resp.status_code == HTTPStatus.OK:
            data = json.loads(resp.text)
            schemas = data.get("schemas", []) if isinstance(data, dict) else data
            for schema in schemas:
                schema_id = schema.get("id")
                schema_name = schema.get("displayName", "unknown")
                if schema_id:
                    print(
                        "Deleting schema '{}' (id: {})".format(schema_name, schema_id)
                    )
                    del_resp = self.session.delete(
                        self.url + "/mso/api/v1/schemas/{}".format(schema_id)
                    )
                    if del_resp.status_code not in (
                        HTTPStatus.OK,
                        HTTPStatus.NO_CONTENT,
                    ):
                        return "Failed to delete schema '{}': {} {}".format(
                            schema_name, del_resp.status_code, del_resp.text
                        )

        # 3. Delete all non-system tenants
        resp = self.session.get(self.url + "/mso/api/v1/tenants")
        if resp.status_code == HTTPStatus.OK:
            data = json.loads(resp.text)
            tenants = data.get("tenants", []) if isinstance(data, dict) else data
            for tenant in tenants:
                tenant_name = tenant.get("name", "")
                tenant_id = tenant.get("id")
                if tenant_name in SYSTEM_TENANTS:
                    print("Skipping system tenant '{}'".format(tenant_name))
                    continue
                if tenant_id:
                    print(
                        "Deleting tenant '{}' (id: {})".format(tenant_name, tenant_id)
                    )
                    del_resp = self.session.delete(
                        self.url
                        + "/mso/api/v1/tenants/{}?msc-only=true".format(tenant_id)
                    )
                    if del_resp.status_code not in (
                        HTTPStatus.OK,
                        HTTPStatus.NO_CONTENT,
                    ):
                        return "Failed to delete tenant '{}': {} {}".format(
                            tenant_name, del_resp.status_code, del_resp.text
                        )

        return ""
