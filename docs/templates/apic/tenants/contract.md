# Contract

Location in GUI:
`Tenants` » `XXX` » `Contracts` » `Standard`


{{ doc_gen }}

### Examples

Example-1: This is a simple contract `CON1` defined with just a single subject named `SUB1`, associated with a single filter for web traffic, aptly named `HTTP`. There is no service graph associated, meaning this contract permits traffic directly.

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

Example-2: This is a simple contract `CON1` with a single subject `SUB1`, which redirect all traffic matching the `IP_ANY` filter to the service graph named `DC_FW_SG`. Such a contract is typically used to redirect all traffic within a given ACI VRF to the DC FW using PBR, and having this contract provided and consumed by vzAny. The contract typically references a filter matching the IP ethertype only.

```yaml
apic:
  tenants:
    - name: ABC
      contracts:
        - name: CON1
          subjects:
            - name: SUB1
              service_graph: DC_FW_SG
              filters:
                - filter: IP_ANY
                  action: permit
```

Example-3: This contract `MS_AD_TO_BKP_SRV` is configured with two subjects: `LDAP` and `BKP`. The `LDAP` subject redirects traffic matching the `LDAP` filter to the `DC_FW_SG` service graph, whereas the `BKP` subject permits traffic matching the `BKP` filter directly through ACI (since there is no service graph attached to the subject). This is typically configured with EPGs containing backup solutions, since some traffic may require service graph redirection (such as LDAP in this case to log into the backup solution), whereas redirecting the backup traffic to a service node is not required since it would unnecessarily overload it. Different contract subjects are able to match on different filters and apply separate actions for each as needed, typically combining subjects with and without a service graph for redirection.

```yaml
apic:
  tenants:
    - name: ABC
      contracts:
        - name: MS_AD_TO_BKP_SRV
          description: Contract between MS AD and backup servers
          subjects:
            - name: LDAP
              description: Redirect LDAP to DC FW
              service_graphs: DC_FW_SG
              filters:
                - name: LDAP
            - name: BKP
              description: Permit backup traffic directly
              filters:
                - name: BKP
      filters:
        - name: LDAP
          entries:
            - name: TCP_389
              ethertype: ip
              protocol: tcp
              destination_to_port: 389
            - name: UDP_389
              ethertype: ip
              protocol: udp
              destination_to_port: 389
        - name: BKP
          entries:
            - name: TCP_2049
              ethertype: ip
              protocol: tcp
              destination_to_port: 2049
```

Example-4: This contract applies a uni-directionally between the web (consumer) and DB (provider) EPGs. It is uni-directional due to the fact that reverse_filter_ports is set to `false`, and each of the consumer and provider sides can have separate configuration in this case. The consumer to provider side matches on the DB port filter, sets a high-priority QoS level of 1 and a DSCP of AF11 to ensure writes to the DB are treated preferentially, and rediects to the DC FW service graph. The provider to consumer side sets a lower QoS level of 3 and a DSCP of AF13, matches on the HTTPS port, and redirects to the DC FW service graph.

```yaml
apic:
  tenants:
    - name: ABC
      contracts:
        - name: WEB_TO_DB
          description: Unidirectional contract between web and DB EPGs
          subjects:
            - name: SUB1
              reverse_filter_ports: false
              consumer_to_provider:
                qos_class: level1
                target_dscp: AF11
                service_graph: DC_FW_SG
                filters:
                - filter: TCP_5432
                  action: permit
              provider_to_consumer:
                qos_class: level3
                target_dscp: AF13
                service_graph: DC_FW_SG
                filters:
                - filter: TCP_443
                  action: permit
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
