# Link Level Interface Policy

Location in GUI:
`Fabric` » `Access Policies` » `Policies` » `Interface` » `Link Level`


{{ doc_gen }}

### Examples

Example 1: The YAML snippet below demonstrates how to configure link-level policies. This includes setting the `link_delay_interval` and `link_debounce_interval` parameters. These are important for managing the "Port Bring-up Delay" required by various Line Cards, such as the Oracle Exadata CX5 Mellanox NICs. Both `link_delay_interval` and `link_debounce_interval` values are specified in milliseconds (ms), and `link_delay_interval` is set to 0ms by default.

```yaml
apic:
  access_policies:
    interface_policies:
      link_level_policies:
        - name: 10G-CX5
          speed: 10G
          link_delay_interval: 10
          link_debounce_interval: 110
          auto: true
          fec_mode: inherit
```

Example 2: The YAML snippet below demonstrates the flexibility of converting a fiber port into a copper port. By specifying the `physical_media_type` as `sfp-10g-tx`, we can easily integrate copper-based devices into the network infrastructure. The `physical_media_type` field can be set to either `auto` or `sfp-10g-tx`.

```yaml
apic:
  access_policies:
    interface_policies:
      link_level_policies:
          - name: 10G-CU
            speed: 10G
            auto: true
            fec_mode: inherit
            physical_media_type: sfp-10g-tx
```
