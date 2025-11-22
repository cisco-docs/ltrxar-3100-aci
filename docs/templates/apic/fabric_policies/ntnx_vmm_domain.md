# Nutanix VMM Domain

Location in GUI:
`Virtual Networking` » `Nutanix`

The integration of Nutanix AHV with Cisco ACI was introduced with Cisco APIC Release 6.0(3).

Please note the following constraints:
- Multiple Controllers (vmmCtrIP) are not allowed under Nutanix Domain (vmmDomP)
- Only one Cluster Controller can be associated with a Controller
- Custom vSwitch Name does not allow updates, changes or deletion once the VMM domain is created

{{ doc_gen }}

### Examples

Example-1: The following example defines two Nutanix VMM Domains, `ntnx_1` with default values and `ntnx_2` with custom values. It also associates both VMM domains with an AAEP and an EPG. Keep in mind that it is not recommended to store credentials in plain text within configuration files; consider using environment variables or Vault tools for enhanced security.

```yaml
apic:
  fabric_policies:
    nutanix_vmm_domains:
      - name: ntnx_1
      - name: ntnx_2
        vlan_pool: VPOOL2
        access_mode: read-only
        custom_vswitch_name: open_vswitch
        security_domains:
          - ntnx_2_SD1
          - ntnx_2_SD2
          - ntnx_2_SD3
        credential_policies:
          - name: credentials_central
            username: admin
            password: C1sco123
          - name: credentials_element
            username: root
            password: 1234QWer!
        controller_profile:
          name: ntnx_prism_central
          hostname_ip: 10.10.10.10
          datacenter: DC1
          aos_version: 6.5
          credentials: credentials_central
          statistics: true
        cluster_controller:
          name: ntnx_prism_element
          hostname_ip: 192.168.1.1
          cluster_name: cluster_1
          credentials: credentials_element
          port: 9441
```
