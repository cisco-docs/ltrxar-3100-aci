# Forwarding Scale Switch Policy

Location in GUI:
`Fabric` » `Access Policies` » `Policies` » `Switch` » `Forwarding Scale Profiles`


{{ doc_gen }}

### Examples

Example-1: this example configures a `HIGH-DUAL-STACK` forwarding scale policy, which chooses the profile type of `high-dual-stack`, which increaes the IPv4 and IPv6 routing scale in favor of other scaling options such as TCAM for contracts, EP table, or multicast routing. The exact nature of the profile to choose will be based on the switch model, published scaling numbers for each profile, and the leaf switch role within the fabric (e.g. border, compute, service, or mixed leaf).

```yaml
apic:
  access_policies:
    switch_policies:
      forwarding_scale_policies:
        - name: HIGH-DUAL-STACK
          profile: high-dual-stack
```
