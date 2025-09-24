# Endpoint MAC Tag

Location in GUI:
`Tenants` » `XXX` » `Policies` » `Endpoint Tags` » `Endpoint MAC`


{{ doc_gen }}

### Examples

Example-1: This data model associates Endpoint Tag based on source MAC addresses. This tagging mechanism enables the classification of endpoints into Endpoint Security Groups (ESGs) through tag selectors, thereby facilitating the application and management of security policies. Endpoint Tag objects represent the MAC address of an endpoint independently of its learning state. These tags serve as metadata or descriptors for the MAC address within a specific BD and can be created and maintained even before the fabric learns the MAC address.

The scope of a MAC Endpoint Tag is typically the bridge domain (e.g. MAC `00:01:02:03:04:AA`), but if the MAC address is unique across bridge domains, the scope can be set to any bridge domain with a VRF as the scope (e.g. MAC `00:01:02:03:04:BB`).

MAC Tags are useful in environments without read-write VMM integration, where VM MAC addresses can be tagged manually.

```yaml
apic:
  tenants:
    - name: ABC
      policies:
        endpoint_mac_tags:
            - mac: 00:01:02:03:04:AA
              bridge_domain: BD1
              vrf: VRF1
              tags:
                - key: Environment
                  value: Test
            - mac: 00:01:02:03:04:BB
              vrf: VRF1
              tags:
                - key: Environment
                  value: Prod
```
