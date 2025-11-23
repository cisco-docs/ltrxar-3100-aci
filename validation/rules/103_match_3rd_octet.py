import re
import ipaddress


class Rule:
    id = "103"
    description = "Verify bridge domain VLAN number matches 3rd octet of IP address"
    severity = "MEDIUM"

    # Regex to extract VLAN number from bridge domain names like BD_VLAN300, BD_VLAN301, etc.
    VLAN_PATTERN = re.compile(r"BD_VLAN(\d+)", re.IGNORECASE)

    @classmethod
    def match(cls, inventory):
        results = []
        try:
            tenants = inventory.get("apic", {}).get("tenants", [])
            if tenants is None:
                tenants = []

            for tenant in tenants:
                tenant_name = tenant.get("name", "Unknown")
                bridge_domains = tenant.get("bridge_domains", [])
                if bridge_domains is None:
                    bridge_domains = []

                for bd in bridge_domains:
                    bd_name = bd.get("name", "")
                    subnets = bd.get("subnets", [])

                    # Skip if no subnets configured
                    if not subnets:
                        continue

                    # Extract VLAN number from BD name
                    vlan_match = cls.VLAN_PATTERN.search(bd_name)
                    if not vlan_match:
                        continue

                    vlan_number = int(vlan_match.group(1))

                    # Check each subnet in the bridge domain
                    for subnet in subnets:
                        ip_address = subnet.get("ip", "")
                        if not ip_address:
                            continue

                        try:
                            # Parse the IP address and extract the 3rd octet
                            network = ipaddress.IPv4Network(ip_address, strict=False)
                            ip_parts = str(network.network_address).split('.')

                            if len(ip_parts) >= 3:
                                third_octet = int(ip_parts[2])

                                # Check if VLAN number matches 3rd octet
                                if vlan_number != third_octet:
                                    results.append(
                                        f"Bridge domain '{bd_name}' in tenant '{tenant_name}' has VLAN number {vlan_number} "
                                        f"that does not match the 3rd octet {third_octet} of IP address '{ip_address}'"
                                    )
                        except (ipaddress.AddressValueError, ValueError, IndexError) as e:
                            # Skip invalid IP addresses
                            continue

        except KeyError:
            pass

        return results
