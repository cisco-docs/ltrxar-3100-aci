*** Settings ***
Documentation   Verify SPAN Source Groups Profile Health
Suite Setup     Login APIC
Default Tags    apic   day2   health   tenants   non-critical
Resource        ../../apic_common.resource

*** Test Cases ***
{% for span in apic.access_policies.span.source_groups | default([]) %}
{% set span_name = span.name ~ defaults.apic.access_policies.span.source_groups.name_suffix %}

{% if span.expected_state.maximum_critical_faults is defined or span.expected_state.maximum_major_faults is defined or span.expected_state.maximum_minor_faults is defined %}
Verify SPAN Source Group {{ span_name }} Faults
    ${r}=   GET On Session   apic   /api/mo/uni/infra/srcgrp-{{ span_name }}/fltCnts.json
    Set Suite Variable   $r   ${r.json()}
    ${critical}=   Json Search String   ${r}   imdata[0].faultCounts.attributes.crit
    ${major}=   Json Search String   ${r}   imdata[0].faultCounts.attributes.maj
    ${minor}=   Json Search String   ${r}   imdata[0].faultCounts.attributes.minor
{% if span.expected_state.maximum_critical_faults is defined %}
    Run Keyword If   ${critical} > {{ span.expected_state.maximum_critical_faults }}   Run Keyword And Continue On Failure
    ...   Fail  "{{ span_name }} has ${critical} critical faults"
{% endif %}
{% if span.expected_state.maximum_major_faults is defined %}
    Run Keyword If   ${major} > {{ span.expected_state.maximum_major_faults }}   Run Keyword And Continue On Failure
    ...   Fail  "{{ span_name }} has ${major} major faults"
{% endif %}
{% if span.expected_state.maximum_minor_faults is defined %}
    Run Keyword If   ${minor} > {{ span.expected_state.maximum_minor_faults }}   Run Keyword And Continue On Failure
    ...   Fail  "{{ span_name }} has ${minor} minor faults"
{% endif %}
{% endif %}

{% if 'pre-check' in robot_include_tags | default() %}
Verify SPAN Source Group {{ span_name }} Faults Pre-Check
    [Tags]   pre-check
    ${r}=   GET On Session   apic   /api/mo/uni/infra/srcgrp-{{ span_name }}/fltCnts.json
    Set Suite Variable   $r   ${r.json()}
    ${critical}=   Json Search String   ${r}   imdata[0].faultCounts.attributes.crit
    ${major}=   Json Search String   ${r}   imdata[0].faultCounts.attributes.maj
    ${minor}=   Json Search String   ${r}   imdata[0].faultCounts.attributes.minor
    &{json}=    Create Dictionary   critical=${critical}   major=${major}   minor=${minor}
    Create Directory   ${STATE_PATH}
    evaluate   json.dump($json, open('${STATE_PATH}ap_span_source_group_{{ span_name }}_faults.json', 'w'))   modules=json
{% endif %}

{% if 'post-check' in robot_include_tags | default() %}
Verify SPAN Source Group {{ span_name }} Faults Post-Check
    [Tags]   post-check
    ${r}=   GET On Session   apic   /api/mo/uni/infra/srcgrp-{{ span_name }}/fltCnts.json
    Set Suite Variable   $r   ${r.json()}
    ${critical}=   Json Search String   ${r}   imdata[0].faultCounts.attributes.crit
    ${major}=   Json Search String   ${r}   imdata[0].faultCounts.attributes.maj
    ${minor}=   Json Search String   ${r}   imdata[0].faultCounts.attributes.minor
    &{previous}=   evaluate   json.load(open('${STATE_PATH}ap_span_source_group_{{ span_name }}_faults.json'))   modules=json
    Run Keyword If   ${critical} > ${previous["critical"]}   Run Keyword And Continue On Failure
    ...   Fail  "Number of critical faults increased from ${previous["critical"]} to ${critical}"
    Run Keyword If   ${major} > ${previous["major"]}   Run Keyword And Continue On Failure
    ...   Fail  "Number of major faults increased from ${previous["major"]} to ${major}"
    Run Keyword If   ${minor} > ${previous["minor"]}   Run Keyword And Continue On Failure
    ...   Fail  "Number of minor faults increased from ${previous["minor"]} to ${minor}"
{% endif %}

{% endfor %}
