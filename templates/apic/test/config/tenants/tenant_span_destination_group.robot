{# iterate_list apic.tenants name item[2] #}
*** Settings ***
Documentation   Verify Tenant SPAN Destination Group
Suite Setup     Login APIC
Default Tags    apic   day2   config   tenants
Resource        ../../../apic_common.resource

*** Test Cases ***
{% set tenant = ((apic | default()) | community.general.json_query('tenants[?name==`' ~ item[2] ~ '`]'))[0] %}
{% for span in tenant.policies.span.destination_groups | default([]) %}
{% set span_dst_grp_name = span.name ~ defaults.apic.tenants.policies.span.destination_groups.name_suffix %}
{% set application_profile_name = span.application_profile ~ defaults.apic.tenants.application_profiles.name_suffix %}
{% set endpoint_group_name = span.endpoint_group ~ defaults.apic.tenants.application_profiles.endpoint_groups.name_suffix %}

Verify Tenant SPAN Destination Group {{ span_dst_grp_name }}
    ${r}=   GET On Session   apic   /api/mo/uni/tn-{{ tenant.name }}/destgrp-{{ span_dst_grp_name }}.json   params=rsp-subtree=full
    Set Suite Variable   $r   ${r.json()}
    Should Be Equal JMESPath Json   ${r}   imdata[0].spanDestGrp.attributes.name   {{ span_dst_grp_name }}
    Should Be Equal JMESPath Json   ${r}   imdata[0].spanDestGrp.attributes.descr   {{ span.description | default() }}
    Should Be Equal JMESPath Json   ${r}   imdata[0].spanDestGrp.children[?spanDest] | [0].spanDest.attributes.name   {{ span_dst_grp_name }}
    Should Be Equal JMESPath Json   ${r}   imdata[0].spanDestGrp.children[?spanDest] | [0].spanDest.children[?spanRsDestEpg] | [0].spanRsDestEpg.attributes.ip   {{ span.ip }}
    Should Be Equal JMESPath Json   ${r}   imdata[0].spanDestGrp.children[?spanDest] | [0].spanDest.children[?spanRsDestEpg] | [0].spanRsDestEpg.attributes.srcIpPrefix   {{ span.source_prefix }}
    Should Be Equal JMESPath Json   ${r}   imdata[0].spanDestGrp.children[?spanDest] | [0].spanDest.children[?spanRsDestEpg] | [0].spanRsDestEpg.attributes.dscp   {{ span.dscp | default(defaults.apic.tenants.policies.span.destination_groups.dscp) }}
    Should Be Equal JMESPath Json   ${r}   imdata[0].spanDestGrp.children[?spanDest] | [0].spanDest.children[?spanRsDestEpg] | [0].spanRsDestEpg.attributes.flowId   {{ span.flow_id | default(defaults.apic.tenants.policies.span.destination_groups.flow_id) }}
    Should Be Equal JMESPath Json   ${r}   imdata[0].spanDestGrp.children[?spanDest] | [0].spanDest.children[?spanRsDestEpg] | [0].spanRsDestEpg.attributes.mtu   {{ span.mtu | default(defaults.apic.tenants.policies.span.destination_groups.mtu) }}
    Should Be Equal JMESPath Json   ${r}   imdata[0].spanDestGrp.children[?spanDest] | [0].spanDest.children[?spanRsDestEpg] | [0].spanRsDestEpg.attributes.ttl   {{ span.ttl | default(defaults.apic.tenants.policies.span.destination_groups.ttl) }}
    Should Be Equal JMESPath Json   ${r}   imdata[0].spanDestGrp.children[?spanDest] | [0].spanDest.children[?spanRsDestEpg] | [0].spanRsDestEpg.attributes.ver   ver{{ span.version | default(defaults.apic.tenants.policies.span.destination_groups.version) }}
    Should Be Equal JMESPath Json   ${r}   imdata[0].spanDestGrp.children[?spanDest] | [0].spanDest.children[?spanRsDestEpg] | [0].spanRsDestEpg.attributes.verEnforced   {{ 'yes' if span.enforce_version | default(defaults.apic.tenants.policies.span.destination_groups.enforce_version) else 'no' }}
    Should Be Equal JMESPath Json   ${r}   imdata[0].spanDestGrp.children[?spanDest] | [0].spanDest.children[?spanRsDestEpg] | [0].spanRsDestEpg.attributes.tDn   uni/tn-{{ span.tenant | default(tenant.name) }}/ap-{{ application_profile_name }}/epg-{{ endpoint_group_name }}

{% endfor %}
