*** Settings ***
Documentation   Verify Date Time Policy Health
Suite Setup     Login APIC
Default Tags    apic   day1   health   fabric_policies   non-critical
Resource        ../../apic_common.resource

*** Test Cases ***
{% for policy in apic.fabric_policies.pod_policies.date_time_policies | default([]) %}
{% set date_time_policy_name = policy.name ~ defaults.apic.fabric_policies.pod_policies.date_time_policies.name_suffix %}

{% if policy.expected_state.maximum_critical_faults is defined or policy.expected_state.maximum_major_faults is defined or policy.expected_state.maximum_minor_faults is defined %}
Verify Date Time Policy {{ date_time_policy_name }} Faults
    ${r}=   GET On Session   apic   /api/mo/uni/fabric/time-{{ date_time_policy_name }}/fltCnts.json
    Set Suite Variable   $r   ${r.json()}
    ${critical}=   Json Search String   ${r}   imdata[0].faultCounts.attributes.crit
    ${major}=   Json Search String   ${r}   imdata[0].faultCounts.attributes.maj
    ${minor}=   Json Search String   ${r}   imdata[0].faultCounts.attributes.minor
{% if policy.expected_state.maximum_critical_faults is defined %}
    Run Keyword If   ${critical} > {{ policy.expected_state.maximum_critical_faults }}   Run Keyword And Continue On Failure
    ...   Fail  "{{ date_time_policy_name }} has ${critical} critical faults"
{% endif %}
{% if policy.expected_state.maximum_major_faults is defined %}
    Run Keyword If   ${major} > {{ policy.expected_state.maximum_major_faults }}   Run Keyword And Continue On Failure
    ...   Fail  "{{ date_time_policy_name }} has ${major} major faults"
{% endif %}
{% if policy.expected_state.maximum_minor_faults is defined %}
    Run Keyword If   ${minor} > {{ policy.expected_state.maximum_minor_faults }}   Run Keyword And Continue On Failure
    ...   Fail  "{{ date_time_policy_name }} has ${minor} minor faults"
{% endif %}
{% endif %}


{% if 'pre-check' in robot_include_tags | default() %}
Verify Date Time Policy {{ date_time_policy_name }} Faults Pre-Check
    [Tags]   pre-check
    ${r}=   GET On Session   apic  /api/mo/uni/fabric/time-{{ date_time_policy_name }}/fltCnts.json
    Set Suite Variable   $r   ${r.json()}
    ${critical}=   Json Search String   ${r}   imdata[0].faultCounts.attributes.crit
    ${major}=   Json Search String   ${r}   imdata[0].faultCounts.attributes.maj
    ${minor}=   Json Search String   ${r}   imdata[0].faultCounts.attributes.minor
    &{json}=    Create Dictionary   critical=${critical}   major=${major}   minor=${minor}
    Create Directory   ${STATE_PATH}
    evaluate   json.dump($json, open('${STATE_PATH}date_time_policy_{{ date_time_policy_name }}_faults.json', 'w'))   modules=json
{% endif %}

{% if 'post-check' in robot_include_tags | default() %}
Verify Date Time Policy {{ date_time_policy_name }} Faults Post-Check
    [Tags]   post-check
    ${r}=   GET On Session   apic   /api/mo/uni/fabric/time-{{ date_time_policy_name }}/fltCnts.json
    Set Suite Variable   $r   ${r.json()}
    ${critical}=   Json Search String   ${r}   imdata[0].faultCounts.attributes.crit
    ${major}=   Json Search String   ${r}   imdata[0].faultCounts.attributes.maj
    ${minor}=   Json Search String   ${r}   imdata[0].faultCounts.attributes.minor
    &{previous}=   evaluate   json.load(open('${STATE_PATH}date_time_policy_{{ date_time_policy_name }}_faults.json'))   modules=json
    Run Keyword If   ${critical} > ${previous["critical"]}   Run Keyword And Continue On Failure
    ...   Fail  "Number of critical faults increased from ${previous["critical"]} to ${critical}"
    Run Keyword If   ${major} > ${previous["major"]}   Run Keyword And Continue On Failure
    ...   Fail  "Number of major faults increased from ${previous["major"]} to ${major}"
    Run Keyword If   ${minor} > ${previous["minor"]}   Run Keyword And Continue On Failure
    ...   Fail  "Number of minor faults increased from ${previous["minor"]} to ${minor}"
{% endif %}

{% endfor %}
