# Fabric Leaf Switch Profile

Leaf Switch Profiles can either be auto-generated (one per leaf) by providing a naming convention, or can be system-generated (one per leaf), or can be defined explicitly. In case of auto-generated profiles the following placeholders can be used when defining the naming convention:

* `\\g<id>`: gets replaced by the respective leaf node ID
* `\\g<name>`: gets replaced by the respective leaf hostname

Location in GUI:
`Fabric` » `Fabric Policies` » `Switches` » `Leaf Switches` » `Profiles`


{{ doc_gen }}

### Examples

Auto-generated profiles:

```yaml
apic:
  auto_generate_fabric_leaf_switch_interface_profiles: true
  fabric_policies:
    leaf_switch_profile_name: "LEAF\\g<id>"
    leaf_switch_selector_name: "LEAF\\g<id>"
  node_policies:
    nodes:
      - id: 101
        role: leaf
        fabric_policy_group: ALL_LEAFS
```

System-generated profiles:

```yaml
apic:
  new_interface_configuration: true
  node_policies:
    nodes:
      - id: 101
        role: leaf
        fabric_policy_group: ALL_LEAFS
```

Explicitly configured profiles:

```yaml
apic:
  fabric_policies:
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
