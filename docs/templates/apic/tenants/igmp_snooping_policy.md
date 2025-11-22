# IGMP Snooping Policy

Location in GUI:
`Tenants` » `XXX` » `Policies` » `Protocol` » `IGMP Snoop`

{{ doc_gen }}

### Examples

Example-1: This is a single example of an IGMP Sooping Policy where the IGMP Sooping Policy `IGMP-SNOOP1` is configured under tenant `ABC`. This sample illustrates a configuration where IGMP Fast Leave and Querier are `enabled`.

```yaml
apic:
  tenants:
    - name: ABC
      policies:
        igmp_snooping_policies:
          - name: IGMP-SNOOP1
            fast_leave: true
            querier: true
```

Example-2: This is a single example of an IGMP Sooping Policy where the IGMP Sooping Policy IGMP_Snooping_Disabled is configured under tenant `ABC`. This sample illustrates a configuration where IGMP Snooping is `disabled`.

```yaml
apic:
  tenants:
    - name: ABC
      policies:
        igmp_snooping_policies:
          - name: IGMP_Snooping_Disabled
            admin_state: false
```
