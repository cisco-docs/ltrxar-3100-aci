class Rule:
    id = "312"
    description = "Verify VPC and PC channel node IDs can be resolved"
    severity = "HIGH"

    # Paths where VPC/PC channels can be used with channel and optional node_id/node2_id
    channel_paths = [
        "apic.tenants.application_profiles.endpoint_groups.static_ports",
        "apic.tenants.application_profiles.endpoint_groups.static_endpoints",
        "apic.tenants.l3outs.nodes.interfaces",
        "apic.tenants.l3outs.node_profiles.interface_profiles.interfaces",
        "apic.tenants.services.l4l7_devices.concrete_devices.interfaces",
        "apic.access_policies.span.source_groups.sources.access_paths",
        "apic.access_policies.vspan.sessions.sources.access_paths",
    ]

    @classmethod
    def get_policy_groups_by_type(cls, inventory):
        """
        Get interface policy groups from access_policies grouped by type.
        Returns a tuple of (vpc_groups set, pc_groups set).
        """
        vpc_groups = set()
        pc_groups = set()
        policy_groups = (
            inventory.get("apic", {})
            .get("access_policies", {})
            .get("leaf_interface_policy_groups", [])
        )
        if policy_groups is None:
            policy_groups = []

        for pg in policy_groups:
            pg_type = pg.get("type")
            pg_name = pg.get("name")
            if pg_type == "vpc":
                vpc_groups.add(pg_name)
            elif pg_type == "pc":
                pc_groups.add(pg_name)

        return vpc_groups, pc_groups

    @classmethod
    def get_node_assignments(cls, inventory):
        """
        Get node assignments for policy groups from interface_policies.
        Returns a dict mapping policy group name to a set of node IDs where it's assigned.
        """
        node_assignments = {}
        nodes = inventory.get("apic", {}).get("interface_policies", {}).get("nodes", [])
        if nodes is None:
            nodes = []

        for node in nodes:
            node_id = node.get("id")
            if node_id is None:
                continue

            # Check regular interfaces
            interfaces = node.get("interfaces", [])
            if interfaces is None:
                interfaces = []
            for interface in interfaces:
                policy_group = interface.get("policy_group")
                if policy_group:
                    if policy_group not in node_assignments:
                        node_assignments[policy_group] = set()
                    node_assignments[policy_group].add(node_id)

            # Check FEX interfaces
            fexes = node.get("fexes", [])
            if fexes is None:
                fexes = []
            for fex in fexes:
                fex_interfaces = fex.get("interfaces", [])
                if fex_interfaces is None:
                    fex_interfaces = []
                for interface in fex_interfaces:
                    policy_group = interface.get("policy_group")
                    if policy_group:
                        if policy_group not in node_assignments:
                            node_assignments[policy_group] = set()
                        node_assignments[policy_group].add(node_id)

        return node_assignments

    @classmethod
    def traverse_path(
        cls,
        inventory,
        path_elements,
        current_path,
        vpc_groups,
        pc_groups,
        node_assignments,
    ):
        """
        Recursively traverse the inventory following the path and check for channel resolution.
        Returns a list of error messages.
        """
        results = []

        if not path_elements:
            return results

        current_element = path_elements[0]
        remaining_elements = path_elements[1:]

        if isinstance(inventory, dict):
            next_inv = inventory.get(current_element)
            if next_inv is not None:
                if remaining_elements:
                    results.extend(
                        cls.traverse_path(
                            next_inv,
                            remaining_elements,
                            f"{current_path}.{current_element}",
                            vpc_groups,
                            pc_groups,
                            node_assignments,
                        )
                    )
                elif isinstance(next_inv, list):
                    # We've reached the target list, check each item
                    for idx, item in enumerate(next_inv):
                        error = cls.check_channel(
                            item,
                            f"{current_path}.{current_element}[{idx}]",
                            vpc_groups,
                            pc_groups,
                            node_assignments,
                        )
                        if error:
                            results.append(error)
        elif isinstance(inventory, list):
            for idx, item in enumerate(inventory):
                results.extend(
                    cls.traverse_path(
                        item,
                        path_elements,
                        f"{current_path}[{idx}]",
                        vpc_groups,
                        pc_groups,
                        node_assignments,
                    )
                )

        return results

    @classmethod
    def check_channel(cls, item, path, vpc_groups, pc_groups, node_assignments):
        """
        Check if a VPC or PC channel reference can be resolved.
        - VPC channels require exactly 2 nodes or explicit node_id/node2_id
        - PC channels require exactly 1 node or explicit node_id
        Returns an error message if it cannot be resolved, None otherwise.
        """
        if not isinstance(item, dict):
            return None

        channel = item.get("channel")
        if not channel:
            return None

        # Check if this channel is a VPC or PC - either by explicit type or by policy group lookup
        explicit_type = item.get("type")
        is_vpc = explicit_type == "vpc" or (
            explicit_type is None and channel in vpc_groups
        )
        is_pc = explicit_type == "pc" or (
            explicit_type is None and channel in pc_groups
        )

        if is_vpc:
            return cls._check_vpc_channel(item, path, channel, node_assignments)
        elif is_pc:
            return cls._check_pc_channel(item, path, channel, node_assignments)

        # Not a VPC or PC (could be access or undefined), skip
        return None

    @classmethod
    def _check_vpc_channel(cls, item, path, channel, node_assignments):
        """
        Validate VPC channel can be resolved to exactly 2 nodes.
        """
        node_id = item.get("node_id")
        node2_id = item.get("node2_id")

        if node_id is not None and node2_id is not None:
            # Both node IDs are explicitly defined, no issue
            return None

        # Check if this VPC can be resolved from interface_policies
        assigned_nodes = node_assignments.get(channel, set())

        if len(assigned_nodes) == 2:
            # VPC is assigned to exactly 2 nodes, can be resolved
            return None

        if len(assigned_nodes) == 0:
            return (
                f"{path} - VPC channel '{channel}' cannot be resolved: "
                f"not found in apic.interface_policies.nodes and "
                f"node_id/node2_id are not explicitly defined"
            )
        elif len(assigned_nodes) == 1:
            return (
                f"{path} - VPC channel '{channel}' cannot be resolved: "
                f"only assigned to 1 node ({list(assigned_nodes)[0]}) in "
                f"apic.interface_policies.nodes, expected 2 nodes or "
                f"explicit node_id/node2_id definition"
            )
        else:
            return (
                f"{path} - VPC channel '{channel}' cannot be resolved: "
                f"assigned to {len(assigned_nodes)} nodes ({sorted(assigned_nodes)}) in "
                f"apic.interface_policies.nodes, expected exactly 2 nodes or "
                f"explicit node_id/node2_id definition"
            )

    @classmethod
    def _check_pc_channel(cls, item, path, channel, node_assignments):
        """
        Validate PC channel can be resolved to exactly 1 node.
        """
        node_id = item.get("node_id")

        if node_id is not None:
            # node_id is explicitly defined, no issue
            return None

        # Check if this PC can be resolved from interface_policies
        assigned_nodes = node_assignments.get(channel, set())

        if len(assigned_nodes) == 1:
            # PC is assigned to exactly 1 node, can be resolved
            return None

        if len(assigned_nodes) == 0:
            return (
                f"{path} - PC channel '{channel}' cannot be resolved: "
                f"not found in apic.interface_policies.nodes and "
                f"node_id is not explicitly defined"
            )
        else:
            return (
                f"{path} - PC channel '{channel}' cannot be resolved: "
                f"assigned to {len(assigned_nodes)} nodes ({sorted(assigned_nodes)}) in "
                f"apic.interface_policies.nodes, expected exactly 1 node or "
                f"explicit node_id definition"
            )

    @classmethod
    def match(cls, inventory):
        results = []

        # Get all VPC and PC policy groups from access_policies
        vpc_groups, pc_groups = cls.get_policy_groups_by_type(inventory)

        # Get node assignments for policy groups from interface_policies
        node_assignments = cls.get_node_assignments(inventory)

        # Check each path where VPC/PC channels can be used
        for path in cls.channel_paths:
            path_elements = path.split(".")
            results.extend(
                cls.traverse_path(
                    inventory,
                    path_elements,
                    "",
                    vpc_groups,
                    pc_groups,
                    node_assignments,
                )
            )

        return results
