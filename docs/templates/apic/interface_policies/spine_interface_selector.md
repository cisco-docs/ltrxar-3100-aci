# Access Spine Interface Selector

Spine Interface Selectors can be auto-generated (one per interface) by providing a naming convention. The following placeholders can be used when defining the naming convention:

* `\\g<mod>`: gets replaced by the respective interface module ID
* `\\g<port>`: gets replaced by the respective interface port ID

Location in GUI:
`Fabric` » `Access Policies` » `Interfaces` » `Spine Interfaces` » `Profiles` » `XXX`


{{ doc_gen }}

### Examples

```yaml
apic:
  auto_generate_access_spine_switch_interface_profiles: true
  access_policies:
    spine_interface_selector_name: "ETH\\g<mod>-\\g<port>"
  interface_policies:
    nodes:
      - id: 1001
        interfaces:
          - port: 60
            policy_group: IPN
```
