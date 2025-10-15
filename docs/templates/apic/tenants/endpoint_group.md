# Endpoint Group

Location in GUI:
`Tenants` » `XXX` » `Application Profiles` » `XXX` » `Application EPGs`

In Cisco ACI, an Endpoint Group (EPG) is a logical group of endpoints (such as servers, virtual machines, and containers) that share common network and security policies.

{{ doc_gen }}

### Examples

Example-1: This is a single example of an EPG configuration where a static port is defined using a single interface (non-vPC, non-port-channel). The configuration is placed under application profile `AP1` and associated with bridge-domain `BD1`. The physical domain `PHY1` is specified, and in the static port configuration, interface `Eth1/10` on leaf node `101` with VLAN `135` is defined. In addition, the consumer contract `CON1` is applied. The rest of the settings use default values.

```yaml
apic:
  tenants:
    - name: ABC
      application_profiles:
        - name: AP1
          endpoint_groups:
            - name: EPG1
              bridge_domain: BD1
              physical_domains:
                - PHY1
              static_ports:
                - node_id: 101
                  port: 10
                  vlan: 135
              contracts:
                consumers:
                  - CON1
```

Example-2: This is a single example of an EPG configuration where a static port is defined using a vPC interface. The predefined vPC interface policy group `Lf1010_Lf1011_eth1_1_vPC` from the Access Policy is specified, and the nodes are defined as the vPC peers, leaf `1010` and leaf `1011`. In this example, the mode is explicitly set to regular (trunk) and the deployment immediacy is specified as immediate. Apart from the static port specification, the configuration is the same as Example-1.

```yaml
apic:
  tenants:
    - name: ABC
      application_profiles:
        - name: AP1
          endpoint_groups:
            - name: EPG1
              bridge_domain: BD1
              physical_domains:
                - PHY1
              static_ports:
                - channel: Lf1010_Lf1011_eth1_1_vPC
                  node_id: 1010
                  node2_id: 1011
                  vlan: 135
                  mode: regular
                  deployment_immediacy: immediate
              contracts:
                consumers:
                  - CON1
```

Exaple-3: This is a single example of an EPG configuration where a static port is defined using a PC interface. The predefined PC interface policy group Internet_PC from the Access Policy is specified, and the nodes are defined as the PC, leaf `1010`. In this example, the mode is explicitly set to `regular` (trunk) and the deployment immediacy is specified as `immediate`. Apart from the static port specification, the configuration is the same as Example-1.

```yaml
apic:
  tenants:
    - name: ABC
      application_profiles:
        - name: AP1
          endpoint_groups:
            - name: EPG1
              bridge_domain: BD1
              physical_domains:
                - PHY1
              static_ports:
                - channel: Internet_PC
                  node_id: 1010
                  vlan: 135
                  mode: regular
                  deployment_immediacy: immediate
              contracts:
                consumers:
                  - CON1
```

Example-4: This is a single example of a configuration where all parameters are explicitly specified.

```yaml
apic:
  tenants:
    - name: ABC
      application_profiles:
        - name: AP1
          endpoint_groups:
            - name: EPG1
              bridge_domain: BD1
              flood_in_encap: false
              intra_epg_isolation: false
              preferred_group: false
              data_plane_policing_policy: DPP1
              physical_domains:
                - PHY1
              vmware_vmm_domains:
                - name: VMM1
                  u_segmentation: true
                  delimiter: '|'
                  vlan:
                  primary_vlan: 100
                  secondary_vlan: 101
                  netflow: false
                  deployment_immediacy: lazy
                  resolution_immediacy: immediate
                  allow_promiscuous: reject
                  forged_transmits: reject
                  mac_changes: reject
                  elag: ELAGCustom
                  active_uplinks_order: 1,2
                  standby_uplinks: 3,4
              static_ports:
                - node_id: 101
                  description: Static Port Description
                  port: 10
                  vlan: 135
                  mode: regular
                  deployment_immediacy: lazy
              static_leafs:
                - pod_id: 1
                  node_id: 101
                  vlan: 135
                  primary_vlan: 136
                  mode: regular
                  deployment_immediacy: lazy
              static_endpoints:
                - name: ST_EP1
                  mac: 00:00:00:00:00:01
                  ip: 1.1.1.1
                  type: silent-host
                  vlan: 123
                  node_id: 101
                  port: 1
              contracts:
                consumers:
                  - CON1
                providers:
                  - CON1
                imported_consumers:
                  - IMPORT-CON1
                intra_epgs:
                  - CON1
              subnets:
                - ip: 5.50.5.1/30
                  description: My Desc
                  public: true
                  shared: true
                  igmp_querier: true
                  nd_ra_prefix: true
                  no_default_gateway: false
                - ip: 5.50.5.5/32
                  no_default_gateway: true
                  next_hop_ip: 8.8.8.8
                  ips_pools:
                    - name: POOL1
                      start_ip: 172.16.0.1
                      end_ip: 172.16.0.10
                      dns_server: dns.cisco.com
                      dns_search_suffix: cisco
                      dns_suffix: cisco
                      wins_server: wins
                - ip: fd00:0:abcd:2::2/64
                  description: My IPv6 Desc
                  public: true
                  shared: false
                  igmp_querier: true
                  nd_ra_prefix: true
                  no_default_gateway: true
                  nd_ra_prefix_policy: ND-RA-PREFIX1
                  ip_dataplane_learning: false
              tags:
                - tag1
                - tag2
              l4l7_virtual_ips:
                - ip: 11.11.11.11
                  description: My LB VIP
              l4l7_address_pools:
                - name: L4L7_POOL1
                  gateway_address: 11.11.11.254/24
                  from: 11.11.11.100
                  to: 11.11.11.200
```
