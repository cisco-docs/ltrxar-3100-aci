# Imported Contract

Location in GUI:
`Tenants` » `XXX` » `Contracts` » `Imported`


{{ doc_gen }}

### Examples

Example-1: This data model imports contract `CON1` defined in Tenant `DEF` to enable tenant `ABC` to consume it.  This mechanism allows for controlled sharing of policies and communication rules across tenant boundaries while maintaining tenant isolation. The consumer tenant's Endpoint Groups (EPGs) can then consume the imported contract by adding it as a consumed contract interface.

```yaml
apic:
  tenants:
    - name: ABC
      imported_contracts:
        - name: IMPORT-CON1
          tenant: DEF
          contract: CON1
```
