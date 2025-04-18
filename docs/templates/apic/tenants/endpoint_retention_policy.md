# Endpoint Retention Policy

Location in GUI:
`Tenants` » `XXX` » `Policies` » `Protocol` » `End Point Retention`


{{ doc_gen }}

### Examples

```yaml
apic:
  tenants:
    - name: ABC
      policies:
        route_tag_policies:
          - name: TAG1
            description: DESC1
            hold_interval: 180
            bounce_entry_aging_interval: 180
            remote_endpoint_aging_interval: 180
            local_endpoint_aging_interval: 0
            move_frequency: 180
```
