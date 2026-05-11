# -*- coding: utf-8 -*-
"""
Validation Rule: Service Graph Template Validations

This module validates the configuration of service graph templates under
apic.tenants.services.service_graph_templates. It ensures:
1. Either 'device' (dict) or 'devices' (list) is defined, but not both (mutually exclusive)
2. No duplicate node_name values exist across devices in a service graph template
3. Each device name is properly referenced in the connections list
4. EPG-Consumer and EPG-Provider are correctly placed in the connections list

"""

from functools import wraps
from typing import Any, Callable

# Registry of validation functions
_validations: list[Callable] = []


def validation(func: Callable) -> Callable:
    """
    Decorator to register a validation function.

    Each validation function receives:
        - sg_template: dict - The service graph template being validated
        - tenant_name: str - Name of the tenant containing the template
        - path: str - Full path to the service graph template for error messages

    Returns:
        List of error messages (empty if validation passes)
    """

    @wraps(func)
    def wrapper(*args, **kwargs):
        return func(*args, **kwargs)

    _validations.append(wrapper)
    return wrapper


def _get_safe_list(data: dict, key: str) -> list:
    """
    Safely retrieve a list from a dictionary, returning empty list if None or missing.

    Args:
        data: Dictionary to retrieve from
        key: Key to look up

    Returns:
        List value or empty list if None/missing
    """
    value = data.get(key, [])
    return value if value is not None else []


def _build_devices_list(sg_template: dict, tenant_name: str) -> list[dict]:
    """
    Build a normalized devices list from a service graph template.

    If 'devices' (list) is defined, iterate over it and normalize each device:
        - devices[]['name'] = device['name']
        - devices[]['node_name'] = device['node_name'] if exists, else device['name']
        - devices[]['tenant'] = device['tenant'] if exists, else tenant_name

    Args:
        sg_template: The service graph template dictionary
        tenant_name: Name of the tenant containing the template

    Returns:
        Normalized list of device dictionaries with name, node_name, and tenant
    """
    devices_list = _get_safe_list(sg_template, "devices")
    normalized_devices = []

    for device in devices_list:
        device_name = device.get("name", "")
        normalized_device = {
            "name": device_name,
            "node_name": device.get("node_name", device_name),
            "tenant": device.get("tenant", tenant_name),
        }
        normalized_devices.append(normalized_device)

    return normalized_devices


def _count_device_references_in_connections(
    connections: list[dict],
) -> dict[str, dict[str, int]]:
    """
    Count how many times each device name appears in each connection field.

    Iterates through all connections and counts occurrences of each device name
    in consumer_node, provider_node, and copy_node fields. Note that connections
    reference device names, not node_names (the Jinja2 template resolves names
    to node_names during rendering).

    Args:
        connections: List of connection dictionaries from the service graph template

    Returns:
        Dictionary mapping device name to a dict of field counts:
        {
            'device_name': {
                'consumer_node': count,
                'provider_node': count,
                'copy_node': count
            }
        }
    """
    device_counts: dict[str, dict[str, int]] = {}

    for connection in connections:
        for field in ["consumer_node", "provider_node", "copy_node"]:
            device_name = connection.get(field)
            if device_name is not None:
                if device_name not in device_counts:
                    device_counts[device_name] = {
                        "consumer_node": 0,
                        "provider_node": 0,
                        "copy_node": 0,
                    }
                device_counts[device_name][field] += 1

    return device_counts


@validation
def validate_device_mutual_exclusivity(
    sg_template: dict, tenant_name: str, path: str
) -> list[str]:
    """
    Validation 1: Verify that 'device' and 'devices' are mutually exclusive.

    A service graph template MUST have either:
    - 'device' (single dict): For simple single-device service graphs
    - 'devices' (list of dicts): For multi-device service graphs

    But NEVER both, and at least one must be defined.

    Args:
        sg_template: The service graph template dictionary
        tenant_name: Name of the tenant (unused in this validation)
        path: Full path to the template for error messages

    Returns:
        List of error messages if validation fails, empty list otherwise
    """
    results = []

    has_device = "device" in sg_template and sg_template.get("device") is not None
    has_devices = "devices" in sg_template and sg_template.get("devices") is not None

    if has_device and has_devices:
        results.append(
            f"{path} - Both 'device' and 'devices' are defined. "
            f"These are mutually exclusive; use only one."
        )
    elif not has_device and not has_devices:
        results.append(
            f"{path} - Neither 'device' nor 'devices' is defined. "
            f"At least one must be specified."
        )

    return results


@validation
def validate_unique_node_names(
    sg_template: dict, tenant_name: str, path: str
) -> list[str]:
    """
    Validation 2: Verify that node_name values are unique within a service graph template.

    When using 'devices' (list), each device's node_name must be unique within
    that service graph template. The node_name defaults to the device name if
    not explicitly specified.

    Args:
        sg_template: The service graph template dictionary
        tenant_name: Name of the tenant for building normalized devices
        path: Full path to the template for error messages

    Returns:
        List of error messages if validation fails, empty list otherwise
    """
    results = []

    # Only validate if 'devices' list is defined
    if "devices" not in sg_template or sg_template.get("devices") is None:
        return results

    devices = _build_devices_list(sg_template, tenant_name)

    # Track node_names and their occurrences
    node_name_counts: dict[str, list[str]] = {}
    for device in devices:
        node_name = device["node_name"]
        device_name = device["name"]
        if node_name not in node_name_counts:
            node_name_counts[node_name] = []
        node_name_counts[node_name].append(device_name)

    # Report duplicates
    for node_name, device_names in node_name_counts.items():
        if len(device_names) > 1:
            results.append(
                f"{path}.devices - Duplicate node_name '{node_name}' found "
                f"in devices: {device_names}. Each node_name must be unique."
            )

    return results


@validation
def validate_device_names_in_connections(
    sg_template: dict, tenant_name: str, path: str
) -> list[str]:
    """
    Validation 3: Verify that each device name is properly referenced in connections.

    When using 'devices' (list), each device's name MUST appear in the connections
    list following one of these patterns:
    - As 'copy_node' at least ONCE in the connections list (can appear multiple times), OR
    - As both 'consumer_node' AND 'provider_node', each exactly ONCE in the entire list

    Note: Connections reference device names (not node_names). The Jinja2 template
    resolves device names to their node_names during rendering.

    This ensures every device in the service graph is properly wired in the topology.

    Args:
        sg_template: The service graph template dictionary
        tenant_name: Name of the tenant for building normalized devices
        path: Full path to the template for error messages

    Returns:
        List of error messages if validation fails, empty list otherwise
    """
    results = []

    # Only validate if 'devices' list is defined
    if "devices" not in sg_template or sg_template.get("devices") is None:
        return results

    connections = _get_safe_list(sg_template, "connections")
    if not connections:
        return results

    devices = _build_devices_list(sg_template, tenant_name)
    device_counts = _count_device_references_in_connections(connections)

    for device in devices:
        device_name = device["name"]
        counts = device_counts.get(
            device_name,
            {
                "consumer_node": 0,
                "provider_node": 0,
                "copy_node": 0,
            },
        )

        consumer_count = counts["consumer_node"]
        provider_count = counts["provider_node"]
        copy_count = counts["copy_node"]

        # Check if device is used as copy_node at least once (can be multiple times)
        is_copy_device = copy_count >= 1 and consumer_count == 0 and provider_count == 0

        # Check if device is used as both consumer_node and provider_node exactly once each
        is_inline_device = (
            consumer_count == 1 and provider_count == 1 and copy_count == 0
        )

        if not is_copy_device and not is_inline_device:
            # Build detailed error message
            if copy_count > 0 and (consumer_count > 0 or provider_count > 0):
                results.append(
                    f"{path}.connections - Device '{device_name}' is used as both "
                    f"copy_node ({copy_count}x) and consumer_node/provider_node. "
                    f"It must be used ONLY as copy_node, OR as both "
                    f"consumer_node and provider_node once each."
                )
            elif copy_count == 0 and (consumer_count != 1 or provider_count != 1):
                details = []
                if consumer_count != 1:
                    details.append(f"consumer_node {consumer_count}x")
                if provider_count != 1:
                    details.append(f"provider_node {provider_count}x")
                results.append(
                    f"{path}.connections - Device '{device_name}' has invalid "
                    f"references ({', '.join(details)}). It must appear as copy_node "
                    f"at least once, OR as both consumer_node and provider_node "
                    f"exactly once each."
                )

    return results


@validation
def validate_epg_consumer_provider_placement(
    sg_template: dict, tenant_name: str, path: str
) -> list[str]:
    """
    Validation 4: Verify EPG-Consumer and EPG-Provider are correctly placed in connections.

    The reserved names 'EPG-Consumer' and 'EPG-Provider' have strict placement rules:

    EPG-Consumer:
    - MUST be defined exactly once as 'consumer_node' in the connections list
    - MUST NOT be defined as 'provider_node' anywhere in the list
    - MUST NOT be defined as 'copy_node' anywhere in the list

    EPG-Provider:
    - MUST be defined exactly once as 'provider_node' in the connections list
    - MUST NOT be defined as 'consumer_node' anywhere in the list
    - MUST NOT be defined as 'copy_node' anywhere in the list

    Args:
        sg_template: The service graph template dictionary
        tenant_name: Name of the tenant (unused in this validation)
        path: Full path to the template for error messages

    Returns:
        List of error messages if validation fails, empty list otherwise
    """
    results = []

    # Only validate if 'devices' list is defined (connections only apply to multi-device)
    if "devices" not in sg_template or sg_template.get("devices") is None:
        return results

    connections = _get_safe_list(sg_template, "connections")
    if not connections:
        return results

    device_counts = _count_device_references_in_connections(connections)

    # Validate EPG-Consumer
    epg_consumer = "EPG-Consumer"
    consumer_counts = device_counts.get(
        epg_consumer,
        {
            "consumer_node": 0,
            "provider_node": 0,
            "copy_node": 0,
        },
    )

    if consumer_counts["consumer_node"] != 1:
        results.append(
            f"{path}.connections - '{epg_consumer}' must be defined exactly once "
            f"as 'consumer_node', but found {consumer_counts['consumer_node']} "
            f"occurrence(s)."
        )

    if consumer_counts["provider_node"] > 0:
        results.append(
            f"{path}.connections - '{epg_consumer}' must NOT be defined as "
            f"'provider_node', but found {consumer_counts['provider_node']} "
            f"occurrence(s)."
        )

    if consumer_counts["copy_node"] > 0:
        results.append(
            f"{path}.connections - '{epg_consumer}' must NOT be defined as "
            f"'copy_node', but found {consumer_counts['copy_node']} occurrence(s)."
        )

    # Validate EPG-Provider
    epg_provider = "EPG-Provider"
    provider_counts = device_counts.get(
        epg_provider,
        {
            "consumer_node": 0,
            "provider_node": 0,
            "copy_node": 0,
        },
    )

    if provider_counts["provider_node"] != 1:
        results.append(
            f"{path}.connections - '{epg_provider}' must be defined exactly once "
            f"as 'provider_node', but found {provider_counts['provider_node']} "
            f"occurrence(s)."
        )

    if provider_counts["consumer_node"] > 0:
        results.append(
            f"{path}.connections - '{epg_provider}' must NOT be defined as "
            f"'consumer_node', but found {provider_counts['consumer_node']} "
            f"occurrence(s)."
        )

    if provider_counts["copy_node"] > 0:
        results.append(
            f"{path}.connections - '{epg_provider}' must NOT be defined as "
            f"'copy_node', but found {provider_counts['copy_node']} occurrence(s)."
        )

    return results


class Rule:
    """
    Validation rule for service graph templates.

    This rule validates the configuration under apic.tenants.services.service_graph_templates
    using a modular validation approach where each validation is implemented as a
    separate decorated function.

    Validations performed:
    1. Mutual exclusivity of 'device' and 'devices' fields
    2. Uniqueness of node_name values within the devices list
    3. Each device name is properly referenced in connections
    4. EPG-Consumer and EPG-Provider are correctly placed in connections
    """

    id = "313"
    description = "Verify service graph template configurations"
    severity = "HIGH"

    @classmethod
    def match(cls, inventory: dict[str, Any]) -> list[str]:
        """
        Main validation entry point.

        Iterates through all tenants and their service graph templates,
        running all registered validation functions on each template.

        Args:
            inventory: The complete NAC YAML data model as a dict

        Returns:
            List of error message strings. Empty list = no errors.
        """
        results = []

        try:
            tenants = inventory.get("apic", {}).get("tenants", [])
            if tenants is None:
                tenants = []

            for tenant in tenants:
                tenant_name = tenant.get("name", "unknown")

                services = tenant.get("services", {})
                if services is None:
                    services = {}

                sg_templates = services.get("service_graph_templates", [])
                if sg_templates is None:
                    sg_templates = []

                for sg_template in sg_templates:
                    template_name = sg_template.get("name", "unknown")
                    path = (
                        f"apic.tenants[{tenant_name}].services."
                        f"service_graph_templates[{template_name}]"
                    )

                    # Run all registered validations
                    for validation_func in _validations:
                        errors = validation_func(sg_template, tenant_name, path)
                        results.extend(errors)

        except KeyError:
            pass

        return results
