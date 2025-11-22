# MCP Interface Policy

Location in GUI:
`Fabric` » `Access Policies` » `Policies` » `Interface` » `MCP Interface`


{{ doc_gen }}

### Examples

Example 1: In this first example we created an MCP policy to enable MCP onto an interface. For the policy to take affect MCP needs to be enabled globally first. The global MCP policy is defined in the apic.acces_policies.mcp object in the data model.

```yaml
apic:
  access_policies:
    interface_policies:
      mcp_policies:
        - name: mcpEnabled
          admin_state: true
```

Example 2: In this first example we created an MCP policy to disable MCP onto an interface. For the policy to take affect MCP needs to be enabled globally first. The global MCP policy is defined in the apic.acces_policies.mcp object in the data model.

```yaml
apic:
  access_policies:
    interface_policies:
      mcp_policies:
        - name: mcpDisabled
          admin_state: false
```
