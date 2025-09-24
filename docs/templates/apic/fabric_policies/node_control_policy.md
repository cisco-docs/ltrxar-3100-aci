# Node Control Switch Policy

Location in GUI:
`Fabric` » `Fabric Policies` » `Policies` » `Monitoring` » `Fabric Node Controls`


{{ doc_gen }}

### Examples

Example-1: this node contro policy named `NODE_CTRL_POL`, which enables digital optics monitoring by setting the dom property to `true`. It also defines the telemetry property to `telemetry`, which is required for Cisco NDI integration. This property can alternatively be set to `analytics` when integrating the ACI fabric with Cisco Secure Workload (previously known as Tetration), or set to `netflow` for standard NetFlow integration. 

```yaml
apic:
  fabric_policies:
    switch_policies:
      node_control_policies:
        - name: NODE_CTRL_POL
          dom: true
          telemetry: telemetry
```
