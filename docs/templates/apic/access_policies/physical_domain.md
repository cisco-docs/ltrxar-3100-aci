# Physical Domain

Location in GUI:
`Fabric` » `Access Policies` » `Physical and External Domains` » `Physical Domains`


{{ doc_gen }}

### Examples

```yaml
apic:
  access_policies:
    physical_domains:
      - name: PHY1
        vlan_pool: STATIC1
```

Example-1: This example creates a physical domain named `PROD_PHY` that is associated with a VLAN pool called `PROD_VLANS` using dynamic allocation. The physical domain is also linked to two security domains: `PROD_SEC` and `AUDIT_SEC`. This configuration ensures that the physical domain is properly segmented and secured according to organizational requirements.

```yaml
apic:
  access_policies:
    vlan_pools:
      - name: PROD_VLANS
        allocation: dynamic
    physical_domains:
      - name: PROD_PHY
        vlan_pool: PROD_VLANS
        security_domains:
          - PROD_SEC
          - AUDIT_SEC

```

Example-2: This example defines a physical domain named `LAB_PHY` using the VLAN pool `LAB_VLANS` with static allocation. It is associated with the security domain `LAB_SEC`, suitable for lab or test environments.

```yaml
apic:
  access_policies:
    vlan_pools:
      - name: LAB_VLANS
        allocation: static
    physical_domains:
      - name: LAB_PHY
        vlan_pool: LAB_VLANS
        security_domains:
          - LAB_SEC
```
