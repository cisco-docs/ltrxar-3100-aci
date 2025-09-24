# Fabric MACsec Keychain Policy

Location in GUI:
`Fabric` » `Fabric Policies` » `Policies` » `MACsec` » `MACsec KeyChain Policies`


{{ doc_gen }}

### Examples

```yaml
apic:
  fabric_policies:
    macsec_keychain_policies:
      - name: fabric-macsec-keychain-1
        description: Fabric MACsec Keychain Policy
        type: fabric
        key_policies:
          - name: fabric-primary-key-spine
            description: Primary encryption key
            key_name: abcdef0123456789
            pre_shared_key: deadbeefcafebabefeedface12345678deadbeefcafebabefeedface12345678
            start_time: now
            end_time: infinite
```
