# VXLAN Stretch

Location in GUI:
`Tenants` » `xxx` » `Networking` » `VXLAN Stretch`


{{ doc_gen }}

### Examples

Example-1: This example shows how to configure a VXLAN VRF stretch with border gateway set policy, normalized VNI, import route map, and export route map:

```yaml
apic:
  tenants:
    - name: infra
      vrfs:
        - name: VRF3
          vxlan_stretch:
            border_gateway_set_policy: BorderGatewaySet
            normalized_vni: 1003
            import_route_map: import-rm
            export_route_map: export-rm
```

Example-2: This example shows how to configure a VXLAN Bridge Domain stretch with border gateway set policy and normalized VNI:

```yaml
apic:
  tenants:
    - name: infra
      bridge_domains:
        - name: BD6
          vxlan_stretch:
            border_gateway_set_policy: BorderGatewaySet
            normalized_vni: 1002
```
