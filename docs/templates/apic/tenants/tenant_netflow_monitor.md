# Tenant NetFlow Monitors

Location in GUI:
`Tenant` » `XXX` » `Policies` » `Netflow` » `NetFlow Monitors`

{{ doc_gen }}

### Examples

```yaml
apic:
  tenants:
    - name: 'ABC'
      policies:
        netflow_monitors:
          - name: MONITOR1
            description: monitor 1
            flow_record: RECORD1
            flow_exporters:
              - EXPORTER1
              - EXPORTER2
```
