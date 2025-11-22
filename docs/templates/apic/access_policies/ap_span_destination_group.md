# Access SPAN Destination Groups

Location in GUI:
`Fabric` » `Access Policies` » `Policies` » `Troubleshooting` » `SPAN` » `SPAN Destination Groups`

{{ doc_gen }}

### Examples

Example-1: This example demonstrates how to configure a SPAN destination group under access policies for ERSPAN.
The destination group `Lf1011-EPC-CP-DstGrp` defines the ERSPAN collector with IP `192.168.101.151`. The source_prefix `10.1.1.1` specifies the ERSPAN source IP. The MTU is set to `9216` to support jumbo frames. By default, the ERSPAN version is 2; in this example, it is explicitly set to `1`. The tenant `mgmt`, application_profile `Mgmt-AP`, and endpoint_group `VLAN-1001-EPG` identify the EPG used to reach the collector. The collector IP must be reachable and learned in this EPG.

```yaml
apic:
  access_policies:
    span:
      destination_groups:
        - name: Lf1011-EPC-CP-DstGrp
          description: ERSPAN destination group for the EPC-CP collector.
          ip: 192.168.101.151
          source_prefix: 10.1.1.1
          mtu: 9216
          version: 1
          tenant: mgmt
          application_profile: Mgmt-AP
          endpoint_group: VLAN-1001-EPG

```

Example-2: This example demonstrates how to configure a local SPAN destination group under access policies.
The destination group Local-Span-DstGrp directs mirrored traffic to a physical interface on a specific leaf. The node_id and port fields identify the egress interface used for the SPAN destination (port `10` on node `1011`). Because this is local SPAN, ERSPAN-specific fields such as ip, source_prefix, and version are not required. By default, the destination interface MTU is 1518 unless explicitly specified.

```yaml
apic:
  access_policies:
    span:
      destination_groups:
        - name: Local-Span-DstGrp
          description: Local SPAN Destination Group
          node_id: 1011
          port: 10
```
