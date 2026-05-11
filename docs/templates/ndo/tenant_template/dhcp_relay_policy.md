# DHCP Relay Policy

Location in GUI:
`Tenant Template` » `Tenant Policies`

{{ doc_gen }}

### Examples

Example-1: The example below shows a tenant policy template called `TP1` that is created under the tenant `NDO1` and the site `APIC1`. The DHCP relay policy `DRP1` is defined under the tenant policy template. In this DHCP Relay policy there is one provider `P1` that is defined with the IP address `1.1.1.1` and the type `epg`. The EPG name is `EPG1` and it is located in the schema `ABC`, template `TEMPLATE1` and the application profile `AP1`. The provider `P1` is also configured to use the server VRF.

```yaml
ndo:
  tenant_templates:
    tenant_policies:
      - name: TP1
        tenant: NDO1
        sites:
          - APIC1
        dhcp_relay_policies:
          - name: DRP1
            description: DHCP Relay Policy
            providers:
              - name: P1
                ip: 1.1.1.1
                type: epg
                schema: ABC
                template: TEMPLATE1
                application_profile: AP1
                endpoint_group: EPG1
                use_server_vrf: true
```
