# Pod Setup

Location in GUI:
`Fabric` » `Inventory` » `Pod Fabric Setup Policy`


{{ doc_gen }}

### Examples

```yaml
apic:
  pod_policies:
    pods:
      - id: 1
      - id: 2
        tep_pool: 10.1.0.0/16
        external_tep_pools:
          - prefix: 172.16.1.0/24
            reserved_address_count: 2
        remote_pools:
          - id: 1
            remote_pool: 10.2.0.0/24
```

Auto-generated Pod Profiles Full Example:

```yaml
apic:
  auto_generate_switch_pod_profiles: true
  fabric_policies:
    pod_profile_name: POD\g<id>
    pod_profile_pod_selector_name: POD\g<id>
    pod_policy_groups:
      - name: Policy1
  pod_policies:
    pods:
      - id: 1
        policy: Policy1
```

Example: This example shows the Autonomous RL Group feature configuration. This was introduced in 6.1(3) ACI release. The first section contains all the configurable attributes for this feature, while the second section contains an example of the minimal required configuration.

```yaml
apic:
  pod_policies:
    pods:
      - id: 3
        tep_pool: 10.3.0.0/16
        data_plane_tep: 192.168.3.1
        unicast_tep: 172.16.13.3
        policy: POD3
        resiliency_groups:
          # Resiliency Group 1 with all the configurable atrributes
          - name: 1
            description: Resiliency Group 1
            remote_pool_ids:
              - 1
              - 2
              - 3
          # Resiliency Group 2 with minimal required configuration
          - name: 2
```
