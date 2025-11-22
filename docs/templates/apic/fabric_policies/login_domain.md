# Login Domain

Location in GUI:
`Admin` » `AAA` » `Authentication` » `AAA`


{{ doc_gen }}

### Examples

Example 1: In this example we configure a `login_domain` named `yourDomainRadius` which adds 2 radius providers with a clear priority to define the order of usage.

```yaml
apic:
  fabric_policies:
    aaa:
      login_domains:
        - name: yourDomainRadius
          realm: radius
          description: login domain radius
          radius_providers:
            - hostname_ip: 10.10.10.1
              priority: 1
            - hostname_ip: 10.10.10.2
              priority: 2
```

Example 2: In this example we configure a `login_domain` named `yourDomainTacacs` which adds 2 tacacs providers with a clear priority to define the order of usage.

```yaml
apic:
  fabric_policies:
    aaa:
      login_domains:
        - name: yourDomainTacacs
          realm: tacacs
          description: login domain tacacs
          tacacs_providers:
            - hostname_ip: 11.11.11.1
              priority: 1
            - hostname_ip: 11.11.11.2
              priority: 2
```

Example 3: In this example we configure the `local` login domain and add a description to it.

```yaml
apic:
  fabric_policies:
    aaa:
      login_domains:
        - name: yourLocalDomain
          description: Local Domain
          realm: local
```
