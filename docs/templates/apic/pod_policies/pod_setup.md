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
