# Filter

Location in GUI:
`Tenants` » `XXX` » `Contracts` » `Filters`


{{ doc_gen }}

### Examples

Example-1: This configures a basic filter `FILTER1` with a single `HTTP` entry, which matches traffic with the ethertype of `ip`, protocol of `tcp`, and a destination port of `80` for HTTP. The destination port can be a range between destination_from_port and destination_to_port, and they are both set to the same value to only match a single port and not a range.

```yaml
apic:
  tenants:
    - name: ABC
      filters:
        - name: FILTER1
          entries:
            - name: HTTP
              ethertype: ip
              protocol: tcp
              destination_from_port: 80
              destination_to_port: 80
```

Example-2: This configures a filter `WEB` with multiple entries to match related traffic, such as entry 1 being for `HTTP` and the second named `HTTPS`. The `HTTP` entry matches traffic with the ethertype of `ip`, protocol of `tcp`, and a destination port of `80` for HTTP. The `HTTPS` entry matches traffic with the ethertype of `ip`, protocol of `tcp`, and a destination port of `443` for HTTP. This allows for the logical grouping of related types of traffic into a single filter for flexibility where a number of different ports are related to a given service. Another similar example could be backup traffic.

```yaml
apic:
  tenants:
    - name: ABC
      filters:
        - name: WEB
          description: Matches HTTP and HTTPS traffic
          entries:
            - name: HTTP
              ethertype: ip
              protocol: tcp
              destination_from_port: 80
              destination_to_port: 80
            - name: HTTPS
              ethertype: ip
              protocol: tcp
              destination_from_port: 443
              destination_to_port: 443
```

Example-3: This configures a filter `K8S` which demonstrates the use of a range of ports. This example allows TCP ports between destination_from_port `10250` to destination_to_port `10259` for Kubernetes as an example.

```yaml
apic:
  tenants:
    - name: ABC
      filters:
        - name: WEB
          description: Matches K8S ports
          entries:
            - name: HTTP
              ethertype: ip
              protocol: tcp
              destination_from_port: 10250
              destination_to_port: 10259
```

Example-4: This configures a `WEB` filter with source_from_port and source_to_port set to `80` with the ethertype being `ip` and the protocol `tcp`. While it is not common to define the source ports, this can be useful when used with uni-directional contracts to selectively match differen types of traffic in a given direction (provider or consumer). Such a filter may be used with the web EPG being the consumer, where it initiates a request from the web server.

```yaml
apic:
  tenants:
    - name: ABC
      filters:
        - name: WEB
          description: Matches HTTP traffic as the source port
          entries:
            - name: HTTP
              ethertype: ip
              protocol: tcp
              source_from_port: 80
              source_to_port: 80
```

Example-5: This configures a `FILTER1` filter with an entry named `TCP_FRAGMENTS` that matches TCP fragments only. When an entry has `match_only_fragments` enabled, the rest of the options (e.g. `source_from_port`, `destination_from_port`, `source_to_port`, `destination_to_port` and `stateful`) are not available for configuration.

```yaml
apic:
  tenants:
    - name: ABC
      filters:
        - name: FILTER1
          entries:
            - name: TCP_FRAGMENTS
              ethertype: ip
              protocol: tcp
              match_only_fragments: true
```
