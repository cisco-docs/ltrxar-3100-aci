# Route Tag Policy

Location in GUI:
`Tenants` » `XXX` » `Policies` » `Protocol` » `Route Tag`


{{ doc_gen }}

### Examples

Example-1: This data model creates the `Context1` tag and assigns it a value of `112233`. When applied to a specific VRF, it attaches a 32-bit tag to routes during redistribution into supported protocols. This tag serves as an identifier to prevent routing loops. Additionally, Route Tag Policies allow customization of the tag value on a per-VRF basis, which is essential in multi-VRF environments where transit routes are learned from multiple VRFs.

```yaml
apic:
  tenants:
    - name: ABC
      policies:
        route_tag_policies:
          - name: Context1
            description: "My Tag"
            tag: 112233
```
