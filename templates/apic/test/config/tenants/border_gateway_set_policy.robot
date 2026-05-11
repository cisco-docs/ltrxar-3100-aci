{# iterate_list apic.tenants name item[2] #}
*** Settings ***
Documentation   Verify Border Gateway Set Policy
Suite Setup     Login APIC
Default Tags    apic   day2   config   tenants
Resource        ../../../apic_common.resource

*** Test Cases ***
{% set tenant = ((apic | default()) | community.general.json_query('tenants[?name==`' ~ item[2] ~ '`]'))[0] %}
{% if tenant.name == "infra" %}
{% if tenant.policies.border_gateway_set_policy is defined %}
{% set policy_name = tenant.policies.border_gateway_set_policy.name ~ defaults.apic.tenants.policies.border_gateway_set_policy.name_suffix %}

Verify Border Gateway Set Policy {{ policy_name }}
    ${r}=   GET On Session   apic   /api/mo/uni/tn-infra/vxlanbgwset-{{ policy_name }}.json   params=rsp-subtree=full
    Set Suite Variable   $r   ${r.json()}
    Should Be Equal JMESPath Json   ${r}   imdata[0].vxlanBgwSet.attributes.name   {{ policy_name }}

{% for ip in tenant.policies.border_gateway_set_policy.external_data_plane_ips | default([]) %}
Verify Border Gateway Set Policy {{ policy_name }} External IP {{ ip.ip }} Pod {{ ip.pod_id }}
    ${extip}=   Set Variable   imdata[0].vxlanBgwSet.children[?vxlanExtAnycastIP.attributes.addr=='{{ ip.ip }}' && vxlanExtAnycastIP.attributes.podId=='{{ ip.pod_id }}'] | [0].vxlanExtAnycastIP
    Should Be Equal JMESPath Json   ${r}   ${extip}.attributes.addr   {{ ip.ip }}
    Should Be Equal JMESPath Json   ${r}   ${extip}.attributes.podId   {{ ip.pod_id }}
{% endfor %}

Verify VXLAN Site {{ tenant.policies.border_gateway_set_policy.vxlan_site_id }}
    ${r}=   GET On Session   apic   /api/mo/uni/tn-infra/vxlansite.json
    Set Suite Variable   $r   ${r.json()}
    Should Be Equal JMESPath Json   ${r}   imdata[0].vxlanSite.attributes.id   {{ tenant.policies.border_gateway_set_policy.vxlan_site_id }}

{% endif %}
{% endif %}
