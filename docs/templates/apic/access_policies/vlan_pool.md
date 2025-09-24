# VLAN Pool

Location in GUI:
`Fabric` » `Access Policies` » `Pools` » `VLAN`


{{ doc_gen }}

### Examples

Example-1: This configuration defines a static VLAN pool named `STATIC1` for external use. The pool allocates VLANs statically within the range `4000–4002`, with the role set to `external`. This is typically used for assigning specific VLANs to external connectivity or services, ensuring that the VLAN IDs are reserved and not dynamically assigned elsewhere in the fabric.

```yaml
apic:
  access_policies:
    vlan_pools:
      - name: STATIC1
        description: "Static VLAN Pool"
        allocation: static
        ranges:
          - from: 4000
            to: 4002
            role: external
            description: "Range #1"
```

Example-2: This example creates a dynamic VLAN pool named `DYNAMIC_INTERNAL`, intended for internal VLAN allocation. The pool includes two ranges: one for general internal VLANs and another for a special project. The allocation is set to `dynamic`, and the role is `internal`.


```yaml
apic:
  access_policies:
    vlan_pools:
      - name: DYNAMIC_INTERNAL
        description: "Dynamic VLAN Pool for Internal Networks"
        allocation: dynamic
        ranges:
          - from: 100
            to: 150
            role: internal
            description: "General Internal VLANs"
          - from: 200
            to: 210
            role: internal
            description: "Project VLANs"
```
