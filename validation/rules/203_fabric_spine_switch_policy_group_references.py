class Rule:
    id = "203"
    description = "Verify Fabric Spine Switch Policy Group references"
    severity = "HIGH"

    @classmethod
    def match(cls, inventory):
        results = []
        try:
            policy_groups = (
                inventory.get("apic", {})
                .get("fabric_policies", {})
                .get("spine_switch_policy_groups", [])
            )
            if policy_groups is None:
                policy_groups = []

            keys = [str(obj.get("name")) for obj in policy_groups]

            nodes = inventory.get("apic", {}).get("node_policies", {}).get("nodes", [])
            # If an xxx.nac.yaml config file includes the 'nodes' key without
            # providing a corresponding value, then the *nodes* variable will
            # be `None` (the 'nodes' key will be in the inventory `dict`, so
            # rather than the line above assigning the *default* argument = [],
            # in the *get()* method, it will take the value from the `dict`,
            # which is `None`).
            # Therefore, if *nodes* is `None`, we will assign it an empty `list`
            if nodes is None:
                nodes = []

            for node in nodes:
                if node.get("role") == "spine":
                    policy = node.get("fabric_policy_group")
                    if policy and policy not in keys:
                        results.append(
                            "apic.node_policies.nodes.fabric_policy_group"
                            + " - "
                            + str(node.get("fabric_policy_group"))
                        )
        except KeyError:
            pass
        return results
