# OSPF Route Summarization Policy

Location in GUI:
`Tenants` » `XXX` » `Policies` » `Protocol` » `OSPF` » `OSPF Route Summarization`

{{ doc_gen }}

### Examples

Example-1: This configures a route summarization policy named `OSPF_SUMM`. The cost attribute is set to `100` and it will be set to the summary route. The cost is used for path selection. The inter_area attribute is set to `true` to use the area range for the summary configuration. If set to `false` it will use summary address. Once configured, the policy will be associated with an external EPG subnet marked with export route control in order to execute the actual summarization for the configured external EPG subnet.

```yaml
apic:
  tenants:
    - name: ABC
      policies:
        ospf_route_summarization_policies:
          - name: OSPF_SUMM
            description: OSPF route summarization policy
            cost: 100
            inter_area: true

```
