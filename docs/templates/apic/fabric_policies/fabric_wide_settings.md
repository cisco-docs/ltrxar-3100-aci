# Fabric Wide Settings

Location in GUI:
`System` » `System Settings` » `Fabric-Wide Settings`


{{ doc_gen }}

### Examples

Example-1: This example demonstrates how to configure Fabric-Wide Settings under System Settings. In this example, opflex_authentication is enabled to override the default, while all other settings remain at their defaults. By default, domain_validation, enforce_subnet_check, overlapping_vlan_validation, and remote_leaf_direct are enabled, and disable_remote_endpoint_learn and reallocate_gipo are disabled, which is considered a general best practice unless there is a valid requirement to override them.

```yaml
apic:
  fabric_policies:
    global_settings:
      opflex_authentication: true

```

Example-2: This example demonstrates how to configure Fabric-Wide Settings under System Settings. The configured settings are the same as Example-1, but all default settings are specified explicitly in the configuration for clarity.

```yaml
apic:
  fabric_policies:
    global_settings:
      domain_validation: true
      enforce_subnet_check: true
      opflex_authentication: true
      disable_remote_endpoint_learn: false
      overlapping_vlan_validation: true
      remote_leaf_direct: true
      reallocate_gipo: false

```
