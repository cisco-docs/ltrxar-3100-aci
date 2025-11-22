# Storm Control Interface Policy

Location in GUI:
`Fabric` » `Access Policies` » `Policies` » `Interface` » `Storm Control`


{{ doc_gen }}

### Examples

Example-1: This configuration creates a storm control policy named `20P` with a burst rate and rate of burst_pps (packet-per-second) and rate_pps are left unspecified, meaning they are not set. This policy applies the same rate limits to all traffic types (broadcast, multicast, unknown unicast) as per the default behavior.

```yaml
apic:
  access_policies:
    interface_policies:
      storm_control_policies:
        - name: 20P
          alias: 20P
          burst_pps: unspecified
          rate_pps: unspecified
          burst_rate: 20
          rate: 20
```

Example-2: This example defines a storm control policy named `10P` that sets specific rate and burst rate limits to `10` for broadcast, multicast, and unknown unicast traffic. The action is set to drop, meaning traffic exceeding these limits will be dropped. All `*_pps` fields (packet-per-second) are unspecified, so only rate-based limits are enforced.

```yaml
apic:
  access_policies:
    interface_policies:
      storm_control_policies:
        - name: 10P
          alias: 10P
          broadcast_burst_pps: unspecified
          broadcast_pps: unspecified
          broadcast_burst_rate: 10
          broadcast_rate: 10
          multicast_burst_pps: unspecified
          multicast_pps: unspecified
          multicast_burst_rate: 10
          multicast_rate: 10
          unknown_unicast_burst_pps: unspecified
          unknown_unicast_pps: unspecified
          unknown_unicast_burst_rate: 10
          unknown_unicast_rate: 10
          action: drop
```

Example-3: This configuration defines a storm control policy named `SEPARATE_LIMITS` with the alias `SEPLIM`. It sets individual pps (packet-per-second) limits for all, broadcast, multicast, and unknown unicast traffic types. If any of the specified thresholds are exceeded, the action taken is to administratively shut down the affected interface. This allows for granular protection against network storms on a per-traffic-type basis.

```yaml
apic:
  access_policies:
    interface_policies:
      storm_control_policies:
        - name: SEPARATE_LIMITS
          alias: SEPLIM
          description: "Separate storm control for each traffic type"
          burst_pps: 5000
          rate_pps: 1000
          broadcast_burst_pps: 2000
          broadcast_pps: 500
          multicast_burst_pps: 1500
          multicast_pps: 300
          unknown_unicast_burst_pps: 1000
          unknown_unicast_pps: 200
          action: shutdown
```
