# LLDP Interface Policy

Location in GUI:
`Fabric` » `Access Policies` » `Policies` » `Interface` » `LLDP Interface`


{{ doc_gen }}

### Examples

Example-1: This data model creates an LLDP Interface Policy named `LLDP-ENABLED` with LLDP transmission and reception enabled.

```yaml
apic:
  access_policies:
    interface_policies:
      lldp_policies:
        - name: LLDP-ENABLED
          admin_rx_state: true
          admin_tx_state: true
```

Example-2: Starting with ACI release 6.0(3)+, LLDP supports the IEEE DCBX extension. DCBX enables devices to discover each other's Data Center Bridging (DCB) capabilities, such as Priority Flow Control (PFC) and Enhanced Transmission Selection (ETS), and to negotiate a consistent configuration. DCBX is a critical component in establishing a lossless Ethernet environment.

Please note that if the `dcbxp_version` option is included in data models for earlier releases, the deployment will fail.

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
