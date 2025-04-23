# Contract

Location in GUI:
`Tenants` » `XXX` » `Contracts` » `Standard`


{{ doc_gen }}

### Examples

Simple example:

```yaml
apic:
  tenants:
    - name: ABC
      contracts:
        - name: CON1
          subjects:
            - name: SUB1
              filters:
                - filter: HTTP
```

Full example:

```yaml
apic:
  tenants:
    - name: ABC
      contracts:
        - name: CON1
          alias: CON1-ALIAS
          description: My Desc
          scope: global
          qos_class: level3
          target_dscp: AF13
          subjects:
            - name: SUB1
              alias: SUB1-ALIAS
              description: My Desc
              service_graph: TEMPLATE1
              qos_class: level3
              target_dscp: AF13
              filters:
                - filter: FILTER1
                  action: permit
                  priority: default
                  log: true
                  no_stats: false
``` 

Example of unidirectional contract:

```yaml
apic:
  tenants:
    - name: ABC
      contracts:
        - name: CON1
          alias: CON1-ALIAS
          description: My Desc
          scope: global
          subjects:
            - name: SUB2
              alias: SUB2-ALIAS
              description: My Desc
              reverse_port_filters: false
              consumer_to_provider:
                qos_class: level3
                target_dscp: AF13
                service_graph: TEMPLATE2
                filters:
                - filter: FILTER1
                  action: permit
                  priority: default
                  log: true
                  no_stats: false
              provider_to_consumer:
                qos_class: level3
                target_dscp: AF13
                service_graph: TEMPLATE2
                filters:
                - filter: FILTER1
                  action: permit
                  priority: default
                  log: true
                  no_stats: false
```
