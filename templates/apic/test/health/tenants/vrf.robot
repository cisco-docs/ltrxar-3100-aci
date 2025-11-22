{# iterate_list apic.tenants name item[2] #}
*** Settings ***
Documentation   Verify VRF Health
Suite Setup     Login APIC
Default Tags    apic   day2   health   tenants   non-critical
Resource        ../../../apic_common.resource

*** Test Cases ***
{% set tenant = ((apic | default()) | community.general.json_query('tenants[?name==`' ~ item[2] ~ '`]'))[0] %}
{% for vrf in tenant.vrfs | default([]) %}
{% set vrf_name = vrf.name ~ ('' if vrf.name in ('inb', 'obb', 'overlay-1') else defaults.apic.tenants.vrfs.name_suffix) %}

{% if vrf.expected_state.maximum_critical_faults is defined or vrf.expected_state.maximum_major_faults is defined or vrf.expected_state.maximum_minor_faults is defined %}
Verify VRF {{ vrf_name }} Faults
    ${r}=   GET On Session   apic   /api/mo/uni/tn-{{ tenant.name }}/ctx-{{ vrf_name }}/fltCnts.json
    Set Suite Variable   $r   ${r.json()}
    ${critical}=   Json Search String   ${r}   imdata[0].faultCounts.attributes.crit
    ${major}=   Json Search String   ${r}   imdata[0].faultCounts.attributes.maj
    ${minor}=   Json Search String   ${r}   imdata[0].faultCounts.attributes.minor
{% if vrf.expected_state.maximum_critical_faults is defined %}
    Run Keyword If   ${critical} > {{ vrf.expected_state.maximum_critical_faults }}   Run Keyword And Continue On Failure
    ...   Fail  "{{ vrf_name }} has ${critical} critical faults"
{% endif %}
{% if vrf.expected_state.maximum_major_faults is defined %}
    Run Keyword If   ${major} > {{ vrf.expected_state.maximum_major_faults }}   Run Keyword And Continue On Failure
    ...   Fail  "{{ vrf_name }} has ${major} major faults"
{% endif %}
{% if vrf.expected_state.maximum_minor_faults is defined %}
    Run Keyword If   ${minor} > {{ vrf.expected_state.maximum_minor_faults }}   Run Keyword And Continue On Failure
    ...   Fail  "{{ vrf_name }} has ${minor} minor faults"
{% endif %}
{% endif %}

{% if 'pre-check' in robot_include_tags | default() %}
Verify VRF {{ vrf_name }} Faults Pre-Check
    [Tags]   pre-check
    ${r}=   GET On Session   apic   /api/mo/uni/tn-{{ tenant.name }}/ctx-{{ vrf_name }}/fltCnts.json
    Set Suite Variable   $r   ${r.json()}
    ${critical}=   Json Search String   ${r}   imdata[0].faultCounts.attributes.crit
    ${major}=   Json Search String   ${r}   imdata[0].faultCounts.attributes.maj
    ${minor}=   Json Search String   ${r}   imdata[0].faultCounts.attributes.minor
    &{json}=    Create Dictionary   critical=${critical}   major=${major}   minor=${minor}
    Create Directory   ${STATE_PATH}
    evaluate   json.dump($json, open('${STATE_PATH}tenant_{{ tenant.name }}_vrf_{{ vrf_name }}_faults.json', 'w'))   modules=json
{% endif %}

{% if 'post-check' in robot_include_tags | default() %}
Verify VRF {{ vrf_name }} Faults Post-Check
    [Tags]   post-check
    ${r}=   GET On Session   apic   /api/mo/uni/tn-{{ tenant.name }}/ctx-{{ vrf_name }}/fltCnts.json
    Set Suite Variable   $r   ${r.json()}
    ${critical}=   Json Search String   ${r}   imdata[0].faultCounts.attributes.crit
    ${major}=   Json Search String   ${r}   imdata[0].faultCounts.attributes.maj
    ${minor}=   Json Search String   ${r}   imdata[0].faultCounts.attributes.minor
    &{previous}=   evaluate   json.load(open('${STATE_PATH}tenant_{{ tenant.name }}_vrf_{{ vrf_name }}_faults.json'))   modules=json
    Run Keyword If   ${critical} > ${previous["critical"]}   Run Keyword And Continue On Failure
    ...   Fail  "Number of critical faults increased from ${previous["critical"]} to ${critical}"
    Run Keyword If   ${major} > ${previous["major"]}   Run Keyword And Continue On Failure
    ...   Fail  "Number of major faults increased from ${previous["major"]} to ${major}"
    Run Keyword If   ${minor} > ${previous["minor"]}   Run Keyword And Continue On Failure
    ...   Fail  "Number of minor faults increased from ${previous["minor"]} to ${minor}"
{% endif %}

{% if vrf.expected_state.minimum_health is defined %}
Verify VRF {{ vrf_name }} Health
    ${r}=   GET On Session   apic   /api/mo/uni/tn-{{ tenant.name }}/ctx-{{ vrf_name }}/health.json
    Set Suite Variable   $r   ${r.json()}
    ${health}=   Json Search String   ${r}   imdata[0].healthInst.attributes.cur
    Run Keyword If   ${health} < {{ vrf.expected_state.minimum_health }}   Run Keyword And Continue On Failure
    ...   Fail  "{{ vrf_name }} health score: ${health}"
{% endif %}

{% if 'pre-check' in robot_include_tags | default() %}
Verify VRF {{ vrf_name }} Health Pre-Check
    [Tags]   pre-check
    ${r}=   GET On Session   apic   /api/mo/uni/tn-{{ tenant.name }}/ctx-{{ vrf_name }}/health.json
    Set Suite Variable   $r   ${r.json()}
    ${health}=   Json Search String   ${r}   imdata[0].healthInst.attributes.cur
    &{json}=    Create Dictionary   health=${health}
    Create Directory   ${STATE_PATH}
    evaluate   json.dump($json, open('${STATE_PATH}tenant_{{ tenant.name }}_vrf_{{ vrf_name }}_health.json', 'w'))   modules=json
{% endif %}

{% if 'post-check' in robot_include_tags | default() %}
Verify VRF {{ vrf_name }} Health Post-Check
    [Tags]   post-check
    ${r}=   GET On Session   apic   /api/mo/uni/tn-{{ tenant.name }}/ctx-{{ vrf_name }}/health.json
    Set Suite Variable   $r   ${r.json()}
    ${health}=   Json Search String   ${r}   imdata[0].healthInst.attributes.cur
    &{previous}=   evaluate   json.load(open('${STATE_PATH}tenant_{{ tenant.name }}_vrf_{{ vrf_name }}_health.json'))   modules=json
    Run Keyword If   ${health} < ${previous["health"]}   Run Keyword And Continue On Failure
    ...   Fail  "{{ ap_name }} health score degraded from ${previous["health"]} to ${health}"
{% endif %}

{% endfor %}
