# Access Monitoring Policy

Location in GUI:
`Fabric` » `Access Policies` » `Policies` » `Monitoring` » `XXX`


{{ doc_gen }}

### Examples

```yaml
---
apic:
  access_policies:
    monitoring:
      policies:
        - name: test_mon_pol
          snmp_traps:
            - name: test_trap
              destination_group: test_destination
          syslogs:
            - name: test_syslog
              audit: false
              events: false
              faults: true
              session: false
              minimum_severity: alerts
              destination_group: syslog_destination
          fault_severity_policies:
            - class: l1PhysIf
              faults:
                - fault_id: F1696
                  initial_severity: warning
                  target_severity: inherit
                  description: test
```