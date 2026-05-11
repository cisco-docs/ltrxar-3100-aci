# Multicast Route Map

Location in GUI:
`Tenant Template` » `Tenant Policies`

{{ doc_gen }}

### Examples

Example-1: The example below shows a tenant policy template called `TP1` that is created under the tenant `NDO1` and the site `APIC1`. The multicast route map `MRM1` is defined under the tenant policy template. In this multicast route map there are two entries. Entry with order `1` is defined with the source IP address `1.2.3.4/32` and the group IP address `224.0.0.0/8`. The RP IP address is `3.4.5.6` and the action is `permit`. Entry with order `2` is defined with the source IP address `7.8.9.10/32` and the group IP address `224.0.0.0/8`.

```yaml
ndo:
  tenant_templates:
    tenant_policies:
      - name: TP1
        tenant: NDO1
        sites:
          - APIC1
        multicast_route_maps:
          - name: MRM1
            description: Multicast Route Map
            entries:
              - order: 1
                source_ip: 1.2.3.4/32
                group_ip: 224.0.0.0/8
                rp_ip: 3.4.5.6
                action: permit
              - order: 2
                source_ip: 7.8.9.10/32
                group_ip: 224.0.0.0/8
```
