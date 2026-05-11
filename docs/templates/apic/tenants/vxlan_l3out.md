# VXLAN L3out

Location in GUI:

- `Tenants` » `infra` » `Networking` » `VXLAN Infra L3Outs`

{{ doc_gen }}

### Examples

VXLAN Infra L3Out in `infra` tenant:

```yaml
apic:
  tenants:
    - name: infra
      vxlan_l3outs:
        - name: vxlan-l3out
          description: vxlan l3out
          border_gateway_set_policy: BorderGatewaySet

          node_profiles:
            - name: BGW-NP
              description: Border Gateway Node Profile
              vxlan_custom_qos_policy: VxlanCustomQos
              nodes:
                - node_id: 401
                  pod_id: 1
                  loopback: 1.1.1.1/32
              interface_profiles:
                - name: BWG-IP
                  description: Border Gateway Interface Profile
                  bfd_policy: BFD_POL
                  interfaces:
                    - node_id: 401
                      port: 10
                      mtu: 9000
                      ip: 172.16.3.1/24
                      bgp_peers:
                        - ip: 172.16.3.10
                          description: peer1
                          remote_as: 65123
                          admin_state: true
                          password: Cisco@123
                          bfd: true
                          peer_prefix_policy: PEER_POL
                          local_as: 123
                          as_propagate: no-prepend
                        - ip: 172.16.3.11
                          remote_as: 65124
```
