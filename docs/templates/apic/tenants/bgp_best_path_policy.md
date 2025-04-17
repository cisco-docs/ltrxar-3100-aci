# BGP Best Path Policy

Location in GUI:
`Tenants` » `XXX` » `Policies` » `Protocol` » `BGP` » `BGP Best Path Policy`

{{ doc_gen }}

### Examples

```yaml
apic:
  tenants:
    - name: ABC
      policies:
        bgp_best_path_policies:
          - name: BGP-BEST-PATH1
            as_path_multipath_relax: true
```

Example with `ignore_igp_metric` (ACI 6.1+):

```yaml
apic:
  tenants:
    - name: ABC
      policies:
        bgp_best_path_policies:
          - name: BGP-BEST-PATH1
            as_path_multipath_relax: true
            ignore_igp_metric: true
```