*** Settings ***
Documentation   Verify DNS Policy
Suite Setup     Login APIC
Default Tags    apic   day0   config   fabric_policies
Resource        ../../apic_common.resource

*** Test Cases ***
{% for policy in apic.fabric_policies.dns_policies | default([]) %}
{% set policy_name = policy.name ~ defaults.apic.fabric_policies.dns_policies.name_suffix %}

Verify DNS Policy {{ policy_name }}
    ${r}=   GET On Session   apic   /api/mo/uni/fabric/dnsp-{{ policy_name }}.json   params=rsp-subtree=full
    Set Suite Variable   $r   ${r.json()}
    Should Be Equal Value Json String   ${r}    $..dnsProfile.attributes.name   {{ policy_name }}
{% set mgmt_epg = policy.mgmt_epg | default(defaults.apic.fabric_policies.dns_policies.mgmt_epg) %}
{% if mgmt_epg == "oob" %}
    Should Be Equal Value Json String   ${r}    $..dnsRsProfileToEpg.attributes.tDn   uni/tn-mgmt/mgmtp-default/oob-{{ apic.node_policies.oob_endpoint_group | default(defaults.apic.node_policies.oob_endpoint_group) }}
{% elif mgmt_epg == "inb" %}
    Should Be Equal Value Json String   ${r}    $..dnsRsProfileToEpg.attributes.tDn   uni/tn-mgmt/mgmtp-default/inb-{{ apic.node_policies.inb_endpoint_group | default(defaults.apic.node_policies.inb_endpoint_group) }}
{% endif %}

{% for provider in policy.providers | default([]) %}

Verify DNS Policy {{ policy_name }} Provider {{ provider.ip }}
    ${provider}=   Set Variable   $..dnsProfile.children[?(@.dnsProv.attributes.addr=='{{ provider.ip }}')]
    Should Be Equal Value Json String   ${r}    ${provider}..dnsProv.attributes.addr   {{ provider.ip }}
    Should Be Equal Value Json String   ${r}    ${provider}..dnsProv.attributes.preferred   {{ 'yes' if provider.preferred | default(defaults.apic.fabric_policies.dns_policies.providers.preferred) else 'no' }}

{% endfor %}

{% for domain in policy.domains | default([]) %}

Verify DNS Policy {{ policy_name }} Domain {{ domain.name }}
    ${domain}=   Set Variable   $..dnsProfile.children[?(@.dnsDomain.attributes.name=='{{ domain.name }}')]
    Should Be Equal Value Json String   ${r}    ${domain}..dnsDomain.attributes.name   {{ domain.name }}
    Should Be Equal Value Json String   ${r}    ${domain}..dnsDomain.attributes.isDefault   {{ 'yes' if domain.default | default(defaults.apic.fabric_policies.dns_policies.domains.default) else 'no' }}
{% endfor %}

{% endfor %}
