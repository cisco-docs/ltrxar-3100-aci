# Tenant

Tenant is a logical container used to segment and isolate network resources, policies, and configurations. Tenants allow multiple organizations, departments, or applications to securely share the same physical infrastructure while maintaining independent network and security policies.

Location in GUI:
`Tenants`


{{ doc_gen }}

### Examples

Example-1: This example defines a tenant named `ABC` with an alias `ABC-ALIAS` and a description. The tenant is associated with the security domain `SECURITY-DOMAIN1`. This configuration will create or manage the tenant, and associate it with the `SECURITY-DOMAIN1` security domain.

```yaml
apic:
  tenants:
    - name: ABC
      alias: ABC-ALIAS
      description: My Description
      security_domains:
        - SECURITY-DOMAIN1
```
Example-2: This example creates a tenant named `FINANCE` with the alias `FIN-ALIAS` and the description. The tenant is associated with two security domains: `FIN_SEC_DOMAIN` and `AUDIT_SEC_DOMAIN`.

```yaml
apic:
  tenants:
    - name: FINANCE
      alias: FIN-ALIAS
      description: Finance Department Tenant
      security_domains:
        - FIN_SEC_DOMAIN
        - AUDIT_SEC_DOMAIN
```
