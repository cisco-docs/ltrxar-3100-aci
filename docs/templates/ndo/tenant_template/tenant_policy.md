# Tenant Policy

Location in GUI:
`Tenant Template` » `Tenant Policies`

{{ doc_gen }}

### Examples

Example-1: The example below shows a tenant policy template called `TP1` that is created under the tenant `NDO1` and the site `APIC1`.

```yaml
ndo:
  tenant_templates:
    tenant_policies:
      - name: TP1
        tenant: NDO1
        sites:
          - APIC1
```
