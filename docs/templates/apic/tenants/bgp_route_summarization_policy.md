# BGP Route Summarization Policy

Location in GUI:
`Tenants` » `XXX` » `Policies` » `Protocol` » `BGP` » `BGP Route Summarization Policy`

{{ doc_gen }}

### Examples

Example-1: This configures a route summarization policy named `BGP_SUMM`. The as_set attribute is set to `true` to generate the AS-SET data to maintain the AS path post-summarization. It should be set to `false` if it required for the summary prefix to be originated by ACI based on the overall BGP routing design. The summary_only attribute is set to `true` to only advertise the summary prefix and suppress the more specific prefixes within it, which is typically wanted when summarizing routes. This policy will only match the unicast address family since af_ucast is set to `true`, and af_mcast is set to `false`. Once configured, the policy will be associated with an external EPG subnet marked with export route control in order to execute the actual summarization for the configured external EPG subnet.

```yaml
apic:
  tenants:
    - name: ABC
      policies:
        bgp_route_summarization_policies:
          - name: BGP_SUMM
            description: Policy to only advertise unicast summary prefixes and generate AS-SET data
            as_set: true
            summary_only: true
            af_mcast: false
            af_ucast: true
```
