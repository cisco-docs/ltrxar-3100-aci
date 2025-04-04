# Access FEX Interface Profile

FEX Interface Profiles can either be auto-generated (one per FEX) by providing a naming convention, or can be system-generated (one per FEX), or can be defined explicitly. In case of auto-generated profiles the following placeholders can be used when defining the naming convention:

* `\\g<id>`: gets replaced by the respective leaf node ID
* `\\g<name>`: gets replaced by the respective leaf hostname
* `\\g<fex>`: gets replaced by the respective FEX ID

Location in GUI:
`Fabric` » `Access Policies` » `Interfaces` » `Leaf Interfaces` » `Profiles`


{{ doc_gen }}

### Examples

Auto-generated profiles:

```yaml
apic:
  auto_generate_access_leaf_switch_interface_profiles: true
  access_policies:
    fex_profile_name: "LEAF\\g<id>-FEX\\g<fex>"
  interface_policies:
    nodes:
      - id: 101
        fexes:
          - id: 101
```

System-generated profiles:

```yaml
apic:
  new_interface_configuration: true
  interface_policies:
    nodes:
      - id: 101
        fexes:
          - id: 101
```

Explicitly configured profiles:

```yaml
apic:
  access_policies:
    fex_interface_profiles:
      - name: LEAF101-FEX101
        selectors:
          - name: SEL1
            policy_group: 10G-SERVER
            port_blocks:
              - name: BLOCK1
                description: Server ABC
                from_port: 1
```
