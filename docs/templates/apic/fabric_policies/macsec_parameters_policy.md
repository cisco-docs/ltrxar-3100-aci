# Fabric MACsec Parameters Policy

Location in GUI:
`Fabric` » `Fabric Policies` » `Policies` » `MACsec` » `Parameters`


{{ doc_gen }}

### Examples

```yaml
apic:
  fabric_policies:
    macsec_parameters_policies:
      - name: fabric-macsec-params-1
        description: Fabric MACsec Parameters Policy
        type: fabric
        cipher_suite: gcm-aes-xpn-256
        window_size: 2048
        key_expiry_time: 86400
        security_policy: must-secure
```
