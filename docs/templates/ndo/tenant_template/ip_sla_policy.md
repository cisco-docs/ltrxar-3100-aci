# IP SLA Policy

Location in GUI:
`Tenant Template` » `Tenant Policies`

{{ doc_gen }}

### Examples

Example-1: The example below shows a tenant policy template called `TP1` that is created under the tenant `NDO1` and the site `APIC1`. The IP SLA policy `HTTP` is defined under the tenant policy template. This is a policy of type `http`. The policy is configured with a frequency of 120 seconds, a multiplier of 4, a timeout of 800 milliseconds and a threshold of 800 milliseconds. It is using HTTP version 1.1 and the URI `/tmp`. The policy is also configured with a request data size of 1024 bytes and a type of service of 2.

```yaml
ndo:
  tenant_templates:
    tenant_policies:
      - name: TP1
        tenant: NDO1
        sites:
          - APIC1
        ip_sla_policies:
          - name: HTTP
            description: HTTP SLA Policy
            frequency: 120
            multiplier: 4
            sla_type: http
            http_version: HTTP11
            http_uri: /tmp
            request_data_size: 1024
            type_of_service: 2
            timeout: 800
            threshold: 800
            ipv6_traffic_class: 2
```

Example-2: The example below shows a tenant policy template called `TP1` that is created under the tenant `NDO1` and the site `APIC1`. The IP SLA policy `TCP` is defined under the tenant policy template. This is a policy of type `tcp`. It is using TCP port 44.

```yaml
ndo:
  tenant_templates:
    tenant_policies:
      - name: TP1
        tenant: NDO1
        sites:
          - APIC1
        ip_sla_policies:
         - name: TCP
            description: ICMP SLA Policy
            sla_type: tcp
            port: 44
```

Example-3: The example below shows a tenant policy template called `TP1` that is created under the tenant `NDO1` and the site `APIC1`. The IP SLA policy `ICMP` is defined under the tenant policy template. This is a policy of type `icmp`.

```yaml
ndo:
  tenant_templates:
    tenant_policies:
      - name: TP1
        tenant: NDO1
        sites:
          - APIC1
        ip_sla_policies:
         - name: ICMP
            description: ICMP SLA Policy
            sla_type: icmp
```

Example-4: The example below shows a tenant policy template called `TP1` that is created under the tenant `NDO1` and the site `APIC1`. The IP SLA policy `L2Ping` is defined under the tenant policy template. This is a policy of type `l2ping`. It is using frequency of 120 seconds, a multiplier of 4, a timeout of 800 milliseconds and a threshold of 800 milliseconds.

```yaml
ndo:
  tenant_templates:
    tenant_policies:
      - name: TP1
        tenant: NDO1
        sites:
          - APIC1
        ip_sla_policies:
          - name: L2Ping
            sla_type: l2ping
            frequency: 120
            multiplier: 4
            timeout: 800
            threshold: 800
            ipv6_traffic_class: 2
```
