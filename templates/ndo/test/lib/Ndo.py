# -*- coding: utf-8 -*-

# Copyright: (c) 2023, Daniel Schmidt <danischm@cisco.com>

# mypy: ignore-errors

from robot.api.deco import keyword
from robot.libraries.BuiltIn import BuiltIn

__version__ = "0.2.0"

API_ENDPOINT_MAPPINGS = {
    "users": {
        "container": None,
        "key": "loginID",
        "id_key": "userID",
        "api_version": "v2",
    },
    "sites": {
        "container": "sites",
        "key": "common.name",
        "api_version": "v2",
    },
    "tenants": {
        "container": "tenants",
        "key": "name",
    },
    "schemas/list-identity": {
        "container": "schemas",
        "key": "displayName",
    },
    "templates/summaries": {
        "container": None,
        "key": "templateName",
        "id_key": "templateId",
    },
    "schemas/templates/anps/epgs": {
        "container": "epg",
        "key": "name",
        "id_key": "uuid",
        # This will require special handling for hierarchical lookup
    },
    "schemas/templates/externalEpgs": {
        "container": "externalEpg",
        "key": "name",
        "id_key": "uuid",
        # This will require special handling for hierarchical lookup
    },
}


class Ndo(object):
    ROBOT_LIBRARY_VERSION = __version__
    ROBOT_LIBRARY_SCOPE = "GLOBAL"

    def __init__(self, session_name: str):
        self.session_name = session_name
        self.lookup_cache = {}
        self.builtin = BuiltIn()

    def _query_objs(self, path, key=None, api_version="v1", **kwargs):
        """Retrieve objects via REST GET and optionally filter by key"""

        # Handle hierarchical EPG and external EPG lookups
        if path in ["schemas/templates/anps/epgs", "schemas/templates/externalEpgs"]:
            return self._query_nested_epg(key, path)

        found = []
        resp = self.builtin.run_keyword(
            "Get On Session", self.session_name, "/mso/api/" + api_version + "/" + path
        )
        objs = resp.json()

        if objs == {}:
            return found

        if key is not None and key not in objs:
            raise Exception("Key '{}' missing from data".format(key))

        if key is None and isinstance(objs, list):
            return objs
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

    def _query_nested_epg(self, search_key, path):
        """Handle nested EPG/external EPG queries for Robot Framework tests"""
        if search_key is None:
            return []

        # Parse the composite key based on path type
        if path == "schemas/templates/anps/epgs":
            # Format: "schema_name/template_name/anp_name/epg_name"
            key_parts = search_key.split("/")
            if len(key_parts) != 4:
                raise Exception(
                    "EPG key must be in format 'schema_name/template_name/anp_name/epg_name', got: '{}'".format(
                        search_key
                    )
                )
            schema_name, template_name, anp_name, epg_name = key_parts
        elif path == "schemas/templates/externalEpgs":
            # Format: "schema_name/template_name/external_epg_name"
            key_parts = search_key.split("/")
            if len(key_parts) != 3:
                raise Exception(
                    "External EPG key must be in format 'schema_name/template_name/external_epg_name', got: '{}'".format(
                        search_key
                    )
                )
            schema_name, template_name, external_epg_name = key_parts
        else:
            raise Exception("Unsupported path type: '{}'".format(path))

        # First resolve schema_name to schema_id using existing lookup
        schema_obj = self._lookup("schemas/list-identity", schema_name, use_cache=True)
        if not schema_obj or "id" not in schema_obj:
            raise Exception("Failed to resolve schema '{}' to ID".format(schema_name))
        schema_id = schema_obj["id"]

        # Construct the full API path
        if path == "schemas/templates/anps/epgs":
            api_path = "schemas/{}/templates/{}/anps/{}/epgs/{}".format(
                schema_id, template_name, anp_name, epg_name
            )
        else:  # externalEpgs
            api_path = "schemas/{}/templates/{}/externalEpgs/{}".format(
                schema_id, template_name, external_epg_name
            )

        # Make the API call
        resp = self.builtin.run_keyword(
            "Get On Session", self.session_name, "/mso/api/v1/" + api_path
        )

        if resp.status_code != 200:
            raise Exception(
                "Failed to query {}: status {}, response: {}".format(
                    api_path, resp.status_code, resp.text
                )
            )

        result = resp.json()

        # Return as a single-item list to match expected format
        # The response structure is {"epg": {...}} or {"externalEpg": {...}}
        container_key = (
            "epg" if path == "schemas/templates/anps/epgs" else "externalEpg"
        )
        if container_key in result:
            return [result[container_key]]
        else:
            return []

    def _lookup(self, path, search_key, use_cache=True):
        """Lookup object by key either from a cache or via REST GET"""

        def check_cache(key):
            for obj in self.lookup_cache.get(path, []):
                keys = key.split(".")
                if search_key is None or obj.get(key) == search_key:
                    return obj
                elif len(keys) == 2 and obj.get(keys[0]).get(keys[1]) == search_key:
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
        self.lookup_cache[path] = self._query_objs(
            path,
            key=container,
            api_version=API_ENDPOINT_MAPPINGS.get(path, {}).get("api_version", "v1"),
        )
        obj = check_cache(key)
        if obj:
            return obj
        return {}

    @keyword("NDO Lookup")
    def lookup(self, path, key):
        key_id = API_ENDPOINT_MAPPINGS.get(path, {}).get("id_key", "id")
        return self._lookup(path, key).get(key_id)
