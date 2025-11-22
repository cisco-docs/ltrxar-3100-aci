*** Settings ***
Documentation   Verify Fabric Leaf Switch Profile Health
Suite Setup     Login APIC
Default Tags    apic   day1   health   fabric_policies   non-critical
Resource        ../../apic_common.resource

*** Test Cases ***
{% for pod in apic.pod_policies.pods | default([]) %}
{% set pod_profile_name = (pod.id) | regex_replace("^(?P<id>.+)$", (apic.fabric_policies.pod_profile_name | default(defaults.apic.fabric_policies.pod_profile_name))) %}


{% if pod.expected_state.maximum_critical_faults is defined or pod.expected_state.maximum_major_faults is defined or pod.expected_state.maximum_minor_faults is defined %}
Verify Pod Profile {{ pod_profile_name }} Faults
    ${r}=   GET On Session   apic   /api/mo/uni/fabric/podprof-{{ pod_profile_name }}/fltCnts.json
    Set Suite Variable   $r   ${r.json()}
    ${critical}=   Json Search String   ${r}   imdata[0].faultCounts.attributes.crit
    ${major}=   Json Search String   ${r}   imdata[0].faultCounts.attributes.maj
    ${minor}=   Json Search String   ${r}   imdata[0].faultCounts.attributes.minor
{% if pod.expected_state.maximum_critical_faults is defined %}
    Run Keyword If   ${critical} > {{ pod.expected_state.maximum_critical_faults }}   Run Keyword And Continue On Failure
    ...   Fail  "{{ pod_profile_name }} has ${critical} critical faults"
{% endif %}
{% if pod.expected_state.maximum_major_faults is defined %}
    Run Keyword If   ${major} > {{ pod.expected_state.maximum_major_faults }}   Run Keyword And Continue On Failure
    ...   Fail  "{{ pod_profile_name }} has ${major} major faults"
{% endif %}
{% if pod.expected_state.maximum_minor_faults is defined %}
    Run Keyword If   ${minor} > {{ pod.expected_state.maximum_minor_faults }}   Run Keyword And Continue On Failure
    ...   Fail  "{{ pod_profile_name }} has ${minor} minor faults"
{% endif %}
{% endif %}

{% if 'pre-check' in robot_include_tags | default() %}
Verify Pod Profile {{ pod_profile_name }} Faults Pre-Check
    [Tags]   pre-check
    ${r}=   GET On Session   apic   /api/mo/uni/fabric/podprof-{{ pod_profile_name }}/fltCnts.json
    Set Suite Variable   $r   ${r.json()}
    ${critical}=   Json Search String   ${r}   imdata[0].faultCounts.attributes.crit
    ${major}=   Json Search String   ${r}   imdata[0].faultCounts.attributes.maj
    ${minor}=   Json Search String   ${r}   imdata[0].faultCounts.attributes.minor
    &{json}=    Create Dictionary   critical=${critical}   major=${major}   minor=${minor}
    Create Directory   ${STATE_PATH}
    evaluate   json.dump($json, open('${STATE_PATH}pod_profile_{{ pod_profile_name }}_faults.json', 'w'))   modules=json
{% endif %}

{% if 'post-check' in robot_include_tags | default() %}
Verify Pod Profile {{ pod_profile_name }} Faults Post-Check
    [Tags]   post-check
    ${r}=   GET On Session   apic   /api/mo/uni/fabric/podprof-{{ pod_profile_name }}/fltCnts.json
    Set Suite Variable   $r   ${r.json()}
    ${critical}=   Json Search String   ${r}   imdata[0].faultCounts.attributes.crit
    ${major}=   Json Search String   ${r}   imdata[0].faultCounts.attributes.maj
    ${minor}=   Json Search String   ${r}   imdata[0].faultCounts.attributes.minor
    &{previous}=   evaluate   json.load(open('${STATE_PATH}pod_profile_{{ pod_profile_name }}_faults.json'))   modules=json
    Run Keyword If   ${critical} > ${previous["critical"]}   Run Keyword And Continue On Failure
    ...   Fail  "Number of critical faults increased from ${previous["critical"]} to ${critical}"
    Run Keyword If   ${major} > ${previous["major"]}   Run Keyword And Continue On Failure
    ...   Fail  "Number of major faults increased from ${previous["major"]} to ${major}"
    Run Keyword If   ${minor} > ${previous["minor"]}   Run Keyword And Continue On Failure
    ...   Fail  "Number of minor faults increased from ${previous["minor"]} to ${minor}"
{% endif %}

{% endfor %}
