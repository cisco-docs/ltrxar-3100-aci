# Bridge Domain

Location in GUI:
`Tenants` » `XXX` » `Networking` » `Bridge Domains`

In Cisco ACI, a Bridge Domain (BD) is a logical construct that defines a layer-2 forwarding domain. It is the equivalent of a VLAN or a broadcast domain in traditional networking. A BD is created as a component of a tenant and must be associated with one VRF instance.

{{ doc_gen }}

### Examples

Example-1: This is a single example of a layer-3 bridge-domain where the bridge-domain `BD1` is configured under tenant `ABC` and associated with vrf `VRF1`. As this is a layer-3 bridge-domain is it configured with IP subnet `1.1.1.1/24`. The rest of the bridge-domain settings uses default values.

```yaml
apic:
  tenants:
    - name: ABC
      bridge_domains:
        - name: BD1
          vrf: VRF1
          subnets:
            - ip: 1.1.1.1/24
```

Example-2: This is a single example of a layer-2 bridge-domain where the bridge-domain `BD1` is configured under tenant `ABC` and associated with vrf `VRF1`. Unlike a layer-3 bridge-domain, no IP subnet is configured. Instead,, L2 unknown unicast is set to `flooding`, unicast routing is `disabled`, and ARP flooding is `enabled`. The rest of the settings use default values.

```yaml
apic:
  tenants:
    - name: ABC
      bridge_domains:
        - name: BD1
          vrf: VRF1
          unknown_unicast: flood
          arp_flooding: true
          unicast_routing: false
```

Example-3: This is a single example of a configuration where all parameters are explicitly specified.

```yaml
apic:
  tenants:
    - name: ABC
      bridge_domains:
        - name: BD1
          alias: ABC_BD1
          mac: 00:22:BD:F8:19:FE
          virtual_mac: 00:23:BD:F8:19:12
          ep_move_detection: true
          arp_flooding: false
          ip_dataplane_learning: false
          limit_ip_learn_to_subnets: false
          multi_destination_flooding: encap-flood
          unknown_unicast: proxy
          unknown_ipv4_multicast: flood
          unknown_ipv6_multicast: flood
          unicast_routing: true
          clear_remote_mac_entries: true
          advertise_host_routes: true
          l3_multicast: false
          multicast_arp_drop: false
          vrf: VRF1
          nd_interface_policy: "ND_INTF_POL1"
          endpoint_retention_policy: ERP1
          subnets:
            - ip: 1.1.1.1/24
              description: My Desc
              primary_ip: true
              public: true
              shared: true
              virtual: false
              igmp_querier: true
              nd_ra_prefix: true
              no_default_gateway: false
            - ip: fd00:0:abcd:1::1/64
              description: My IPv6 Desc
              primary_ip: true
              public: true
              shared: false
              virtual: false
              igmp_querier: true
              nd_ra_prefix: true
              no_default_gateway: false
              nd_ra_prefix_policy: ND-RA-PREFIX1
              ip_dataplane_learning: false
          l3outs:
            - L3OUT1
          dhcp_labels:
            - dhcp_relay_policy: DHCP-RELAY1
              dhcp_option_policy: DHCP-OPTION1
```
