# Access Leaf Switch Profile

Leaf Switch Profiles can either be auto-generated (one per leaf) by providing a naming convention, or can be system-generated (one per leaf), or can be defined explicitly. In case of auto-generated profiles the following placeholders can be used when defining the naming convention:

* `\\g<id>`: gets replaced by the respective leaf node ID
* `\\g<name>`: gets replaced by the respective leaf hostname

Location in GUI:
`Fabric` » `Access Policies` » `Switches` » `Leaf Switches` » `Profiles`


{{ doc_gen }}

### Examples

Auto-generated profiles:

```yaml
apic:
  auto_generate_access_leaf_switch_interface_profiles: true
  access_policies:
    leaf_switch_profile_name: "LEAF\\g<id>"
    leaf_switch_selector_name: "LEAF\\g<id>"
  node_policies:
    nodes:
      - id: 101
        role: leaf
        access_policy_group: ALL_LEAFS
```

System-generated profiles:

```yaml
apic:
  new_interface_configuration: true
  node_policies:
    nodes:
      - id: 101
        role: leaf
        access_policy_group: ALL_LEAFS
```

Example-1: This configuration creates a leaf switch profile named `LEAF101` that applies the `ALL_LEAFS` policy to node `101` and associates it with the `LEAF101` interface profile for port configuration. This is used to control which switches get which policies and interface settings.

```yaml
apic:
  access_policies:
    leaf_switch_profiles:
      - name: LEAF101
        selectors:
          - name: SEL1
            policy: ALL_LEAFS
            node_blocks:
              - name: BLOCK1
                from: 101
        interface_profiles:
          - LEAF101
```

Example-2: This configuration creates a leaf switch profile that applies the `ALL_LEAFS_POLICY` to both leaf switches `101` and `102`, and associates each with its respective interface profile for port configuration. This allows you to manage policies and interface settings for multiple switches as a group.

```yaml
apic:
  access_policies:
    leaf_switch_profiles:
      - name: LEAF_PROFILE_101_102
        selectors:
          - name: LEAFS_101_102
            policy: ALL_LEAFS_POLICY
            node_blocks:
              - name: BLOCK_101_102
                from: 101
                to: 102
        interface_profiles:
          - LEAF101_INTF_PROFILE
          - LEAF102_INTF_PROFILE
```
