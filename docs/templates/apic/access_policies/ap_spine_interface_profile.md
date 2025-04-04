# Access Spine Interface Profile

Spine Interface Profiles can either be auto-generated (one per spine) by providing a naming convention, or can be system-generated (one per spine), or can be defined explicitly. In case of auto-generated profiles the following placeholders can be used when defining the naming convention:

* `\\g<id>`: gets replaced by the respective spine node ID
* `\\g<name>`: gets replaced by the respective spine hostname

Location in GUI:
`Fabric` » `Access Policies` » `Interfaces` » `Spine Interfaces` » `Profiles`


{{ doc_gen }}

### Examples

Auto-generated profiles:

```yaml
apic:
  auto_generate_access_spine_switch_interface_profiles: true
  access_policies:
    spine_interface_profile_name: "SPINE\\g<id>"
  interface_policies:
    nodes:
      - id: 1001
```

System-generated profiles:

```yaml
apic:
  new_interface_configuration: true
  interface_policies:
    nodes:
      - id: 1001
```

Explicitly configured profiles:

```yaml
apic:
  access_policies:
    spine_interface_profiles:
      - name: SPINE1001
        selectors:
          - name: SEL1
            policy_group: IPN
            port_blocks:
              - name: BLOCK1
                description: IPN1
                from_port: 1
```
