# Site Fabric Connectivity

Location in GUI:
`Infrastructure` » `Infra Configuration`

{{ doc_gen }}

### Examples

Example 1: In Multi-Site deployments, external TEP pools serve a crucial role in enabling communication and integration with external networks and devices. The configuration below demonstrates the use of multiple external_tep_pools entries (`10.10.10.0/24`, `10.10.11.0/24`, `10.10.12.0/24`) for pod `1`. This approach allows for the allocation of distinct IP address ranges for Inter-site L3Out communication.

```yaml
ndo:
  sites:
    - name: NLD1
      multisite: true
      multicast_tep: 239.1.1.1
      bgp:
        as: 65009
      pods:
        - id: 1
          unicast_tep: 10.12.12.13
          external_tep_pools:
            - ip: 10.10.10.0/24
            - ip: 10.10.11.0/24
            - ip: 10.10.12.0/24
```

full-example:

```yaml
ndo:
  sites:
    - name: APIC1
      multisite: true
      multicast_tep: 5.6.7.8
      fabric_id: 2
      bgp:
        as: 65009
        password: cisco
      ospf:
        area_id: 0
        area_type: regular
      routed_domain: L3
      ospf_policies:
        - name: IPN
          network_type: point-to-point
          priority: 1
          interface_cost: 0
          passive_interface: false
          mtu_ignore: false
          advertise_subnet: false
          bfd: false
          hello_interval: 10
          dead_interval: 40
          retransmit_interval: 5
          retransmit_delay: 1
      pods:
        - id: 1
          unicast_tep: 3.4.5.6
          external_tep_pools:
            - ip: 10.10.10.0/24
          spines:
            - id: 1001
              name: SPINE1001
              bgp_peering: true
              bgp_route_reflector: false
              control_plane_tep: 100.100.100.1
              interfaces:
                - port: 1
                  ip: 11.11.11.1/24
                  mtu: inherit
                  ospf:
                    policy: IPN
                    authentication_type: none
                    authentication_key: cisco
                    authentication_key_id: 1
  fabric_connectivity:
    bgp:
      peering_type: full-mesh
      ttl: 15
      max_as: 10
      keepalive_interval: 30
      hold_interval: 90
      stale_interval: 180
      graceful_restart: false
```
