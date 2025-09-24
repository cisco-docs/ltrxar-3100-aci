# Rogue EP Control

Location in GUI:
`System` » `System Settings` » `Endpoint Controls` » `Rogue EP Control`


{{ doc_gen }}

### Examples

Example-1: This example demonstrates how to configure Rogue Endpoint Control, which identifies an endpoint (MAC/IP address) as rogue when the same endpoint is learned on different interfaces multiple times within the configured interval. By default, Rogue Endpoint Control is enabled, which is a general best practice. In this example, Rogue Endpoint Control is enabled with detection_interval set to `180` seconds (default 30), detection_multiplier  set to `10` (default 10) and hold_interval set to `1800` seconds (defult 1800 seconds).

```yaml
apic:
  fabric_policies:
    rogue_ep_control:
      admin_state: true
      detection_interval: 180
      detection_multiplier: 10
      hold_interval: 1800
```
