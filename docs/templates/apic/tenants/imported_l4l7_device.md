# Imported L4L7 Device

Location in GUI:
`Tenants` » `XXX` » `Services` » `L4-L7` » `Imported Devices`

{{ doc_gen }}

### Examples

Example-1: This data model imports the device `FW` which was created in the tenant `PBR_ServGraph` and makes it available for use in the tenant `ABC`. This enables the sharing and reuse of the L4-L7 device across multiple tenants without the need to redefine the device multiple times. In other words, it allows service graph templates and policies in tenant `ABC` to reference the `FW` device.

The data model can be applied as is, regardless of whether the referenced devices exist.

```yaml
apic:
  tenants:
    - name: ABC
      services:
        imported_l4l7_devices:
          - name: FW
            tenant: PBR_ServGraph
```
