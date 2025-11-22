# Routed Domain

Location in GUI:
`Fabric` » `Access Policies` » `Physical and External Domains` » `L3 Domains`


{{ doc_gen }}

### Examples

Example 1: In the first example we created a `routed_domain` attached with a vlan pool `routedVlanPool`.

```yaml
apic:
  access_policies:
    routed_domains:
      - name: routedDomain
        vlan_pool: routedVlanPool
```

Example 2: In this example we created a `routed_domain` attached with a vlan pool `myRoutedVlanPool`, additionally we have added a security domain.

```yaml
apic:
  access_policies:
    routed_domains:
      - name: myRoutedDomain
        vlan_pool: myRoutedVlanPool
        security_domains:
          - mySecurityDomain
```
