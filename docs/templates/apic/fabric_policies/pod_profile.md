# Fabric Pod Profile

Location in GUI:
`Fabric` » `Fabric Policies` » `Pods` » `Profiles`


{{ doc_gen }}

### Examples

Pod Profile Example:

```yaml
apic:
  auto_generate_switch_pod_profiles: false
  fabric_policies:
    pod_profiles:
      - name: PodProfile1
        selectors:
          - name: Selector1
            type: range
            policy: Policy1
            pod_blocks:
              - name: "1"
                from: 1
                to: 1
```
Auto-generated Pod Profile Example:

```yaml
apic:
  auto_generate_switch_pod_profiles: true
  fabric_policies:
    pod_profile_name: "POD\\g<id>"
    pod_profile_pod_selector_name: "POD\\g<id>"
```
