# L3out

L3out Node and Interface Profiles can either be auto-generated, one per L3out, or can be defined explicitly.

> Note: Whether an interface is an `svi`, `routed sub-interface`, or `routed` depends on the following configuration:

**svi** - `vlan: <not null>`, `svi: true`, `ip: <not null>`

**routed sub-interface** - `vlan: <not null>`, `svi: false`, `ip: <not null>`

**routed interface** - `vlan: <null>`, `svi: false`, `ip: <not null>`

The following table maps the subnet flags of external endpoint groups to the corresponding GUI terminology:

|Subnet Flag|GUI Terminology|
|---|---|
|`import_security`|`External Subnets for External EPG`|
|`shared_security`|`Shared Security Import Subnet`|
|`import_route_control`|`Import Route Control Subnet`|
|`export_route_control`|`Export Route Control Subnet`|
|`shared_route_control`|`Shared Route Control Subnet`|
|`aggregate_import_route_control`|`Aggregate Import`|
|`aggregate_export_route_control`|`Aggregate Export`|
|`aggregate_shared_route_control`|`Aggregate Shared Routes`|

Location in GUI:

- `Tenants` » `XXX` » `Networking` » `L3outs`

{{ doc_gen }}

### Examples

Simple example:

```yaml
apic:
  tenants:
    - name: ABC
      l3outs:
        - name: L3OUT1
          vrf: VRF1
          domain: ROUTED1
          nodes:
            - node_id: 101
              router_id: 5.5.5.5
              static_routes:
                - prefix: 2.2.2.0/24
                  description: My Desc
                  next_hops:
                    - ip: 6.6.6.6
                  track_list: TRACK_POL
              interfaces:
                - node_id: 101
                  port: 10
                  vlan: 301
                  ip: 14.14.14.1/24
                  bgp_peers:
                    - ip: 14.14.14.14
                      remote_as: 65010
          external_endpoint_groups:
            - name: EXT-EPG1
              subnets:
                - prefix: 0.0.0.0/0
              contracts:
                consumers:
                  - CON1
```

SVI example:

```yaml
apic:
  tenants:
    - name: ABC
      l3outs:
        - name: L3OUT1
          vrf: VRF1
          domain: ROUTED1
          node_profiles:
            - name: NODE_101
              nodes:
                - node_id: 101
                  router_id: 5.5.5.5
                  static_routes:
                    - prefix: 2.2.2.0/24
                      description: My Desc
                      next_hops:
                        - ip: 6.6.6.6
              interface_profiles:
                - name: NODE_101
                  interfaces:
                    - node_id: 101
                      port: 10
                      vlan: 301
                      svi: true
                      ip: 14.14.14.1/24
```

Routed Sub-interface example:

```yaml
apic:
  tenants:
    - name: ABC
      l3outs:
        - name: L3OUT1
          vrf: VRF1
          domain: ROUTED1
          node_profiles:
            - name: NODE_101
              nodes:
                - node_id: 101
                  router_id: 5.5.5.5
                  static_routes:
                    - prefix: 2.2.2.0/24
                      description: My Desc
                      next_hops:
                        - ip: 6.6.6.6
              interface_profiles:
                - name: NODE_101
                  interfaces:
                    - node_id: 101
                      port: 10
                      vlan: 301
                      svi: false
                      ip: 14.14.14.1/24
```

Routed Interface example:

```yaml
apic:
  tenants:
    - name: ABC
      l3outs:
        - name: L3OUT1
          vrf: VRF1
          domain: ROUTED1
          node_profiles:
            - name: NODE_101
              nodes:
                - node_id: 101
                  router_id: 5.5.5.5
                  static_routes:
                    - prefix: 2.2.2.0/24
                      description: My Desc
                      next_hops:
                        - ip: 6.6.6.6
              interface_profiles:
                - name: NODE_101
                  interfaces:
                    - node_id: 101
                      port: 10
                      ip: 14.14.14.1/24
```

Example with explicit profiles:

```yaml
apic:
  tenants:
    - name: ABC
      l3outs:
        - name: L3OUT1
          vrf: VRF1
          domain: ROUTED1
          node_profiles:
            - name: NODE_101
              bgp:
                name: BGP_PROT1
                timer_policy: BGP_TIMER1
                as_path_policy: BGP_AS_PATH1
              nodes:
                - node_id: 101
                  router_id: 5.5.5.5
                  static_routes:
                    - prefix: 2.2.2.0/24
                      description: My Desc
                      next_hops:
                        - ip: 6.6.6.6
                          track_list: TRACK_POL
              interface_profiles:
                - name: NODE_101
                  description: NODE_101 Description
                  ingress_data_plane_policing_policy: DPP1
                  egress_data_plane_policing_policy: DPP2
                  dhcp_labels:
                    - dhcp_relay_policy: DHCP-RELAY1
                      dhcp_option_policy: DHCP-OPTION1
                      scope: tenant
                  interfaces:
                    - node_id: 101
                      port: 10
                      vlan: 301
                      ip: 14.14.14.1/24
                      bgp_peers:
                        - ip: 14.14.14.14
                          remote_as: 65010
          external_endpoint_groups:
            - name: EXT-EPG1
              subnets:
                - prefix: 0.0.0.0/0
```

Full example:

```yaml
apic:
  tenants:
    - name: ABC
      l3outs:
        - name: L3OUT1
          alias: L3OUT1-ALIAS
          description: My Desc
          target_dscp: AF13
          qos_class: level3
          import_route_control_enforcement: true
          export_route_control_enforcement: true
          custom_qos_policy: QOS_POLICY
          ingress_data_plane_policing_policy: DPP1
          egress_data_plane_policing_policy: DPP2
          vrf: VRF1
          domain: ROUTED1
          bfd_policy: BFD1
          dhcp_labels:
            - dhcp_relay_policy: DHCP-RELAY1
              dhcp_option_policy: DHCP-OPTION1
              scope: tenant
          bgp:
            timer_policy: BGP_TIMER1
            as_path_policy: BGP_AS_PATH1
          ospf:
            area: 0
            area_type: regular
            area_cost: 1
            auth_type: simple
            auth_key: cisco
            auth_key_id: 1
            policy: OIP1
          interleak_route_map: ROUTE_MAP1
          default_route_leak_policy:
            always: false
            criteria: 'in-addition'
            context_scope: false
            outside_scope: false
          redistribution_route_maps:
            - source: direct
              route_map: ROUTE_MAP2
          dampening_ipv4_route_map: ROUTE_MAP3
          dampening_ipv6_route_map: ROUTE_MAP4
          bfd_multihop_node_policy: BFD-NODE1
          bfd_multihop_auth:
            type: sha1
            key_id: 1
            key: Secure123
          nodes:
            - node_id: 101
              router_id: 5.5.5.5
              router_id_as_loopback: true
              static_routes:
                - prefix: 2.2.2.0/24
                  description: My Desc
                  preference: 1
                  next_hops:
                    - ip: 6.6.6.6
                      description: My Next Hop Desc
                      ip_sla_policy: IP_SLA1
              interfaces:
                - channel: VPC1
                  svi: true
                  scope: local
                  vlan: 301
                  ip_a: 14.14.14.1/24
                  ip_b: 14.14.14.2/24
                  ip_shared: 14.14.14.3/24
                  ip_shared_dhcp_relay: true
                  link_local_address: fe80::ffff:ffff:ffff:ffff
                  mode: native
                  bgp_peers:
                    - ip: 14.14.14.14
                      remote_as: 65010
                      description: My Desc
                      allow_self_as: true
                      as_override: true
                      bfd: true
                      disable_connected_check: true
                      remove_private_as: true
                      remove_all_private_as: true
                      multicast_address_family: true
                      ttl: 1
                      weight: 0
                      password: C1sco123
                      local_as: 1234
                      as_propagate: dual-as
                      peer_prefix_policy: BGP_PP1
                      export_route_control: ROUTE_MAP1
                      import_route_control: ROUTE_MAP2
                - channel: PC1
                  vlan: 311
                  ip: 24.24.24.1/24
                  bgp_peers:
                    - ip: 24.24.24.2
                      remote_as: 65010
                  micro_bfd:
                    destination_ip: 24.24.24.2
                    start_timer: 120
          import_route_map:
            name: example-import-name
            description: desc
            type: global
            contexts:
              - name: CONTEXT1
                description: desc1
                action: deny
                order: 2
                match_rules:
                - MATCH1
                set_rule: SET1
          route_maps:
            - name: example-name
              description: desc
              type: global
              contexts:
              - name: CONTEXT1
                  description: desc1
                  action: deny
                  order: 2
                  match_rules:
                  - MATCH1
                  set_rule: SET1
          export_route_map:
            name: example-export-name
            contexts:
              - name: CONTEXT1
                match_rules:
                - MATCH2
                set_rule: SET2
          external_endpoint_groups:
            - name: EXT-EPG1
              alias: ABC-EXT-EPG1
              description: My Desc
              preferred_group: false
              qos_class: level4
              target_dscp: CS5
              route_control_profiles:
                - name: IMPORT-RCP1
                  direction: import
              subnets:
                - name: ALL
                  prefix: 0.0.0.0/0
                  import_route_control: false
                  export_route_control: false
                  shared_route_control: false
                  import_security: true
                  shared_security: false
                  route_control_profiles:
                    - name: EXPORT-RCP1
                      direction: export
              contracts:
                consumers:
                  - CON1
                providers:
                  - CON1
                imported_consumers:
                  - IMPORT-CON1
```

example: This example shows how to configure an L3out with IPv4/IPv6 dual stack and a VIP on the SVI. The configuration includes static routes and external EPGs for the L3out, and is typically used when deploying a high-availability (HA) pair of firewalls with a NAT pool. The L3out is configured as SVI Vlan '100' on Port '10' of Node '1001' and Node '1002'. Each node has its own IPv4, IPv6, and shared VIP addresses, and the shared VIP address is used as the gateway for APP1. Static routing is used as a routing protocol, and an External EPG is configured to permit communication from those routes.

```yaml
apic:
  tenants:
    - name: TENANT1
      l3outs:
        - name: 'APP1-L3out'
          description: Interface for APP1
          vrf: VRF1
          domain: DOMAIN1
          node_profiles:
            - name: 'APP1-NodeProf'
              nodes:
                - node_id: 1001
                  router_id: 10.1.1.1
                  router_id_as_loopback: false
                  static_routes:
                    - prefix: 2001:db8:1234:1000::/64
                      next_hops:
                        - ip: 2001:db8:1234:2000::10
                    - prefix: 192.168.1.0/24
                      next_hops:
                        - ip: 192.168.2.10
                - node_id: 1002
                  router_id: 10.1.1.2
                  router_id_as_loopback: false
                  static_routes:
                    - prefix: 192.168.1.0/24
                      next_hops:
                        - ip: 192.168.2.10
                    - prefix: 2001:db8:1234:1000::/64
                      next_hops:
                        - ip: 2001:db8:1234:2000::10
              interface_profiles:
                - name: 'APP1-IPv6-IntProf'
                  description: IPv6 Interface Profile for APP1
                  interfaces:
                    - node_id: 1001
                      port: 10
                      ip: 2001:db8:1234:2000::1/64
                      svi: true
                      vlan: 100
                      ip_shared: 2001:db8:1234:2000::3/64
                    - node_id: 1002
                      port: 10
                      ip: 2001:db8:1234:2000::2/64
                      svi: true
                      vlan: 100
                      ip_shared: 2001:db8:1234:2000::3/64
                - name: 'APP1-IPv4-IntProf'
                  description: IPv4 Interface Profile for APP1
                  interfaces:
                    - node_id: 1001
                      port: 10
                      ip: 192.168.2.1/24
                      svi: true
                      vlan: 100
                      ip_shared: 192.168.2.3/24
                    - node_id: 1002
                      port: 10
                      ip: 192.168.2.2/24
                      svi: true
                      vlan: 100
                      ip_shared: 192.168.2.3/24
          external_endpoint_groups:
            - name: 'APP1-ExtEPG'
              subnets:
                - prefix: 2001:db8:1234:1000::/64
                - prefix: 192.168.1.0/24
```

example: In this example, BGP is used as dynamic routing protocol. The BGP parameters are configured as follows:
BGP remote-as '65530', IPv6 neighbor address '2001:db8:1234:2000::10', IPv4 neighbor address '192.168.2.10', bfd is enabled with the policy 'BFD-Policy'. ACI advertises default route '::/0' and '0.0.0.0/0' to the BGP neighbor and is assumed to receive '2001:db8:1234:1000::/64' and '192.168.1.0/24' from it.

```yaml
apic:
  tenants:
    - name: TENANT1
      l3outs:
        - name: 'APP1-L3out'
          description: Interface for APP1
          vrf: VRF1
          domain: DOMAIN1
          node_profiles:
            - name: 'APP1-NodeProf'
              nodes:
                - node_id: 1001
                  router_id: 10.1.1.1
                  router_id_as_loopback: false
                - node_id: 1002
                  router_id: 10.1.1.2
                  router_id_as_loopback: false
              interface_profiles:
                - name: 'APP1-IPv6-IntProf'
                  description: IPv6 Interface Profile for APP1
                  bfd_policy: BFD-Policy
                  interfaces:
                    - node_id: 1001
                      port: 10
                      ip: 2001:db8:1234:2000::1/64
                      svi: true
                      vlan: 100
                      bgp_peers:
                        - ip: 2001:db8:1234:2000::10
                          remote_as: 65530
                          description: BGP Peer for APP1
                          bfd: true
                          multicast_address_family: false
                    - node_id: 1002
                      port: 10
                      ip: 2001:db8:1234:2000::2/64
                      svi: true
                      vlan: 100
                      bgp_peers:
                        - ip: 2001:db8:1234:2000::10
                          remote_as: 65530
                          description: BGP Peer for APP1
                          bfd: true
                          multicast_address_family: false
                - name: 'APP1-IPv4-IntProf'
                  description: IPv4 Interface Profile for APP1
                  interfaces:
                    - node_id: 1001
                      port: 10
                      ip: 192.168.2.1/24
                      svi: true
                      vlan: 100
                      bgp_peers:
                        - ip: 192.168.2.10
                          remote_as: 65530
                          description: BGP Peer for APP1
                          bfd: true
                          multicast_address_family: false
                    - node_id: 1002
                      port: 10
                      ip: 192.168.2.2/24
                      svi: true
                      vlan: 100
                      bgp_peers:
                        - ip: 192.168.2.10
                          remote_as: 65530
                          description: BGP Peer for APP1
                          bfd: true
                          multicast_address_family: false
          external_endpoint_groups:
            - name: 'APP1-ExtEPG'
              subnets:
                - prefix: 2001:db8:1234:1000::/64
                - prefix: 192.168.1.0/24
                - prefix: ::/0
                  export_route_control: true
                  import_security: false
                - prefix: 0.0.0.0/0
                  export_route_control: true
                  import_security: false
```
