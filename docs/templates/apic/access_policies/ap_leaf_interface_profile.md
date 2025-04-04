# Access Leaf Interface Profile

Leaf Interface Profiles can either be auto-generated (one per leaf) by providing a naming convention, or can be system-generated (one per leaf), or can be defined explicitly. In case of auto-generated profiles the following placeholders can be used when defining the naming convention:

* `\\g<id>`: gets replaced by the respective leaf node ID
* `\\g<name>`: gets replaced by the respective leaf hostname

Location in GUI:
`Fabric` » `Access Policies` » `Interfaces` » `Leaf Interfaces` » `Profiles`


{{ doc_gen }}

### Examples

Auto-generated profiles:

```yaml
apic:
  auto_generate_access_leaf_switch_interface_profiles: true
  access_policies:
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
  access_policies:
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
          - name: FEX101
            fex_id: 101
            fex_profile: LEAF101-FEX101
            port_blocks:
              - name: BLOCK1
                from_port: 2
```
