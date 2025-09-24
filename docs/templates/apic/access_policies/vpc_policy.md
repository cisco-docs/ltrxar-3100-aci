# vPC Switch Policy

Location in GUI:
`Fabric` » `Access Policies` » `Policies` » `Switch` » `VPC Domain`


{{ doc_gen }}

### Examples

Example 1: In this example we create our own vPC policy which can be applied to vPC groups, it defines the time to wait until a peer is decleared dead (`peer_dead_interval`) and as of when it is considered up (`delay_restore_timer`).

```yaml
apic:
  access_policies:
    switch_policies:
      vpc_policies:
        - name: myVpcPolicy
          peer_dead_interval: 300
          delay_restore_timer: 210
```

Example 2: In this example we modify the default timers which are automatically applied to all nodes unless a specific policy is applied to a vPC Group. 

```yaml
apic:
  access_policies:
    switch_policies:
      vpc_policies:
        - name: default
          peer_dead_interval: 300
          delay_restore_timer: 210
```
