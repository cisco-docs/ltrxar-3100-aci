# Data Plane Policing Policy

Location in GUI:
`Fabric` » `Access Policies` » `Policies` » `Interface` » `Data Plane Policing`


{{ doc_gen }}

### Examples

```yaml
apic:
  access_policies:
    interface_policies:
        data_plane_policing_policies:
          - name: DPP1
            admin_state: true
            mode: packet
            type: 2R3C
            sharing_mode: shared
            conform_action: mark
            conform_mark_cos: 1
            conform_mark_dscp: 10
            exceed_action: mark
            exceed_mark_cos: 2
            exceed_mark_dscp: 20
            violate_action: mark
            violate_mark_cos: 3
            violate_mark_dscp: 30
            rate: 10
            rate_unit: mega
            burst: 20
            burst_unit: mega
            peak_rate: 30
            peak_rate_unit: mega
            burst_excessive: 40
            burst_excessive_unit: mega
```
