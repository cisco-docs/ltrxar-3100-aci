# Access FEX Interface Selector

FEX Interface Selectors can be auto-generated (one per interface) by providing a naming convention. The following placeholders can be used when defining the naming convention:

* `\\g<mod>`: gets replaced by the respective interface module ID
* `\\g<port>`: gets replaced by the respective interface port ID

Location in GUI:
`Fabric` » `Access Policies` » `Interfaces` » `Leaf Interfaces` » `Profiles` » `XXX`


{{ doc_gen }}

### Examples

```yaml
apic:
  auto_generate_access_leaf_switch_interface_profiles: true
  access_policies:
    fex_interface_selector_name: "ETH\\g<mod>-\\g<port>"
  interface_policies:
    nodes:
      - id: 101
        fexes:
          - id: 101
            interfaces:
              - port: 1
                description: interface descr
                policy_group: ACC1
```
