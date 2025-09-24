# DHCP Relay Policy

Location in GUI:
`Tenants` » `XXX` » `Policies` » `Protocol` » `DHCP` » `Relay Policies`


{{ doc_gen }}

### Examples

Example-1: This data model defines a DHCP Relay Policy named `DHCP-SERVERS`, which enables communication between DHCP clients and servers residing in different subnets or endpoint groups (EPGs). The DHCP servers are specified in the providers section, including details such as the server IP address `6.6.6.6` and its location within the tenant `ABC`, application profile `AP1`, and EPG `EPG1`. The server can be located in either an EPG or an External EPG (L3Out). DHCP Relay Policies are associated with a Bridge Domain alongside a DHCP Option Policy. Key points about DHCP Relay Policies in Cisco ACI:

- The fabric inserts DHCP Option 82 (DHCP Relay Agent Information Option) into the DHCP requests it proxies. DHCP servers must support Option 82; otherwise, DHCP offers without this option are dropped by the fabric.
- A contract must be created between the DHCP server EPG and the client EPG to allow DHCP communication.
- DHCP Relay Policies support both IPv4 and IPv6, including DHCPv6 relay with Option 79 for carrying client link-layer addresses.
- Changes to DHCP Relay Policies require redeployment of the associated bridge domain to update the fabric.
- DHCP Relay Policies are supported in user or common tenants but not in infra or mgmt tenants.

```yaml
apic:
  tenants:
    - name: ABC
      policies:
        dhcp_relay_policies:
          - name: DHCP-SERVERS
            description: "My Description"
            providers:
              - ip: 6.6.6.6
                type: epg
                tenant: ABC
                application_profile: AP1
                endpoint_group: EPG1
```
