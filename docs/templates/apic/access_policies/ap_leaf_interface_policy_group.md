# Access Leaf Interface Policy Group

Location in GUI:
`Fabric` » `Access Policies` » `Interfaces` » `Leaf Interfaces` » `Policy Groups`


{{ doc_gen }}

### Examples

Example-1: This example configures a basic access (single link) IPG named `SERVER1`, defining the essential properties of link_level_policy to be `10G` (a user-defined policy), the cdp_policy being set to `CDP-ENABLED`, the lldp_policy being set to `LLDP-ENABLED`, and associating to the aaep named `AAEP1`. The AAEP association is critical since it allows ACI to validate which VLAN pools are allowed on which interface policy groups, linking the access policies configuration chain.

```yaml
apic:
  access_policies:
    leaf_interface_policy_groups:
      - name: SERVER1
        type: access
        link_level_policy: 10G
        cdp_policy: CDP-ENABLED
        lldp_policy: LLDP-ENABLED
        aaep: AAEP1
```

Example-2: This example configures a pair of bundle (PC or vPC) interface policy group, typically seen for HA devices such as firewalls, load balancers, etc. The IPGs in this case are for `Palo-Alto-FW-01` and `Palo-Alto-FW-02`, with each device connecting to a pair of leafs using vPC. Since this is a bundle IPG, the bundle name must be unique per PC/vPC since all interfaces associated to it will become members of the same bundle. It is identified as a bundle IPG since its type is configured as `vpc`. Since the two IPGs are for identical devices, they are identical in configuration. This examlpe makes use of system defined policies, where the cdp_policy is set to `system-cdp-disabled` since these are non-Cisco devices, the lldp_policy is set to `system-lldp-enabled`, and the link_level_policy is configured to `system-link-level-40G-auto` (40G with auto-negotiation on). The IPGs are associated to the relevant AAEP named `AAEP1`.

```yaml
apic:
  access_policies:
    leaf_interface_policy_groups:
      - name: Palo-Alto-FW-01
        type: vpc
        link_level_policy: system-link-level-40G-auto
        cdp_policy: system-cdp-disabled
        lldp_policy: system-lldp-enabled
        aaep: AAEP1
        port_channel_policy: system-lacp-active
      - name: Palo-Alto-FW-02
        type: vpc
        link_level_policy: system-link-level-40G-auto
        cdp_policy: system-cdp-disabled
        lldp_policy: system-lldp-enabled
        aaep: AAEP1
        port_channel_policy: system-lacp-active
```

Example-3: This examlpe demonstrates an IPG for an HPE Synergy blade server chassis, connecting to ACI via its ToR Virtual Connect switches. The IPG is named `HPE-Synergy`, and it builds on the previous examples in that it shows some L2 hardening configuration, which may be required during the migration phase to ensure such a ToR switch does not misbehave (e.g. by causing a loop or participating in STP unexpectedly for example). To achieve this, in addition to the configuration outlined in example-2, this IPG adds an mcp_policy using the `system-mcp-enabled` system policy, a storm_control_policy named `10P` to apply storm control, and an STP policy named `BPDU-FILTER` to discard any unwanted BPDUs.

```yaml
apic:
  access_policies:
    leaf_interface_policy_groups:
      - name: HPE-Synergy
        type: vpc
        link_level_policy: system-link-level-40G-auto
        cdp_policy: system-cdp-disabled
        lldp_policy: system-lldp-enabled
        aaep: AAEP1
        port_channel_policy: system-lacp-active
        mcp_policy: system-mcp-enabled
        storm_control_policy: 10P
        spanning_tree_policy: BPDU-FILTER
```

Example-4: Full example

```yaml
apic:
  access_policies:
    leaf_interface_policy_groups:
      - name: SERVER1
        description: "Server1"
        type: access
        link_level_policy: 10G
        cdp_policy: CDP-ENABLED
        lldp_policy: LLDP-ENABLED
        spanning_tree_policy: BPDU-FILTER
        mcp_policy: MCP-ENABLED
        l2_policy: PORT-LOCAL
        storm_control_policy: 10P
        port_channel_policy: LACP-ACTIVE
        port_channel_member_policy: FAST
        aaep: AAEP1
        netflow_monitor_policies:
          - name: MONITOR1
            ip_filter_type: ipv6
        macsec_interface_policy: MACSEC_INT1
```
