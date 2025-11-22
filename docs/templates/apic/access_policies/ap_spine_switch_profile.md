# Access Spine Switch Profile

Spine Switch Profiles can either be auto-generated (one per spine) by providing a naming convention, or can be system-generated, or can be defined explicitly. In case of auto-generated profiles the following placeholders can be used when defining the naming convention:

* `\\g<id>`: gets replaced by the respective spine node ID
* `\\g<name>`: gets replaced by the respective spine hostname

Location in GUI:
`Fabric` » `Access Policies` » `Switches` » `Spine Switches` » `Profiles`


{{ doc_gen }}

### Examples

Auto-generated profiles:

```yaml
apic:
  auto_generate_access_spine_switch_interface_profiles: true
  access_policies:
    spine_switch_profile_name: "SPINE\\g<id>"
    spine_switch_selector_name: "SPINE\\g<id>"
  node_policies:
    nodes:
      - id: 1001
        role: spine
        access_policy_group: ALL_SPINES
```

System-generated profiles:

```yaml
apic:
  new_interface_configuration: true
  node_policies:
    nodes:
      - id: 1001
        role: spine
        access_policy_group: ALL_SPINES
```

Explicitly configured profiles:

```yaml
apic:
  access_policies:
    spine_switch_profiles:
      - name: SPINE1001
        selectors:
          - name: SEL1
            policy: ALL_SPINES
            node_blocks:
              - name: BLOCK1
                from: 1001
        interface_profiles:
          - SPINE1001
```
