*** Settings ***
Documentation   Verify VSPAN Destination Group Health
Suite Setup     Login APIC
Default Tags    apic   day2   health   tenants   non-critical
Resource        ../../apic_common.resource

*** Test Cases ***
{% for vspan in apic.access_policies.vspan.destination_groups | default([]) %}
{% set vspan_name = vspan.name ~ defaults.apic.access_policies.vspan.destination_groups.name_suffix %}

{% if vspan.expected_state.maximum_critical_faults is defined or vspan.expected_state.maximum_major_faults is defined or vspan.expected_state.maximum_minor_faults is defined %}
Verify VSPAN Destination Group {{ vspan_name }} Faults
    ${r}=   GET On Session   apic   /api/mo/uni/infra/vdestgrp-{{ vspan_name }}/fltCnts.json
    Set Suite Variable   $r   ${r.json()}
    ${critical}=   Json Search String   ${r}   imdata[0].faultCounts.attributes.crit
    ${major}=   Json Search String   ${r}   imdata[0].faultCounts.attributes.maj
    ${minor}=   Json Search String   ${r}   imdata[0].faultCounts.attributes.minor
{% if vspan.expected_state.maximum_critical_faults is defined %}
    Run Keyword If   ${critical} > {{ vspan.expected_state.maximum_critical_faults }}   Run Keyword And Continue On Failure
    ...   Fail  "{{ vspan_name }} has ${critical} critical faults"
{% endif %}
{% if vspan.expected_state.maximum_major_faults is defined %}
    Run Keyword If   ${major} > {{ vspan.expected_state.maximum_major_faults }}   Run Keyword And Continue On Failure
    ...   Fail  "{{ vspan_name }} has ${major} major faults"
{% endif %}
{% if vspan.expected_state.maximum_minor_faults is defined %}
    Run Keyword If   ${minor} > {{ vspan.expected_state.maximum_minor_faults }}   Run Keyword And Continue On Failure
    ...   Fail  "{{ vspan_name }} has ${minor} minor faults"
{% endif %}
{% endif %}

{% if 'pre-check' in robot_include_tags | default() %}
Verify VSPAN Destination Group {{ vspan_name }} Faults Pre-Check
    [Tags]   pre-check
    ${r}=   GET On Session   apic   /api/mo/uni/infra/vdestgrp-{{ vspan_name }}/fltCnts.json
    Set Suite Variable   $r   ${r.json()}
    ${critical}=   Json Search String   ${r}   imdata[0].faultCounts.attributes.crit
    ${major}=   Json Search String   ${r}   imdata[0].faultCounts.attributes.maj
    ${minor}=   Json Search String   ${r}   imdata[0].faultCounts.attributes.minor
    &{json}=    Create Dictionary   critical=${critical}   major=${major}   minor=${minor}
    Create Directory   ${STATE_PATH}
    evaluate   json.dump($json, open('${STATE_PATH}vspan_destination_group_{{ vspan.name }}_faults.json', 'w'))   modules=json
{% endif %}

{% if 'post-check' in robot_include_tags | default() %}
Verify VSPAN Destination Group {{ vspan_name }} Faults Post-Check
    [Tags]   post-check
    ${r}=   GET On Session   apic   /api/mo/uni/infra/vdestgrp-{{ vspan_name }}/fltCnts.json
    Set Suite Variable   $r   ${r.json()}
    ${critical}=   Json Search String   ${r}   imdata[0].faultCounts.attributes.crit
    ${major}=   Json Search String   ${r}   imdata[0].faultCounts.attributes.maj
    ${minor}=   Json Search String   ${r}   imdata[0].faultCounts.attributes.minor
    &{previous}=   evaluate   json.load(open('${STATE_PATH}vspan_destination_group_{{ vspan.name }}_faults.json'))   modules=json
    Run Keyword If   ${critical} > ${previous["critical"]}   Run Keyword And Continue On Failure
    ...   Fail  "Number of critical faults increased from ${previous["critical"]} to ${critical}"
    Run Keyword If   ${major} > ${previous["major"]}   Run Keyword And Continue On Failure
    ...   Fail  "Number of major faults increased from ${previous["major"]} to ${major}"
    Run Keyword If   ${minor} > ${previous["minor"]}   Run Keyword And Continue On Failure
    ...   Fail  "Number of minor faults increased from ${previous["minor"]} to ${minor}"
{% endif %}

{% endfor %}
