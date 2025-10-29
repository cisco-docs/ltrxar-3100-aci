*** Settings ***
Documentation   Verify Date and Time Policy
Suite Setup     Login APIC
Default Tags    apic   day1   config   fabric_policies
Resource        ../../apic_common.resource

*** Test Cases ***
{% for policy in apic.fabric_policies.pod_policies.date_time_policies | default([]) %}
{% set date_time_policy_name = policy.name ~ defaults.apic.fabric_policies.pod_policies.date_time_policies.name_suffix %}
Verify Date and Time Policy {{ date_time_policy_name }}
    ${r}=   GET On Session   apic   /api/mo/uni/fabric/time-{{ date_time_policy_name }}.json   params=rsp-subtree=full
    Set Suite Variable   $r   ${r.json()}
    Should Be Equal Value Json String   ${r}    $..datetimePol.attributes.name   {{ date_time_policy_name }}
    Should Be Equal Value Json String   ${r}    $..datetimePol.attributes.StratumValue   {{ policy.apic_ntp_server_master_stratum | default(defaults.apic.fabric_policies.pod_policies.date_time_policies.apic_ntp_server_master_stratum) }}
    Should Be Equal Value Json String   ${r}    $..datetimePol.attributes.adminSt   {{ 'enabled' if policy.ntp_admin_state | default(defaults.apic.fabric_policies.pod_policies.date_time_policies.ntp_admin_state) else 'disabled' }}
    Should Be Equal Value Json String   ${r}    $..datetimePol.attributes.authSt   {{ 'enabled' if policy.ntp_auth_state | default(defaults.apic.fabric_policies.pod_policies.date_time_policies.ntp_auth_state) else 'disabled' }}
    Should Be Equal Value Json String   ${r}    $..datetimePol.attributes.serverState   {{ 'enabled' if policy.apic_ntp_server_state | default(defaults.apic.fabric_policies.pod_policies.date_time_policies.apic_ntp_server_state) else 'disabled' }}

{% for server in policy.ntp_servers | default([]) %}

Verify NTP Server {{ server.hostname_ip }}
    ${server}=   Set Variable   $..datetimePol.children[?(@.datetimeNtpProv.attributes.name=='{{ server.hostname_ip }}')]
    Should Be Equal Value Json String   ${r}    ${server}..datetimeNtpProv.attributes.name   {{ server.hostname_ip }}
    Should Be Equal Value Json String   ${r}    ${server}..datetimeNtpProv.attributes.preferred   {{ 'yes' if server.preferred | default(defaults.apic.fabric_policies.pod_policies.date_time_policies.ntp_servers.preferred) else 'no' }}
{% set mgmt_epg = server.mgmt_epg | default(defaults.apic.fabric_policies.pod_policies.date_time_policies.ntp_servers.mgmt_epg) %}
{% if mgmt_epg == "oob" %}
    Should Be Equal Value Json String   ${r}    ${server}..datetimeRsNtpProvToEpg.attributes.tDn   uni/tn-mgmt/mgmtp-default/oob-{{ apic.node_policies.oob_endpoint_group | default(defaults.apic.node_policies.oob_endpoint_group) }}
{% elif mgmt_epg == "inb" %}
    Should Be Equal Value Json String   ${r}    ${server}..datetimeRsNtpProvToEpg.attributes.tDn   uni/tn-mgmt/mgmtp-default/inb-{{ apic.node_policies.inb_endpoint_group | default(defaults.apic.node_policies.inb_endpoint_group) }}
{% endif %}
{% if server.auth_key_id is defined %}
    Should Be Equal Value Json String   ${r}    ${server}..datetimeRsNtpProvToNtpAuthKey.attributes.tnDatetimeNtpAuthKeyId   {{ server.auth_key_id }}
{% endif %}

{% endfor %}

{% for key in policy.ntp_keys | default([]) %}

Verify NTP Key {{ key.id }}
    ${key}=   Set Variable   $..datetimePol.children[?(@.datetimeNtpAuthKey.attributes.id=='{{ key.id }}')]
    Should Be Equal Value Json String   ${r}    ${key}.datetimeNtpAuthKey.attributes.id   {{ key.id }}
    Should Be Equal Value Json String   ${r}    ${key}.datetimeNtpAuthKey.attributes.keyType   {{ key.auth_type }}
    Should Be Equal Value Json String   ${r}    ${key}.datetimeNtpAuthKey.attributes.trusted   {{ 'yes' if key.trusted else 'no' }}

{% endfor %}

{% endfor %}
