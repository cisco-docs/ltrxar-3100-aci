# Route Control Route Map

Location in GUI:
`Tenants` » `XXX` » `Policies` » `Protocol` » `Route Maps for Route Control`

{{ doc_gen }}

### Examples

Example-1: This is a basic route-map `ROUTE_MAP_1` used to control which routes are advertised/received (based on which direction the route map is applied in). The route-map type is `combinable`, meaning it will match the prefixes explicitly configured in the match rules, in addition to any BD subnets for which the BD is associated with an L3Out, and any external EPG subnets marked for export route control. The route map consists of a single context named `DC_PREFIXES`, for which the action is `permit` to accept all matching prefixes. The context order is set to `4` even though it is the only context in to accomodate for future flexibility if another context is to be added above this one. Within the context, a match rule `DC_PREFIXES` is configured, and no set rules are configured, meaning the matched prefixes will be advertised/received as is.

```yaml
apic:
  tenants:
    - name: ABC
      policies:
        route_control_route_maps:
          - name: ROUTE_MAP_1
            type: combinable
            contexts:
              - name: DC_PREFIXES
                action: 'permit'
                order: 4
                match_rules:
                  - DC_PREFIXES
```

Example-2: This route-map `ROUTE_MAP_2` shows an example of the application of BGP routing policies. Its type is `global`, meaning matching will only occur based on the associated match rules (`DC_PREFIXES` in this example), and BD/extEPG subnet flags will be ignored. This behaves the same way as the well-known route-maps on NX-OS and other platforms. The route-map is configured with a set rule named `SET_BGP_ATTRS`, which can set a number of BGP attributes as per the overall BGP/routing design (e.g. weight, next-hop, community, metric, AS path, etc.)

```yaml
apic:
  tenants:
    - name: ABC
      policies:
        route_control_route_maps:
          - name: ROUTE_MAP_1
            type: global
            contexts:
              - name: DC_PREFIXES
                action: permit
                match_rules:
                  - DC_PREFIXES
                set_rule: SET_BGP_ATTRS
```

Example-3: This route-map `ROUTE_MAP_3` is a multi-context route-map. This is configured to treat different prefixes differently, such as to set attributes differently for each context. This example showcases a common use case with ACI multi-site when using inter-site L3Outs. The first context of `DR_PREFIXES` matches the `DR_DC_PREFIXES` and `DR_DMZ_PREFIXES` match rules, and will then use the `PREPEND_AS` set rule to prepend the remote site subnets' AS-path to optimize the N/S traffic path. The second context of `HQ_PREFIXES` matches against the `HQ_DC_PREFIXES` and `HQ_DMZ_PREFIXES` match rules, but without using any set rule. If not using inter-site L3Outs, the first context action may be set to `deny` to prevent any routing mishaps altogether.

```yaml
apic:
  tenants:
    - name: ABC
      policies:
        route_control_route_maps:
          - name: ROUTE_MAP_1
            type: global
            contexts:
              - name: DR_PREFIXES
                action: permit
                match_rules:
                  - DR_DC_PREFIXES
                  - DR_DMZ_PREFIXES
                set_rule: PREPEND_AS
              - name: HQ_PREFIXES
                action: permit
                match_rules:
                  - HQ_DC_PREFIXES
                  - HQ_DMZ_PREFIXES
```
