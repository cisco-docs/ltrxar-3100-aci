# DHCP Option Policy

Location in GUI:
`Tenants` » `XXX` » `Policies` » `Protocol` » `DHCP` » `Option Policies`


{{ doc_gen }}

### Examples

Example-1: This data model defines DHCP Option `42`, specifying the Network Time Protocol (NTP) server IP address as `192.168.1.10`, and DHCP Option `43`, specifying the Vendor Specific Information IP address as `192.168.1.254`. These options are appended to the messages exchanged between DHCP servers and clients, providing additional configuration information during the DHCP relay process. DHCP Option Policies are referenced within a Bridge Domain alongside a DHCP Relay Policy.

```yaml
apic:
  tenants:
    - name: ABC
      policies:
        dhcp_option_policies:
          - name: DHCP-OPTIONS42-43
            description: "My Description"
            options:
              - name: NTP
                id: 42
                data: 192.168.1.10
              - name: Controller
                id: 43
                data: 192.168.1.254
```
