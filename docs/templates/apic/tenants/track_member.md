# Track Member

Location in GUI:
`Tenants` » `XXX` » `Policies` » `Protocol` » `IP SLA` » `Track Members`

{{ doc_gen }}

### Examples

Example-1: This data model specifies two IP addresses (`10.0.0.1` and `10.0.0.2`) located in the `Firewall_L3` L3Out to be monitored using the `L2PingEach30sec` IP SLA monitoring policy.

Track Members are the fundamental units of IP SLA monitoring. They represent endpoints or next-hop IP addresses whose reachability is continuously verified. The monitoring results dynamically influence network behavior, such as static route tracking, which can be associated with either an L3Out or a Bridge Domain (BD) and referenced by a Track List.

If IP SLA Policy is not existing in configured Tenant's Data Model and it exists in `common` Tenant Data Model, then relation for ip_sla_policy attribute will reflect IP SLA Policy in `common` Tenant.

```yaml
apic:
  tenants:
    - name: ABC
      policies:
        track_members:
          - name: FW_1_Track_Mem
            destination_ip: 10.0.0.1
            scope_type: l3out
            scope: Firewall_L3
            ip_sla_policy: L2PingEach30sec
          - name: FW_2_Track_Mem
            destination_ip: 10.0.0.2
            scope_type: l3out
            scope: Firewall_L3
            ip_sla_policy: L2PingEach30sec
```
