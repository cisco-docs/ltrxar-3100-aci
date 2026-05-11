# Border Gateway Set

Location in GUI:
`Tenants` » `infra` » `Policies` » `VXLAN Gateway` » `Border Gateway Sets`


{{ doc_gen }}

### Examples

This example shows how to configure a border gateway set:

```yaml
apic:
  tenants:
    - name: infra
      policies:
        border_gateway_sets:
          - name: BorderGatewaySet
            vxlan_site_id: 65122
            external_data_plane_ips:
              - pod_id: 1
                ip: 10.2.3.4
```
