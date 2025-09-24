# Redirect Backup Policy

Location in GUI:
`Tenants` » `XXX` » `Policies` » `Protocol` » `L4-L7 Policy-Based Redirect Backup`

{{ doc_gen }}

### Examples

Example-1: This data model creates an L3-type Redirect Backup Policy named `L4L7_PBR_BKP`, which enhances high availability and resilience for Redirect Policies within the same Redirect Health Group, `L4L7RedirectHealthGroup`.

The Redirect Backup Policy is usually implemented when Resilient Hashing option (`resilient_hashing`) is enabled in a Redirect Policy. In this case, if a PBR destination specified under `apic.tenants.policies.redirect_policy.l3_destinations` fails, the traffic is rerouted to a PBR destination (`l3_destinations`) defined in the Redirect Backup Policy (`FW_bkp_Virtual_Interface` in this example).

Note that Redirect Backup Policies are not eligible to IP SLA Policies monitoring.

```yaml
apic:
  tenants:
    - name: PBR_ServGraph
      services:
        redirect_backup_policies:
          - name: L4L7_PBR_BKP
            l3_destinations:
              - name: FW_bkp_Virtual_Interface
                description: FW bkp virtual interface
                ip: 10.0.0.5
                mac: 00:00:00:11:22:33
                redirect_health_group: L4L7RedirectHealthGroup
```
