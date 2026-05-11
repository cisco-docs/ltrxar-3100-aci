# HSRP Group Policy

Location in GUI:
`Tenants` » `XXX` » `Policies` » `Protocol` » `HSRP` » `HSRP Group Policies`


{{ doc_gen }}

### Examples

Simple example:

```yaml
apic:
  tenants:
    - name: ABC
      policies:
        hsrp_group_policies:
          - name: HSRP_GRP1
            preempt: true
```

Full example:

```yaml
apic:
  tenants:
    - name: ABC
      policies:
        hsrp_group_policies:
          - name: HSRP_GRP1
            description: My HSRP Group Policy
            preempt: true
            hello_interval: 1000
            hold_interval: 3000
            priority: 150
            auth_type: md5
            key: secure_key
            preempt_delay_min: 60
            preempt_delay_reload: 300
            preempt_delay_max: 60
            timeout: 90
```
