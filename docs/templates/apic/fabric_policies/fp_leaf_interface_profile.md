# Fabric Leaf Interface Profile

Leaf Interface Profiles can either be auto-generated (one per leaf) by providing a naming convention, or can be system-generated (one per leaf), or can be defined explicitly. In case of auto-generated profiles the following placeholders can be used when defining the naming convention:

* `\\g<id>`: gets replaced by the respective leaf node ID
* `\\g<name>`: gets replaced by the respective leaf hostname

Location in GUI:
`Fabric` » `Fabric Policies` » `Interfaces` » `Leaf Interfaces` » `Profiles`


{{ doc_gen }}

### Examples

Auto-generated profiles:

```yaml
apic:
  auto_generate_fabric_leaf_switch_interface_profiles: true
  fabric_policies:
    leaf_interface_profile_name: "LEAF\\g<id>"
  interface_policies:
    nodes:
      - id: 101
```

System-generated profiles:

```yaml
apic:
  new_interface_configuration: true
  interface_policies:
    nodes:
      - id: 101
```

Explicitly configured profiles:

```yaml
apic:
  fabric_policies:
    leaf_interface_profiles:
      - name: LEAF101
        selectors:
          - name: SEL1
            description: Leaf Interface Profile Description
            policy_group: 10G-SERVER
            port_blocks:
              - name: BLOCK1
                description: Server ABC
                from_port: 1
          - name: SUB-151
            description: Breakout port 1/5/1
            policy_group: 10G-SERVER
            sub_port_blocks:
              - name: '1-5-1'
                from_port: 5
                from_sub_port: 1
```
