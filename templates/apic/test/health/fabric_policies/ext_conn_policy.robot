*** Settings ***
Documentation   Verify External Connectivity Policy Health
Suite Setup     Login APIC
Default Tags    apic   day1   health   fabric_policies   non-critical
Resource        ../../apic_common.resource

*** Test Cases ***

{% if apic.fabric_policies.external_connectivity_policy.expected_state.maximum_critical_faults is defined or apic.fabric_policies.external_connectivity_policy.expected_state.maximum_major_faults is defined or apic.fabric_policies.external_connectivity_policy.expected_state.maximum_minor_faults is defined %}
Verify External Connectivity Policy Faults
    ${r}=   GET On Session   apic   /api/mo/uni/tn-infra/fabricExtConnP-1/fltCnts.json
    Set Suite Variable   $r   ${r.json()}
    ${critical}=   Json Search String   ${r}   imdata[0].faultCounts.attributes.crit
    ${major}=   Json Search String   ${r}   imdata[0].faultCounts.attributes.maj
    ${minor}=   Json Search String   ${r}   imdata[0].faultCounts.attributes.minor
{% if apic.fabric_policies.external_connectivity_policy.expected_state.maximum_critical_faults is defined %}
    Run Keyword If   ${critical} > {{ apic.fabric_policies.external_connectivity_policy.expected_state.maximum_critical_faults }}   Run Keyword And Continue On Failure
    ...   Fail  "External Connectivity Policy has ${critical} critical faults"
{% endif %}
{% if apic.fabric_policies.external_connectivity_policy.expected_state.maximum_major_faults is defined %}
    Run Keyword If   ${major} > {{ apic.fabric_policies.external_connectivity_policy.expected_state.maximum_major_faults }}   Run Keyword And Continue On Failure
    ...   Fail  "External Connectivity Policy has ${major} major faults"
{% endif %}
{% if apic.fabric_policies.external_connectivity_policy.expected_state.maximum_minor_faults is defined %}
    Run Keyword If   ${minor} > {{ apic.fabric_policies.external_connectivity_policy.expected_state.maximum_minor_faults }}   Run Keyword And Continue On Failure
    ...   Fail  "External Connectivity Policy has ${minor} minor faults"
{% endif %}
{% endif %}

{% if 'pre-check' in robot_include_tags | default() %}
Verify External Connectivity Policy Faults Pre-Check
    [Tags]   pre-check
    ${r}=   GET On Session   apic   /api/mo/uni/tn-infra/fabricExtConnP-1/fltCnts.json
    Set Suite Variable   $r   ${r.json()}
    ${critical}=   Json Search String   ${r}   imdata[0].faultCounts.attributes.crit
    ${major}=   Json Search String   ${r}   imdata[0].faultCounts.attributes.maj
    ${minor}=   Json Search String   ${r}   imdata[0].faultCounts.attributes.minor
    &{json}=    Create Dictionary   critical=${critical}   major=${major}   minor=${minor}
    Create Directory   ${STATE_PATH}
    evaluate   json.dump($json, open('${STATE_PATH}ext_conn_policy_faults.json', 'w'))   modules=json
{% endif %}

{% if 'post-check' in robot_include_tags | default() %}
Verify External Connectivity Policy Faults Post-Check
    [Tags]   post-check
    ${r}=   GET On Session   apic   /api/mo/uni/tn-infra/fabricExtConnP-1/fltCnts.json
    Set Suite Variable   $r   ${r.json()}
    ${critical}=   Json Search String   ${r}   imdata[0].faultCounts.attributes.crit
    ${major}=   Json Search String   ${r}   imdata[0].faultCounts.attributes.maj
    ${minor}=   Json Search String   ${r}   imdata[0].faultCounts.attributes.minor
    &{previous}=   evaluate   json.load(open('${STATE_PATH}ext_conn_policy_faults.json'))   modules=json
    Run Keyword If   ${critical} > ${previous["critical"]}   Run Keyword And Continue On Failure
    ...   Fail  "Number of critical faults increased from ${previous["critical"]} to ${critical}"
    Run Keyword If   ${major} > ${previous["major"]}   Run Keyword And Continue On Failure
    ...   Fail  "Number of major faults increased from ${previous["major"]} to ${major}"
    Run Keyword If   ${minor} > ${previous["minor"]}   Run Keyword And Continue On Failure
    ...   Fail  "Number of minor faults increased from ${previous["minor"]} to ${minor}"
{% endif %}
