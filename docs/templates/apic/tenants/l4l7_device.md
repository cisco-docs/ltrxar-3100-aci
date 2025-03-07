# L4L7 Device

Location in GUI:
`Tenants` » `XXX` » `Services` » `L4-L7` » `Devices`


{{ doc_gen }}

### Examples

Simple example:

```yaml
apic:
  tenants:
    - name: ABC
      services:
        l4l7_devices:
          - name: DEV1
            physical_domain: PHY1
            concrete_devices:
              - name: DEV1
                interfaces:
                  - name: INT1
                    node_id: 101
                    port: 11
            logical_interfaces:
              - name: INT1
                vlan: 135
                concrete_interfaces:
                  - device: DEV1
                    interface_name: INT1
```

Full GoTo example:

```yaml
apic:
  tenants:
    - name: ABC
      services:
        l4l7_devices:
          - name: DEV1
            alias: DEV1-ALIAS
            context_aware: single-Context
            type: PHYSICAL
            function: GoTo
            copy_device: false
            managed: false
            promiscuous_mode: false
            service_type: FW
            trunking: false
            physical_domain: PHY1
            concrete_devices:
              - name: DEV1
                alias: DEV1-ALIAS
                vcenter_name:
                vm_name:
                interfaces:
                  - name: INT1
                    alias: INT1-ALIAS
                    vnic_name:
                    node_id: 101
                    module: 1
                    port: 11
                  - name: INT2
                    node_id: 101
                    fex_id: 101
                    port: 13
            logical_interfaces:
              - name: INT1
                alias: INT1-ALIAS
                vlan: 135
                concrete_interfaces:
                  - device: DEV1
                    interface_name: INT1
```

Full L2 example:

```yaml
apic:
  tenants:
    - name: ABC
      services:
        l4l7_devices:
          - name: DEV2
            type: PHYSICAL
            function: L2
            service_type: OTHERS
            physical_domain: PHY1
            active_active: true
            concrete_devices:
              - name: DEV1
                alias: DEV1-ALIAS
                interfaces:
                  - name: INT1
                    node_id: 101
                    module: 1
                    port: 11
                    vlan: 123
                  - name: INT2
                    node_id: 101
                    fex_id: 101
                    port: 13
                    channel: PC1
                    vlan: 124
            logical_interfaces:
              - name: INT1
                alias: INT1-ALIAS
                concrete_interfaces:
                  - device: DEV1
                    interface_name: INT1
              - name: INT2
                concrete_interfaces:
                  - device: DEV1
                    interface_name: INT2
```

Example for GoTo with firewall behind vPC as a concrete device, using vlan-812 as encap with explicit interface configuration (port-channel not created in access_policies.yaml requires providing both node ids): 

```yaml
apic:
  tenants:
    - name: ABC
      services:
        l4l7_devices:
          - name: FW-vl812
            type: PHYSICAL
            function: GoTo
            service_type: FW
            physical_domain: firewalldom
            concrete_devices:
              - name: FW-vl812
                interfaces:
                - name: FW
                  pod_id: 2
                  node_id: 131
                  node2_id: 132
                  channel: fw-vpc
            logical_interfaces:
              - name: FW-vl812
                vlan: 812
                concrete_interfaces:
                  - device: FW-vl812
                    interface_name: FW

```
