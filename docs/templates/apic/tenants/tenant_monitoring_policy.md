# Tenant Monitoring Policy

Location in GUI:
`Tenants` » `XXX` » `Policies` » `Monitoring` » `XXX`


{{ doc_gen }}

### Examples

```yaml
apic:
  tenants:
    - name: 'ABC'
      policies:
        monitoring:
          policies:
            - name: MON_POL
              snmp_traps:
                - name: TRAP1
                  destination_group: DEST1
              syslogs:
                - name: SYSLOG1
                  audit: false
                  events: false
                  faults: false
                  session: true
                  minimum_severity: alerts
                  destination_group: DEST2
              fault_severity_policies:
                - class: vzRsSubjFiltAtt
                  faults:
                    - fault_id: F1127
                      initial_severity: warning
                      target_severity: critical
                      description: test
```
