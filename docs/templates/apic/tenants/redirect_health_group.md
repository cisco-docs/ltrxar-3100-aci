# Redirect Health Group

Location in GUI:
`Tenants` » `XXX` » `Policies` » `Protocol` » `L4-L7 Redirect Health Groups`

{{ doc_gen }}

### Examples

Example-1: This data model creates one L4-L7 Redirect Health Group named `L4L7RedirectHealthGroup`. These health groups are typically referenced by Redirect Policies and Redirect Backup Policies to provide health tracking of service nodes. It is highly recommended to review the examples in those modules for better understanding. The health group aggregates the status of ingress and egress redirect destination nodes to prevent traffic black-holing by marking nodes as down if they become unreachable. This mechanism enables full failover and traffic redirection capabilities within Cisco ACI Policy-Based Redirect (PBR).

```yaml
apic:
  tenants:
    - name: PBR_ServGraph
      services:
        redirect_health_groups:
          - name: L4L7RedirectHealthGroup
            description: Group for PBR destinations
```
