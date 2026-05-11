# Port Security Policy

Location in GUI:
`Fabric` » `Access Policies` » `Policies` » `Interface` » `Port Security`


{{ doc_gen }}

### Examples

Example-1: This configuration creates a port security policy named `PS-FULL` with a maximum of 100 endpoints allowed and a timeout of 120 seconds. When the maximum endpoints limit is reached, new MAC addresses will not be learned until existing entries age out.

```yaml
apic:
  access_policies:
    interface_policies:
      port_security_policies:
        - name: PS-FULL
          description: Port Security Full Config
          maximum_endpoints: 100
          timeout: 120
```

Example-2: This example defines a port security policy named `PS-STRICT` with strict endpoint limiting. Only 10 endpoints are allowed, and the timeout is set to one hour (3600 seconds). This is useful for high-security environments where the number of devices connecting to a port must be tightly controlled.

```yaml
apic:
  access_policies:
    interface_policies:
      port_security_policies:
        - name: PS-STRICT
          description: Strict port security
          maximum_endpoints: 10
          timeout: 3600
```

Example-3: This configuration creates a minimal port security policy named `PS-MIN` using all default values. The maximum_endpoints defaults to 0 (unlimited) and timeout defaults to 60 seconds.

```yaml
apic:
  access_policies:
    interface_policies:
      port_security_policies:
        - name: PS-MIN
```

### Attaching Port Security Policy to Interface Policy Group

To apply the port security policy to an interface, reference it in a leaf interface policy group:

```yaml
apic:
  access_policies:
    leaf_interface_policy_groups:
      - name: ACC1
        type: access
        port_security_policy: PS-FULL
```
