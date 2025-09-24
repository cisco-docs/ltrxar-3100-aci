# Access SPAN Filter Groups

Location in GUI:
`Fabric` » `Access Policies` » `Policies` » `Troubleshooting` » `SPAN` » `SPAN Filter Groups`

{{ doc_gen }}

### Examples

Example-1: This configuration defines a SPAN (Switched Port Analyzer) filter group. It creates a filter group named `FILTER-GROUP-1` with a description and a single entry `ENTRY-1`. This entry matches `TCP` traffic from source IP `20.20.20.20` (ports `80–81`) to destination IP `10.10.10.10` (ports `1–65535`). This allows you to monitor or capture only specific network traffic that matches these criteria for troubleshooting or analysis.

```yaml
apic:
  access_policies:
    span:
      filter_groups:
        - name: FILTER-GROUP-1
          description: My SPAN Filter Group 1
          entries:
            - name: ENTRY-1
              destination_ip: 10.10.10.10
              destination_from_port: 1
              destination_to_port: 65535
              source_ip: 20.20.20.20
              source_from_port: 80
              source_to_port: 81
              ip_protocol: tcp
```

Example-2: This second example demonstrates how to define a filter group with multiple entries, each targeting different types of traffic and hosts, and is suitable for use cases where you want to monitor or troubleshoot specific application flows in your network

Filter Group Name: `WEB-TRAFFIC-FILTER`. This filter group is designed to capture web (HTTP/HTTPS) and SSH traffic between specific hosts.

Entries:

- `WEB-ENTRY`
Matches `TCP` traffic from source IP `192.168.1.10` to destination IP `172.16.0.5`.
Source ports: `1024–65535` (typical ephemeral port range).
Destination ports: `80–443` (covers HTTP and HTTPS).
Only `TCP` protocol is matched.
Useful for monitoring web traffic from a specific client to a web server.

- `SSH-ENTRY`
Matches `TCP` traffic from source IP `10.0.0.2` to destination IP `10.0.0.100`.
Destination port: `22` (SSH).
Only `TCP` protocol is matched.
Useful for monitoring SSH access from a specific management host to a server.

```yaml
apic:
  access_policies:
    span:
      filter_groups:
        - name: WEB-TRAFFIC-FILTER
          description: Filter for web and SSH traffic from specific sources
          entries:
            - name: WEB-ENTRY
              source_ip: 192.168.1.10
              destination_ip: 172.16.0.5
              source_from_port: 1024
              source_to_port: 65535
              destination_from_port: 80
              destination_to_port: 443
              ip_protocol: tcp

            - name: SSH-ENTRY
              source_ip: 10.0.0.2
              destination_ip: 10.0.0.100
              destination_from_port: 22
              destination_to_port: 22
              ip_protocol: tcp
```
