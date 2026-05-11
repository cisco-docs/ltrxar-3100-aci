# HSRP Interface Policy

Location in GUI:
`Tenants` » `XXX` » `Policies` » `Protocol` » `HSRP` » `HSRP Interface Policies`


{{ doc_gen }}

### Examples

Simple example:

```yaml
apic:
  tenants:
    - name: ABC
      policies:
        hsrp_interface_policies:
          - name: HSRP_IF1
            bfd_enable: true
```

Full example:

```yaml
apic:
  tenants:
    - name: ABC
      policies:
        hsrp_interface_policies:
          - name: HSRP_IF1
            description: My HSRP Interface Policy
            bfd_enable: true
            use_bia: false
            delay: 5
            reload_delay: 10
```
