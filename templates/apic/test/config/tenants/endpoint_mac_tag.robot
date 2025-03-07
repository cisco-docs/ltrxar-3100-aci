{# iterate_list apic.tenants name item[2] #}
*** Settings ***
Documentation   Verify Endpoint MAC Tag
Suite Setup     Login APIC
Default Tags    apic   day2   config   tenants
Resource        ../../../apic_common.resource

*** Test Cases ***
{% set tenant = ((apic | default()) | community.general.json_query('tenants[?name==`' ~ item[2] ~ '`]'))[0] %}
{% for tag in tenant.policies.endpoint_mac_tags | default([]) %}
{% set bd_name = tag.bridge_domain ~ defaults.apic.tenants.bridge_domains.name_suffix if tag.bridge_domain is defined and tag.bridge_domain != 'all' else '*' %}
{% set vrf_name = tag.vrf ~ defaults.apic.tenants.vrfs.name_suffix %}

Verify Endpoint MAC Tag {{ tag.mac }}
    ${r}=   GET On Session   apic   /api/mo/uni/tn-{{ tenant.name }}/eptags/epmactag-{{ tag.mac }}-[{{ bd_name }}].json   params=rsp-subtree=full
    Set Suite Variable   ${r}
    Should Be Equal Value Json String   ${r.json()}   $..fvEpMacTag.attributes.mac   {{ tag.mac }}
    Should Be Equal Value Json String   ${r.json()}   $..fvEpMacTag.attributes.bdName   {{ bd_name }}
    Should Be Equal Value Json String   ${r.json()}   $..fvEpMacTag.attributes.ctxName   {{ vrf_name }}

{% for kv in tag.tags | default([]) %}

Verify Endpoint MAC Tag {{ tag.mac }} Key {{ kv.key }} Value {{ kv.value }}
    ${con}=   Set Variable   $..fvEpMacTag.children[?(@.tagTag.attributes.key=='{{ kv.key }}')]
    Should Be Equal Value Json String   ${r.json()}   ${con}..tagTag.attributes.key   {{ kv.key }}
    Should Be Equal Value Json String   ${r.json()}   ${con}..tagTag.attributes.value   {{ kv.value }}

{% endfor %}

{% endfor %}
