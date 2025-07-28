# Leaf Interface Policy Group

Location in GUI:
`Fabric` » `Fabric Policies` » `Interfaces` » `Leaf Interfaces` » `Policy Groups` » `Leaf Fabric Port`


{{ doc_gen }}

### Examples

```yaml
apic:
  fabric_policies:
    leaf_interface_policy_groups:
      - name: ALL_LEAF
        description: All Leaf Interfaces
        link_level_policy: link-level-policy1
```
