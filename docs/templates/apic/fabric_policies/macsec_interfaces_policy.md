# Fabric MACsec Interfaces Policy

Location in GUI:
`Fabric` » `Fabric Policies` » `Policies` » `MACsec` » `Interfaces`


{{ doc_gen }}

### Examples

```yaml
apic:
  fabric_policies:
    macsec_interfaces_policies:
      - name: fabric-macsec-interface-1
        description: Fabric MACsec Interface Policy
        type: fabric
        admin_state: true
        macsec_parameters_policy: fabric-macsec-params-1
        macsec_keychain_policy: fabric-macsec-keychain-1
```
