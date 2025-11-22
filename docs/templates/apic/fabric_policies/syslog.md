# Syslog

Location in GUI:
`Admin` » `External Data Collectors` » `Monitoring Destinations` » `Syslog`


{{ doc_gen }}

### Examples

Example-1: This data model creates a syslog policy named `syslog_policy_simple`. The policy has a single syslog destination server defined using an IP address over udp/514 (udp is default).  The log messages that have a severity level of `warning` or higher for facility `local7` will be sent to syslog server using the `oob` management EPG.

```yaml
apic:
  fabric_policies:
    monitoring:
      syslogs:
        - name: syslog_policy_simple
          description: Simple Syslog Example
          destinations:
            - hostname_ip: 10.0.0.100
              name: syslog_server_1
              port: 514
              facility: local7
              severity: warnings
              mgmt_epg: oob
```

Example-2: This data model creates a syslog policy named `syslog_policy_advanced`. The policy has a single syslog destination server defined using an FQDN over tcp/1468.  The log messages that have a severity level of `information` or higher for facility `local7` will be sent to syslog server using the `inb` management epg.  The log format is configured to use the `nxos` log format with timestamps that include milliseconds and show the timezone.  This policy also disables alerts on the console.

```yaml
apic:
  fabric_policies:
    monitoring:
      syslogs:
        - name: syslog_policy_advanced
          description: Advanced Syslog Example
          format: nxos
          show_millisecond: true
          show_timezone: true
          console_admin_state: false
          destinations:
            - hostname_ip: syslogserver.example.com
              name: syslog_server_2
              protocol: tcp
              port: 1468
              facility: local7
              severity: information
              mgmt_epg: inb
```
