# Radius Provider

Location in GUI:
`Admin` » `AAA` » `Authentication` » `Providers`


{{ doc_gen }}

### Examples

Example 1: In this example we configure 2 radius servers which use CHAP and are reachable over the out-of-band connection, where the timeout is set to 5s and only 1 retry will be made.


```yaml
apic:
  fabric_policies:
    aaa:
      radius_providers:
        - hostname_ip: 10.10.10.1
          description: Radius Server 1
          protocol: chap
          timeout: 5
          retries: 1
          key: myKey
          mgmt_epg: oob
        - hostname_ip: 10.10.10.2
          description: Radius Server 2
          protocol: chap
          timeout: 5
          retries: 1
          key: myKey
          mgmt_epg: oob
```
