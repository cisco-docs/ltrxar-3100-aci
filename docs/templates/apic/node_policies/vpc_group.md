# VPC Groups

vPC groups can be named according to a naming convention defined once, without having to specify a name for every group. The following placeholders can be used when defining the naming convention:

* `\\g<switch1_id>`: gets replaced by the respective node ID of the first leaf
* `\\g<switch2_id>`: gets replaced by the respective node ID of the second leaf

Location in GUI:
`Fabric` » `Access Policies` » `Policies` » `Switch` » `Virtual Port Channel default`


{{ doc_gen }}

### Examples

Example 1: In the example below we create vPC pairs by manually defining them, including the name of the group. The `switch_1` and `switch_2` refer to the nodes ids which were assigned during discovery, where the `id` is a new id which refers to the new vPC group containing both leaf switches.

```yaml
apic:
  node_policies:
    vpc_groups:
      mode: explicit
      groups:
        - id: 101
          switch_1: 101
          switch_2: 102
          name: vpc-group-1
```

Example 2: In the example below we create vPC pairs by manually defining them and we apply a vpc domain policy defining the peer dead interval and delay restore timers. The policy `myVpcPolicy` is a policy which defines the `peer_dead_interval` and `delay_restore_timer` for a leaf switch. (apic:access_policies:switch_policies:vpc_policies)

```yaml
apic:
  node_policies:
    vpc_groups:
      mode: explicit
      groups:
        - id: 101
          switch_1: 101
          switch_2: 102
          policy: myVpcPolicy
```

Example 3: In the example below we automatically create vPC pairs of all switches in a consecutive order (101-102, 103-104,...) .

```yaml
apic:
  node_policies:
    vpc_groups:
      mode: consecutive
```

Example 4: In the example below we automatically create vPC pairs of all switches in a reciprocal order (101-103, 102-104,...) .

```yaml
apic:
  node_policies:
    vpc_groups:
      mode: reciprocal
```


Example 5: In the example below we create vPC pairs by manually defining them, but we make use of the automatic naming convention for each group. Where in our example this would result into `vpc-101-102`. The `\g` will capture a value of the object listed between `<>` from within this group, which is in our case the `switch1_id` and `switch2_id` values.

```yaml
apic:
  access_policies:
    vpc_group_name: vpc-\g<switch1_id>-\g<switch2_id>
  node_policies:
    vpc_groups:
      mode: explicit
      groups:
        - id: 101
          switch_1: 101
          switch_2: 102
```
