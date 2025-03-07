# Endpoint IP Tag

Location in GUI:
`Tenants` » `XXX` » `Policies` » `Endpoint Tags` » `Endpoint IP`


{{ doc_gen }}

### Examples

```yaml
apic:
  tenants:
    - name: ABC
      policies:
        endpoint_ip_tags:
            - ip: 1.1.1.1
              vrf: VRF1
              tags:
                - key: Environment
                  value: Prod
```
