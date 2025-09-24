# Date and Time Policy

Location in GUI:
`Fabric` » `Fabric Policies` » `Fabric Policies` » `Policies` » `Pod` » `Date and Time`


{{ doc_gen }}

### Examples

Example-1: This data model creates a Data and Time policy named `ntp_policy_simple`. This creates a simple policy with two NTP servers defined.  This configuration sets one of the NTP servers as the preferred time server (`preferred: true`).  

```yaml
apic:
  fabric_policies:
    pod_policies:
      date_time_policies:
        - name: ntp_policy_simple
          ntp_servers:
            - hostname_ip: 10.0.0.100
              preferred: true
            - hostname_ip: 20.0.0.200
              preferred: false
```


Example-2: This data model creates a Data and Time policy named `ntp_policy_with_auth`. This creates a policy with two NTP servers defined where NTP Authentication is used.  This configuration sets one of the NTP servers as the preferred time server (`preferred: true`) and uses the out-of-band management network for the NTP traffic (`mgmt_epg: oob`). The NTP servers use the value for the `auth_key_id` key to associate it the NTP server with the `id` of the NTP key listed in the `ntp_keys` section. If the key includes special characters it is recommended to enclose the key in single quotes `''`.  

```yaml
apic:
  fabric_policies:
    pod_policies:
      date_time_policies:
        - name: ntp_policy_with_auth
          ntp_auth_state: true
          ntp_servers:
            - hostname_ip: 10.0.0.100
              auth_key_id: 1
              preferred: true
              mgmt_epg: oob
            - hostname_ip: 20.0.0.200
              auth_key_id: 1
              mgmt_epg: oob
              preferred: false
          ntp_keys:
            - id: 1
              key: 'My$ecretKey'
              auth_type: md5
              trusted: false
```
