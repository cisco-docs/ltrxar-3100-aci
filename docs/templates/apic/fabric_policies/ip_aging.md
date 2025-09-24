# IP Aging

Location in GUI:
`System` » `System Settings` » `Endpoint Controls` » `IP Aging`


{{ doc_gen }}

### Examples

Example-1: This example demonstrates how to configure Endpoint IP Aging.
When the Endpoint IP Aging is enabled, the IP aging policy sends ARP requests (for IPv4) and neighbor solicitations (for IPv6) to track IPs on endpoints. If no response is given, the policy ages the unused IPs. By default, Endpoint IP Aging is enabled. In this example, Endpoint IP Aging is explicitly disabled. 

```yaml
apic:
  fabric_policies:
    ip_aging: true
```
