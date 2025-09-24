# Endpoint IP Tag

Location in GUI:
`Tenants` » `XXX` » `Policies` » `Endpoint Tags` » `Endpoint IP`


{{ doc_gen }}

### Examples

Example-1: This data model associates Endpoint Tags based on source IP addresses, supporting both IPv4 and IPv6 formats. This tagging mechanism enables the classification of endpoints into Endpoint Security Groups (ESGs) through tag selectors, thereby facilitating the application and management of security policies. Endpoint Tag objects represent the IP address of an endpoint independently of its learning state. These tags serve as metadata or descriptors for the IP address within a specific VRF and can be created and maintained even before the fabric learns the IP address.

IP Tags are more suitable when IP addresses are stable and VMM integration or routing is in place.

```yaml
apic:
  tenants:
    - name: ABC
      policies:
        endpoint_ip_tags:
            - ip: 1.1.1.1
              vrf: VRF1
              tags:
                - key: Environment
                  value: Prod
            - ip: 2001::1
              vrf: VRF1
              tags:
                - key: Environment
                  value: Prod
                - key: Protocol
                  value: IPv6
```
