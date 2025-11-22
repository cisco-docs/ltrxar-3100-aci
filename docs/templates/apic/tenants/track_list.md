# Track List

Location in GUI:
`Tenants` » `XXX` » `Policies` » `Protocol` » `IP SLA` » `Track Lists`

{{ doc_gen }}

### Examples

Example-1: This data model groups two IP addresses (track members `FW_1_Track_Mem` and `FW_2_Track_Mem`) to evaluate the validity of a static route or its next-hop within an L3Out or Bridge Domain. The track members are monitored using a specified IP SLA monitoring policy (e.g., ICMP or TCP probes). Based on a configured threshold-expressed as a percentage or weight-the track list determines whether the route or next-hop is considered up or down. If marked down, the static route or next-hop is removed from the routing table; if marked up, it is reinstated. Static routes reference these track lists to dynamically manage route availability.

```yaml
apic:
  tenants:
    - name: ABC
      policies:
        track_lists:
          - name: TRACK_LIST
            type: percentage
            percentage_up: 10
            percentage_down: 2
            track_members:
              - FW_1_Track_Mem
              - FW_2_Track_Mem
```
