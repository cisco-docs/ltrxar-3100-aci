# Monitoring Policy

This object will attach the `Syslog` and `SNMP Trap` policies to the `common` monitoring policy.

Location in GUI:
`Fabric` » `Fabric Policies` » `Policies` » `Monitoring` » `Common Policy`


{{ doc_gen }}


### Examples

```yaml
---
apic:
  fabric_policies:
    monitoring:
      policies:
        - name: Custom_Policy
          description: "This is a custom policy for policy monitoring."
          fault_severity_policies:
            - class: snmpClient
              faults:
                - fault_id: F1368
                  description: "Fault 1368 nice description"
                  initial_severity: minor
                  target_severity: major
            - class: snmpTrapDest
              faults:
                - fault_id: F1449
                  description: "Fault 1449 superb description"
                  initial_severity: minor
                  target_severity: critical
          snmp_traps:
            - name: policy_trap1
              destination_group: pol_snmp_dst_grp
          syslogs:
            - name: policy_syslog1
              description: desc1
              session: true
              audit: false
              events: false
              faults: false
              minimum_severity: debugging
              destination_group: pol_syslog_dst_grp
```
