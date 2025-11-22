# TACACS Provider

Location in GUI:
`Admin` » `AAA` » `Authentication` » `TACACS`


{{ doc_gen }}

### Examples

Example 1: In this example we configure 2 TACACS+ servers which use CHAP and are reachable over the out-of-band connection, where the timeout is set to 5s and only 1 retry will be made.

```yaml
apic:
  fabric_policies:
    aaa:
      tacacs_providers:
        - hostname_ip: 11.11.11.1
          description: TACACS Server 1
          protocol: chap
          timeout: 5
          retries: 1
          key: myKey
          mgmt_epg: oob
        - hostname_ip: 11.11.11.2
          description: TACACS Server 2
          protocol: chap
          timeout: 5
          retries: 1
          key: myKey
          mgmt_epg: oob
```
