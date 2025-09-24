# VMware VMM Domain

Location in GUI:
`Virtual Networking` » `VMware`


{{ doc_gen }}

### Examples

Example-1: this is a simple VMM domain named `VMM_DOM` with the most basic required data. The VMM domain is associated with a dynamic VLAN pool `VMM_VLP`, and is configured with the integration credentials under the `VCENTER_CREDS` credentials policy, specifying the vSphere username and password. These credentials are used to authenticate against the vCenters defined under the vcenters list, named `PROD_VCENTER`, which defines the vCenter hostname/IP of `10.10.10.10`, datacenter name on the vSphere side (`DC1` in this example), and the associated credentials policy. A new VDS with the name of the VMM domain will be created on the vCenter upon successful integration. 

```yaml
apic:
  fabric_policies:
    vmware_vmm_domains:
      - name: VMM_DOM
        vlan_pool: VMM_VLP
        credential_policies:
          - name: VCENTER_CREDS
            username: admin
            password: password
        vcenters:
          - name: PROD_VCENTER
            hostname_ip: 10.10.10.10
            datacenter: DC1
            credential_policy: VCENTER_CREDS
```
Example-2: this VMM domain `VMM_DOM` defines specific configuration for the vSwitch policies, such as the CDP, LLDP and port-channel policies for the VDS. If left unspecified, the APIC will create custom CDP and LLDP policies for the VDS, so the system policies are used to achieve the required intent. CDP is enabled as it is used by default on the VDS using the ACI system policy of `system-cdp-enabled`, and LLDP is disabled using the equivalent `system-lldp-disabled` policy. The port-channel policy is set to `system-mac-pinning` to enable load sharing across the uplinks without using LACP, following the recommendation from VMware. This VMM domain defines the uplinks as well to be used by the ESXi hosts to be attached to the VDS, in this case defining `UPLINK1` and `UPLINK2` with their respective IDs of `1` and `2`. This should only be defined when the uplink count is well-known and uniform across all hosts attached to the VDS, otherwise it should be left undefined for the VMware admin to define as needed. 

```yaml
apic:
  fabric_policies:
    vmware_vmm_domains:
      - name: VMM_DOM
        vlan_pool: VMM_VLP
        credential_policies:
          - name: VCENTER_CREDS
            username: admin
            password: password
        vcenters:
          - name: PROD_VCENTER
            hostname_ip: 10.10.10.10
            datacenter: DC1
            credential_policy: VCENTER_CREDS
        vswitch:
          cdp_policy: system_cdp_pol_enabled
          lldp_policy: system_lldp_pol_disabled
          port_channel_policy: system_mac_pinning
        uplinks:
          - id: 1
            name: UPLINK_1
          - id: 2
            name: UPLINK_2
```

Example-3: full example- of VMM domain with all properties configured

```yaml
apic:
  fabric_policies:
    vmware_vmm_domains:
      - name: VMM1
        access_mode: read-write
        delimiter: '|'
        tag_collection: true
        vlan_pool: VMM1
        allocation: dynamic
        vswitch:
          cdp_policy: CDP-ENABLED
          lldp_policy: LLDP-ENABLED
          port_channel_policy: LACP-ACTIVE
          netflow_exporter_policy: VMM-EXPORTER1
          enhanced_lags:
            - name: ELAGCUSTOM
              mode: active
              lb_mode: src-dst-l4port
              num_links: 3
        credential_policies:
          - name: CRED1
            username: Administrator
            password: C1sco123
        vcenters:
          - name: VC
            hostname_ip: 10.10.10.10
            datacenter: DC1
            dvs_version: unmanaged
            statistics: true
            credential_policy: CRED1
        uplinks:
          - id: 1
            name: UPLINK1
          - id: 2
            name: UPLINK2
```
