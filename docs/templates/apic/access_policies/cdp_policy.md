# CDP Interface Policy

Location in GUI:
`Fabric` » `Access Policies` » `Policies` » `Interface` » `CDP Interface`


{{ doc_gen }}

### Examples

Example-1: this example configures a CDP policy named `CDP-ENABLED`, which enables CDP on the associated interfaces due to the admin_state property being set to `true`. Since CDP is a Cisco-proprietary protocol, it should be enabled on interfaces connecting to devices only. LLDP is the vendor-agnostic alternative. A CDP policy may also be required for VMM integration as part of the vSwitch policy configuration. 

```yaml
apic:
  access_policies:
    interface_policies:
      cdp_policies:
        - name: CDP-ENABLED
          admin_state: true
```
