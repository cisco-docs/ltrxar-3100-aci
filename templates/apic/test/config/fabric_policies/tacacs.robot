*** Settings ***
Documentation   Verify TACACS Providers
Suite Setup     Login APIC
Default Tags    apic   day0   config   fabric_policies
Resource        ../../apic_common.resource

*** Test Cases ***
{% for prov in apic.fabric_policies.aaa.tacacs_providers | default([]) %}

Verify TACACS Provider {{ prov.hostname_ip }}
    ${r}=   GET On Session   apic   /api/mo/uni/userext/tacacsext/tacacsplusprovider-{{ prov.hostname_ip }}.json   params=rsp-subtree=full
    Set Suite Variable   $r   ${r.json()}
    Should Be Equal Value Json String   ${r}    $..aaaTacacsPlusProvider.attributes.name   {{ prov.hostname_ip }}
    Should Be Equal Value Json String   ${r}    $..aaaTacacsPlusProvider.attributes.authProtocol   {{ prov.protocol | default(defaults.apic.fabric_policies.aaa.tacacs_providers.protocol) }}
    Should Be Equal Value Json String   ${r}    $..aaaTacacsPlusProvider.attributes.descr   {{ prov.description | default() }}
    Should Be Equal Value Json String   ${r}    $..aaaTacacsPlusProvider.attributes.port   {{ prov.port | default(defaults.apic.fabric_policies.aaa.tacacs_providers.port) }}
    Should Be Equal Value Json String   ${r}    $..aaaTacacsPlusProvider.attributes.retries   {{ prov.retries | default(defaults.apic.fabric_policies.aaa.tacacs_providers.retries) }}
    Should Be Equal Value Json String   ${r}    $..aaaTacacsPlusProvider.attributes.timeout   {{ prov.timeout | default(defaults.apic.fabric_policies.aaa.tacacs_providers.timeout) }}
    Should Be Equal Value Json String   ${r}    $..aaaTacacsPlusProvider.attributes.monitorServer   {{ 'enabled' if prov.monitoring | default(defaults.apic.fabric_policies.aaa.tacacs_providers.monitoring) else 'disabled' }}
{% if prov.monitoring | default(defaults.apic.fabric_policies.aaa.tacacs_providers.monitoring) %}
    Should Be Equal Value Json String   ${r}    $..aaaTacacsPlusProvider.attributes.monitoringUser   {{ prov.monitoring_username | default() }}
{% endif %}
{% set mgmt_epg = prov.mgmt_epg | default(defaults.apic.fabric_policies.aaa.tacacs_providers.mgmt_epg) %}
{% if mgmt_epg == "oob" %}
    Should Be Equal Value Json String   ${r}    $..aaaRsSecProvToEpg.attributes.tDn   uni/tn-mgmt/mgmtp-default/oob-{{ apic.node_policies.oob_endpoint_group | default(defaults.apic.node_policies.oob_endpoint_group) }}
{% elif mgmt_epg == "inb" %}
    Should Be Equal Value Json String   ${r}    $..aaaRsSecProvToEpg.attributes.tDn   uni/tn-mgmt/mgmtp-default/inb-{{ apic.node_policies.inb_endpoint_group | default(defaults.apic.node_policies.inb_endpoint_group) }}
{% endif %}

{% endfor %}
