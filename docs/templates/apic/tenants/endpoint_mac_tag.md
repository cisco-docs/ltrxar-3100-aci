# Endpoint MAC Tag

Location in GUI:
`Tenants` » `XXX` » `Policies` » `Endpoint Tags` » `Endpoint MAC`


{{ doc_gen }}

### Examples

Example Endpoint MAC tag in all bridge domains in a VRF:

```yaml
apic:
  tenants:
    - name: ABC
      policies:
        endpoint_mac_tags:
            - mac: 00:01:02:03:04:05
              vrf: VRF1
              tags:
                - key: Environment
                  value: Prod
```

Example Endpoint MAC tag in explicit bridge-domain:

```yaml
apic:
  tenants:
    - name: ABC
      policies:
        endpoint_mac_tags:
            - mac: 00:01:02:03:04:06
              bridge_domain: BD1
              vrf: VRF1
              tags:
                - key: Environment
                  value: Test
```
