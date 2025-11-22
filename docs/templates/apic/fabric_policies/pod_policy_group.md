# Pod Policy Group

Location in GUI:
`Fabric` » `Fabric Policies` » `Pods` » `Policy Groups`


{{ doc_gen }}

### Examples

Example-1: this pod policy group named `POD1` defines pod-wide configurations, such as the snmp_policy `POD1_SNMP` containing the SNMP configuration, the date_time_policy `POD1_NTP` contaeining the NTP server information, and the management_access_policy `POD1_MGMT` containing the ACI management access settings and ciphers. This policy is put into effect by associating it to the relevant pod profile.

```yaml
apic:
  fabric_policies:
    pod_policy_groups:
      - name: POD1
        snmp_policy: POD1_SNMP
        date_time_policy: POD1_NTP
        management_access_policy: POD1_MGMT
```
