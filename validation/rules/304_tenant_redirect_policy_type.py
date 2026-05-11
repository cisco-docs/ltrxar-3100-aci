class Rule:
    id = "304"
    description = "Verify if destType match destinations for redirect policy"
    severity = "HIGH"

    @classmethod
    def match(cls, inventory):
        results = []
        try:
            has_redirect_policy = False
            tenants = inventory.get("apic", {}).get("tenants", [])
            if tenants is None:
                tenants = []

            for tenant in tenants:
                for redirect_policies in tenant.get("services", {}).get(
                    "redirect_policies", {}
                ):
                    if redirect_policies is None:
                        redirect_policies = {}
                    if redirect_policies.get("type", ""):
                        has_redirect_policy = True

            if has_redirect_policy:
                for tenant in tenants:
                    for redirect_policies in tenant.get("services", {}).get(
                        "redirect_policies", {}
                    ):
                        if redirect_policies.get(
                            "type", "L3"
                        ) == "L3" and redirect_policies.get("l1l2_destinations", {}):
                            results.append(
                                "l1l2_destinations should have DestType as L1/L2"
                            )

                        if redirect_policies.get("type", "L3") in [
                            "L1",
                            "L2",
                        ] and redirect_policies.get("l3_destinations", {}):
                            results.append("l3_destinations should have DestType as L3")

        except KeyError:
            pass
        return results
