# Match Rule

Location in GUI:
`Tenants` » `XXX` » `Policies` » `Protocol` » `Match Rules`


{{ doc_gen }}

### Examples

Example-1: This match rule matches any subnets within the `10.0.0.0/16` prefix if the subnet mask is between `/24` and `/32`. It can be used in an outbound route-map to control advertisement of subnets configured within ACI. The aggregate option is set to `true` to allow for the matching of more specific subnets within the defined range using the from_length and to_length parameters. In ACI multi-site deployments, the to_length parameter can be set to `31` in the HQ site and `32` in the DR site to reduce the number of routes advertised to the external world while maintaining the optimal paths N/S traffic.

```yaml
apic:
  tenants:
    - name: ABC
      policies:
        match_rules:
          - name: HQ_DC_SUBNETS
            description: Match HQ DC prefixes for route advertisement
            prefixes:
              - ip: 10.0.0.0/16
                description: HQ DC specific subnets
                aggregate: true
                from_length: 24
                to_length: 32
```

Example-2: This match rule matches the `10.0.0.0/16` prefix literally, regardless of the existence of more specific routes. Such a match rule is typically configured in cases where route summarization is in use, to match just the summary route. The aggregate option is set to `false` for the literal matching, which naturally disables the ability to use the from_length and to_length parameters.

```yaml
apic:
  tenants:
    - name: ABC
      policies:
        match_rules:
          - name: HQ_DC_SUBNETS
            description: Match HQ DC aggregate prefix for route advertisement
            prefixes:
              - ip: 10.0.0.0/16
                description: HQ DC aggregate subnet
                aggregate: false
```

Example-3: This match rule matches any prefixes tagged with the BGP community value of `65000:100` -- using regular BGP communities with a two-byte ASN of `65000` and a two-byte network number of `100`. This allows for the flexible application of BGP routing policy based on the assigned community regardless of the IP prefix. The community scope is set to `transitive` to allow for its propagation in BGP advertisements. Such a match rule is used to match a specific community, or set of communities, as is.

This match rule can be used in two directions:

- Outbound, when paired with an appropriately configured set rule, to identify ACI subnets to the exteral world
- Inbound, to only accept the needed subnets, e.g. in ACI multi-site deployments to prevent a given site from receiving the remote sites' prefixes via L3Out since they should be only reachable via the ISN.

```yaml
apic:
  tenants:
    - name: ABC
      policies:
        match_rules:
          - name: HQ_DC_SUBNETS
            description: Match subnets tagged with BGP community assigned for HQ prefixes
            community_terms:
              - name: HQ_DC_COMMUNITY
                description: HQ DC prefixes community
                factors:
                  - community: regular:as2-nn2:65000:100
                    scope: transitive
```

Example-4: This match rule matches any prefixes whose BGP communities include an ASN of `65000` and a network number in the range of `100` to `199`. This match rule allows for more flexible matching than the standard community terms matching due to its use of regular expressions, which allow for advanced pattern matching. This can be useful in mutli-tenant environments where each tenant is assigned a unique community value to control the advertised or received BGP prefixes.

```yaml
apic:
  tenants:
    - name: ABC
      policies:
        match_rules:
          - name: HQ_DC_SUBNETS
            description: Match subnets tagged with BGP community assigned for HQ prefixes
            regex_community_terms:
              - name: HQ_DC_COMMUNITIES
                description: Match any community between 65000:100 and 65000:199
                regex: *65000:1[0-1][0-9]*
                type: regular
```
