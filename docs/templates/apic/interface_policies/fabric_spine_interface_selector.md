# Fabric Spine Interface Selector

Spine Interface Selectors can be auto-generated (one per interface) by providing a naming convention. The following placeholders can be used when defining the naming convention:

* `\\g<mod>`: gets replaced by the respective interface module ID
* `\\g<port>`: gets replaced by the respective interface port ID
* `\\g<sport>`: gets replaced by the respective interface sub-port ID

Location in GUI:
`Fabric` » `Fabric Policies` » `Interfaces` » `Spine Interfaces` » `Profiles` » `XXX`


{{ doc_gen }}

### Examples

```yaml
apic:
  auto_generate_fabric_spine_switch_interface_profiles: true
  fabric_policies:
    spine_interface_selector_name: "ETH\\g<mod>-\\g<port>"
    spine_interface_selector_sub_port_name: "ETH\\g<mod>-\\g<port>-\\g<sport>"
  interface_policies:
    nodes:
      - id: 101
        interfaces:
          - port: 1
            description: interface descr 1
            policy_group: FAB1
            fabric: true
```
