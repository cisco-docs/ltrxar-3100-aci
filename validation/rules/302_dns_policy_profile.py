class Rule:
    id = "302"
    description = "Verify the DNS Policy Profiles"
    severity = "HIGH"

    @classmethod
    def match(cls, inventory):
        results = []
        try:
            dns_policies = (
                inventory.get("apic", {})
                .get("fabric_policies", {})
                .get("dns_policies", [])
            )
            if dns_policies is None:
                dns_policies = []

            for x in dns_policies:
                if len(x.setdefault("providers", [])) > 2:
                    results.append(
                        "apic.fabric_policies.dns_policies.providers - "
                        + x.get("name")
                        + " has more than 2 DNS providers"
                    )
        except KeyError:
            pass
        return results
