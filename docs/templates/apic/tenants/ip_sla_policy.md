# IP SLA Policy

Location in GUI:
`Tenants` » `XXX` » `Policies` » `Protocol` » `IP SLA` » `IP SLA Monitoring Policies`

{{ doc_gen }}

### Examples

Example-1: This data model creates two IP SLA Policies named `L2PingEach30sec` and `PingEach20sec`. They are usually referenced by Redirect Policies as a method for active traffic monitoring that measures network performance by generating traffic probes such as ICMP, TCP, or L2Ping (specified in `sla_type`). It will provide reachability and performance data, but it will not automatically influence PBR traffic redirection decisions. If you select `tcp` as `sla_type`, you must define a `port` value as well.

```yaml
apic:
  tenants:
    - name: PBR_ServGraph
      policies:
        ip_sla_policies:
          - name: 'L2PingEach30sec'
            description: Send L2 ping each 30 seconds
            frequency: 30
            multiplier: 2
            sla_type: l2ping
          - name: 'PingEach20sec'
            description: Send ping each 20 seconds
            frequency: 20
            multiplier: 4
```
