{# iterate_list apic.tenants name item[2] #}
*** Settings ***
Documentation   Verify Tenant SPAN Source Group
Suite Setup     Login APIC
Default Tags    apic   day2   config   tenants
Resource        ../../../apic_common.resource

*** Test Cases ***
{% set tenant = ((apic | default()) | community.general.json_query('tenants[?name==`' ~ item[2] ~ '`]'))[0] %}
{% for span in tenant.policies.span.source_groups | default([]) %}
{% set span_grp_name = span.name ~ defaults.apic.tenants.policies.span.source_groups.name_suffix %}
{% set span_destination_name = span.destination ~ defaults.apic.tenants.policies.span.destination_groups.name_suffix %}

Verify Tenant SPAN Source Group {{ span_grp_name }}
    ${r}=   GET On Session   apic   /api/mo/uni/tn-{{ tenant.name }}/srcgrp-{{ span_grp_name }}.json   params=rsp-subtree=full
    Set Suite Variable   $r   ${r.json()}
    Should Be Equal JMESPath Json   ${r}   imdata[0].spanSrcGrp.attributes.name   {{ span_grp_name }}
    Should Be Equal JMESPath Json   ${r}   imdata[0].spanSrcGrp.attributes.descr   {{ span.description | default() }}
    Should Be Equal JMESPath Json   ${r}   imdata[0].spanSrcGrp.attributes.adminSt   {{ 'enabled' if span.admin_state | default(defaults.apic.tenants.policies.span.source_groups.admin_state) else 'disabled' }}
    Should Be Equal JMESPath Json   ${r}   imdata[0].spanSrcGrp.children[?spanSpanLbl] | [0].spanSpanLbl.attributes.name   {{ span_destination_name }}

{% for source in span.sources | default([]) %}
Verify Tenant SPAN Source Group {{ span_grp_name }} Source {{ source.name }}
    ${src}=   Set Variable   imdata[0].spanSrcGrp.children[?spanSrc.attributes.name=='{{ source.name }}'] | [0].spanSrc
    Should Be Equal JMESPath Json   ${r}   ${src}.attributes.name   {{ source.name  }}
    Should Be Equal JMESPath Json   ${r}   ${src}.attributes.descr   {{ source.description | default()}}
    Should Be Equal JMESPath Json   ${r}   ${src}.attributes.dir   {{ source.direction | default(defaults.apic.tenants.policies.span.source_groups.sources.direction ) }}
{% if source.application_profile is defined and source.endpoint_group is defined %}
{% set application_profile_name = source.application_profile ~ defaults.apic.tenants.application_profiles.name_suffix %}
{% set endpoint_group_name = source.endpoint_group ~ defaults.apic.tenants.application_profiles.endpoint_groups.name_suffix %}
    Should Be Equal JMESPath Json   ${r}   ${src}.children[?spanRsSrcToEpg] | [0].spanRsSrcToEpg.attributes.tDn   uni/tn-{{ tenant.name }}/ap-{{ application_profile_name }}/epg-{{ endpoint_group_name }}
{% endif %}

{% endfor %}

{% endfor %}
