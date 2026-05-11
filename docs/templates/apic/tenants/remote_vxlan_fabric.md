# Remote VXLAN Fabric

Location in GUI:
`Tenants` » `infra` » `Policies` » `VXLAN Gateway` » `Remote VXLAN Fabrics`


{{ doc_gen }}

### Examples

This example shows how to configure a remote VXLAN fabric with a border gateway set policy and a remote EVPN peer:

```yaml
apic:
  tenants:
    - name: infra
      policies:
        remote_vxlan_fabrics:
          - name: Fabric-1
            border_gateway_set_policy: BorderGatewaySet
            remote_evpn_peers:
              - ip: 172.16.2.10
                remote_as: 65123
                description: peer1
                admin_state: true
                disable_peer_as_check: true
                password: Secure@123
                ttl: 5
                peer_prefix_policy: PEER_POL
                as_propagate: no-prepend
                local_as: 123
```
