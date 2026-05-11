# -*- coding: utf-8 -*-
"""
Validation Rule: Filter Port Protocol Requirement

Ensures that filter entries with non-well-known port specifications have an
explicit protocol of TCP or UDP specified.

Well-known ports (http, https, ssh, dns, smtp, pop3, rtsp, ftpData) automatically
default to TCP via the module, so explicit protocol is not required for these.

For non-well-known ports, best practice dictates that protocol be explicitly defined.
"""

# Well-known ports that have implied protocols (all default to TCP in the module)
# Maps port names to their numeric values
WELL_KNOWN_PORTS = {
    "ftpdata": 20,
    "ssh": 22,
    "smtp": 25,
    "dns": 53,
    "http": 80,
    "pop3": 110,
    "https": 443,
    "rtsp": 554,
}

# Create reverse mapping (number -> name) and set of all well-known values
WELL_KNOWN_PORT_NUMBERS = set(WELL_KNOWN_PORTS.values())
WELL_KNOWN_PORT_NAMES = set(WELL_KNOWN_PORTS.keys())


class Rule:
    id = "311"
    description = (
        "Verify TCP or UDP protocol is specified for non-well-known ports in filters"
    )
    severity = "HIGH"

    # Valid protocols when ports are specified
    VALID_PORT_PROTOCOLS = {"tcp", "udp", 6, 17}  # 6 = TCP, 17 = UDP

    @classmethod
    def _is_well_known_port(cls, port_value):
        """Check if a port value is a well-known port (by name or number)."""
        if port_value is None:
            return True  # No port specified is OK

        # Check by name (case-insensitive)
        if isinstance(port_value, str):
            if port_value.lower() in WELL_KNOWN_PORT_NAMES:
                return True
            # Try to parse as number
            try:
                port_num = int(port_value)
                return port_num in WELL_KNOWN_PORT_NUMBERS
            except ValueError:
                # Unknown string port name - not well-known
                return False

        # Check by number
        if isinstance(port_value, int):
            return port_value in WELL_KNOWN_PORT_NUMBERS

        return False

    @classmethod
    def match(cls, inventory):
        results = []

        # Check APIC tenants
        tenants = inventory.get("apic", {}).get("tenants", [])
        if tenants is None:
            tenants = []

        for tenant in tenants:
            tenant_name = tenant.get("name", "unknown")
            filters = tenant.get("filters", [])
            if filters is None:
                filters = []

            for filter_obj in filters:
                filter_name = filter_obj.get("name", "unknown")
                entries = filter_obj.get("entries", [])
                if entries is None:
                    entries = []

                for entry in entries:
                    entry_name = entry.get("name", "unknown")
                    path = f"apic.tenants[{tenant_name}].filters[{filter_name}].entries[{entry_name}]"

                    # Check if any port field is defined
                    port_fields = [
                        ("source_from_port", entry.get("source_from_port")),
                        ("source_to_port", entry.get("source_to_port")),
                        ("destination_from_port", entry.get("destination_from_port")),
                        ("destination_to_port", entry.get("destination_to_port")),
                    ]

                    defined_ports = [
                        (name, val) for name, val in port_fields if val is not None
                    ]

                    if not defined_ports:
                        continue

                    protocol = entry.get("protocol")

                    # Normalize protocol for comparison
                    protocol_normalized = protocol
                    if isinstance(protocol, str):
                        protocol_normalized = protocol.lower()

                    # Check if protocol is explicitly set and valid
                    if protocol_normalized in cls.VALID_PORT_PROTOCOLS:
                        continue  # Protocol is valid, no issue

                    # Protocol is not set or invalid - check if all ports are well-known
                    non_well_known_ports = [
                        (name, val)
                        for name, val in defined_ports
                        if not cls._is_well_known_port(val)
                    ]

                    if non_well_known_ports:
                        # Has non-well-known ports without valid protocol
                        port_names = ", ".join(
                            f"{name}={val}" for name, val in non_well_known_ports
                        )
                        if protocol is None:
                            results.append(
                                f"{path} - Port fields contain non-well-known port(s) ({port_names}) "
                                f"but protocol is not specified. Best practice dictates that protocol "
                                f"(tcp/udp) be explicitly defined when using non-well-known port numbers."
                            )
                        else:
                            results.append(
                                f"{path} - Port fields contain non-well-known port(s) ({port_names}) "
                                f"but protocol is '{protocol}' which is not valid for port-based filtering. "
                                f"Protocol must be 'tcp' or 'udp' when port fields are used."
                            )

        return results
