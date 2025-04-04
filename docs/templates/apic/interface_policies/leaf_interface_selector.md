# Access Leaf Interface Selector

Leaf Interface Selectors can be auto-generated (one per interface) by providing a naming convention. The following placeholders can be used when defining the naming convention:

* `\\g<mod>`: gets replaced by the respective interface module ID
* `\\g<port>`: gets replaced by the respective interface port ID
* `\\g<sport>`: gets replaced by the respective interface sub-port ID

Location in GUI:
`Fabric` » `Access Policies` » `Interfaces` » `Leaf Interfaces` » `Profiles` » `XXX`


{{ doc_gen }}

### Examples

```yaml
apic:
  auto_generate_access_leaf_switch_interface_profiles: true
  access_policies:
    leaf_interface_selector_name: "ETH\\g<mod>-\\g<port>"
    leaf_interface_selector_sub_port_name: "ETH\\g<mod>-\\g<port>-\\g<sport>"
  interface_policies:
    nodes:
      - id: 101
        interfaces:
          - port: 1
            description: interface descr 1
            policy_group: ACC1
          - port: 2
            fex_id: 101
```
