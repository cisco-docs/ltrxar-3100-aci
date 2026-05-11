# Priority Flow Control Policy

Location in GUI:
`Fabric` » `Access Policies` » `Policies` » `Interface` » `Priority Flow Control`


### Priority Flow Control States

The PFC state is determined by two boolean variables:

| auto_state | admin_state | Result State |
|------------|-------------|--------------|
| true       | (ignored)   | auto         |
| false      | true        | on           |
| false      | false       | off          |


{{ doc_gen }}

### Examples

Example-1: This configuration creates a priority flow control policy named `PFC-ON` with PFC explicitly enabled. The `auto_state` is set to false to disable auto-negotiation, and `admin_state` is set to true to enable PFC.

```yaml
apic:
  access_policies:
    interface_policies:
      priority_flow_control_policies:
        - name: PFC-ON
          description: Priority Flow Control Enabled
          admin_state: true
          auto_state: false
```

Example-2: This example defines a priority flow control policy named `PFC-OFF` with PFC explicitly disabled. The `auto_state` is set to false and `admin_state` is set to false to disable PFC.

```yaml
apic:
  access_policies:
    interface_policies:
      priority_flow_control_policies:
        - name: PFC-OFF
          description: Priority Flow Control Disabled
          admin_state: false
          auto_state: false
```

Example-3: This configuration creates a priority flow control policy named `PFC-AUTO` with auto-negotiation enabled. When `auto_state` is true, the PFC state is automatically negotiated with the peer.

```yaml
apic:
  access_policies:
    interface_policies:
      priority_flow_control_policies:
        - name: PFC-AUTO
          description: Priority Flow Control Auto
          auto_state: true
```

Example-4: This configuration creates a minimal PFC policy named `PFC-MIN` using all default values. By default, `auto_state` is true and `admin_state` is true.

```yaml
apic:
  access_policies:
    interface_policies:
      priority_flow_control_policies:
        - name: PFC-MIN
```

### Attaching Priority Flow Control Policy to Interface Policy Group

To apply the priority flow control policy to an interface, reference it in a leaf interface policy group:

```yaml
apic:
  access_policies:
    leaf_interface_policy_groups:
      - name: ACC1
        type: access
        priority_flow_control_policy: PFC-ON
```
