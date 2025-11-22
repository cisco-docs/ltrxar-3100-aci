# Tenant NetFlow Exporters

Location in GUI:
`Tenant` » `XXX` » `Policies` » `Netflow` » `NetFlow Exporters`

{{ doc_gen }}

### Examples for configuring netflow exporter with App EPG

```yaml
apic:
  tenants:
    - name: 'ABC'
      policies:
        netflow_exporters:
          - name: EXPORTER1
            description: exporter 1
            source_type: custom-src-ip
            source_ip: 1.1.1.1/20
            destination_port: 1234
            destination_ip: 2.2.2.2
            dscp: AF11
            epg_type: epg
            tenant: ABC
            application_profile: AP1
            endpoint_group: EPG1
            vrf: VRF1
```

### Examples for configuring netflow exporter with L3 EPG

```yaml
apic:
  tenants:
    - name: 'ABC'
      policies:
        netflow_exporters:
          - name: EXPORTER2
            description: exporter 2
            source_type: oob-mgmt-ip
            destination_port: 1234
            destination_ip: 2.2.2.2
            dscp: AF11
            epg_type: external_epg
            tenant: ABC
            l3out: L3OUT1
            external_endpoint_group: L3OUT1-EPG1
            vrf: VRF1
```