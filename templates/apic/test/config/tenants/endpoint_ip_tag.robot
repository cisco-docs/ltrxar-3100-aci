{# iterate_list apic.tenants name item[2] #}
*** Settings ***
Documentation   Verify Endpoint IP Tag
Suite Setup     Login APIC
Default Tags    apic   day2   config   tenants
Resource        ../../../apic_common.resource

*** Test Cases ***
{% set tenant = ((apic | default()) | community.general.json_query('tenants[?name==`' ~ item[2] ~ '`]'))[0] %}
{% for tag in tenant.policies.endpoint_ip_tags | default([]) %}
{% set vrf_name = tag.vrf ~ defaults.apic.tenants.vrfs.name_suffix %}

Verify Endpoint IP Tag {{ tag.ip }}
    ${r}=   GET On Session   apic   /api/mo/uni/tn-{{ tenant.name }}/eptags/epiptag-[{{ tag.ip }}]-{{ vrf_name }}.json   params=rsp-subtree=full
    Set Suite Variable   $r   ${r.json()}
    Should Be Equal Value Json String   ${r}   $..fvEpIpTag.attributes.ip   {{ tag.ip }}
    Should Be Equal Value Json String   ${r}   $..fvEpIpTag.attributes.ctxName   {{ vrf_name }}

{% for kv in tag.tags | default([]) %}

Verify Endpoint IP Tag {{ tag.ip }} Key {{ kv.key }} Value {{ kv.value }}
    ${con}=   Set Variable   $..fvEpIpTag.children[?(@.tagTag.attributes.key=='{{ kv.key }}')]
    Should Be Equal Value Json String   ${r}   ${con}..tagTag.attributes.key   {{ kv.key }}
    Should Be Equal Value Json String   ${r}   ${con}..tagTag.attributes.value   {{ kv.value }}

{% endfor %}

{% endfor %}
