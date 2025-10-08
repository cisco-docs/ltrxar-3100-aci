# ACI As-Built

The following sections provide an overview of the main ACI Objects configured in the fabric.

## System

This section describes the system wide configuration.

### APIC Connectivity Preferences

<caption name="APIC Connectivity Preferences">

| Properties | Value |
|---|---|
| Interface to use for External Connections: | {{apic.fabric_policies.apic_conn_pref | default(defaults.apic.fabric_policies.apic_conn_pref)}} |
</caption>

### COOP Group Policy

<caption name="COOP Group Policy">

| Properties | Value |
|---|---|
| Type: | {{apic.fabric_policies.coop_group_policy | default(defaults.apic.fabric_policies.coop_group_policy)}} |
</caption>

### Date and Time Format Policy

<caption name="Date and Time Format Policy">

| Properties | Value |
|---|---|
| Display Format: | {{apic.fabric_policies.date_time_format.display_format | default(defaults.apic.fabric_policies.date_time_format.display_format)}} |
| Time Zone: | {{apic.fabric_policies.date_time_format.timezone | default(defaults.apic.fabric_policies.date_time_format.timezone)}} |
| Offset State: |  {{apic.fabric_policies.date_time_format.show_offset | default(defaults.apic.fabric_policies.date_time_format.show_offset)}} |
</caption>

### EP Loop Protection

<caption name="EP Loop Protection">

| Properties | Value |
|---|---|
| Administrative State: |  {{apic.fabric_policies.ep_loop_protection.admin_state | default(defaults.apic.fabric_policies.ep_loop_protection.admin_state)}} |
| Loop Detection Interval: |  {{apic.fabric_policies.ep_loop_protection.detection_interval | default(defaults.apic.fabric_policies.ep_loop_protection.detection_interval)}} |
| Loop Detection Multiplication Factor: |  {{apic.fabric_policies.ep_loop_protection.detection_multiplier | default(defaults.apic.fabric_policies.ep_loop_protection.detection_multiplier)}} |
| Action - Port Disable:  |  {{apic.fabric_policies.ep_loop_protection.port_disable | default(defaults.apic.fabric_policies.ep_loop_protection.port_disable)}} |
| Action - BD Learn Disable:  |  {{apic.fabric_policies.ep_loop_protection.bd_learn_disable | default(defaults.apic.fabric_policies.ep_loop_protection.bd_learn_disable)}} |
</caption>

### Rogue EP Control

<caption name="Rogue EP Control">

| Properties | Value |
|---|---|
| Administrative State: | {{apic.fabric_policies.rogue_ep_control.admin_state | default(defaults.apic.fabric_policies.rogue_ep_control.admin_state)}} |
| Rogue EP Detection Interval: | {{apic.fabric_policies.rogue_ep_control.detection_interval | default(defaults.apic.fabric_policies.rogue_ep_control.detection_interval)}} |
| Rogue EP Detection Multiplication Factor: | {{apic.fabric_policies.rogue_ep_control.detection_multiplier | default(defaults.apic.fabric_policies.rogue_ep_control.detection_multiplier)}} |
| Hold Interval (sec): | {{apic.fabric_policies.rogue_ep_control.hold_interval | default(defaults.apic.fabric_policies.rogue_ep_control.hold_interval)}} |
</caption>

### IP Aging

<caption name="IP Aging">

| Properties | Value |
|---|---|
| Administrative State: | {{apic.fabric_policies.ip_aging | default(defaults.apic.fabric_policies.ip_aging)}} |
</caption>

### Fabric Wide Settings

<caption name="Fabric Wide Settings">

| Properties | Value |
|---|---|
| Disable Remote EP Learning: | {{apic.fabric_policies.global_settings.disable_remote_endpoint_learn | default(defaults.apic.fabric_policies.global_settings.disable_remote_endpoint_learn)}} |
| Enforce Subnet Check: | {{apic.fabric_policies.global_settings.enforce_subnet_check | default(defaults.apic.fabric_policies.global_settings.enforce_subnet_check)}} |
| Enforce EPG VLAN Validation: | {{apic.fabric_policies.global_settings.overlapping_vlan_validation | default(defaults.apic.fabric_policies.global_settings.overlapping_vlan_validation)}} |
| Enforce Domain Validation: | {{apic.fabric_policies.global_settings.domain_validation | default(defaults.apic.fabric_policies.global_settings.domain_validation)}} |
| Opflex Client Authentication: | {{apic.fabric_policies.global_settings.opflex_authentication | default(defaults.apic.fabric_policies.global_settings.opflex_authentication)}} |
| Reallocate Gipo: | {{apic.fabric_policies.global_settings.reallocate_gipo | default(defaults.apic.fabric_policies.global_settings.reallocate_gipo)}} |
| Restrict Infra VLAN Traffic: | |
</caption>

### ISIS Domain Policy

<caption name="ISIS Domain Policy">

| Properties | Value |
|---|---|
| ISIS MTU: | |
| ISIS Metric for redistributed routes: | {{apic.fabric_policies.fabric_isis_redistribute_metric | default(defaults.apic.fabric_policies.fabric_isis_redistribute_metric)}} |
| LSP Fast Flood Mode: | |
| LSP generation initial wait interval: | |
| LSP generation maximum wait interval: | |
| LSP generation second wait interval: | |
| SPF computation frequency initial wait interval: | |
| SPF computation frequency maximum wait interval: | |
| SPF computation frequency second wait interval: | |
</caption>

### Port Tracking

<caption name="Port Tracking">

| Properties | Value |
|---|---|
| Port Tracking State: | {{apic.fabric_policies.port_tracking.admin_state | default(defaults.apic.fabric_policies.port_tracking.admin_state)}} |
| Delay restore timer: | {{apic.fabric_policies.port_tracking.delay | default(defaults.apic.fabric_policies.port_tracking.delay)}} |
| Number of active fabric ports that triggers port tracking: | {{apic.fabric_policies.port_tracking.min_links | default(defaults.apic.fabric_policies.port_tracking.min_links)}} |
| Include APIC ports when port tracking is triggered: | {{apic.fabric_policies.port_tracking.include_apic | default(defaults.apic.fabric_policies.port_tracking.include_apic)}} |
</caption>

### PTP

<caption name="PTP">

| Properties | Value |
|---|---|
| PTP admin State: | {{apic.fabric_policies.ptp.admin_state | default(defaults.apic.fabric_policies.ptp.admin_state)}} |
| Global Domain: | {{apic.fabric_policies.ptp.global_domain | default(defaults.apic.fabric_policies.ptp.global_domain)}} |
| PTP Profile: | {{apic.fabric_policies.ptp.profile | default(defaults.apic.fabric_policies.ptp.profile)}} |
| Announce Interval: | {{apic.fabric_policies.ptp.announce_interval | default(defaults.apic.fabric_policies.ptp.announce_interval)}} |
| Sync Interval: | {{apic.fabric_policies.ptp.sync_interval | default(defaults.apic.fabric_policies.ptp.sync_interval)}} |
| Delay Request Interval: | {{apic.fabric_policies.ptp.delay_interval | default(defaults.apic.fabric_policies.ptp.delay_interval)}} |
| Announce Timeout: | {{apic.fabric_policies.ptp.announce_timeout | default(defaults.apic.fabric_policies.ptp.announce_timeout)}} |
</caption>

### Remote Leaf POD Redundancy

<caption name="Remote Leaf POD Redundancy">

| Properties | Value |
|---|---|
| Enable Remote Leaf Pod Redundancy Policy: | |
| Enable Remote Leaf Pod Redundancy pre-emption: | |
</caption>

### System Alias and Banners

<caption name="System Alias and Banners">

| Properties | Value |
|---|---|
| GUI Alias: | {{apic.fabric_policies.banners.apic_gui_alias | default(defaults.apic.fabric_policies.banners.apic_gui_alias) | replace("\n", "<br>")}} |
| Controller CLI Banner: | {{apic.fabric_policies.banners.apic_cli_banner | default(defaults.apic.fabric_policies.banners.apic_cli_banner) | replace("\n", "<br>")}} |
| Switch CLI Banner: | {{apic.fabric_policies.banners.switch_cli_banner | default(defaults.apic.fabric_policies.banners.switch_cli_banner) | replace("\n", "<br>")}} |
| Application Banner: | |
| Banner Severity: | |
| Use Text Banner: | |
| GUI Banner Text: | |
</caption>

## Fabric

This section describes the Fabric configuration, including node registration and node management configuration.

### Fabric Nodes

<caption name="Fabric Nodes">

| Name | Node ID | Pod ID | Serial Number | Role |
|---|---|---|---|---|
{% for node in apic.node_policies.nodes %}
| {{ node.name | default("") }} | {{ node.id }} | {{ node.pod | default(defaults.apic.node_policies.nodes.pod) }} | {{node.serial_number}} | {{node.role}} |
{% endfor %}
</caption>

### Node Management OOB Addressing

{% if apic.node_policies.nodes|length > 0 %}
<caption name="Node Management OOB Addressing">

| Name | Node ID | Pod ID | IPv4 Address | IPv4 Gateway | IPv6 Address | IPv6 Gateway |
|---|---|---|---|---|---|---|
{% for node in apic.node_policies.nodes %}
| {{ node.name | default("") }} | {{ node.id }} | {{ node.pod | default(defaults.apic.node_policies.nodes.pod) }} | {{node.oob_address | default("")}} | {{node.oob_gateway | default("")}} | {{node.oob_v6_address | default("")}} | {{node.oob_v6_gateway | default("")}} |
{% endfor %}
</caption>
{% else %}
No OOB Management addresses configured.
{% endif %}

### Node Management In-Band Addressing

{% if apic.node_policies.nodes|length > 0 %}
<caption name="Node Management In-Band Addressing">

| Name | Node ID | Pod ID | IPv4 Address | IPv4 Gateway | IPv6 Address | IPv6 Gateway |
|---|---|---|---|---|---|---|
{% for node in apic.node_policies.nodes %}
| {{ node.name | default("") }} | {{ node.id }} | {{ node.pod | default(defaults.apic.node_policies.nodes.pod) }} | {{node.inb_address | default("")}} | {{node.inb_gateway | default("")}} | {{node.inb_v6_address | default("")}} | {{node.inb_v6_gateway | default("")}} |
{% endfor %}
</caption>
{% else %}
No In-Band Management addresses configured.
{% endif %}

## Fabric Policies

This section describes the Fabric Policies.

### DNS Profiles

{% if apic.fabric_policies.dns_policies|length > 0 %}
{% for dns in apic.fabric_policies.dns_policies | default([])%}
<caption name="DNS Profiles: {{dns.name}}">

| DNS Profile Name | {{dns.name}} |
|---|---|
| IP Address | Preferred |
{% for provider in dns.providers | default([]) %}
| {{provider.ip}} | {% if provider.preferred | default(defaults.apic.fabric_policies.dns_policies.providers.preferred) %}yes{%else%}no{%endif%} |
{% endfor %}
| Domain Name | Default |
{% for domain in dns.domains | default([])  %}
| {{domain.name}} | {% if domain.default | default(defaults.apic.fabric_policies.dns_policies.domains.default) %}yes{%else%}no{%endif%} |
{% endfor %}
</caption>
{% endfor %}
{% else %}
No DNS Profiles configured.
{% endif %}

### Date/Time Policy

{% if apic.fabric_policies.pod_policies.date_time_policies|length > 0 %}
{% for policy in apic.fabric_policies.pod_policies.date_time_policies | default([]) %}

#### {{policy.name}}

<caption name="Date/Time Policy: {{policy.name}}">

| Administrative State | Authentication State | Server State | Timezone | Display Format | Offset State |
|---|---|---|---|---|---|
| {{ policy.ntp_admin_state | default(defaults.apic.fabric_policies.pod_policies.date_time_policies.ntp_admin_state)}} | {{ policy.ntp_auth_state | default(defaults.apic.fabric_policies.pod_policies.date_time_policies.ntp_auth_state)}} | {{ policy.apic_ntp_server_state | default(defaults.apic.fabric_policies.pod_policies.date_time_policies.apic_ntp_server_state)}} | {{apic.fabric_policies.date_time_format.timezone | default(defaults.apic.fabric_policies.date_time_format.timezone)}} | {{apic.fabric_policies.date_time_format.display_format | default(defaults.apic.fabric_policies.date_time_format.display_format)}} | {{apic.fabric_policies.date_time_format.show_offset | default(defaults.apic.fabric_policies.date_time_format.show_offset)}} |
</caption>

{% if policy.ntp_servers|length > 0 %}
<caption name="Date/Time Servers: {{policy.name}}">

| NTP Server | Preferred | Key ID | Min Polling Interval | Max Polling Interval | Mgmt EPG |
| --- | --- | --- | --- | --- | --- |
{% for srv in policy.ntp_servers %}
| {{srv.hostname_ip}} | {{srv.preferred | default(defaults.apic.fabric_policies.pod_policies.date_time_policies.ntp_servers.preferred)}} | {{srv.auth_key_id | default("")}} | | | {{srv.mgmt_epg | default(defaults.apic.fabric_policies.pod_policies.date_time_policies.ntp_servers.mgmt_epg)}} |
{% endfor %}
</caption>
{% else %}
No NTP servers configured.
{% endif %}
{% endfor %}
{% else %}
No Date/Time Policies configured.
{% endif %}

### Syslog

{% if apic.fabric_policies.monitoring.syslogs|length > 0 %}
{% for syslog in apic.fabric_policies.monitoring.syslogs | default([]) %}
<caption name="Syslog: {{syslog.name ~ defaults.apic.fabric_policies.monitoring.syslogs.name_suffix}}">

| Profile Name | Administrative State | Format | Show Milliseconds | Local Admin State | Local Severity | Console Admin State | Console Severity |
|---|---|---|---|---|---|---|---|
| {{syslog.name ~ defaults.apic.fabric_policies.monitoring.syslogs.name_suffix}} | {{syslog.admin_state | default(defaults.apic.fabric_policies.monitoring.syslogs.admin_state)}} | {{syslog.format | default(defaults.apic.fabric_policies.monitoring.syslogs.format)}} | {{syslog.show_millisecond | default(defaults.apic.fabric_policies.monitoring.syslogs.show_millisecond)}} | {{ syslog.local_admin_state | default(defaults.apic.fabric_policies.monitoring.syslogs.local_admin_state)}} | {{syslog.local_severity | default(defaults.apic.fabric_policies.monitoring.syslogs.local_severity)}} | {{syslog.console_admin_state | default(defaults.apic.fabric_policies.monitoring.syslogs.console_admin_state)}} | {{syslog.console_severity | default(defaults.apic.fabric_policies.monitoring.syslogs.console_severity)}} |
</caption>

{% if syslog.destinations|length > 0 %}
<caption name = "Syslog Profile {{syslog.name}} Destinations">

| Hostname | Name | Protocol | Port | Administrative State | Facility | Severity | Mgmt EPG |
|---|---|---|---|---|---|---|---|
{% for dst in syslog.destinations %}
| {{dst.hostname_ip}} | {{dst.name}} | {{dst.protocol}} | {{dst.port | default(defaults.apic.fabric_policies.monitoring.syslogs.destinations.port)}} | {{dst.admin_state | default(defaults.apic.fabric_policies.monitoring.syslogs.destinations.admin_state)}} | {{dst.facility | default(defaults.apic.fabric_policies.monitoring.syslogs.destinations.facility)}} | {{dst.severity | default(defaults.apic.fabric_policies.monitoring.syslogs.destinations.severity)}} | {{dst.mgmt_epg | default(defaults.apic.fabric_policies.monitoring.syslogs.destinations.mgmt_epg)}} |
{% endfor %}
</caption>
{% else %}
No Syslog Destinations configured.
{% endif %}
{% endfor %}
{% else %}
No Syslog Policies configured.
{% endif %}

### SNMP
{% if apic.fabric_policies.pod_policies.snmp_policies|length > 0 %}
{% for snmp in apic.fabric_policies.pod_policies.snmp_policies | default([]) %}
<caption name="SNMP Policy: {{snmp.name ~ defaults.apic.fabric_policies.pod_policies.snmp_policies.name_suffix}}">

| Name | Administrative State | Contact | Location |
|---|---|---|---|
| {{snmp.name ~ defaults.apic.fabric_policies.pod_policies.snmp_policies.name_suffix}} | {{snmp.admin_state | default(defaults.apic.fabric_policies.pod_policies.snmp_policies.admin_state)}} | {{snmp.contact | default(apic.fabric_policies.pod_policies.snmp_policies.contact)}} | {{snmp.location | default(defaults.apic.fabric_policies.pod_policies.snmp_policies.location)}} |
</caption>

{% if snmp.communities is defined %}
<caption name="Community Policy (SNMP Policy: {{snmp.name ~ defaults.apic.fabric_policies.pod_policies.snmp_policies.name_suffix}})">

| Community Policies | Description |
|---|---|
{% for community in snmp.communities | default([]) %}
| {{community}} | |
{% endfor %}
</caption>
{% else %}
No SNMP Communities configured.
{% endif %}

{% if snmp.client is defined %}
<caption name="Client Group Policy (SNMP Policy: {{snmp.name ~ defaults.apic.fabric_policies.pod_policies.snmp_policies.name_suffix}}">

| Client Name | Address | Mgmt EPG |
|---|---|---|
{% for client in snmp.clients %}
{% for entry in clients.entries | default([]) %}
| {{client.name ~ defaults.apic.fabric_policies.pod_policies.snmp_policies.clients.name_suffix}} | {{entry.ip}} | {{client.mgmt_epg}} |
{% endfor %}
{% endfor %}
</caption>
{% else %}
No SNMP Client Group Policies configured.
{% endif %}
{%endfor%}
{% else %}
No SNMP policies configured.
{% endif %}

### SNMP Trap
{% if apic.fabric_policies.monitoring.snmp_traps|length>0 %}
{% for pol in apic.fabric_policies.monitoring.snmp_traps | default([])%}
{{pol.name ~ defaults.apic.fabric_policies.monitoring.snmp_traps.name_suffix}}
<caption name="SNMP Trap: {{pol.name ~ defaults.apic.fabric_policies.monitoring.snmp_traps.name_suffix}}">

| Hostname/IP | Port | Version | Security/Community Name | v3 Security level | Management EPG |
|---|---|---|---|---|---|
{% for host in pol.destinations | default([])%}
{% set default = defaults.apic.fabric_policies.monitoring.snmp_traps.destinations %}
| {{host.hostname_ip | default(default.destinations.port)}} | {{host.port | default(default.port)}} | {{host.version | default(default.version)}} | {{host.community}} | {{host.security | default(default.security)}} | {{host.mgmt_epg | default(default.mgmt_epg)}} |
{% endfor %}

</caption>
{% endfor %}
{% else %}
No SNMP Trap configured.
{% endif %}

### Management Access Policy

{% if apic.fabric_policies.pod_policies.management_access_policies|length > 0 %}
{% for policy in apic.fabric_policies.pod_policies.management_access_policies | default([]) %}
{% set ssh_ciphers = [] %}
{% if policy.ssh.aes128_ctr | default(defaults.apic.fabric_policies.pod_policies.management_access_policies.ssh.aes128_ctr) %}{% set ssh_ciphers = ssh_ciphers + [("aes128-ctr")] %}{% endif %}
{% if policy.ssh.aes128_gcm | default(defaults.apic.fabric_policies.pod_policies.management_access_policies.ssh.aes128_gcm) %}{% set ssh_ciphers = ssh_ciphers + [("aes128-gcm@openssh.com")] %}{% endif %}
{% if policy.ssh.aes192_ctr | default(defaults.apic.fabric_policies.pod_policies.management_access_policies.ssh.aes192_ctr) %}{% set ssh_ciphers = ssh_ciphers + [("aes192-ctr")] %}{% endif %}
{% if policy.ssh.aes256_ctr | default(defaults.apic.fabric_policies.pod_policies.management_access_policies.ssh.aes256_ctr) %}{% set ssh_ciphers = ssh_ciphers + [("aes256-ctr")] %}{% endif %}
{% if policy.ssh.aes256_gcm | default(defaults.apic.fabric_policies.pod_policies.management_access_policies.ssh.aes256_gcm) %}{% set ssh_ciphers = ssh_ciphers + [("aes256-gcm@openssh.com")] %}{% endif %}
{% if policy.ssh.chacha | default(defaults.apic.fabric_policies.pod_policies.management_access_policies.ssh.chacha) %}{% set ssh_ciphers = ssh_ciphers + [("chacha20-poly1305@openssh.com")] %}{% endif %}
{% set ssh_kexalgos = [] %}
{% if policy.ssh.curve25519_sha256 | default(defaults.apic.fabric_policies.pod_policies.management_access_policies.ssh.curve25519_sha256) %}{% set ssh_kexalgos = ssh_kexalgos + [("curve25519-sha256")] %}{% endif %}
{% if policy.ssh.curve25519_sha256_libssh | default(defaults.apic.fabric_policies.pod_policies.management_access_policies.ssh.curve25519_sha256_libssh) %}{% set ssh_kexalgos = ssh_kexalgos + [("curve25519-sha256@libssh.org")] %}{% endif %}
{% if policy.ssh.dh1_sha1 | default(defaults.apic.fabric_policies.pod_policies.management_access_policies.ssh.dh1_sha1) %}{% set ssh_kexalgos = ssh_kexalgos + [("diffie-hellman-group1-sha1")] %}{% endif %}
{% if policy.ssh.dh14_sha1 | default(defaults.apic.fabric_policies.pod_policies.management_access_policies.ssh.dh14_sha1) %}{% set ssh_kexalgos = ssh_kexalgos + [("diffie-hellman-group14-sha1")] %}{% endif %}
{% if policy.ssh.dh14_sha256 | default(defaults.apic.fabric_policies.pod_policies.management_access_policies.ssh.dh14_sha256) %}{% set ssh_kexalgos = ssh_kexalgos + [("diffie-hellman-group14-sha256")] %}{% endif %}
{% if policy.ssh.dh16_sha512 | default(defaults.apic.fabric_policies.pod_policies.management_access_policies.ssh.dh16_sha512) %}{% set ssh_kexalgos = ssh_kexalgos + [("diffie-hellman-group16-sha512")] %}{% endif %}
{% if policy.ssh.ecdh_sha2_nistp256 | default(defaults.apic.fabric_policies.pod_policies.management_access_policies.ssh.ecdh_sha2_nistp256) %}{% set ssh_kexalgos = ssh_kexalgos + [("ecdh-sha2-nistp256")] %}{% endif %}
{% if policy.ssh.ecdh_sha2_nistp384 | default(defaults.apic.fabric_policies.pod_policies.management_access_policies.ssh.ecdh_sha2_nistp384) %}{% set ssh_kexalgos = ssh_kexalgos + [("ecdh-sha2-nistp384")] %}{% endif %}
{% if policy.ssh.ecdh_sha2_nistp521 | default(defaults.apic.fabric_policies.pod_policies.management_access_policies.ssh.ecdh_sha2_nistp521) %}{% set ssh_kexalgos = ssh_kexalgos + [("ecdh-sha2-nistp521")] %}{% endif %}
{% set ssh_macs = [] %}
{% if policy.ssh.hmac_sha1 | default(defaults.apic.fabric_policies.pod_policies.management_access_policies.ssh.hmac_sha1) %}{% set ssh_macs = ssh_macs + [("hmac-sha1")] %}{% endif %}
{% if policy.ssh.hmac_sha2_256 | default(defaults.apic.fabric_policies.pod_policies.management_access_policies.ssh.hmac_sha2_256) %}{% set ssh_macs = ssh_macs + [("hmac-sha2-256")] %}{% endif %}
{% if policy.ssh.hmac_sha2_512 | default(defaults.apic.fabric_policies.pod_policies.management_access_policies.ssh.hmac_sha2_512) %}{% set ssh_macs = ssh_macs + [("hmac-sha2-512")] %}{% endif %}
{% set ssl_protocols = [] %}
{% if policy.https.tlsv1 | default(defaults.apic.fabric_policies.pod_policies.management_access_policies.https.tlsv1) %}{% set ssl_protocols = ssl_protocols + [("TLSv1")] %}{% endif %}
{% if policy.https.tlsv1_1 | default(defaults.apic.fabric_policies.pod_policies.management_access_policies.https.tlsv1_1) %}{% set ssl_protocols = ssl_protocols + [("TLSv1.1")] %}{% endif %}
{% if policy.https.tlsv1_2 | default(defaults.apic.fabric_policies.pod_policies.management_access_policies.https.tlsv1_2) %}{% set ssl_protocols = ssl_protocols + [("TLSv1.2")] %}{% endif %}
{% if policy.https.tlsv1_3 | default(defaults.apic.fabric_policies.pod_policies.management_access_policies.https.tlsv1_3) %}{% set ssl_protocols = ssl_protocols + [("TLSv1.3")] %}{% endif %}

#### {{policy.name}}

<caption name="Management Access Policy: {{policy.name ~ defaults.apic.fabric_policies.pod_policies.management_access_policies.name_suffix}}">

| Properties | Value |
|---|---|
| Name | {{policy.name}} |
| Description | {{policy.description}} |
| Alias | {{policy.alias}} |
</caption>

<caption name="Management Access Policy: {{policy.name ~ defaults.apic.fabric_policies.pod_policies.management_access_policies.name_suffix}} - SSH">

| Properties | Value |
|---|---|
| Admin State | {{'enabled' if policy.ssh.admin_state | default(defaults.apic.fabric_policies.pod_policies.management_access_policies.ssh.admin_state) else 'disabled'}} |
| Password Auth State | {{'enabled' if policy.ssh.password_auth | default(defaults.apic.fabric_policies.pod_policies.management_access_policies.ssh.password_auth) else 'disabled'}} |
| Port | {{policy.ssh.port | default(defaults.apic.fabric_policies.pod_policies.management_access_policies.ssh.port)}} |
| Ciphers | {{ssh_ciphers | join(',')}} |
| KEX Algorithms | {{ssh_kexalgos | join(',')}} |
| MACs | {{ssh_macs | join(',')}} |
</caption>

<caption name="Management Access Policy: {{policy.name ~ defaults.apic.fabric_policies.pod_policies.management_access_policies.name_suffix}} - Telnet">

| Properties | Value |
|---|---|
| Admin State | {{'enabled' if policy.telnet.admin_state | default(defaults.apic.fabric_policies.pod_policies.management_access_policies.telnet.admin_state) else 'disabled'}} |
| Port | {{policy.telnet.port | default(defaults.apic.fabric_policies.pod_policies.management_access_policies.telnet.port)}} |
</caption>

<caption name="Management Access Policy: {{policy.name ~ defaults.apic.fabric_policies.pod_policies.management_access_policies.name_suffix}} - HTTP">

| Properties | Value |
|---|---|
| Admin State | {{'enabled' if policy.http.admin_state | default(defaults.apic.fabric_policies.pod_policies.management_access_policies.http.admin_state) else 'disabled'}} |
| Port | {{policy.http.port | default(defaults.apic.fabric_policies.pod_policies.management_access_policies.http.port)}} |
</caption>

<caption name="Management Access Policy: {{policy.name ~ defaults.apic.fabric_policies.pod_policies.management_access_policies.name_suffix}} - HTTPS">

| Properties | Value |
|---|---|
| Admin State | {{'enabled' if policy.https.client_cert_auth_state | default(defaults.apic.fabric_policies.pod_policies.management_access_policies.https.client_cert_auth_state) else 'disabled'}} |
| Port | {{policy.https.port | default(defaults.apic.fabric_policies.pod_policies.management_access_policies.https.port)}} |
| SSL Protocols | {{ssl_protocols | join(',')}} |
| DH Param | {{policy.https.dh | default(defaults.apic.fabric_policies.pod_policies.management_access_policies.https.dh)}} |
| Admin KeyRing | {{policy.https.key_ring | default(defaults.apic.fabric_policies.pod_policies.management_access_policies.https.key_ring)}} |
| Client Certificate Authentication state | {{'enabled' if policy.https.client_cert_auth_state | default(defaults.apic.fabric_policies.pod_policies.management_access_policies.https.client_cert_auth_state) else 'disabled'}} |
</caption>
{% endfor %}
{% endif %}

### BGP Route Reflectors

<caption name="BGP Route Reflectors">

| Properties | Value |
|---|---|
| Name | default |
| ASN | {{apic.fabric_policies.fabric_bgp_as | default("")}} |
| Route Reflector Nodes | {{apic.fabric_policies.fabric_bgp_rr | default([]) | join(", ")}} |
| External Route Reflector Nodes | {{apic.fabric_policies.fabric_bgp_ext_rr | default([]) | join(", ")}} |
</caption>

### Pod Policy Group

{% if apic.fabric_policies.pod_policy_groups|length > 0 %}
{% for pg in apic.fabric_policies.pod_policy_groups | default([]) %}

#### {{pg.name}}

<caption name="Pod Policy Group: {{pg.name}}">

| Properties | Value |
|---|---|
| Pod Policy Group Name | {{pg.name ~ defaults.apic.fabric_policies.pod_policy_groups.name_suffix}} |
| Date / Time Policy | {{ pg.date_time_policy | default("")}} |
| ISIS Policy | |
| COOP Group Policy | |
| BGP Route Reflector Policy | |
| Management Access Policy | {{ pg.management_access_policy | default("")}} |
| SNMP Policy | {{ pg.snmp_policy | default("")}} |
| MACSec Policy | |
</caption>
{% endfor %}
{% else %}
No Pod Policy Groups configured.
{% endif %}

### Pod Fabric Setup Policy

<caption name="Pod Fabric Setup Policy">

| Pod ID | TEP Pool |
|---|---|
{% for pod in apic.pod_policies.pods | default([]) %}
| {{pod.id}} | {{pod.tep_pool}} |
{% endfor %}
</caption>

{% for pod in apic.pod_policies.pods | default([]) %}
{% if pod.remote_pools|length>0 %}

#### Pod {{pod.id}}: Remote Pools

<caption name="Pod {{pod.id}}: Remote Pools">

| Pod ID | Remote ID | Remote Pool |
|---|---|---|
{% for pool in pod.remote_pools | default([]) %}
| {{pod.id}} | {{pool.id}} | {{pool.remote_pool}} |
{% endfor %}
</caption>
{% endif %}
{% if pod.external_tep_pools|length>0 %}

#### Pod {{pod.id}}: External TEP Pools

<caption name="Pod {{pod.id}}: External TEP Pools">

| Pod ID | IP | Reserved Address Count |
|---|---|---|
{% for pool in pod.external_tep_pools | default([]) %}
| {{pod.id}} | {{pool.prefix}} | {{pool.reserved_address_count}} |
{% endfor %}
</caption>
{% endif %}
{% endfor %}

### Fabric Leaf Switch Policy Groups

{% for leaf_polgrp in apic.fabric_policies.leaf_switch_policy_groups | default([]) %}

### Policy: {{leaf_polgrp.name ~ defaults.apic.fabric_policies.leaf_switch_policy_groups.name_suffix}}

<caption name="Fabric Leaf Switch Policy Groups: {{leaf_polgrp.name ~ defaults.apic.fabric_policies.leaf_switch_policy_groups.name_suffix}}">

| Properties | Value |
|---|---|
| Monitoring Policy | |
| TechSupport Export Policy: | |
| Core Export Policy | |
| Inventory Policy | |
| Power Redundancy Policy | {{ leaf_polgrp.psu_policy | default("")}} |
| Analytics Policy | |
| Node Control Policy | {{ leaf_polgrp.node_control_policy| default("")}} |
| TWAMP Server Policy | |
| TWAMP Responder Policy | |
</caption>
{% endfor %}

### Fabric Leaf Switch Profiles

<caption name="Fabric Leaf Switch Profiles">

| Name | Switch Association(s) | Block(s) | Policy Group |
|---|---|---|---|
{% if apic.auto_generate_fabric_leaf_switch_interface_profiles | default(defaults.apic.auto_generate_fabric_leaf_switch_interface_profiles) or apic.auto_generate_switch_pod_profiles | default(defaults.apic.auto_generate_switch_pod_profiles) %}
{% for node in apic.node_policies.nodes | default([]) %}
{% if node.role == "leaf" %}
{% set leaf_switch_profile_name = (node.id ~ ":" ~ node.name) | regex_replace("^(?P<id>.+):(?P<name>.+)$", (apic.fabric_policies.leaf_switch_profile_name | default(defaults.apic.fabric_policies.leaf_switch_profile_name))) %}
{% set leaf_switch_selector_name = (node.id ~ ":" ~ node.name) | regex_replace("^(?P<id>.+):(?P<name>.+)$", (apic.fabric_policies.leaf_switch_selector_name | default(defaults.apic.fabric_policies.leaf_switch_selector_name))) %}
| {{leaf_switch_profile_name}} | {{leaf_switch_selector_name}} | {{node.id}} | {{node.fabric_policy_group | default("")}} |
{% endif %}
{% endfor %}
{% else %}
{% for sw_prof in apic.fabric_policies.leaf_switch_profiles | default([])%}
{% set ns = namespace(blocks = []) %}
{% for sel in sw_prof.selectors | default([]) %}
{% for block in sel.node_blocks | default([]) %}
{% if block.to is not defined %}
{% set _ = ns.blocks.append(block.from) %}
{% else %}
{% set _ = ns.blocks.append(block.from ~ "-" ~ block.to) %}
{% endif %}
{% endfor %}
| {{ sw_prof.name ~ defaults.apic.fabric_policies.leaf_switch_profiles.name_suffix}} | {{sel.name ~ defaults.apic.fabric_policies.leaf_switch_profiles.selectors.name_suffix}} | {{ ns.blocks | join(", ")}} | {{ sel.policy | default("")}} |
{% endfor %}
{% endfor %}
{% endif %}
</caption>

### Fabric Spine Switch Policy Groups

{% for spine_polgrp in apic.fabric_policies.spine_switch_policy_groups | default([]) %}

### Policy: {{spine_polgrp.name ~ defaults.apic.fabric_policies.spine_switch_policy_groups.name_suffix}}

<caption name="Fabric Spine Switch Policy Groups: {{spine_polgrp.name ~ defaults.apic.fabric_policies.spine_switch_policy_groups.name_suffix}}">

| Properties | Value |
|---|---|
| Monitoring Policy | |
| TechSupport Export Policy: | |
| Core Export Policy | |
| Inventory Policy | |
| Power Redundancy Policy | {{ spine_polgrp.psu_policy | default("")}} |
| Analytics Policy | |
| Node Control Policy | {{ spine_polgrp.node_control_policy| default("")}} |
| TWAMP Server Policy | |
| TWAMP Responder Policy | |
</caption>
{% endfor %}

### Fabric Spine Switch Profiles

<caption name="Fabric Spine Switch Profiles">

| Name | Switch Association(s) | Block(s) | Policy Group |
|---|---|---|---|
{% if apic.auto_generate_fabric_spine_switch_interface_profiles | default(defaults.apic.auto_generate_fabric_spine_switch_interface_profiles) or apic.auto_generate_switch_pod_profiles | default(defaults.apic.auto_generate_switch_pod_profiles) %}
{% for node in apic.node_policies.nodes | default([]) %}
{% if node.role == "spine" %}
{% set spine_switch_profile_name = (node.id ~ ":" ~ node.name) | regex_replace("^(?P<id>.+):(?P<name>.+)$", (apic.fabric_policies.spine_switch_profile_name | default(defaults.apic.fabric_policies.spine_switch_profile_name))) %}
{% set spine_switch_selector_name = (node.id ~ ":" ~ node.name) | regex_replace("^(?P<id>.+):(?P<name>.+)$", (apic.fabric_policies.spine_switch_selector_name | default(defaults.apic.fabric_policies.spine_switch_selector_name))) %}
| {{spine_switch_profile_name}} | {{spine_switch_selector_name}} | {{node.id}} | {{node.fabric_policy_group | default("")}} |
{% endif %}
{% endfor %}
{% else %}
{% for sw_prof in apic.fabric_policies.spine_switch_profiles | default([])%}
{% set ns = namespace(blocks = []) %}
{% for sel in sw_prof.selectors | default([]) %}
{% for block in sel.node_blocks | default([]) %}
{% if block.to is not defined %}
{% set _ = ns.blocks.append(block.from) %}
{% else %}
{% set _ = ns.blocks.append(block.from ~ "-" ~ block.to) %}
{% endif %}
{% endfor %}
| {{ sw_prof.name ~ defaults.apic.fabric_policies.spine_switch_profiles.name_suffix}} | {{sel.name ~ defaults.apic.fabric_policies.spine_switch_profiles.selectors.name_suffix}} | {{ ns.blocks | join(", ")}} | {{ sel.policy | default("")}} |
{% endfor %}
{% endfor %}
{% endif %}
</caption>

### Fabric ISIS BFD

<caption name="Fabric ISIS BFD">

| Properties | Value |
|---|---|
| BFD ISIS Policy Configuration | {{apic.fabric_policies.fabric_isis_bfd | default(defaults.apic.fabric_policies.fabric_isis_bfd) }} |
</caption>

### DSCP class-CoS translation policy for L3 traffic

<caption name="DSCP class-CoS translation policy for L3 traffic">

| Properties | Value |
|---|---|
| Admin State | {{apic.fabric_policies.infra_dscp_translation_policy.admin_state | default(defaults.apic.fabric_policies.infra_dscp_translation_policy.admin_state) }} |
| User Level 1 | {{apic.fabric_policies.infra_dscp_translation_policy.level_1 | default(defaults.apic.fabric_policies.infra_dscp_translation_policy.level_1) }} |
| User Level 2 | {{apic.fabric_policies.infra_dscp_translation_policy.level_2 | default(defaults.apic.fabric_policies.infra_dscp_translation_policy.level_2) }} |
| User Level 3 | {{apic.fabric_policies.infra_dscp_translation_policy.level_3 | default(defaults.apic.fabric_policies.infra_dscp_translation_policy.level_3) }} |
| User Level 4 | {{apic.fabric_policies.infra_dscp_translation_policy.level_4 | default(defaults.apic.fabric_policies.infra_dscp_translation_policy.level_4) }} |
| User Level 5 | {{apic.fabric_policies.infra_dscp_translation_policy.level_5 | default(defaults.apic.fabric_policies.infra_dscp_translation_policy.level_5) }} |
| User Level 6 | {{apic.fabric_policies.infra_dscp_translation_policy.level_6 | default(defaults.apic.fabric_policies.infra_dscp_translation_policy.level_6) }} |
| Control Plane Traffic	 | {{apic.fabric_policies.infra_dscp_translation_policy.control_plane | default(defaults.apic.fabric_policies.infra_dscp_translation_policy.control_plane) }} |
| Policy Plane Traffic | {{apic.fabric_policies.infra_dscp_translation_policy.policy_plane | default(defaults.apic.fabric_policies.infra_dscp_translation_policy.policy_plane) }} |
| Span Traffic | {{apic.fabric_policies.infra_dscp_translation_policy.span | default(defaults.apic.fabric_policies.infra_dscp_translation_policy.span) }} |
| Traceroute Traffic | {{apic.fabric_policies.infra_dscp_translation_policy.traceroute | default(defaults.apic.fabric_policies.infra_dscp_translation_policy.traceroute) }} |
</caption>

### PSU Switch Policy

{% if apic.fabric_policies.switch_policies.psu_policies %}
<caption name="PSU Switch Policy">

| Name | Adminitsrative State |
|---|---|
{% for pol in apic.fabric_policies.switch_policies.psu_policies | default([]) %}
{% if pol.admin_state == "n1red" %}
| {{pol.name ~ defaults.apic.fabric_policies.switch_policies.psu_policies.name_suffix}}  | N+1 Redundancy |
{% elif pol.admin_state == "nnred" %}
| {{pol.name ~ defaults.apic.fabric_policies.switch_policies.psu_policies.name_suffix}}  | N+N Redundancy |
{% elif pol.admin_state == "combined" %}
| {{pol.name ~ defaults.apic.fabric_policies.switch_policies.psu_policies.name_suffix}}  | Combined |
{% endif %}
{% endfor %}
</caption>

{% else %}
No PSU Switch Policy configured.
{% endif %}

### Node Control Switch Policy

{% if apic.fabric_policies.switch_policies.node_control_policies|length > 0 %}
<caption name="Node Control Switch Policy">

| Name | Enabled DOM | Feature Selection |
|---|---|---|
{% for pol in apic.fabric_policies.switch_policies.node_control_policies | default([]) %}
| {{pol.name ~ defaults.apic.fabric_policies.switch_policies.node_control_policies.name_suffix}} | {{pol.dom}} | {{pol.telemetry}} |
{% endfor %}
</caption>
{% else %}
No Node Control Switch Policy configured.
{% endif %}

## Access Policies

This section describes the Fabric Access Policies.

## Access Leaf Switch Profiles
<caption name="Access Leaf Switch Profiles">

| Name | Leaf Selector(s) | Block(s) | Policy Group | Interface Selector Profile(s) |
|---|---|---|---|---|
{% if apic.auto_generate_access_leaf_switch_interface_profiles | default(defaults.apic.auto_generate_access_leaf_switch_interface_profiles) or apic.auto_generate_switch_pod_profiles | default(defaults.apic.auto_generate_switch_pod_profiles) %}
{% for node in apic.node_policies.nodes | default([]) %}
{% if node.role == "leaf" %}
{% set leaf_switch_profile_name = (node.id ~ ":" ~ node.name) | regex_replace("^(?P<id>.+):(?P<name>.+)$", (apic.access_policies.leaf_switch_profile_name | default(defaults.apic.access_policies.leaf_switch_profile_name))) %}
{% set leaf_switch_selector_name = (node.id ~ ":" ~ node.name) | regex_replace("^(?P<id>.+):(?P<name>.+)$", (apic.access_policies.leaf_switch_selector_name | default(defaults.apic.access_policies.leaf_switch_selector_name))) %}
{%- set leaf_interface_profile_name = (node.id ~ ":" ~ node.name) | regex_replace("^(?P<id>.+):(?P<name>.+)$", (apic.access_policies.leaf_interface_profile_name | default(defaults.apic.access_policies.leaf_interface_profile_name))) %}
| {{leaf_switch_profile_name}} | {{leaf_switch_selector_name}} | {{node.id}} | {{node.access_policy_group | default("")}} | {{leaf_interface_profile_name}} |
{% endif %}
{% endfor %}
{% else %}
{% for sw_prof in apic.access_policies.leaf_switch_profiles | default([])%}
{% set ns = namespace(blocks = []) %}
{% for sel in sw_prof.selectors | default([]) %}
{% for block in sel.node_blocks | default([]) %}
{% if block.to is not defined %}
{% set _ = ns.blocks.append(block.from) %}
{% else %}
{% set _ = ns.blocks.append(block.from ~ "-" ~ block.to) %}
{% endif %}
{% endfor %}
| {{ sw_prof.name ~ defaults.apic.access_policies.leaf_switch_profiles.name_suffix}} | {{sel.name ~ defaults.apic.access_policies.leaf_switch_profiles.selectors.name_suffix}} | {{ ns.blocks | join(", ")}} | {{ sel.policy | default("")}} | {{sw_prof.interface_profiles | default([]) | join(", ")}} |
{% endfor %}
{% endfor %}
{% endif %}
</caption>

### Access Leaf Interface Profiles

<caption name="Access Leaf Interface Profiles">

| Name | Block(s) | Description | Policy Group |
|---|---|---|---|
{% if apic.auto_generate_access_leaf_switch_interface_profiles | default(defaults.apic.auto_generate_access_leaf_switch_interface_profiles) or apic.auto_generate_switch_pod_profiles | default(defaults.apic.auto_generate_switch_pod_profiles) %}
{% for node in apic.interface_policies.nodes | default([]) %}
{% for node2 in apic.node_policies.nodes | default([]) %}
{% if node2.id == node.id and node2.role == "leaf" %}
{% for port in node.interfaces | default([]) %}
{% set leaf_interface_profile_name = (node.id ~ ":" ~ node2.name) | regex_replace("^(?P<id>.+):(?P<name>.+)$", (apic.access_policies.leaf_interface_profile_name | default(defaults.apic.access_policies.leaf_interface_profile_name))) %}
{% set leaf_interface_selector_name = (node.module | default(defaults.apic.interface_policies.nodes.interfaces.module) ~ ":" ~ port.port) | regex_replace("^(?P<mod>.+):(?P<port>.+)$", (apic.access_policies.leaf_interface_selector_name | default(defaults.apic.access_policies.leaf_interface_selector_name))) %}
| {{leaf_interface_profile_name}} | {{leaf_interface_selector_name}} | {{port.description | default("")}} | {{port.policy_group | default("")}} |
{% endfor %}
{% endif %}
{% endfor %}
{% endfor %}
{% else %}
{% for node in apic.access_policies.leaf_interface_profiles | default([]) %}
{% for selector in node.selectors | default([])%}
{% for block in selector.port_blocks | default([])%}
{% if block.to_port is defined %}
| {{ node.name ~ apic.access_policies.leaf_interface_profiles.name_suffix }} | {{ block.from_module|default(defaults.apic.access_policies.leaf_interface_profiles.selectors.port_blocks.from_module) ~"/"~block.from_port ~ "-" ~ block.from_module|default(defaults.apic.access_policies.leaf_interface_profiles.selectors.port_blocks.from_module)~"/"~block.to_port }} | {{block.description | default("")}} | {{selector.policy_group | default("")}} |
{% else %}
| {{ node.name ~ apic.access_policies.leaf_interface_profiles.name_suffix  }} | {{ block.from_module|default(defaults.apic.access_policies.leaf_interface_profiles.selectors.port_blocks.from_module)~"/"~block.from_port }} | {{block.description | default("")}} | {{selector.policy_group | default("")}} |
{% endif %}
{% endfor %}
{% for block in selector.sub_port_blocks | default([])%}
{% if block.to_port is defined %}
| {{ node.name ~ apic.access_policies.leaf_interface_profiles.name_suffix }} | {{ block.from_module|default(defaults.apic.access_policies.leaf_interface_profiles.selectors.sub_port_blocks.from_module) ~"/"~block.from_port ~ "-" ~ block.from_module|default(defaults.apic.access_policies.leaf_interface_profiles.selectors.sub_port_blocks.from_module)~"/"~block.to_port }} | {{block.description | default("")}} | {{selector.policy_group | default("")}} |
{% else %}
| {{ node.name ~ apic.access_policies.leaf_interface_profiles.name_suffix  }} | {{ block.from_module|default(defaults.apic.access_policies.leaf_interface_profiles.selectors.sub_port_blocks.from_module)~"/"~block.from_port }} | {{block.description | default("")}} | {{selector.policy_group | default("")}} |
{% endif %}
{% endfor %}
{% endfor %}
{% endfor %}
{% endif %}
</caption>

### Access Leaf Interface Policy Groups

<caption name="Access Leaf Interface Policy Groups">

| Name | Link Level Policy | LACP Policy | CDP Policy | LLDP Policy | AAEP | Link Type |
|---|---|---|---|---|---|---|
{% for ipg in apic.access_policies.leaf_interface_policy_groups | default([]) %}
{% set port_type = "" %}
{% if ipg.type == "vpc"%}
{% set port_type = "vPC"%}
{% elif ipg.type == "pc" %}
{% set port_type = "PC" %}
{% elif ipg.type == "access"%}
{% set port_type = "Access" %}
{% else %}
{% endif %}
| {{ipg.name ~ defaults.apic.access_policies.leaf_interface_policy_groups.name_suffix}} | {{ipg.link_level_policy | default("default")}} | {% if ipg.type == "access" %} {%else%}{{ipg.port_channel_policy | default("default")}}{%endif%} | {{ipg.cdp_policy | default("default")}} | {{ipg.lldp_policy | default("default")}} | {{ipg.aaep | default("default")}} | {{port_type}} |
{% endfor %}
</caption>

### Access Spine Switch Profiles

<caption name="Access Spine Switch Profiles">

| Name | Spine Selector(s) | Block(s) | Policy Group | Interface Selector Profile(s) |
|---|---|---|---|---|
{% if apic.auto_generate_access_spine_switch_interface_profiles | default(defaults.apic.auto_generate_access_spine_switch_interface_profiles) or apic.auto_generate_switch_pod_profiles | default(defaults.apic.auto_generate_switch_pod_profiles) %}
{% for node in apic.node_policies.nodes | default([]) %}
{% if node.role == "spine" %}
{% set spine_switch_profile_name = (node.id ~ ":" ~ node.name) | regex_replace("^(?P<id>.+):(?P<name>.+)$", (apic.access_policies.spine_switch_profile_name | default(defaults.apic.access_policies.spine_switch_profile_name))) %}
{% set spine_switch_selector_name = (node.id ~ ":" ~ node.name) | regex_replace("^(?P<id>.+):(?P<name>.+)$", (apic.access_policies.spine_switch_selector_name | default(defaults.apic.access_policies.spine_switch_selector_name))) %}
{%- set spine_interface_profile_name = (node.id ~ ":" ~ node.name) | regex_replace("^(?P<id>.+):(?P<name>.+)$", (apic.access_policies.spine_interface_profile_name | default(defaults.apic.access_policies.spine_interface_profile_name))) %}
| {{spine_switch_profile_name}} | {{spine_switch_selector_name}} | {{node.id}} | {{node.access_policy_group | default("")}} | {{spine_interface_profile_name}} |
{% endif %}
{% endfor %}
{% else %}
{% for sw_prof in apic.access_policies.spine_switch_profiles | default([])%}
{% set ns = namespace(blocks = []) %}
{% for sel in sw_prof.selectors | default([]) %}
{% for block in sel.node_blocks | default([]) %}
{% if block.to is not defined %}
{% set _ = ns.blocks.append(block.from) %}
{% else %}
{% set _ = ns.blocks.append(block.from ~ "-" ~ block.to) %}
{% endif %}
{% endfor %}
| {{ sw_prof.name ~ defaults.apic.access_policies.spine_switch_profiles.name_suffix}} | {{sel.name ~ defaults.apic.access_policies.spine_switch_profiles.selectors.name_suffix}} | {{ ns.blocks | join(", ")}} | {{ sel.policy | default("")}} | {{sw_prof.interface_profiles | default([]) | join(", ")}} |
{% endfor %}
{% endfor %}
{% endif %}
</caption>

### Access Spine Interface Profiles

<caption name="Access Spine Interface Profiles">

| Name | Block(s) | Description | Policy Group |
|---|---|---|---|
{% if apic.auto_generate_access_spine_switch_interface_profiles | default(defaults.apic.auto_generate_access_spine_switch_interface_profiles) or apic.auto_generate_switch_pod_profiles | default(defaults.apic.auto_generate_switch_pod_profiles) %}
{% for node in apic.interface_policies.nodes | default([]) %}
{% for node2 in apic.node_policies.nodes | default([]) %}
{% if node2.id == node.id and node2.role == "spine" %}
{% for port in node.interfaces | default([]) %}
{% set spine_interface_profile_name = (node.id ~ ":" ~ node2.name) | regex_replace("^(?P<id>.+):(?P<name>.+)$", (apic.access_policies.spine_interface_profile_name | default(defaults.apic.access_policies.spine_interface_profile_name))) %}
{% set spine_interface_selector_name = (node.module | default(defaults.apic.interface_policies.nodes.interfaces.module) ~ ":" ~ port.port) | regex_replace("^(?P<mod>.+):(?P<port>.+)$", (apic.access_policies.spine_interface_selector_name | default(defaults.apic.access_policies.spine_interface_selector_name))) %}
| {{spine_interface_profile_name}} | {{spine_interface_selector_name}} | {{port.description | default("")}} | {{port.policy_group | default("")}} |
{% endfor %}
{% endif %}
{% endfor %}
{% endfor %}
{% else %}
{% for node in apic.access_policies.spine_interface_profiles | default([]) %}
{% for selector in node.selectors | default([]) %}
{% for block in selector.port_blocks | default([]) %}
{% if block.to_port is defined %}
| {{ node.name ~ apic.access_policies.spine_interface_profiles.name_suffix }} | {{ block.from_module|default(defaults.apic.access_policies.spine_interface_profiles.selectors.port_blocks.from_module) ~"/"~block.from_port ~ "-" ~ block.from_module|default(defaults.apic.access_policies.spine_interface_profiles.selectors.port_blocks.from_module)~"/"~block.to_port }} | {{block.description | default("")}} | {{selector.policy_group | default("")}} |
{% else %}
| {{ node.name ~ apic.access_policies.spine_interface_profiles.name_suffix  }} | {{ block.from_module|default(defaults.apic.access_policies.spine_interface_profiles.selectors.port_blocks.from_module)~"/"~block.from_port }} | {{block.description | default("")}} | {{selector.policy_group | default("")}} |
{% endif %}
{% endfor %}
{% endfor %}
{% endfor %}
{% endif %}
</caption>

### Access Spine Interface Policy Groups

<caption name="Access Spine Interface Policy Groups">

| Name | Link Level Policy | CDP Policy | AAEP |
|---|---|---|---|
{% for ipg in apic.access_policies.leaf_interface_policy_groups | default([]) %}
| {{ipg.name ~ defaults.apic.access_policies.spine_interface_policy_groups.name_suffix}} | {{ipg.link_level_policy | default("default")}} | {{ipg.cdp_policy | default("default")}} | {{ipg.aaep | default("default")}} |
{% endfor %}
</caption>


### Link Level Policies

{% if apic.access_policies.link_level_policies|length > 0 %}
<caption name="Link Level Policies">

| Name | Auto-Negotiation | Speed | Link Bounce Interval (ms) |
|---|---|---|---|
{% for pol in apic.access_policies.link_level_policies | default([])%}
| {{pol.name ~ defaults.apic.access_policies.link_level_policies.name_suffix}} | {{pol.auto | default(defaults.apic.access_policies.link_level_policies.auto)}} | {{pol.speed | default(defaults.apic.access_policies.link_level_policies.speed)}} | |
{% endfor %}
</caption>
{% else %}
No Link Level Policies configured.
{% endif %}

### CDP Policies

{% if apic.access_policies.interface_policies.cdp_policies|length > 0 %}
<caption name="CDP Policies">

| Name | Admin State |
|---|---|
{% for pol in apic.access_policies.interface_policies.cdp_policies | default([]) %}
| {{pol.name ~ defaults.apic.access_policies.interface_policies.cdp_policies.name_suffix}} | {{pol.admin_state}} |
{% endfor %}
</caption>
{% else %}
No CDP Policies configured.
{% endif %}

### LLDP Interface Policies

{% if apic.access_policies.interface_policies.lldp_policies|length > 0 %}
<caption name="LLDP Policies">

| Name | Receive State | Transmit State |
|---|---|---|
{% for pol in apic.access_policies.interface_policies.lldp_policies | default([]) %}
| {{pol.name ~ defaults.apic.access_policies.interface_policies.lldp_policies.name_suffix}} | {{pol.admin_rx_state}} | {{pol.admin_tx_state}} |
{% endfor %}
</caption>
{% else %}
No LLDP Policies configured.
{% endif %}

### LACP Interface Policies

{% if apic.access_policies.interface_policies.port_channel_policies|length > 0 %}
<caption name="LACP Interface Policies">

| Name | Controls | Mode | Minimum Links | Maximum Links |
|---|---|---|---|---|
{% for pol in apic.access_policies.interface_policies.port_channel_policies | default([]) %}
| {{pol.name ~ defaults.apic.access_policies.interface_policies.port_channel_policies.name_suffix}} | {% set controls = [] %}{% if pol.fast_select_standby | default(defaults.apic.access_policies.interface_policies.port_channel_policies.fast_select_standby) %}{% set _ = controls.append("fast-sel-hot-stdby") %}{%endif%}{% if pol.graceful_convergence | default(defaults.apic.access_policies.interface_policies.port_channel_policies.graceful_convergence) %}{% set _ = controls.append("graceful-conv")%}{%endif%}{% if pol.suspend_individual | default(defaults.apic.access_policies.interface_policies.port_channel_policies.suspend_individual) %}{% set _ = controls.append("susp-individual") %}{%endif%}{{controls | join(",")}} | {{pol.mode}} | {{pol.min_links | default(defaults.apic.access_policies.interface_policies.port_channel_policies.min_links)}} | {{pol.max_links | default(defaults.apic.access_policies.interface_policies.port_channel_policies.max_links)}} |
{% endfor %}
</caption>
{% else %}
No LACP Interface Policies configured.
{% endif %}

### LACP Member Policies

{% if apic.access_policies.interface_policies.port_channel_member_policies|length > 0 %}
<caption name="LACP Member Policies">

| Name | Priority | Transmit Rate |
|---|---|---|
{% for pol in apic.access_policies.interface_policies.port_channel_member_policies | default([]) %}
| {{pol.name ~ defaults.apic.access_policies.interface_policies.port_channel_member_policies.name_suffix}} | {{pol.priority | default(defaults.apic.access_policies.interface_policies.port_channel_member_policies.priority)}} | {{pol.rate | default(defaults.apic.access_policies.interface_policies.port_channel_member_policies.rate)}} |
{% endfor %}
</caption>
{% else %}
No LACP Member Policies configured.
{% endif %}

### MCP Interface Policies

{% if apic.access_policies.interface_policies.mcp_policies|length > 0 %}
<caption name="MCP Interface Policies">

| Name | Administrative State |
|---|---|
{% for pol in apic.access_policies.interface_policies.mcp_policies | default([]) %}
| {{pol.name ~ defaults.apic.access_policies.interface_policies.mcp_policies.name_suffix}} | {{pol.admin_state}} |
{% endfor %}
</caption>
{% else %}
No MCP Interface Policies configured.
{% endif %}

### MCP Global Policy

{% if apic.access_policies.mcp|length > 0 %}
<caption name="MCP Global Policy">

| Administrative State | Control | Initial Delay (sec) | Loop Detect Multiplier | Loop Protection Action | Transmit Frequency (sec) |
|---|---|---|---|---|---|
{% set pol = apic.access_policies.mcp %}
| {{pol.admin_state | default(defaults.apic.access_policies.mcp.admin_state)}} | {% if apic.access_policies.mcp.per_vlan | default(defaults.apic.access_policies.mcp.per_vlan) %}pdu-per-vlan{%endif%} | {{pol.apic.access_policies.mcp.initial_delay | default(defaults.apic.access_policies.mcp.initial_delay)}} | {{pol.loop_detection | default(defaults.apic.access_policies.mcp.loop_detection)}} | {{pol.loop_detection | default(defaults.apic.access_policies.mcp.loop_detection)}} | {{pol.frequency_sec | default(defaults.apic.access_policies.mcp.frequency_sec)}} |
</caption>
{% else %}
No MCP Global Policies configured.
{% endif %}

### STP Interface Policies

{% if apic.access_policies.spanning_tree_policies|length > 0 %}
<caption name="STP Interface Policies">
| Name | Control |
|---|---|
{% for pol in apic.access_policies.spanning_tree_policies | default([]) %}{% set control = [] %}{% if pol.bpdu_filter | default(defaults.apic.access_policies.spanning_tree_policies.bpdu_filter) %}{% set _ = control.append("bpdu-filter")%}{%endif%}{% if pol.bpdu_guard | default(defaults.apic.access_policies.spanning_tree_policies.bpdu_guard) %}{% set _ = control.append("bpdu-guard") %}{%endif%}
| {{pol.name ~ defaults.apic.access_policies.spanning_tree_policies.name_suffix}} | {{control | join(",")}} |
{% endfor %}
</caption>
{% else %}
No STP Interface Policies configured.
{% endif %}

### Virtual Port Channel Security Policy

{% if apic.node_policies.vpc_groups.groups|length > 0 %}
<caption name="Virtual Port Channel Security Policy">

| Name | Domain Policy | Nodes | Logical ID | Pod |
|---|---|---|---|---|
{% for vpc in apic.node_policies.vpc_groups.groups | default([]) %}
{% set ns = namespace(pod_id = "1") %}
{% for node in apic.node_policies.nodes %}
{% if node.id == vpc.switch_1 or node.id == vpc.switch_2%}{% set ns.pod_id = node.id %}{%endif%}
{% endfor %}
| {{vpc.name | default("")}} | {{vpc.policy | default("")}} | {{vpc.switch_1}},{{vpc.switch_2}} | {{vpc.id}} | {{ ns.pod_id }} |
{% endfor %}
</caption>
{% else %}
No Virtual Port Channel Security Policy configured.
{% endif %}

### Error Disabled Recovery Policy

<caption name="Error Disabled Recovery Policy">

| Properties | Value |
|---|---|
| Error disable recovery interval| {{apic.fabric_policies.err_disabled_recovery.interval | default(apic.fabric_policies.err_disabled_recovery.interval)}} |
| Frequent EP move | {{apic.fabric_policies.err_disabled_recovery.ep_move | default(apic.fabric_policies.err_disabled_recovery.ep_move)}} |
| BPDU guard | {{apic.fabric_policies.err_disabled_recovery.bpdu_guard | default(apic.fabric_policies.err_disabled_recovery.bpdu_guard)}} |
| Loop indication by MCP | {{apic.fabric_policies.err_disabled_recovery.mcp_loop | default(apic.fabric_policies.err_disabled_recovery.mcp_loop)}} |
</caption>

### AAEPS

<caption name="AAEPs">

| Name | Associated Domain(s) | VLAN Pool(s) |
|---|---|---|
{% for aaep in apic.access_policies.aaeps | default([]) %}
{% for dom in aaep.physical_domains | default([])%}
{% for _dom in apic.access_policies.physical_domains | default([]) %}
{% if dom  ~ defaults.apic.access_policies.physical_domains.name_suffix == _dom.name  ~ defaults.apic.access_policies.physical_domains.name_suffix %}
| {{aaep.name  ~ defaults.apic.access_policies.aaeps.name_suffix}} | {{ dom  ~ defaults.apic.access_policies.physical_domains.name_suffix}} | {{_dom.vlan_pool | default("")}} |
{% endif %}
{% endfor %}
{% endfor %}
{% for dom in aaep.routed_domains | default([])%}
{% for _dom in apic.access_policies.routed_domains | default([]) %}
{% if dom  ~ defaults.apic.access_policies.routed_domains.name_suffix == _dom.name  ~ defaults.apic.access_policies.routed_domains.name_suffix %}
| {{aaep.name  ~ defaults.apic.access_policies.aaeps.name_suffix}} | {{ dom  ~ defaults.apic.access_policies.routed_domains.name_suffix}} | {{_dom.vlan_pool | default("")}} |
{% endif %}
{% endfor %}
{% endfor %}
{% for dom in aaep.vmware_vmm_domains | default([])%}
{% for _dom in apic.fabric_policies.vmware_vmm_domains | default([]) %}
{% if dom  ~ defaults.apic.fabric_policies.vmware_vmm_domains.name_suffix == _dom.name  ~ defaults.apic.fabric_policies.vmware_vmm_domains.name_suffix %}
| {{aaep.name  ~ defaults.apic.fabric_policies.aaeps.name_suffix}} | {{ dom  ~ defaults.apic.fabric_policies.vmware_vmm_domains.name_suffix}} | {{_dom.vlan_pool | default("")}} |
{% endif %}
{% endfor %}
{% endfor %}
{# Missing logic for L2 Domains, FC Domains, Red Hat Domains#}
{% endfor %}
</caption>

### AAEPs Associated with Application EPGs

<caption name="AAEP Associated Application EPGs">

| AAEP | EPG | Encap | Primary Encap | Mode | Deployment Immediacy |
|---|---|---|---|---|---|
{% for aaep in apic.access_policies.aaeps | default([]) %}
{% for epg in aaep.endpoint_groups | default([]) %}
{% if epg.primary_vlan is defined %}
{% set vlan = epg.secondary_vlan %}
{% else %}
{% set vlan = epg.vlan %}
{% endif %}
| {{aaep.name ~ defaults.apic.access_policies.aaeps.name_suffix}} | uni/tn-{{epg.tenant}}/ap-{{epg.application_profile ~ defaults.apic.tenants.application_profiles.name_suffix}}/epg-{{epg.endpoint_group ~ defaults.apic.tenants.application_profiles.endpoint_groups.name_suffix}} | vlan-{{vlan}} | {% if epg.primary_vlan is defined %}vlan-{{epg.primary_vlan}}{% endif %} | {{epg.mode | default(defaults.apic.access_policies.aaeps.endpoint_groups.mode)}} | {{epg.deployment_immediacy | default(defaults.apic.access_policies.aaeps.endpoint_groups.deployment_immediacy)}} |
{% endfor %}
{% endfor %}
</caption>

### Domains

<caption name="Domains">

| Name | Type | Associated VLAN Pool |
|---|---|---|
{% for dom in apic.access_policies.physical_domains | default([])%}
| {{ dom.name ~ defaults.apic.access_policies.physical_domains.name_suffix}} | phys | {{dom.vlan_pool | default("")}} |
{% endfor %}
{% for dom in apic.access_policies.routed_domains | default([])%}
| {{ dom.name ~ defaults.apic.access_policies.physical_domains.routed_domains}} | l3dom | {{dom.vlan_pool | default("")}} |
{% endfor %}
{% for dom in apic.fabric_policies.vmware_vmm_domains | default([])%}
| {{ dom.name ~ defaults.apic.access_policies.physical_domains.vmware_vmm_domains}} | l3dom | {{dom.vlan_pool | default("")}} |
{% endfor %}
</caption>

### VLAN Pools

<caption name="VLAN Pools">

| Name | Pool Allocation Mode | VLAN Range / Allocation Mode |
|---|---|---|
{% for pool in apic.access_policies.vlan_pools | default([]) %}
{% for range in pool.ranges | default([]) %}
| {{ pool.name ~ defaults.apic.access_policies.vlan_pools.name_suffix}} | {{pool.allocation | default(defaults.apic.access_policies.vlan_pools.allocation)}} | {{range.from}}-{{range.to | default(range.from)}} ({{range.allocaton | default(defaults.apic.access_policies.vlan_pools.ranges.allocation)}}) |
{% endfor %}
{% endfor %}
</caption>

## Virtual Networking

This section describes the Virtual Machine Manager (VMM) configuration.

### VMM Domains

<caption name="VMM Domain(s)">

| Name | Vendor | vSwitch Type | VLAN Pool | Access Mode |
|---|---|---|---|---|
{% for vmm in apic.fabric_policies.vmware_vmm_domains | default([]) %}
| {{ vmm.name ~ defaults.apic.fabric_policies.vmware_vmm_domains.name_suffix}} | VMware | Distributed Switch | {{vmm.vlan_pool | default("")}} | {{vmm.access_mode ~ defaults.apic.fabric_policies.vmware_vmm_domains.access_mode}} |
{% endfor %}
</caption>

<caption name="vSwitch Policies">

| VMM Domain | Port Channel Policy | LLDP Policy | CDP Policy | MTU Policy | Netflow Exporter |
|---|---|---|---|---|---|
{% for vmm in apic.fabric_policies.vmware_vmm_domains | default([]) %}
| {{vmm.name ~ defaults.apic.fabric_policies.vmware_vmm_domains.name_suffix}} | {{vmm.vswitch.port_channel_policy | default("")}} | {{vmm.vswitch.lldp_policy | default("")}} | {{vmm.vswitch.cdp_policy | default("")}} | {{vmm.vswitch.mtu_policy | default("")}} | |
{% endfor %}
</caption>

<caption name="vCenter Credential(s)">

| VMM Domain | Profile Name | Username | Description |
|---|---|---|---|
{% for vmm in apic.fabric_policies.vmware_vmm_domains | default([]) %}
{% for creds in vmm.credential_policies | default([]) %}
| {{vmm.name ~ defaults.apic.fabric_policies.vmware_vmm_domains.name_suffix}} | {{ creds.name ~ defaults.apic.fabric_policies.vmware_vmm_domains.credential_policies.name_suffix}} | {{creds.username}} | |
{% endfor %}
{% endfor %}
</caption>

<caption name="vCenter(s)">

| VMM Domain | Name | Type | IP/Hostname | Associated Credential |
|---|---|---|---|---|
{% for vmm in apic.fabric_policies.vmware_vmm_domains | default([]) %}
{% for vcenter in vmm.vcenters %}
| {{vcenter.name ~ defaults.apic.fabric_policies.vmware_vmm_domains.vcenters.name_suffi}} | VMware | {{vcenter.hostname_ip}} | {{vcenter.credential_policy}} |
{% endfor %}
{% endfor %}
</caption>

### VMM Controllers

### VMM Credentials

## Admin Policies

This section describes the Admin Policies.

### AAA

#### TACACS Providers

<caption name="TACACS Providers">

| Hostname | Description | Auth Protocol | Monitor Server | Port | Retries | Timeout | Mgmt EPG |
|---|---|---|---|---|---|---|---|
{% for prov in apic.fabric_policies.aaa.tacacs_providers | default([]) %}
| {{prov.hostname_ip}} | {{prov.description | default("")}} | {{prov.protocol | default(defaults.apic.fabric_policies.aaa.tacacs_providers.protocol)}} | {{prov.monitoring | default(defaults.apic.fabric_policies.aaa.tacacs_providers.monitoring)}} | {{prov.port | default(defaults.apic.fabric_policies.aaa.tacacs_providers.port)}} | {{prov.retries | default(defaults.apic.fabric_policies.aaa.tacacs_providers.retries)}} | {{prov.timeout | default(defaults.apic.fabric_policies.aaa.tacacs_providers.timeout)}} | {{prov.mgmt_epg | default(defaults.apic.fabric_policies.aaa.tacacs_providers.mgmt_epg)}} |
{% endfor %}
</caption>

#### Login Domains

<caption name="AAA Login Domains">

| Login Name | Description | Provider Group | Realm | Server Name | Description | Order |
|---|---|---|---|---|---|---|
{% for dom in apic.fabric_policies.aaa.login_domains | default([]) %}
{% for dom_tac in dom.tacacs_providers | default([])%}
| {{dom.name}} | {{dom.description | default("")}} | {{dom.name}} | {{dom_tac.hostname_ip}} | | {{dom_tac.priority | default(defaults.apic.fabric_policies.aaa.login_domains.tacacs_providers.priority)}} |
{% endfor %}
{% endfor %}
</caption>

#### AuthRealm

<caption name="AAA AuthRealm">

| Properties | Configuration |
|---|---|
| Default Login Policy | {{apic.fabric_policies.aaa.remote_user_login_policy | default(defaults.apic.fabric_policies.aaa.remote_user_login_policy)}} |
| Use ICMP Reachable Only | {{apic.fabric_policies.aaa.default_fallback_check | default(defaults.apic.fabric_policies.aaa.default_fallback_check)}} |
</caption>

<caption name="AAA AuthRealm Default Authentication">

| Properties | Configuration |
|---|---|
| Realm | {{apic.fabric_policies.aaa.default_realm | default(defaults.apic.fabric_policies.aaa.default_realm)}} |
| Login Domain | {{apic.fabric_policies.aaa.default_login_domain | default("")}} |
| Fallback Domain Availability | |
| Realm Subtype | |
</caption>

<caption name="AAA AuthRealm Console Authentication">

| Properties | Configuration |
|---|---|
| Realm | {{apic.fabric_policies.aaa.console_realm | default(defaults.apic.fabric_policies.aaa.console_realm)}} |
| Login Domain | {{apic.fabric_policies.aaa.console_login_domain | default("")}} |
| Realm Subtype | |
</caption>

### Schedulers
{% if apic.fabric_policies.schedulers %}
{% for scheduler in apic.fabric_policies.schedulers | default([]) %}
{% if scheduler.recurring_windows|length > 0 %}
<caption name="Scheduler(s): {{scheduler.name ~ defaults.apic.fabric_policies.schedulers.name_suffix}}">
{{scheduler.name ~ defaults.apic.fabric_policies.schedulers.name_suffix}}

| Name | Day | Hour | Minute | Max Concurrent Nodes | Max Running Time (DD:HH:MM:SS) |
|---|---|---|---|---|---|
{% for recurring in scheduler.recurring_windows | default([])%}
| {{recurring.name ~ defaults.apic.fabric_policies.schedulers.recurring_windows.name_suffix}} | {{recurring.day}} | {{recurring.hour}} | {{recurring.minute}} | | |
{% endfor %}
</caption>
{% endif %}
{% endfor %}
{% else %}
No Schedulers configured.
{% endif %}

### Export Policies

#### Configuration Export Policies

{% if apic.fabric_policies.config_exports|length > 0 %}
<caption name="Export Policies">

| Name | Format | Scheduler | Remote Location | Encrypted | Target DN |
|---|---|---|---|---|---|
{% for pol in apic.fabric_policies.config_exports | default([]) %}
| {{pol.name ~ defaults.apic.fabric_policies.config_exports.name_suffi}} | {{pol.format | default(defaults.apic.fabric_policies.config_exports.format)}} | {{pol.scheduler | default("")}} | {{pol.remote_location | default("")}} | {% if apic.fabric_policies.config_passphrase is defined %}yes{%endif%} | |
{% endfor %}
</caption>
{% else %}
No Config Export Policies configured.
{% endif %}

#### Remote Locations

{% if apic.fabric_policies.remote_locations|length > 0 %}
<caption name="Export Policies">

| Name | Hostname | Username | Remote Path | Protocol | Port | Mgmt EPG |
|---|---|---|---|---|---|---|
{% for remote in apic.fabric_policies.remote_locations | default([])%}
| {{remote.name ~ defaults.apic.fabric_policies.remote_locations.name_suffix}} | {{remote.hostname_ip}} | {{remote.username | default("")}} | {{remote.path | default(defaults.apic.fabric_policies.remote_locations.path)}} | {{remote.protocol}} | {{remote.port}} | {{remote.mgmt_epg | default(defaults.apic.fabric_policies.remote_locations.mgmt_epg)}} |
{% endfor %}
</caption>
{% else %}
No Remote Locations configured.
{% endif %}

## Tenant Design

The table below lists the tenants configured in the fabric.

<caption name="{{apic.tenants|default([])|length}} Tenants">

| Name | Description | Monitoring Policy | Security Domains |
|---|---|---|---|
{% for tenant in apic.tenants | default([]) %}
| {{ tenant.name }} | {{tenant.description | default("")}} | | |
{%endfor%}
</caption>

{% for tenant in apic.tenants | default([]) %}
### Tenant Details: {{tenant.name}}

#### Application Profiles

{% if tenant.application_profiles|length > 0 %}
<caption name="Application Profiles - {{tenant.name}}">

| Name | Description |
|---|---|
{% for ap in tenant.application_profiles | default([]) %}
| {{ap.name ~ defaults.apic.tenants.application_profiles.name_suffix}} | {{ap.description | default("")}} |
{%endfor%}
</caption>
{% else %}
No Application Profiles configured
{% endif %}

#### Endpoint Groups (EPGs)

{% set ns_epg = namespace(epgs_configured = false) %}
{% for ap in tenant.application_profiles | default([]) %}
{% if ap.endpoint_groups|length > 0 %}
{% set ns_epg.epgs_configured = true %}
{% endif %}
{% endfor %}

{% if ns_epg.epgs_configured %}
<caption name="Endpoint Groups - {{tenant.name}}">

| Application Profile | Endpoint Group | Physical Domain | Bridge Domain | Contract - Consumer | Contract - Provider |
|---|---|---|---|---|---|
{% for ap in tenant.application_profiles | default([]) %}
{% for epg in ap.endpoint_groups | default([]) %}
{% set physical_domains_list = [] %}
{% for physical_domain in epg.physical_domains | default([]) %}
{% set _ = physical_domains_list.append(physical_domain) %}
{% endfor %}
{% set contract_consumers_list = [] %}
{% for contract_consumer in epg.contracts.consumers | default([]) %}
{% set _ = contract_consumers_list.append(contract_consumer) %}
{% endfor %}
{% set contract_providers_list = [] %}
{% for contract_provider in epg.contracts.providers | default([]) %}
{% set _ = contract_providers_list.append(contract_provider) %}
{% endfor %}
| {{ ap.name ~ defaults.apic.tenants.application_profiles.name_suffix }} | {{ epg.name ~ defaults.apic.tenants.application_profiles.endpoint_groups.name_suffix }} | {{ physical_domains_list | default([]) | join("<br>") }} | {{ epg.bridge_domain ~ defaults.apic.tenants.bridge_domains.name_suffix }} | {{ contract_consumers_list | default([]) | join("<br>") }} | {{ contract_providers_list | default([]) | join("<br>") }} |
{% endfor %}
{% endfor %}
</caption>
{% else %}
No Endpoint Groups configured
{% endif %}

##### EPG Static Bindings

{% set ns_epg_static_ports = namespace(epg_static_ports_configured = false) %}

{% for ap in tenant.application_profiles | default([]) %}
{% for epg in ap.endpoint_groups | default([]) %}
{% if epg.static_ports|length > 0 %}
{% set epg_static_ports_configured = true %}
{% set ns_epg_static_ports.epg_static_ports_configured = true %}
{% endif %}
{% endfor %}
{% endfor %}
{% if ns_epg_static_ports.epg_static_ports_configured %}
<caption name="EPG Static Bindings - {{tenant.name}}">

| EPG | Encap | Path | Deployment Immediacy | Mode |
|---|---|---|---|---|
{% for ap in tenant.application_profiles | default([]) %}
{% for epg in ap.endpoint_groups | default([]) %}
{% for static_port in epg.static_ports | default([]) %}
{% set ns = namespace(pod_id="1") %}{% for node in apic.node_policies.nodes | default([]) %}{% if node.id == static_port.node_id %}{% set ns.pod_id = node.pod | default(defaults.apic.node_policies.nodes.pod)%}{%endif%}{% endfor %}
| {{epg.name ~ defaults.apic.tenants.application_profiles.endpoint_groups.name_suffix}} | vlan-{{static_port.vlan}} | {% if static_port.channel is defined and static_port.node2_id is defined %}topology/pod-{{ns.pod_id}}/protpaths-{{static_port.node_id}}-{{static_port.node2_id}}/pathep-[{{static_port.channel}}]{% elif static_port.channel is defined and static_port.node2_id is not defined %}topology/pod-{{ns.pod_id}}/paths-{{static_port.node_id}}/pathep-[{{static_port.channel}}]{%else%}topology/pod-{{ns.pod_id}}/paths-{{static_port.node_id}}/pathep-[eth{{static_port.module|default(defaults.apic.tenants.application_profiles.endpoint_groups.static_ports.module)}}/{{static_port.port}}]{%endif%} | {{static_port.deployment_immediacy | default(defaults.apic.tenants.application_profiles.endpoint_groups.static_ports.deployment_immediacy)}} | {{static_port.mode | default(defaults.apic.tenants.application_profiles.endpoint_groups.static_ports.mode)}} |
{% endfor %}
{% endfor %}
{% endfor %}
</caption>
{% else %}
No EPG Static Bindings configured.
{% endif %}

#### VRFs

{% if tenant.vrfs|length > 0 %}
<caption name="VRFs - {{tenant.name}}">

| Name | Policy Enforcement | Policy Enforcement Direction | Preferred Group |
|---|---|---|---|---|
{% for vrf in tenant.vrfs | default([])%}
| {{vrf.name ~ defaults.apic.tenants.vrfs.name_suffix}} | {{vrf.enforcement_preference | default(defaults.apic.tenants.vrfs.enforcement_preference)}} | {% if vrf.ndo_managed | default(defaults.apic.tenants.vrfs.ndo_managed) %}NDO Managed{% else %}{{vrf.enforcement_direction | default(defaults.apic.tenants.vrfs.enforcement_direction)}}{% endif %} | {{vrf.preferred_group | default(defaults.tenants.vrfs.preferred_group)}} |
{% endfor %}
</caption>
{% else %}
No VRFs configured
{% endif %}

##### Provided Contracts

{% for vrf in tenant.vrfs | default([]) %}
{% if vrf.contracts.providers|length > 0 %}
{% set provided_contracts = true %}
{% endif %}
{% endfor %}
{% if provided_contracts %}
<caption name="VRF Provided contracts - {{tenant.name}}">

| VRF | Contract | Contract owned by Tenant |
|---|---|---|
{% for vrf in tenant.vrfs | default([]) %}
{% for prov in vrf.contracts.providers | default([]) %}
{% set ns = namespace(contract_in_same_tenant = False) %}
{% for contract in tenant.contracts | default([]) %}
{% if prov == contract.name ~ defaults.apic.tenants.contracts.name_suffix %}
{% set ns.contract_in_same_tenant = True %}
{% endif %}
{% endfor %}
{% if ns.contract_in_same_tenant %}
| {{vrf.name ~ defaults.apic.tenants.vrfs.name_suffix}} | {{prov}} | {{tenant.name}} |
{% else %}
| {{vrf.name ~ defaults.apic.tenants.vrfs.name_suffix}} | {{prov}} | common |
{% endif %}
{% endfor %}
{% endfor %}
</caption>
{% else %}
No contracts are being provided by VRFs.
{% endif %}

##### Consumed Contracts

{% for vrf in tenant.vrfs | default([]) %}
{% if vrf.contracts.providers|length > 0 %}
{% set consumed_contracts = true %}
{% endif %}
{% endfor %}
{% if consumed_contracts %}
<caption name="VRF Consumed contracts - {{tenant.name}}">

| VRF Name | Contract | Contract owned by Tenant |
|---|---|---|
{% for vrf in tenant.vrfs | default([]) %}
{% for contract in vrf.contracts.consumers | default([]) %}
{% set ns = namespace(same_tenant=False) %}
{% for ctr in tenant.contracts | default([])%}
{%if ctr.name == contract %}
{% set ns.same_tenant = True %}
{% endif %}
{% endfor %}
{% if ns.same_tenant == True %}
| {{vrf.name ~ defaults.apic.tenants.vrfs.name_suffix}} | {{contract ~ defaults.apic.tenants.contracts.name_suffix}} | {{tenant.name}} |
{% else %}
| {{vrf.name ~ defaults.apic.tenants.vrfs.name_suffix}} | {{contract ~ defaults.apic.tenants.contracts.name_suffix}} | common |
{% endif %}
{% endfor %}
{% for contract in vrf.contracts.imported_consumers | default([])%}
{% for imp_ctr in tenant.imported_contracts | default([]) %}
{‰ if contract == imp_ctr.name %}
| {{ tenant.name }} | {{vrf.name ~ defaults.apic.tenants.vrfs.name_suffix}} | {{contract ~ defaults.apic.tenants.contracts.name_suffix}} | {{imp_ctr.tenant}} |
{‰ endif %}
{% endfor %}
{% endfor %}
{% endfor %}
</caption>
{% else %}
No contracts are being consumed by VRFs.
{% endif %}

{% if tenant.vrfs|length > 0 %}
##### Miscellaneous Properties

<caption name="VRF(s) Properties - {{tenant.name}}">

| VRF | DNS Labels | IP Dataplane Learning | Endpoint Retention Policy |
|---|---|---|---|---|---|
{% for vrf in tenant.vrfs | default([])%}
| {{vrf.name ~ defaults.apic.tenants.vrfs.name_suffix}} | {{vrf.dns_labels|default([])|join(", ")}} | {% if vrf.data_plane_learning | default(defaults.apic.tenants.vrfs.data_plane_learning) %}enabled{%else%}disabled{%endif%} | {{ vrf.endpoint_retention_policy	| default("") }} |
{% endfor %}
</caption>
{% endif %}

#### Bridge Domains

{% if tenant.bridge_domains|length > 0 %}
<caption name="Bridge Domains - {{tenant.name}}">

| Name | VRF | Description | BD Configuration | BD Subnets | Associated L3OUTs |
|---|---|---|---|---|---|
{% for bd in tenant.bridge_domains | default([])%}
{% set ns = namespace(bd_subnets = []) %}
{% for subnet in bd.subnets %}
{% if subnet.public | default(defaults.apic.tenants.bridge_domains.subnets.public) %}{% set _ = ns.bd_subnets.append(subnet.ip ~ " (public)")%}{%else%}{% set _ = ns.bd_subnets.append(subnet.ip ~ " (private)")%}{%endif%}
{% endfor %}
| {{bd.name ~ defaults.apic.tenants.bridge_domains.name_suffix}} | {{ bd.vrf | default("")}} | {{bd.description|default("")}} | L2 Unicast: {{bd.unkown_unicast|default(defaults.apic.tenants.bridge_domains.unknown_unicast)}}<br>L3 Unknown Multicast: {{bd.unknown_ipv4_multicast|default(defaults.apic.tenants.bridge_domains.unknown_ipv4_multicast)}}<br>Multi-destination Flooding: {{bd.multi_destination_flooding|default(defaults.apic.tenants.bridge_domains.multi_destination_flooding)}}<br>Unicast Routing: {{bd.unicast_routing|default(defaults.apic.tenants.bridge_domains.unicast_routing)}}<br>ARP Flooding: {{bd.arp_flooding | default(defaults.apic.tenants.bridge_domains.arp_flooding)}}<br>Unicast Routing: {{bd.unicast_routing | default(defaults.apic.tenants.bridge_domains.arp_flooding)}}<br>Limit IP Learning to Subnet: {{bd.limit_ip_learn_to_subnets|default(defaults.apic.tenants.bridge_domains.limit_ip_learn_to_subnets)}}<br>EP Move Detect: {{bd.ep_move_detection|default(defaults.apic.tenants.bridge_domains.ep_move_detection)}} | {{ns.bd_subnets|join("<br>")}} | {{bd.l3outs|default([])|join("<br>")}} |
{%endfor%}
</caption>
{% else %}
No Bridge Domains configured.
{%endif%}

#### L3OUTs

{% if tenant.l3outs|length > 0 %}
{% for l3out in tenant.l3outs | default([])%}

##### L3OUT Details: {{ l3out.name ~ defaults.apic.tenants.l3outs.name_suffix }}

<caption name="Layer 3 Outside Connections ({{l3out.name}}) - {{tenant.name}}">

| Name | VRF | Description | External L3 Domain | Routing Protocol |
|---|---|---|---|---|
{% set ns = namespace(bgp=False,ospf=False,eigrp=False)%}
{% for node_profile in l3out.node_profiles | default([])%}
{% for interfaces in node_profile.interface_profiles | default([])%}
{% for interface in interfaces.interfaces | default([])%}
{% if node_profile.bgp_peers is defined or interface.bgp_peers is defined %}
{% set ns.bgp = True%}
{% endif %}
{% endfor %}
{% endfor %}
{% endfor %}
{% if l3out.ospf is defined %}
{% set ns.ospf = True%}
{% endif %}
{% set protocols = []%}
{% if ns.bgp %}{% set _ = protocols.append("BGP")%}{%endif%}
{% if ns.ospf %}{% set _ = protocols.append("OSPF")%}{%endif%}
| {{l3out.name ~ defaults.apic.tenants.l3outs.name_suffix}} | {{l3out.vrf ~ defaults.apic.tenants.vrfs.name_suffix}} | {{l3out.description | default("")}} | {{l3out.domain ~ defaults.access_policies.routed_domains.name_suffix}} | {{protocols | join(", ")}} |
</caption>

###### Node and Interface Profiles

{% if l3out.node_profiles is defined %}
<caption name="Logical Node Profile(s) ({{l3out.name}}) - {{tenant.name}}">

| Name | Description | Node ID | Router ID / Is Loopback | Static Route / Next Hop - Preference |
|---|---|---|---|---|
{% for node_profile in l3out.node_profiles | default([])%}
{% for node in node_profile.nodes | default([]) %}
{% if node.static_routes is defined %}
{% for route in node.static_routes | default([]) %}
{% for next_hop in route.next_hops | default([]) %}
| {{ node_profile.name ~ defaults.apic.tenants.l3outs.node_profiles.name_suffix }} | {{ node.description | default("") }} | {{ node.node_id | default("") }} | {{node.router_id}} / {% if node.router_id_as_loopback | default(defaults.apic.tenants.l3outs.node_profiles.nodes.router_id_as_loopback)%}yes{%else%}no{%endif%} |  {{route.prefix}} / {{next_hop.ip}} - {{next_hop.preference | default(defaults.apic.tenants.l3outs.node_profiles.nodes.static_routes.next_hops.preference) }} |
{% endfor %}
{% endfor %}
{%else%}
| {{ node_profile.name ~ defaults.apic.tenants.l3outs.node_profiles.name_suffix }} | {{ node.description | default("") }} | {{ node.node_id | default("") }} | {{node.router_id}} / {% if node.router_id_as_loopback | default(defaults.apic.tenants.l3outs.node_profiles.nodes.router_id_as_loopback)%}yes{%else%}no{%endif%} |  {{""}} |
{%endif%}
{% endfor %}
{% endfor %}
</caption>
{% else %}
No L3OUT Node Profiles configured.
{% endif %}

{% if ns.ospf %}
<caption name="Logical Interface Profile(s) ({{l3out.name}}) - {{tenant.name}}">

| Node Profile | Node | Path | IP Address | Secondary IP | Encap | Mode | MTU | OSPF Interface Profile | Auth Type | Auth Key Id |
|---|---|---|---|---|---|---|---|---|---|
{% for node_prof in l3out.node_profiles | default([])%}
{% for int_prof in node_prof.interface_profiles | default([])%}
{% for int in int_prof.interfaces | default([])%}
{% set ns = namespace(pod_id="1") %}{% for node in apic.node_policies.nodes | default([]) %}{% if node.id == int.node_id %}{% set ns.pod_id = node.pod | default(defaults.apic.node_policies.nodes.pod)%}{%endif%}{% endfor %}
| {{int_prof.name ~ defaults.apic.tenants.l3outs.node_profiles.interface_profiles.name_suffix  }} | {% if int.node2_id is defined %}{{ int.node_id ~","~int.node2_id}}{%else%}{{int.node_id}}{%endif%} | {% if int.channel is defined and int.node2_id is defined %}topology/pod-{{ns.pod_id}}/protpaths-{{int.node_id}}-{{int.node2_id}}/pathep-[{{int.channel}}]{% elif int.channel is defined and int.node2_id is not defined %}topology/pod-{{ns.pod_id}}/paths-{{int.node_id}}/pathep-[{{int.channel}}]{%else%}topology/pod-{{ns.pod_id}}/paths-{{int.node_id}}/pathep-[eth{{int.module|default(defaults.apic.l3outs.node_profiles.interface_profiles.interfaces.module)}}/{{int.port}}]{%endif%} | {{int.ip | default(defaults.apic.tenants.l3outs.node_profiles.interface_profiles.interfaces.ip)}} | {{ int.ip_shared | default("") }} | {% if int.vlan is defined %}{{ "vlan-"~int.vlan }}{%endif%} | {% if int.svi | default(defaults.apic.tenants.l3outs.node_profiles.nodes.interface_profiles.interfaces.svi) is true %}{{ int.mode | default(defaults.apic.tenants.l3outs.node_profiles.interface_profiles.interfaces.mode) }}{%else%}-{% endif%} | {{int.mtu | default(defaults.apic.tenants.l3outs.node_profiles.interface_profiles.interface.mtu)}} |  {{ int_prof.ospf.policy | default("") }} | {{ int_prof.ospf.auth_type | default(defaults.apic.tenants.l3outs.node_profiles.interface_profiles.ospf.auth_type) }} | {{ int_prof.ospf.auth_key_id | default(defaults.apic.tenants.l3outs.node_profiles.interface_profiles.ospf.auth_key_id) }} |
{% endfor %}
{% endfor %}
{% endfor %}
</caption>

{% elif ns.bgp %}
<caption name="Logical Interface Profile(s) ({{l3out.name}}) - {{tenant.name}}">

| Node Profile | Node | Path | IP Address | Secondary IP | Encap | Mode | MTU | BGP peer |
|---|---|---|---|---|---|---|---|---|---|---|
{% for node_prof in l3out.node_profiles | default([])%}
{% for int_prof in node_prof.interface_profiles | default([])%}
{% for int in int_prof.interfaces | default([])%}
{% set bgp_peers_list =[] %}
{% set ns = namespace(pod_id="1") %}{% for node in apic.node_policies.nodes | default([]) %}{% if node.id == int.node_id %}{% set ns.pod_id = node.pod | default(defaults.apic.node_policies.nodes.pod)%}{%endif%}{% endfor %}
| {{int_prof.name ~ defaults.apic.tenants.l3outs.node_profiles.interface_profiles.name_suffix }} | {% if int.node2_id is defined %}{{ int.node_id ~","~int.node2_id}}{%else%}{{int.node_id}}{%endif%} | {% if int.channel is defined and int.node2_id is defined %}topology/pod-{{ns.pod_id}}/protpaths-{{int.node_id}}-{{int.node2_id}}/pathep-[{{int.channel}}]{% elif int.channel is defined and int.node2_id is not defined %}topology/pod-{{ns.pod_id}}/paths-{{int.node_id}}/pathep-[{{int.channel}}]{%else%}topology/pod-{{ns.pod_id}}/paths-{{int.node_id}}/pathep-[eth{{int.module|default(defaults.apic.tenants.l3outs.node_profiles.interface_profiles.interfaces.module)}}/{{int.port}}]{%endif%} | {{int.ip | default(defaults.apic.tenants.l3outs.node_profiles.interface_profiles.interfaces.ip)}} | {{ int.ip_shared | default("") }} | {% if int.vlan is defined %}{{ "vlan-"~int.vlan }}{%endif%} | {% if int.svi | default(defaults.apic.tenants.l3outs.node_profiles.interface_profiles.interfaces.svi) is true %}{{ int.mode | default(defaults.apic.tenants.l3outs.node_profiles.interface_profiles.interfaces.mode) }}{%else%}-{% endif%} | {{int.mtu | default(defaults.apic.tenants.l3outs.node_profiles.interface_profiles.interface.mtu)}} |  {% for bgp_peer in int.bgp_peers %}{% set _ = bgp_peers_list.append(bgp_peer.ip) %}{% endfor %}{{ bgp_peers_list | join("<br>") }} |
{% endfor %}
{% endfor %}
{% endfor %}
</caption>

<caption name="BGP Peer(s) ({{l3out.name}}) - {{tenant.name}}">

| Node Profile | Node | BGP Peer | BGP Peer Configuration |
|---|---|---|---|---|---|---|---|---|
{% for node_prof in l3out.node_profiles | default([])%}
{% for int_prof in node_prof.interface_profiles | default([])%}
{% for int in int_prof.interfaces | default([])%}
{% for bgp_peer in int.bgp_peers | default([])%}
| {{ int_prof.name }} | {% if int.node2_id is defined %}{{ int.node_id ~","~int.node2_id}}{%else%}{{int.node_id}}{%endif%} | {{ bgp_peer.ip }} | Remote AS: {{ bgp_peer.remote_as | default("") }}<br>TTL: {{bgp_peer.ttl|default(defaults.apic.tenants.l3outs.node_profiles.interface_profiles.interfaces.bgp_peers.ttl)}}<br>Allow Self AS: {{bgp_peer.allow_self_as|default(defaults.apic.tenants.l3outs.node_profiles.interface_profiles.interfaces.bgp_peers.allow_self_as)}}<br>AS Override: {{bgp_peer.as_override|default(defaults.apic.tenants.l3outs.node_profiles.interface_profiles.interfaces.bgp_peers.as_override)}}<br>Disable Peer AS Check: {{bgp_peer.disable_peer_as_check|default(defaults.apic.tenants.l3outs.node_profiles.interface_profiles.interfaces.bgp_peers.disable_peer_as_check)}}<br>Next Hop Self: {{bgp_peer.next_hop_self|default(defaults.apic.tenants.l3outs.node_profiles.interface_profiles.interfaces.bgp_peers.next_hop_self)}}<br>Send Community: {{bgp_peer.send_community|default(defaults.apic.tenants.l3outs.node_profiles.interface_profiles.interfaces.bgp_peers.send_community)}}<br>Send Ext Community: {{bgp_peer.send_ext_community|default(defaults.apic.tenants.l3outs.node_profiles.interface_profiles.interfaces.bgp_peers.send_ext_community)}}<br>Allowed Self As Count: {{bgp_peer.allowed_self_as_count|default(defaults.apic.tenants.l3outs.node_profiles.interface_profiles.interfaces.bgp_peers.allowed_self_as_count)}}<br>BFD: {{bgp_peer.bfd|default(defaults.apic.tenants.l3outs.node_profiles.interface_profiles.interfaces.bgp_peers.bfd)}}<br>Disable Connected Check: {{bgp_peer.disable_connected_check|default(defaults.apic.tenants.l3outs.node_profiles.interface_profiles.interfaces.bgp_peers.disable_connected_check)}}<br>Weight: {{bgp_peer.weight|default(defaults.apic.tenants.l3outs.node_profiles.interface_profiles.interfaces.bgp_peers.weight)}}<br>Remove All Private AS: {{bgp_peer.remove_all_private_as|default(defaults.apic.tenants.l3outs.node_profiles.interface_profiles.interfaces.bgp_peers.remove_all_private_as)}}<br>Remove Private AS: {{bgp_peer.remove_private_as|default(defaults.apic.tenants.l3outs.node_profiles.interface_profiles.interfaces.bgp_peers.remove_private_as)}}<br>Replace Private AS With Local AS: {{bgp_peer.replace_private_as_with_local_as|default(defaults.apic.tenants.l3outs.node_profiles.interface_profiles.interfaces.bgp_peers.replace_private_as_with_local_as)}}<br>Unicast Address Family: {{bgp_peer.unicast_address_family|default(defaults.apic.tenants.l3outs.node_profiles.interface_profiles.interfaces.bgp_peers.unicast_address_family)}}<br>Multicast Address Family: {{bgp_peer.multicast_address_family|default(defaults.apic.tenants.l3outs.node_profiles.interface_profiles.interfaces.bgp_peers.multicast_address_family)}}<br>Admin State: {{bgp_peer.admin_state|default(defaults.apic.tenants.l3outs.node_profiles.interface_profiles.interfaces.bgp_peers.admin_state)}}<br>Local AS: {{bgp_peer.local_as|default("")}}<br>AS Propagate: {% if bgp_peer.as_propagate == "dual-as" %}noPrepend+replace-as+dual-as{% elif bgp_peer.as_propagate == "no-prepend" %}no-prepend{%elif bgp_peer.as_propagate == "replace-as"%}no-prepend+replace-as{%else%}{{defaults.apic.tenants.l3outs.node_profiles.interface_profiles.interfaces.bgp_peers.as_propagate}}{%endif%}<br>Peer Prefix Policy: {{bgp_peer.peer_prefix_policy|default("")}}<br>Export Route Control: {{bgp_peer.export_route_control|default("")}}<br>Import Route Control: {{bgp_peer.import_route_control|default("")}}<br>|
{% endfor %}
{% endfor %}
{% endfor %}
{% endfor %}
</caption>

{% elif l3out.node_profiles is defined %}
<caption name="Logical Interface Profile(s) ({{l3out.name}}) - {{tenant.name}}">

| Node Profile | Node | Path | IP Address | Secondary IP | Encap | Mode | MTU |
|---|---|---|---|---|---|---|
{% for node_prof in l3out.node_profiles | default([])%}
{% for int_prof in node_prof.interface_profiles | default([])%}
{% for int in int_prof.interfaces | default([])%}
{% set ns = namespace(pod_id="1") %}{% for node in apic.node_policies.nodes | default([]) %}{% if node.id == int.node_id %}{% set ns.pod_id = node.pod | default(defaults.apic.node_policies.nodes.pod)%}{%endif%}{% endfor %}
| {{int_prof.name ~ defaults.apic.tenants.l3outs.node_profiles.interface_profiles.name_suffix }} | {% if int.node2_id is defined %}{{ int.node_id ~","~int.node2_id}}{%else%}{{int.node_id}}{%endif%} | {% if int.channel is defined and int.node2_id is defined %}topology/pod-{{ns.pod_id}}/protpaths-{{int.node_id}}-{{int.node2_id}}/pathep-[{{int.channel}}]{% elif int.channel is defined and int.node2_id is not defined %}topology/pod-{{ns.pod_id}}/paths-{{int.node_id}}/pathep-[{{int.channel}}]{%else%}topology/pod-{{ns.pod_id}}/paths-{{int.node_id}}/pathep-[eth{{int.module|default(defaults.apic.tenants.l3outs.node_profiles.interface_profiles.interfaces.module)}}/{{int.port}}]{%endif%} | {{int.ip | default(defaults.apic.tenants.l3outs.node_profiles.interface_profiles.interfaces.ip)}} | {{ int.ip_shared | default("") }} | {% if int.vlan is defined %}{{ "vlan-"~int.vlan }}{%endif%} | {% if int.svi | default(defaults.apic.tenants.l3outs.node_profiles.interface_profiles.interfaces.svi) is true %}{{ int.mode | default(defaults.apic.tenants.l3outs.node_profiles.interface_profiles.interfaces.mode) }}{%else%}-{% endif%} | {{int.mtu | default(defaults.apic.tenants.l3outs.node_profiles.interface_profiles.interface.mtu)}} |
{% endfor %}
{% endfor %}
{% endfor %}
</caption>
{% endif %}

{% if l3out.ospf is defined %}
<caption name="OSPF Configuration ({{l3out.name}}) - {{tenant.name}}">

| L3OUT | Area ID | Area Type | Area Cost | Area Controls |
|---|---|---|---|---|
{% set area_ctrl = [] %}
{% if l3out.ospf.area_control_redistribute | default(defaults.apic.tenants.l3outs.ospf.area_control_redistribute) %}{% set area_ctrl = area_ctrl + [("redistribute")] %}{% endif %}
{% if l3out.ospf.area_control_summary | default(defaults.apic.tenants.l3outs.ospf.area_control_summary) %}{% set area_ctrl = area_ctrl + [("summary")] %}{% endif %}
{% if l3out.ospf.area_control_suppress_fa | default(defaults.apic.tenants.l3outs.ospf.area_control_suppress_fa) %}{% set area_ctrl = area_ctrl + [("suppress-fa")] %}{% endif %}
| {{l3out.name ~ defaults.apic.tenants.l3outs.name_suffix}} | {{ l3out.ospf.area }} | {{l3out.ospf.area_type | default(defaults.apic.tenants.l3outs.ospf.area_type)}} | {{l3out.ospf.area_cost | default(defaults.apic.tenants.l3outs.ospf.area_cost)}} | {{ area_ctrl | join(',') }} |
</caption>
{% endif %}

##### External Network Profiles (External EPGs)

{% if l3out.external_endpoint_groups|length > 0 %}
<caption name ="External Network Profile(s) ({{l3out.name}}) - {{tenant.name}}">

| Name | Subnet | Aggregate | Scope | Route Summarization |
|---|---|---|---|---|
{% for extepg in l3out.external_endpoint_groups | default([])%}
{% for subnet in extepg.subnets | default([])%}
{% set scopes = []%}
{% if subnet.import_security | default(defaults.apic.tenants.l3outs.external_endpoint_groups.subnets.import_security) %}{% set _ = scopes.append("External Subnets for the External EPG")%}{%endif%}{% if subnet.shared_security | default(defaults.apic.tenants.l3outs.external_endpoint_groups.subnets.shared_security)%}{% set _ = scopes.append("Shared Security Import Subnet")%}{%endif%}
| {{extepg.name ~ defaults.apic.tenants.l3outs.external_endpoint_groups.name_suffix}} | {{ subnet.prefix }} | {% if subnet.prefix == "0.0.0.0/0" and subnet.export_route_control | default(defaults.apic.tenants.l3outs.external_endpoint_groups.export_route_control) and subnet.aggregate_export_route_control | default(defaults.apic.tenants.l3outs.external_endpoint_groups.aggregate_export_route_control) %}0.0.0.0/0 le 32{% elif subnet.export_route_control | default(defaults.apic.tenants.l3outs.external_endpoint_groups.export_route_control) and subnet.bgp_route_summarization | default(defaults.apic.tenants.l3outs.external_endpoint_groups.bgp_route_summarization) %}{{ subnet.prefix }}{% else %}-{% endif %} |  {{ scopes | join("<br>") }} | {%if subnet.export_route_control|default(defaults.apic.tenants.l3outs.external_endpoint_groups.export_route_control) and subnet.bgp_route_summarization|default(defaults.apic.tenants.l3outs.external_endpoint_groups.bgp_route_summarization) %}{{subnet.prefix}}{%endif%} |
{% endfor %}
{% endfor %}
</caption>
{% else %}
No External Network Profiles (External EPGs) configured.
{% endif %}

{%endfor%}
{% else %}
No L3OUTs configured.
{% endif %}
#### Security Policies

##### Contracts

{% if tenant.contracts|length >0 %}
<caption name="Contracts - {{tenant.name}}">

| Contract | Scope | QoS-Class |
|---|---|---|
{% for contract in tenant.contracts | default([]) %}
| {{contract.name ~ defaults.apic.tenants.contracts.name_suffix}} | {{contract.scope | default(defaults.apic.tenants.contracts.scope)}} | {{contract.qos_class | default(defaults.apic.tenants.contracts.qos_class)}} |
{% endfor %}
{% for contract in tenant.oob_contracts | default([]) %}
| {{contract.name ~ defaults.apic.tenants.oob_contracts.name_suffix}} | {{contract.scope | default(defaults.apic.tenants.oob_contracts.scope)}} | |
{% endfor %}
</caption>
{% else %}
No contracts configured.
{% endif %}

##### Subjects
{% set ns_subjects = namespace(subjects_configured = false) %}

{% for contract in tenant.contracts | default([]) %}
{% for subject in contract.subjects | default([]) %}
{% if subject.filters|length >0 %}
{% set ns_subjects.subjects_configured = true %}
{% endif %}
{% endfor %}
{% endfor %}
{% if ns_subjects.subjects_configured %}
<caption name="Subjects - {{tenant.name}}">

| Contract | Subject | Description | QoS-Class | Service Graph | Reverse Filter Ports | Filter | Action |
|---|---|---|---|---|---|---|
{% for contract in tenant.contracts | default([]) %}
{% for subject in contract.subjects | default([]) %}
{% for filter in subject.filters | default([])%}
| {{contract.name ~ defaults.apic.tenants.contracts.name_suffix}} | {{subject.name ~ defaults.apic.tenants.contracts.subjects.name_suffix}} | {{subject.description | default("")}} | {{subject.qos_class | default(defaults.apic.tenants.contracts.subjects.qos_class)}} | {{ subject.service_graph | default("") }} | {{ subject.reverse_filter_ports | default("") }} | {{filter.filter  | default("") }} | {{ filter.action | default(defaults.apic.tenants.contracts.subjects.filters.action)}} |
{% endfor %}
{% endfor %}
{% endfor %}
{% for contract in tenant.oob_contracts | default([]) %}
{% for subject in contract.subjects | default([]) %}
{% for filter in subject.filters | default([])%}
| {{contract.name ~ defaults.apic.tenants.contracts.name_suffix}} | {{subject.name ~ defaults.apic.tenants.contracts.subjects.name_suffix}} | {{subject.description | default("")}} | {{subject.qos_class | default(defaults.apic.tenants.contracts.subjects.qos_class)}} | {{ subject.service_graph | default("") }}  |  {{ subject.reverse_filter_ports | default("") }} | {{filter.filter | default("") }} |  {{ filter.action | default(defaults.apic.tenants.contracts.subjects.filters.action)}} |
{% endfor %}
{% endfor %}
{% endfor %}
</caption>
{% else %}
No contract subjects configured.
{% endif %}

##### Filters

{% if tenant.filters|length > 0 %}
<caption name="Filters - {{tenant.name}}">

| Filter Name | Entry | EtherType | IP Protocol | Src Port From | Src Port To | Dst Port From | Dst Port To | TCP Rules |
|---|---|---|---|---|---|---|---|---|
{% for filter in tenant.filters | default([])%}
{% for entry in filter.entries | default([]) %}
{% set properties = [] %}
{% if entry.stateful | default(defaults.apic.tenants.filters.entries.stateful) %}{% set x = properties.append("Stateful: Enabled")%}{%else%}{%set _ = properties.append("Stateful: Disabled")%}{%endif%}
| {{ filter.name ~ defaults.apic.tenants.filters.name_suffix}} | {{entry.name ~ defaults.apic.tenants.filters.entries.name_suffix}} | {{entry.ethertype | default(defaults.apic.tenants.filters.entries.ethertype)}} | {% if entry.ethertype == "unspecified" %}{%else%}{{entry.protocol | default(defaults.apic.tenants.filters.entries.protocol)}}{%endif%}| {{entry.source_from_port | default(defaults.apic.tenants.filters.entries.source_from_port)}} | {{entry.source_to_port|default("")}} | {{entry.destination_from_port | default(defaults.apic.tenants.filters.entries.destination_from_port)}} | {{entry.destination_to_port | default("")}} | {{properties|join("<br>")}} |
{% endfor %}
{% endfor %}
</caption>
{% else %}
No contract filters configured.
{% endif %}

#### Policies (Protocol)

##### BGP Policies - BGP Timers

{% if tenant.policies.bgp_timer_policies|length > 0 %}
<caption name="BGP Timers - {{tenant.name}}">

| Name | Description | Keepalive Interval | Hold Interval |
|---|---|---|---|
{% for bgp_timer in tenant.policies.bgp_timer_policies | default([]) %}
| {{ bgp_timer.name ~ defaults.apic.tenants.policies.bgp_timer_policies.name_suffix}} | {{bgp_timer.description | default("")}} | {{bgp_timer.keepalive_interval | default(defaults.apic.tenants.policies.bgp_timer_policies.keepalive_interval)}} | {{bgp_timer.hold_interval | default(defaults.apic.tenants.policies.bgp_timer_policies.hold_interval)}} |
{% endfor %}
</caption>
{% else %}
No BGP Timers configured.
{% endif %}

##### BGP Policies - BGP Address Family Context
{% if tenant.policies.bgp_address_family_context_policies|length > 0 %}
<caption name="BGP Address Family Context - {{tenant.name}}">

| Name | Description | eBGP Distance | iBGP Distance | Local Distance | eBGP Max ECMP | iBGP Max ECMP | Local Max ECMP | Enable Host Route Leak |
|---|---|---|---|---|---|---|---|---|
{% for bgp_afi_pol in tenant.policies.bgp_address_family_context_policies | default([]) %}
| {{bgp_afi_pol.name ~ defaults.apic.tenants.policies.bgp_address_family_context_policies.name_suffix}} | {{bgp_afi_pol.description | default("")}} | {{bgp_afi_pol.ebgp_distance | default(defaults.apic.tenants.policies.bgp_address_family_context_policies.ebgp_distance)}} | {{bgp_afi_pol.ibgp_distance | default(defaults.apic.tenants.policies.bgp_address_family_context_policies.ibgp_distance)}} | {{bgp_afi_pol.local_distance | default(defaults.apic.tenants.policies.bgp_address_family_context_policies.local_distance)}} | {{bgp_afi_pol.ebgp_max_ecmp | default(defaults.apic.tenants.policies.bgp_address_family_context_policies.ebgp_max_ecmp)}} | {{bgp_afi_pol.ibgp_max_ecmp | default(defaults.apic.tenants.policies.bgp_address_family_context_policies.ibgp_max_ecmp)}} | {{bgp_afi_pol.local_max_ecmp | default(defaults.apic.tenants.policies.bgp_address_family_context_policies.local_max_ecmp)}} | {{bgp_afi_pol.enable_host_route_leak | default(defaults.apic.tenants.policies.bgp_address_family_context_policies.enable_host_route_leak)}} |
{% endfor %}
</caption>
{% else %}
No BGP Address Family Context configured.
{% endif %}


##### OSPF Policies

{% if tenant.policies.ospf_interface_policies|length > 0 %}
<caption name="OSPF Timer Policies - {{tenant.name}}">

| Name | Description | Network Type | Interface Controls | Hello Interval | Dead Interval | Retransmit Interval | Transmit Delay |
|---|---|---|---|---|---|---|---|
{% for ospf_pol in tenant.policies.ospf_interface_policies | default([]) %}
| {{ ospf_pol.name | default(defaults.apic.tenants.policies.ospf_interface_policies.name_suffix)}} | {{ospf_pol.description | default("")}} | {{ospf_pol.network_type | default(defaults.apic.tenants.policies.ospf_interface_policies.network_type)}} | Passive Interface: {% if ospf_pol.passive_interface | default(defaults.apic.tenants.policies.ospf_interface_policies) %}enabled{%else%}disabled{%endif%}<br>MTU Ignore: {%if ospf_pol.mtu_ignore | default(defaults.apic.tenants.policies.ospf_interface_policies.mtu_ignore)%}enabled{%else%}disabled{%endif%}<br>Advertise Subnet: {%if ospf_pol.advertise_subnet | default(defaults.apic.tenants.policies.ospf_interface_policies.advertise_subnet)%}enabled{%else%}disabled{%endif%}<br>BFD: {%if ospf_pol.bfd | default(defaults.apic.tenants.policies.ospf_interface_policies)%}enabled{%else%}disabled{%endif%} | {{ospf_pol.hello_interval | default(defaults.apic.tenants.policies.ospf_interface_policies.hello_interval)}} | {{ospf_pol.dead_interval | default(defaults.apic.tenants.policies.ospf_interface_policies.dead_interval)}} | {{ospf_pol.lsa_retransmit_interval | default(defaults.apic.tenants.policies.ospf_interface_policies.lsa_retransmit_interval)}} | {{ospf_pol.lsa_transmit_delay | default(defaults.apic.tenants.policies.ospf_interface_policies.lsa_transmit_delay)}} |
{% endfor %}
</caption>
{% else %}
No OSPF policies configured.
{% endif %}

##### DHCP

{% for dchp_rel in tenant.policies.dhcp_relay_policies | default([])%}
{% if dhcp_rel.providers|length > 0 %}
{% set dchp_policies_configured = true %}
{% endif %}
{% endfor %}
{% if dchp_policies_configured %}
<caption name ="DHCP Relay Policies - {{tenant.name}}">

| Name | Description | Owner | Provider IP | Associated EPG |
|---|---|---|---|---|
{% for dchp_rel in tenant.policies.dhcp_relay_policies | default([])%}
{% for prov in dhcp_rel.providers | default([]) %}
| {{dhcp_rel.name ~ defaults.apic.tenants.policies.dhcp_relay_policies.name_suffix}} | {{dhcp_rel.description | default("")}} | tenant | {{prov.ip}} | {%if prov.type == "epg"%}uni/tn-{{prov.name}}/ap-{{prov.application_profile}}/epg-{{prov.endpoint_group}}{%else%}uni/tn-{{prov.tenant}}/out-{{prov.l3out}}/instP-{{prov.external_endpoint_group}}{%endif%} |
{%endfor%}
{%endfor%}
</caption>
{% else %}
No DHCP Policies configured.
{% endif %}

{% for bd in tenant.bridge_domains | default([])%}
{% if bd.dhcp_labels|length > 0 %}
{% set dhcp_labels_inuse = true %}
{% endif %}
{% endfor %}
{% if dhcp_labels_inuse %}
<caption name="DHCP Relay Associated Bridge Domains - {{tenant.name}}">

| Bridge Domain | DHCP Relay Policy | Owner |
|---|---|---|
{% for bd in tenant.bridge_domains | default([])%}
{% for dhcp in bd.dhcp_labels %}
| {{bd.name ~ defaults.apic.tenants.bridge_domains.name_suffix}} | {{dhcp.dhcp_relay_policy}} | tenant |
{% endfor %}
{% endfor %}
</caption>
{% else %}
No DHCP Policies associated with Bridge Domains.
{% endif %}

##### Route Maps

{% for l3out in tenants.l3outs | default([])%}
{% if l3out.import_route_map.contexts|length > 0 or l3out.export_route_map.contexts|length > 0%}
{% set default_route_maps_defined = true %}
{% endif %}
{% endfor %}
{% if default_route_maps_defined %}
<caption name="Default L3OUT Route-Maps - {{tenant.name}}">

| L3OUT | Route-Map | Direction | Continue? | Context Name | Action | Order | Match Rule | Set Rule |
|---|---|---|---|---|---|---|---|---|
{% for l3out in tenants.l3outs | default([])%}
{% for context in l3out.import_route_map.contexts | default([]) %}
| {{l3out.name ~ defaults.apic.tenants.l3outs.name_suffix}} | default-import | Import | No | {{context.name ~ defaults.apic.tenants.l3outs.import_route_map.contexts.name_suffix}} | {{context.action | default(defaults.apic.tenants.l3outs.import_route_map.contexts.action)}} | {{context.order | default(defaults.apic.tenants.l3outs.import_route_map.contexts.order)}} | {%if context.match_rule is defined%}{{context.match_rule}} {%endif%}| {% if context.set_rule %}{{context.set_rule}}{%endif%} |
{% endfor %}
{% for export in l3out.export_route_map.contexts | default([]) %}
| {{l3out.name ~ defaults.apic.tenants.l3outs.name_suffix}} | default-export | Export | No | {{context.name ~ defaults.apic.tenants.l3outs.export_route_map.contexts.name_suffix}} | {{context.action | default(defaults.apic.tenants.l3outs.export_route_map.contexts.action)}} | {{context.order | default(defaults.apic.tenants.l3outs.export_route_map.contexts.order)}} | {%if context.match_rule is defined%}{{context.match_rule}} {%endif%}| {% if context.set_rule %}{{context.set_rule}}{%endif%} |
{% endfor %}
{% endfor %}
</caption>
{% else %}
No Default Route Maps configured.
{% endif %}

{% if tenant.policies.route_control_route_maps|length > 0 %}
<caption name="Route-Maps - {{tenant.name}}">

| Route-Map | Context | Action | Order | Match Rule(s) | Set Rule |
|---|---|---|---|---|---|
{% for rm in tenant.policies.route_control_route_maps | default([])%}
{% for ctx in rm.contexts %}
| {{rm.name ~ defaults.apic.tenants.policies.route_control_route_maps.name_suffix}} | {{ctx.name ~ defaults.apic.tenants.policies.route_control_route_maps.contexts.name_suffix}} | {{ctx.action | default(defaults.apic.tenants.policies.route_control_route_maps.contexts.action) }} | {{ctx.order | default(defaults.apic.tenants.policies.route_control_route_maps.contexts.order)}} | {{ctx.match_rules|default([])|join("<br>")}} | {{ctx.set_rule | default("")}} |
{% endfor %}
{% endfor %}
</caption>
{% else %}
No Route-Maps configured.
{% endif %}

{% if tenant.policies.match_rules|length > 0 %}
<caption name="Prefix Match Rules - {{tenant.name}}">

| Match Rule | Description | Prefix | Prefix Description | Prefix Aggregate | Prefix From Lenght | Prefix To Length |
|---|---|---|---|---|---|---|
{% for mr in tenant.policies.match_rules | default([]) %}
{% for prefix in mr.prefixes | default([])%}
| {{mr.name ~ defaults.apic.tenants.policies.match_rules.name_suffix}} | {{mr.description | default("")}} | {{prefix.ip}} | {{prefix.aggregate | default(defaults.apic.tenants.policies.match_rules.prefixes.aggregate)}} | {{prefix.from_length | default(defaults.apic.tenants.policies.match_rules.prefixes.from_length)}} | {{prefix.to_length | default(defaults.apic.tenants.policies.match_rules.prefixes.to_length)}} |
{% endfor %}
{% endfor %}
</caption>
{% else %}
No Prefix Match Rules configured.
{% endif %}

{% if tenant.policies.match_rules|length > 0 %}
<caption name="Community Match Rules - {{tenant.name}}">

| Match Rule | Description | Comunity Rule | Community Rule Description | Community | Description | Scope |
|---|---|---|---|---|---|---|
{% for mr in tenant.policies.match_rules | default([]) %}
{% for community in mr.regex_community_terms | default([])%}
{% for community in community_mr.factors | default([]) %}
| {{mr.name ~ defaults.apic.tenants.policies.match_rules}} | {{mr.description | default("")}} | {{community_mr.name}} | {{community_mr.description | default("")}} | {{community.community}} | {{community.description | default("")}} | {{community.scope | default(defaults.apic.tenants.policies.match_rules.community_terms.factors.scope)}} |
{% endfor %}
{% endfor %}
{% endfor %}
</caption>
{% else %}
No Community Match Rules configured.
{% endif %}

{% if tenant.policies.match_rules|length > 0 %}
<caption name="Regex Community Match Rules - {{tenant.name}}">

| Match Rule | Description | Community Rule | Community Rule Description | Name | Description | Type | Regex |
|---|---|---|---|---|---|---|---|
{% for mr in tenant.policies.match_rules | default([]) %}
{% for prefix in mr.prefixes | default([])%}
| {{mr.name ~ defaults.apic.tenants.policies.match_rules.name_suffix}} | {{mr.description | default("")}} | {{community.name ~ defaults.apic.tenants.policies.match_rules.regex_community_terms.name_suffix}} | {{community.description | default("")}} | {{community.type | default(defaults.apic.tenants.policies.match_rules.regex_community_terms.type)}} | {{community.regex}} |
{% endfor %}
{% endfor %}
</caption>
{% else %}
No Regex Community Match Rules configured.
{% endif %}

{% if tenant.policies.set_rules|length > 0 %}
<caption name="Set Rules - {{tenant.name}}">

| Set Rule | Description | Properties |
|---|---|---|
{% for rule in tenant.policies.set_rules | default([]) %}
{% set ns = namespace(properties = [])%}
{% if rule.community is defined%}{% set _ = ns.properties.append("Community: " ~ rule.community ~ " (" ~ rule.community_mode|default(defaults.apic.tenants.policies.set_rules.community_mode) ~ ")")%}{%endif%}
{% if rule.tag is defined%}{%set _ = ns.properties.append("Tag: "~rule.tag)%}{%endif%}
{% if rule.weight is defined%}{%set _ = ns.properties.append("Weight: "~rule.weight)%}{%endif%}
{% if rule.next_hop is defined%}{%set _ = ns.properties.append("Next-hop: "~rule.next_hop)%}{%endif%}
{% if rule.preference is defined%}{%set _ = ns.properties.append("Preference: "~rule.preference)%}{%endif%}
{% if rule.metric is defined%}{%set _ = ns.properties.append("Metric: "~rule.metric)%}{%endif%}
{% if rule.next_hop_propagation is defined%}{%if rule.next_hop_propagation %}{%set _ = ns.properties.append("Next-hop Propagation: Enabled")%}{%else%}{%set _ = ns.properties.append("Next-hop Propagation: Disabled")%}{%endif%}{%endif%}
{% if rule.multipath is defined%}{%if rule.multipath %}{%set _ = ns.properties.append("Multipath: Enabled")%}{%else%}{%set _ = ns.properties.append("Multipath: Disabled")%}{%endif%}{%endif%}
{% if rule.dampening is defined%}{%set _ = ns.properties.append("Dampening Half-Life: "~rule.dampening.half_life|default(defaults.apic.tenants.policies.set_rules.dampening.half_life)~"<br>Dampening Max Suppress Time: "~rule.dampening.max_suppress_time|default(defaults.apic.tenants.policies.set_rules.dampening.max_suppress_time)~"<br>Dampening Reuse Limit: "~rule.dampening.reuse_limit|default(defaults.apic.tenants.policies.set_rules.dampening.reuse_limit)~"<br>Dampening Suppress Limit: "~rule.dampening.suppress_limit|default(defaults.apic.tenants.policies.set_rules.dampening.suppress_limit))%}{%endif%}
{% if rule.set_as_path is defined%}{%set _ = ns.properties.append("AS-path ASN: "~rule.set_as_path.asn~"<br>AS-path Count: "~rule.set_as_path.count|default(defaults.apic.tenants.policies.set_rules.set_as_path.count)~"<br>AS-path Criteria: "~rule.set_as_path.criteria|default(defaults.apic.tenants.policies.set_rules.set_as_path.criteria)~"<br>AS-path Order: "~rule.set_as_path.order|default(defaults.apic.tenants.policies.set_rules.set_as_path.order))%}{%endif%}
{% for com in rule.additional_communities | default([]) %}
{% set _ = ns.properties.append(com.community)%}
{% endfor %}
| {{ rule.name ~ defaults.apic.tenants.policies.set_rules.name_suffix}} | {{rule.description | default("")}} | {{ns.properties|join("<br>")}} |
{% endfor %}
</caption>
{% else %}
No Set Rules configured.
{% endif %}
##### Redirect Policy

{% if tenant.services.redirect_policies|length > 0 %}
<caption name="Redirect Policy - {{tenant.name}}">

| Name | type | hashing |
|---|---|---|
{% for redirect_pol in tenant.services.redirect_policies | default([]) %}
| {{ redirect_pol.name ~ defaults.apic.tenants.services.redirect_policies.name_suffix }} | {{ redirect_pol.type | default(defaults.apic.tenants.services.redirect_policies.type) }} | {{ redirect_pol.hashing | default(defaults.apic.tenants.services.redirect_policies.hashing) }} |
{% endfor %}
</caption>

<caption name="L3 destinations - Redirect Policy">
| Name | l3_destinations - IP | l3_destinations - mac |
|---|---|---|
{% for redirect_pol in tenant.services.redirect_policies %}
{% for dest in redirect_pol.l3_destinations %}
| {{ redirect_pol.name ~ defaults.apic.tenants.services.redirect_policies.name_suffix }} | {{ dest.ip }} | {{ dest.mac }} |
{% endfor %}
{% endfor %}

</caption>

{% else %}
No Redirect Policy Policies
{% endif %}

#### Services (L4-L7)

##### L4L7 Device

{% if tenant.services.l4l7_devices|length > 0 %}
<caption name="L4L7 Device - {{tenant.name}}">

| Name | Service_type | Type | Physical_domain | Function |
|---|---|---|---|---|
{% for l4l7_device in tenant.services.l4l7_devices | default([]) %}
| {{ l4l7_device.name ~ defaults.apic.tenants.services.l4l7_devices.name_suffix }} | {{ l4l7_device.service_type | default("") }} | {{ l4l7_device.type | default("") }} | {{ l4l7_device.physical_domain | default("") }} | {{ l4l7_device.function | default("") }} |
{% endfor %}
</caption>

<caption name="concrete_devices - L4L7 Device">
| L4L7 Device | Concrete Device Name | Concrete Interface Name | Path |
|---|---|---|---|
{% for l4l7_device in tenant.services.l4l7_devices | default([]) %}
{% for concrete_device in l4l7_device.concrete_devices | default([]) %}
{% for concrete_device_interface in concrete_device.interfaces | default([]) %}
{% set ns = namespace(pod_id="1") %}{% for node in apic.node_policies.nodes | default([]) %}{% if node.id == concrete_device_interface.node_id %}{% set ns.pod_id = node.pod | default(defaults.apic.node_policies.nodes.pod)%}{%endif%}{% endfor %}
| {{ l4l7_device.name ~ defaults.apic.tenants.services.l4l7_devices.name_suffix }} | {{ concrete_device.name ~ defaults.apic.tenants.services.l4l7_devices.concrete_devices.name_suffix }} | {{ concrete_device_interface.name ~ defaults.apic.tenants.services.l4l7_devices.concrete_devices.interfaces.name_suffix }} | {% if concrete_device_interface.channel is defined and concrete_device_interface.node2_id is defined %}topology/pod-{{ns.pod_id}}/protpaths-{{concrete_device_interface.node_id}}-{{concrete_device_interface.node2_id}}/pathep-[{{concrete_device_interface.channel}}]{% elif concrete_device_interface.channel is defined and concrete_device_interface.node2_id is not defined %}topology/pod-{{ns.pod_id}}/paths-{{concrete_device_interface.node_id}}/pathep-[{{concrete_device_interface.channel}}]{%else%}topology/pod-{{ns.pod_id}}/paths-{{concrete_device_interface.node_id}}/pathep-[eth{{concrete_device_interface.module|default(defaults.apic.tenants.services.l4l7_devices.concrete_devices.interfaces.module)}}/{{concrete_device_interface.port}}]{%endif%} |
{% endfor %}
{% endfor %}
{% endfor %}
</caption>

<caption name="logical_interfaces - L4L7 Device">
| L4L7 Device | Logical Interface Name | Concrete Device Name | Concrete interface Name | vlan |
|---|---|---|---|---|
{% for l4l7_device in tenant.services.l4l7_devices | default([]) %}
{% for logical_interface in l4l7_device.logical_interfaces | default([]) %}
{% for concrete_interface in logical_interface.concrete_interfaces | default([]) %}
| {{ l4l7_device.name ~ defaults.apic.tenants.services.l4l7_devices.name_suffix }} | {{ logical_interface.name ~ defaults.apic.tenants.services.l4l7_devices.logical_interfaces.name_suffix }} | {{ concrete_interface.device ~ defaults.apic.tenants.services.l4l7_devices.concrete_devices.name_suffix }} | {{ concrete_interface.interface_name ~ defaults.apic.tenants.services.l4l7_devices.concrete_devices.interfaces.name_suffix }} | {{ logical_interface.vlan }} |
{% endfor %}
{% endfor %}
{% endfor %}
</caption>

{% else %}
No L4L7 Device
{% endif %}

##### Service Graph Template

{% if tenant.services.service_graph_templates|length > 0 %}
<caption name="Service Graph Template - {{tenant.name}}">

| Name | Template_type | Redirect | Device Name |
|---|---|---|---|
{% for service_graph_template in tenant.services.service_graph_templates | default([]) %}
| {{ service_graph_template.name ~ defaults.apic.tenants.services.l4l7_devices.name_suffix }} | {{ service_graph_template.template_type | default(defaults.apic.tenants.services.service_graph_templates.template_type) }} | {{ service_graph_template.redirect | default(defaults.apic.tenants.services.service_graph_templates.redirect) }} | {{ service_graph_template.device.name | default("") }} |
{% endfor %}
</caption>

{% else %}
No Service Graph Template
{% endif %}

##### Device Selection Policy

{% if tenant.services.device_selection_policies|length > 0 %}
<caption name="Device Selection Policy - {{tenant.name}}">

| Contract Name | Service Graph Template Name | consumer - Redirect Policy | consumer - Logical Interface | consumer - Bridge Domain | provider - Redirect Policy | provider - Logical Interface | provider - Bridge Domain |
|---|---|---|---|---|---|---|---|
{% for device_selection_policy in tenant.services.device_selection_policies | default([]) %}
| {{ device_selection_policy.service_graph_template }} | {{ device_selection_policy.contract }} | {{ device_selection_policy.consumer.redirect_policy.name }} | {{ device_selection_policy.consumer.logical_interface }} | {{ device_selection_policy.consumer.bridge_domain.name }} | {{ device_selection_policy.provider.redirect_policy.name }} | {{ device_selection_policy.provider.logical_interface }} | {{ device_selection_policy.provider.bridge_domain.name }} |
{% endfor %}
</caption>

{% else %}
No Device Selection Policy
{% endif %}

{% if tenant.name == "mgmt"%}
#### Node Management EPGs

##### INB Endpoint Group
{% if tenant.inb_endpoint_groups|length > 0 %}
<caption name="INB Endpoint Group - {{tenant.name}}">

| Name | vlan | Bridge Domain | Static Route | Contract - Consumer | Contract - Provider |
|---|---|---|---|---|---|
{% for inb_endpoint_group in tenant.inb_endpoint_groups | default([]) %}
{% set static_route_list = [] %}
{% for static_route in inb_endpoint_group.static_routes | default([]) %}
{% set _ = static_route_list.append(static_route) %}
{% endfor %}
{% set contract_consumer_list = [] %}
{% for contract_consumer in inb_endpoint_group.contracts.consumers | default([]) %}
{% set _ = contract_consumer_list.append(contract_consumer) %}
{% endfor %}
{% set contract_providers_list = [] %}
{% for contract_providers in inb_endpoint_group.contracts.providers | default([]) %}
{% set _ = contract_providers_list.append(contract_providers) %}
{% endfor %}
| {{ inb_endpoint_group.name ~ defaults.apic.tenants.inb_endpoint_groups.name_suffix }} | {{ inb_endpoint_group.vlan }} | {{ inb_endpoint_group.bridge_domain }} | {{ static_route_list | join("<br>") }} | {{ contract_consumer_list | default([]) | join("<br>") }} | {{ contract_providers_list | default([]) | join("<br>") }} |
{% endfor %}
</caption>

{% else %}
No INB Endpoint Group
{% endif %}

##### OOB Endpoint Group
{% if tenant.oob_endpoint_groups|length > 0 %}
<caption name="OOB Endpoint Group - {{tenant.name}}">

| Name | Contract - Provider |
|---|---|
{% for oob_endpoint_group in tenant.oob_endpoint_groups | default([]) %}
{% set contract_providers_list = [] %}
{% for contract_providers in oob_endpoint_group.oob_contracts.providers | default([]) %}
{% set _ = contract_providers_list.append(contract_providers) %}
{% endfor %}
| {{ oob_endpoint_group.name ~ defaults.apic.tenants.oob_endpoint_groups.name_suffix | default(defaults.apic.tenants.oob_endpoint_groups.name) }} | {{ contract_providers_list | default([]) | join("<br>") }} |
{% endfor %}
</caption>

{% else %}
No OOB Endpoint Group
{% endif %}

#### OOB External Management Instance
{% if tenant.ext_mgmt_instances|length > 0 %}
<caption name="OOB External Management Instance - {{tenant.name}}">

| Name | Subnets | Contract - Consumer |
|---|---|---|
{% for ext_mgmt_instance in tenant.ext_mgmt_instances | default([]) %}
{% set subnets_list = [] %}
{% for subnet in ext_mgmt_instance.subnets | default([]) %}
{% set _ = subnets_list.append(subnet) %}
{% endfor %}
{% set contract_consumer_list = [] %}
{% for contract_consumer in ext_mgmt_instance.oob_contracts.consumers | default([]) %}
{% set _ = contract_consumer_list.append(contract_consumer) %}
{% endfor %}
| {{ ext_mgmt_instance.name ~ defaults.apic.tenants.ext_mgmt_instance.name_suffix }} | {{ subnets_list | default([]) | join("<br>") }} | {{ contract_consumer_list | default([]) | join("<br>") }} |
{% endfor %}
</caption>

{% else %}
No OOB External Management Instance
{% endif %}
{% else %}
{% endif %}



{%endfor%}
