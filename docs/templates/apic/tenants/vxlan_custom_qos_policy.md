# VXLAN Custom QoS Policy

Location in GUI:
`Tenants` » `infra` » `Policies` » `Protocol` » `VXLAN Custom QoS Policy`


{{ doc_gen }}

### Examples

This example shows how to configure a VXLAN custom QoS policy with ingress and egress rules:

```yaml
apic:
  tenants:
    - name: infra
      policies:
        vxlan_custom_qos_policies:
          - name: VXLAN_QOS_POL
            description: Custom VXLAN QoS Policy
            ingress_rules:
              - priority: level1
                dscp_from: 0
                dscp_to: 1
                dscp_target: CS0
                cos_target: 1
            egress_rules:
              - dscp_from: AF11
                dscp_to: AF12
                dscp_target: 2
                cos_target: 1
```
