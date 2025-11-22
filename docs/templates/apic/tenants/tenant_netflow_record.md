# Tenant NetFlow Records

Location in GUI:
`Tenant` » `XXX` » `Policies` » `Netflow` » `NetFlow Records`

{{ doc_gen }}

### Examples

```yaml
apic:
  tenants:
    - name: 'ABC'
      policies:
        netflow_records:
          - name: RECORD1
            description: record 1
            match_parameters:
              - dst-ip
              - src-ip
              - dst-port
              - src-port 
```
