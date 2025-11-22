{# iterate_list apic.tenants name item[2] #}
*** Settings ***
Documentation   Verify IP SLA Health
Suite Setup     Login APIC
Default Tags    apic   day2   health   tenants   non-critical
Resource        ../../../apic_common.resource

*** Test Cases ***
{% set tenant = ((apic | default()) | community.general.json_query('tenants[?name==`' ~ item[2] ~ '`]'))[0] %}
{% for ip_sla in tenant.policies.ip_sla_policies | default([]) %}
{% set ip_sla_name = ip_sla.name ~ defaults.apic.tenants.policies.ip_sla_policies.name_suffix %}

{% if ip_sla.expected_state.maximum_critical_faults is defined or ip_sla.expected_state.maximum_major_faults is defined or ip_sla.expected_state.maximum_minor_faults is defined %}
Verify IP SLA {{ ip_sla_name }} Faults
    ${r}=   GET On Session   apic   /api/node/mo/uni/tn-{{ tenant.name }}/ipslaMonitoringPol-{{ ip_sla_name }}/fltCnts.json
    Set Suite Variable   $r   ${r.json()}
    ${critical}=   Json Search String   ${r}   imdata[0].faultCounts.attributes.crit
    ${major}=   Json Search String   ${r}   imdata[0].faultCounts.attributes.maj
    ${minor}=   Json Search String   ${r}   imdata[0].faultCounts.attributes.minor
{% if ip_sla.expected_state.maximum_critical_faults is defined %}
    Run Keyword If   ${critical} > {{ ip_sla.expected_state.maximum_critical_faults }}   Run Keyword And Continue On Failure
    ...   Fail  "{{ ip_sla_name }} has ${critical} critical faults"
{% endif %}
{% if ip_sla.expected_state.maximum_major_faults is defined %}
    Run Keyword If   ${major} > {{ ip_sla.expected_state.maximum_major_faults }}   Run Keyword And Continue On Failure
    ...   Fail  "{{ ip_sla_name }} has ${major} major faults"
{% endif %}
{% if ip_sla.expected_state.maximum_minor_faults is defined %}
    Run Keyword If   ${minor} > {{ ip_sla.expected_state.maximum_minor_faults }}   Run Keyword And Continue On Failure
    ...   Fail  "{{ ip_sla_name }} has ${minor} minor faults"
{% endif %}
{% endif %}

{% if 'pre-check' in robot_include_tags | default() %}
Verify IP SLA {{ ip_sla_name }} Faults Pre-Check
    [Tags]   pre-check
    ${r}=   GET On Session   apic   /api/node/mo/uni/tn-{{ tenant.name }}/ipslaMonitoringPol-{{ ip_sla_name }}/fltCnts.json
    Set Suite Variable   $r   ${r.json()}
    ${critical}=   Json Search String   ${r}   imdata[0].faultCounts.attributes.crit
    ${major}=   Json Search String   ${r}   imdata[0].faultCounts.attributes.maj
    ${minor}=   Json Search String   ${r}   imdata[0].faultCounts.attributes.minor
    &{json}=    Create Dictionary   critical=${critical}   major=${major}   minor=${minor}
    Create Directory   ${STATE_PATH}
    evaluate   json.dump($json, open('${STATE_PATH}tenant_{{ tenant.name }}_ip_sla_policy_{{ ip_sla_name }}_faults.json', 'w'))   modules=json
{% endif %}

{% if 'post-check' in robot_include_tags | default() %}
Verify IP SLA {{ ip_sla_name }} Faults Post-Check
    [Tags]   post-check
    ${r}=   GET On Session   apic   /api/node/mo/uni/tn-{{ tenant.name }}/ipslaMonitoringPol-{{ ip_sla_name }}/fltCnts.json
    Set Suite Variable   $r   ${r.json()}
    ${critical}=   Json Search String   ${r}   imdata[0].faultCounts.attributes.crit
    ${major}=   Json Search String   ${r}   imdata[0].faultCounts.attributes.maj
    ${minor}=   Json Search String   ${r}   imdata[0].faultCounts.attributes.minor
    &{previous}=   evaluate   json.load(open('${STATE_PATH}tenant_{{ tenant.name }}_ip_sla_policy_{{ ip_sla_name }}_faults.json'))   modules=json
    Run Keyword If   ${critical} > ${previous["critical"]}   Run Keyword And Continue On Failure
    ...   Fail  "Number of critical faults increased from ${previous["critical"]} to ${critical}"
    Run Keyword If   ${major} > ${previous["major"]}   Run Keyword And Continue On Failure
    ...   Fail  "Number of major faults increased from ${previous["major"]} to ${major}"
    Run Keyword If   ${minor} > ${previous["minor"]}   Run Keyword And Continue On Failure
    ...   Fail  "Number of minor faults increased from ${previous["minor"]} to ${minor}"
{% endif %}

{% endfor %}
