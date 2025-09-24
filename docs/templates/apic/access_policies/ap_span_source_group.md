# Access SPAN Source Groups

Location in GUI:
`Fabric` » `Access Policies` » `Policies` » `Troubleshooting` » `SPAN` » `SPAN Source Groups`

{{ doc_gen }}

### Examples

Example-1: This example demonstrates how to configure a SPAN source group under access policies with L3Out-based sources on a single leaf.
The source group `Lf1011-EPC-CP-SrcGr` mirrors traffic associated with the L3Out named `EPC-CP-L3Out` in tenant `Core`, encapsulated with VLAN `2001`. Each span source entry specifies the access path that identifies the mirroring point in the fabric (ports `10` and `11` on node `1011`). By default, the mirroring direction is `Both` unless explicitly specified. The destination field binds this source group to the existing destination group `Lf1011-EPC-CP-DstGrp`, which determines where the mirrored traffic is sent.

```yaml
apic:
  access_policies:
    span:
      source_groups:
        - name: Lf1011-EPC-CP-SrcGr
          description: Port-based SPAN sources on leaf 1011 (L3Out EPC-CP-L3Out, VLAN 2001) to destination Lf1011-EPC-CP-DstGrp.
          destination:
            name: Lf1011-EPC-CP-DstGrp
          sources:
            - name: Lf1011-port10
              l3out: EPC-CP-L3Out
              tenant: Core
              vlan: 2001
              access_paths:
                - node_id: 1011
                  port: 10
            - name: Lf1011-port11
              l3out: EPC-CP-L3Out
              tenant: Core
              vlan: 2001
              access_paths:
                - node_id: 1011
                  port: 11
```

Example-2: This example demonstrates how to configure a SPAN source group under access policies with EPG-based sources, including single-port and vPC channel access paths.
The source group `EPC-Tools-SrcGr` mirrors traffic from EPGs in application profile `Core-AP` of tenant `Core`: `VLAN-2010-EPG` and `VLAN-2020-EPG`. Each span source entry specifies the access path that identifies the mirroring point in the fabric: the source `VLAN-2010` specifies access path using node_id and port (port `3` on nodes `1011` and `1021`), while the source `VLAN-2020` specifies a vPC access path by specifying node_id `1011`, node2_id `1021`, and the interface policy group `SVR-vPC1-IfPolGrp`. By default, the mirroring direction is `Both` unless explicitly specified. The destination field binds this source group to the existing destination group `EPC-Tools-DstGrp`, which determines where the mirrored traffic is sent.

```yaml
apic:
  access_policies:
    span:
      source_groups:
        - name: EPC-Tools-SrcGr
          description: EPG-based SPAN sources with single-port and vPC channel paths to destination EPC-Tools-DstGrp.
          destination:
            name: EPC-Tools-DstGrp
          sources:
            - name: VLAN-2010
              description: EPG-based source with single-port access paths.
              tenant: Core
              application_profile: Core-AP
              endpoint_group: VLAN-2010-EPG
              access_paths:
                - node_id: 1011
                  port: 3
                - node_id: 1021
                  port: 3
            - name: VLAN-2020
              description: EPG-based source using a vPC channel path.
              tenant: Core
              application_profile: Core-AP
              endpoint_group: VLAN-2020-EPG
              access_paths:
                - node_id: 1011
                  node2_id: 1021
                  channel: SVR-vPC1-IfPolGrp
```
