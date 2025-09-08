class Rule:
    id = "301"
    description = "Verify Infra VLAN configuration for AAEPs"
    severity = "HIGH"

    @classmethod
    def match(cls, inventory):
        results = []
        try:
            aaeps = (
                inventory.get("apic", {}).get("access_policies", {}).get("aaeps", [])
            )
            if aaeps is None:
                aaeps = []

            has_infra_aaep = False
            for aaep in aaeps:
                if aaep.get("infra_vlan", False):
                    has_infra_aaep = True
            if has_infra_aaep:
                if (
                    inventory.get("apic", {})
                    .get("access_policies", {})
                    .get("infra_vlan", 0)
                    == 0
                ):
                    results.append("apic.access_policies.infra_vlan - missing")
        except KeyError:
            pass
        return results
