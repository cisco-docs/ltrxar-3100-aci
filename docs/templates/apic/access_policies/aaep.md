# AAEP

Location in GUI:
`Fabric` » `Access Policies` » `Policies` » `Global` » `Attachable Access Entity Profiles`

If `infra_vlan` is enabled, the infrastructure VLAN ID must be configured under `access_policies`.

```yaml
apic:
  access_policies:
    infra_vlan: 10
```


{{ doc_gen }}

### Examples

Example-1: This example configures a basic `AAEP1` which is associated to a physical domain named `PHY1`.

```yaml
apic:
  access_policies:
    aaeps:
      - name: AAEP1
        physical_domains:
          - PHY1
```

Example-2: This example configures an AAEP `AAEP1` which is associated to multiple domains of multiple types: `PHY1` physical domain, `ROUTED1` routed domain, and `VMM1` VMware VMM domain.

```yaml
apic:
  access_policies:
    aaeps:
      - name: AAEP1
        infra_vlan: true
        physical_domains:
          - PHY1
        routed_domains:
          - ROUTED1
        vmware_vmm_domains:
          - VMM1
```

Examlpe-3: this examlpe configures an AAEP `SCVMM` with the infra_vlan parameter enabled, which enables the extension of the ACI infra VLAN into external domains such as Microsoft SCVMM or other OpFlex-capable solutions. This is required in such integrations to enable the extension of the ACI infra into a non-ACI infra. The relevant domains must be associated to the AAEP to enable the integration, in this case `SCVMM` physical domain. It is recommended use a dedicated AAEP for such integrations, hence the `PHY1` physical domain being associated to another AAEP with the infra_vlan parameter left unspecified, since its default is `false`.

```yaml
apic:
  access_policies:
    infra_vlan: 10
    aaeps:
      - name: AAEP1
        physical_domains:
          - PHY1
      - name: SCVMM
        infra_vlan: true
        physical_domains:
          - SCVMM
```

Example-4: this is a full example demonstrating `AAEP1` being associated with `PHY1` physical domain, `ROUTED1` routed domain, and `VMM1` VMware VMM domain. It also utilizes the AAEP-to-EPG association feature to bulk-configure inerfaces with a given VLAN. In this case, it shows the `EPG1` EPG under the `AP1` app profile under the `ABC` tenant, using VLAN `1234` in `untagged` (access) mode.

```yaml
apic:
  access_policies:
    infra_vlan: 10
    aaeps:
      - name: AAEP1
        infra_vlan: true
        physical_domains:
          - PHY1
        routed_domains:
          - ROUTED1
        vmware_vmm_domains:
          - VMM1
        endpoint_groups:
          - tenant: ABC
            application_profile: AP1
            endpoint_group: EPG1
            vlan: 1234
            mode: untagged
            deployment_immediacy: immediate
```
