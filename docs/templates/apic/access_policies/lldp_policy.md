# LLDP Interface Policy

Location in GUI:
`Fabric` » `Access Policies` » `Policies` » `Interface` » `LLDP Interface`


{{ doc_gen }}

### Examples

```yaml
apic:
  access_policies:
    interface_policies:
      lldp_policies:
        - name: LLDP-ENABLED
          admin_rx_state: true
          admin_tx_state: true
```

Example with DCBX version (release 6.0(3)+):

```yaml
apic:
  access_policies:
    interface_policies:
      lldp_policies:
        - name: LLDP-ENABLED
          admin_rx_state: true
          admin_tx_state: true
          dcbxp_version: IEEE
```
