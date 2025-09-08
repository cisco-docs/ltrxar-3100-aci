class Rule:
    id = "204"
    description = "Verify Access Leaf Interface Policy Group references"
    severity = "HIGH"

    @classmethod
    def match(cls, inventory):
        results = []
        try:
            policy_groups = (
                inventory.get("apic", {})
                .get("access_policies", {})
                .get("leaf_interface_policy_groups", [])
            )
            if policy_groups is None:
                policy_groups = []

            keys = [str(obj.get("name")) for obj in policy_groups]

            nodes = (
                inventory.get("apic", {}).get("interface_policies", {}).get("nodes", [])
            )
            # If an xxx.nac.yaml config file includes the 'nodes' key without
            # providing a corresponding value, then the *nodes* variable will
            # be `None` (the 'nodes' key will be in the inventory `dict`, so
            # rather than the line above assigning the *default* argument = [],
            # in the *get()* method, it will take the value from the `dict`,
            # which is `None`).
            # Therefore, if *nodes* is `None`, we will assign it an empty `list`
            if nodes is None:
                nodes = []

            np_nodes = (
                inventory.get("apic", {}).get("node_policies", {}).get("nodes", [])
            )
            # For the same reasons as the *nodes* variable above, *np_nodes*
            # may also be `None`. If it is, we will assign it an empty `list`
            if np_nodes is None:
                np_nodes = []

            for node in nodes:
                for np_node in np_nodes:
                    if node["id"] == np_node["id"] and np_node.get("role") == "leaf":
                        interfaces = node.get("interfaces", [])
                        if interfaces is None:
                            interfaces = []
                        for interface in interfaces:
                            policy = interface.get("policy_group")
                            if policy and policy not in keys:
                                results.append(
                                    "apic.interface_policies.nodes.interfaces.policy_group"
                                    + " - "
                                    + str(interface.get("policy_group"))
                                )
        except KeyError:
            pass
        return results
