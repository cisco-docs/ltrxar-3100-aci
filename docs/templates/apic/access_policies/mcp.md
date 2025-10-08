# MCP Global Instance

Location in GUI:
`Fabric` » `Access Policies` » `Policies` » `Global` » `MCP Instance Policy default`


{{ doc_gen }}

### Examples

Example 1: In the first example, we configured the global MCP policy, enabling MCP globally but only on the native VLAN (`per_vlan`). If a loop is detected within the default timers, the port will be disabled (`action`). A key `cisco` has been configured to send out the MCP PDU, and it is validated upon receipt to ensure the loop is detected within the same fabric.

```yaml
apic:
  access_policies:
    mcp:
      admin_state: true
      per_vlan: false
      action: true
      key: cisco
```

Example 2: In this example, we have configured the global MCP policy, whereby MCP is enabled globally and per VLAN (`per_vlan`). Every 5 seconds, an MCP PDU will be transmitted over the enabled interface, which will wait for 180 seconds (`initial_delay`) after the initial interface activation before sending out an MCP PDU every 5 seconds (`frequency_sec`). If the MCP PDU is received 3 times ( `frequency_sec`), the port will be disabled. A key, `cisco`, has been configured to transmit the MCP PDU and is validated upon receipt to ensure that the loop is detected within the same fabric.

```yaml
apic:
  access_policies:
    mcp:
      admin_state: true
      per_vlan: true
      action: true
      key: cisco
      initial_delay: 180
      loop_detection: 3
      frequency_sec: 5
```
