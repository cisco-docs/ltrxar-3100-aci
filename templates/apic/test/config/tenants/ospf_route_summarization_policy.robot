{# iterate_list apic.tenants name item[2] #}
*** Settings ***
Documentation   Verify OSPF Route Summarization Policy
Suite Setup     Login APIC
Default Tags    apic   day2   config   tenants
Resource        ../../../apic_common.resource

*** Test Cases ***
{% set tenant = ((apic | default()) | community.general.json_query('tenants[?name==`' ~ item[2] ~ '`]'))[0] %}
{% for policy in tenant.policies.ospf_route_summarization_policies | default([]) %}
{% set policy_name = policy.name ~ defaults.apic.tenants.policies.ospf_route_summarization_policies.name_suffix %}

Verify OSPF Route Summarization Policy {{ policy_name }}
    ${r}=   GET On Session   apic   /api/mo/uni/tn-{{ tenant.name }}/ospfrtsumm-{{ policy_name }}.json
    Set Suite Variable   ${r}   ${r.json()}
    Should Be Equal JMESPath Json   ${r}   imdata[0].ospfRtSummPol.attributes.name   {{ policy_name }}
    Should Be Equal JMESPath Json   ${r}   imdata[0].ospfRtSummPol.attributes.descr   {{ policy.description | default() }}
    Should Be Equal JMESPath Json   ${r}   imdata[0].ospfRtSummPol.attributes.cost   {{ policy.cost | default(defaults.apic.tenants.policies.ospf_route_summarization_policies.cost) }}
    Should Be Equal JMESPath Json   ${r}   imdata[0].ospfRtSummPol.attributes.interAreaEnabled   {{ 'yes' if policy.inter_area | default(defaults.apic.tenants.policies.ospf_route_summarization_policies.inter_area) else 'no' }}

{% endfor %}
