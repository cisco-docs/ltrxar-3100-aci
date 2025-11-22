# Filter
A filter is a policy object defined within an application template that specifies criteria for network traffic. Filters are composed of one or more entries, each defining specific rules based on parameters like Ethernet type, protocol, source/destination ports, and statefulness. These filters are fundamental for creating contracts and defining granular access control policies within the ACI fabric.

Location in GUI:
`Manage` » `Tenant Templates[Application]` » `Schema (within a template's configuration)`

{{ doc_gen }}

### Examples

Example-1: FILTER1 with HTTP Filter Entry

This example defines a filter named `http_filter` within the `site1_app_template` application template, which is part of the `example_schema` schema. The `http_filter` filter contains a single entry named `http_filter_ent`. This `http_filter_ent` entry is configured to match IPv4 ethertype `ip`, TCP traffic protocol `tcp`, and HTTP traffic with destination_from_port `http` and destination_to_port `http`. The stateful: `true` attribute indicates that the filter should track the connection state for this traffic. This filter could be used in a contract to allow HTTP web traffic.

```yaml
ndo:
  schemas:
    - name: example_schema
      templates:
        - name: site1_app_template
          filters:
            - name: http_filter
              entries:
                - name: http_filter_ent
                  description: HTTP Filter Entry
                  ethertype: ip
                  protocol: tcp
                  source_from_port: unspecified
                  source_to_port: unspecified
                  destination_from_port: http
                  destination_to_port: http
                  stateful: true
```
