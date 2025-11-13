{# iterate_list apic.tenants name item[2] #}
*** Settings ***
Documentation   Verify L3out Health
Suite Setup     Login APIC
Default Tags    apic   day2   health   tenants   non-critical
Resource        ../../../apic_common.resource

*** Test Cases ***
{% set tenant = ((apic | default()) | community.general.json_query('tenants[?name==`' ~ item[2] ~ '`]'))[0] %}
{% for l3out in tenant.l3outs | default([]) %}
{% set l3out_name = l3out.name ~ defaults.apic.tenants.l3outs.name_suffix %}

{% if l3out.expected_state.maximum_critical_faults is defined or l3out.expected_state.maximum_major_faults is defined or l3out.expected_state.maximum_minor_faults is defined %}
Verify L3out {{ l3out_name }} Faults
    ${r}=   GET On Session   apic   /api/mo/uni/tn-{{ tenant.name }}/out-{{ l3out_name }}/fltCnts.json
    Set Suite Variable   $r   ${r.json()}
    ${critical}=   Json Search String   ${r}   imdata[0].faultCounts.attributes.crit
    ${major}=   Json Search String   ${r}   imdata[0].faultCounts.attributes.maj
    ${minor}=   Json Search String   ${r}   imdata[0].faultCounts.attributes.minor
{% if l3out.expected_state.maximum_critical_faults is defined %}
    Run Keyword If   ${critical} > {{ l3out.expected_state.maximum_critical_faults }}   Run Keyword And Continue On Failure
    ...   Fail  "{{ l3out_name }} has ${critical} critical faults"
{% endif %}
{% if l3out.expected_state.maximum_major_faults is defined %}
    Run Keyword If   ${major} > {{ l3out.expected_state.maximum_major_faults }}   Run Keyword And Continue On Failure
    ...   Fail  "{{ l3out_name }} has ${major} major faults"
{% endif %}
{% if l3out.expected_state.maximum_minor_faults is defined %}
    Run Keyword If   ${minor} > {{ l3out.expected_state.maximum_minor_faults }}   Run Keyword And Continue On Failure
    ...   Fail  "{{ l3out_name }} has ${minor} minor faults"
{% endif %}
{% endif %}

{% if 'pre-check' in robot_include_tags | default() %}
Verify L3out {{ l3out_name }} Faults Pre-Check
    [Tags]   pre-check
    ${r}=   GET On Session   apic   /api/mo/uni/tn-{{ tenant.name }}/out-{{ l3out_name }}/fltCnts.json
    Set Suite Variable   $r   ${r.json()}
    ${critical}=   Json Search String   ${r}   imdata[0].faultCounts.attributes.crit
    ${major}=   Json Search String   ${r}   imdata[0].faultCounts.attributes.maj
    ${minor}=   Json Search String   ${r}   imdata[0].faultCounts.attributes.minor
    &{json}=    Create Dictionary   critical=${critical}   major=${major}   minor=${minor}
    Create Directory   ${STATE_PATH}
    evaluate   json.dump($json, open('${STATE_PATH}tenant_{{ tenant.name }}_l3out_{{ l3out_name }}_faults.json', 'w'))   modules=json
{% endif %}

{% if 'post-check' in robot_include_tags | default() %}
Verify L3out {{ l3out_name }} Faults Post-Check
    [Tags]   post-check
    ${r}=   GET On Session   apic   /api/mo/uni/tn-{{ tenant.name }}/out-{{ l3out_name }}/fltCnts.json
    Set Suite Variable   $r   ${r.json()}
    ${critical}=   Json Search String   ${r}   imdata[0].faultCounts.attributes.crit
    ${major}=   Json Search String   ${r}   imdata[0].faultCounts.attributes.maj
    ${minor}=   Json Search String   ${r}   imdata[0].faultCounts.attributes.minor
    &{previous}=   evaluate   json.load(open('${STATE_PATH}tenant_{{ tenant.name }}_l3out_{{ l3out_name }}_faults.json'))   modules=json
    Run Keyword If   ${critical} > ${previous["critical"]}   Run Keyword And Continue On Failure
    ...   Fail  "Number of critical faults increased from ${previous["critical"]} to ${critical}"
    Run Keyword If   ${major} > ${previous["major"]}   Run Keyword And Continue On Failure
    ...   Fail  "Number of major faults increased from ${previous["major"]} to ${major}"
    Run Keyword If   ${minor} > ${previous["minor"]}   Run Keyword And Continue On Failure
    ...   Fail  "Number of minor faults increased from ${previous["minor"]} to ${minor}"
{% endif %}

{% for epg in l3out.external_endpoint_groups | default([]) %}
{% set eepg_name = epg.name ~ defaults.apic.tenants.l3outs.external_endpoint_groups.name_suffix %}

{% if epg.expected_state.maximum_critical_faults is defined or epg.expected_state.maximum_major_faults is defined or epg.expected_state.maximum_minor_faults is defined %}
Verify L3out {{ l3out_name }} External Endpoint Group {{ eepg_name }} Faults
    ${r}=   GET On Session   apic   /api/mo/uni/tn-{{ tenant.name }}/out-{{ l3out_name }}/instP-{{ eepg_name }}/fltCnts.json
    Set Suite Variable   $r   ${r.json()}
    ${critical}=   Json Search String   ${r}   imdata[0].faultCounts.attributes.crit
    ${major}=   Json Search String   ${r}   imdata[0].faultCounts.attributes.maj
    ${minor}=   Json Search String   ${r}   imdata[0].faultCounts.attributes.minor
{% if epg.expected_state.maximum_critical_faults is defined %}
    Run Keyword If   ${critical} > {{ epg.expected_state.maximum_critical_faults }}   Run Keyword And Continue On Failure
    ...   Fail  "{{ eepg_name }} has ${critical} critical faults"
{% endif %}
{% if epg.expected_state.maximum_major_faults is defined %}
    Run Keyword If   ${major} > {{ epg.expected_state.maximum_major_faults }}   Run Keyword And Continue On Failure
    ...   Fail  "{{ eepg_name }} has ${major} major faults"
{% endif %}
{% if epg.expected_state.maximum_minor_faults is defined %}
    Run Keyword If   ${minor} > {{ epg.expected_state.maximum_minor_faults }}   Run Keyword And Continue On Failure
    ...   Fail  "{{ eepg_name }} has ${minor} minor faults"
{% endif %}
{% endif %}

{% if 'pre-check' in robot_include_tags | default() %}
Verify L3out {{ l3out_name }} External Endpoint Group {{ eepg_name }} Faults Pre-Check
    [Tags]   pre-check
    ${r}=   GET On Session   apic   /api/mo/uni/tn-{{ tenant.name }}/out-{{ l3out_name }}/instP-{{ eepg_name }}/fltCnts.json
    Set Suite Variable   $r   ${r.json()}
    ${critical}=   Json Search String   ${r}   imdata[0].faultCounts.attributes.crit
    ${major}=   Json Search String   ${r}   imdata[0].faultCounts.attributes.maj
    ${minor}=   Json Search String   ${r}   imdata[0].faultCounts.attributes.minor
    &{json}=    Create Dictionary   critical=${critical}   major=${major}   minor=${minor}
    Create Directory   ${STATE_PATH}
    evaluate   json.dump($json, open('${STATE_PATH}tenant_{{ tenant.name }}_epg_{{ eepg_name }}_faults.json', 'w'))   modules=json
{% endif %}

{% if 'post-check' in robot_include_tags | default() %}
Verify L3out {{ l3out_name }} External Endpoint Group {{ eepg_name }} Faults Post-Check
    [Tags]   post-check
    ${r}=   GET On Session   apic   /api/mo/uni/tn-{{ tenant.name }}/out-{{ l3out_name }}/instP-{{ eepg_name }}/fltCnts.json
    Set Suite Variable   $r   ${r.json()}
    ${critical}=   Json Search String   ${r}   imdata[0].faultCounts.attributes.crit
    ${major}=   Json Search String   ${r}   imdata[0].faultCounts.attributes.maj
    ${minor}=   Json Search String   ${r}   imdata[0].faultCounts.attributes.minor
    &{previous}=   evaluate   json.load(open('${STATE_PATH}tenant_{{ tenant.name }}_epg_{{ eepg_name }}_faults.json'))   modules=json
    Run Keyword If   ${critical} > ${previous["critical"]}   Run Keyword And Continue On Failure
    ...   Fail  "Number of critical faults increased from ${previous["critical"]} to ${critical}"
    Run Keyword If   ${major} > ${previous["major"]}   Run Keyword And Continue On Failure
    ...   Fail  "Number of major faults increased from ${previous["major"]} to ${major}"
    Run Keyword If   ${minor} > ${previous["minor"]}   Run Keyword And Continue On Failure
    ...   Fail  "Number of minor faults increased from ${previous["minor"]} to ${minor}"
{% endif %}

{% if epg.expected_state.minimum_health is defined %}
Verify L3out {{ l3out_name }} External Endpoint Group {{ eepg_name }} Health
    ${r}=   GET On Session   apic   /api/mo/uni/tn-{{ tenant.name }}/out-{{ l3out_name }}/instP-{{ eepg_name }}/health.json
    Set Suite Variable   $r   ${r.json()}
    ${health}=   Json Search String   ${r}   imdata[0].healthInst.attributes.cur
    Run Keyword If   ${health} < {{ epg.expected_state.minimum_health }}   Run Keyword And Continue On Failure
    ...   Fail  "{{ eepg_name }} health score: ${health}"
{% endif %}

{% if 'pre-check' in robot_include_tags | default() %}
Verify L3out {{ l3out_name }} External Endpoint Group {{ eepg_name }} Health Pre-Check
    [Tags]   pre-check
    ${r}=   GET On Session   apic   /api/mo/uni/tn-{{ tenant.name }}/out-{{ l3out_name }}/instP-{{ eepg_name }}/health.json
    Set Suite Variable   $r   ${r.json()}
    ${health}=   Json Search String   ${r}   imdata[0].healthInst.attributes.cur
    &{json}=    Create Dictionary   health=${health}
    Create Directory   ${STATE_PATH}
    evaluate   json.dump($json, open('${STATE_PATH}tenant_{{ tenant.name }}_epg_{{ eepg_name }}_health.json', 'w'))   modules=json
{% endif %}

{% if 'post-check' in robot_include_tags | default() %}
Verify L3out {{ l3out_name }} External Endpoint Group {{ eepg_name }} Health Post-Check
    [Tags]   post-check
    ${r}=   GET On Session   apic   /api/mo/uni/tn-{{ tenant.name }}/out-{{ l3out_name }}/instP-{{ eepg_name }}/health.json
    Set Suite Variable   $r   ${r.json()}
    ${health}=   Json Search String   ${r}   imdata[0].healthInst.attributes.cur
    &{previous}=   evaluate   json.load(open('${STATE_PATH}tenant_{{ tenant.name }}_epg_{{ eepg_name }}_health.json'))   modules=json
    Run Keyword If   ${health} < ${previous["health"]}   Run Keyword And Continue On Failure
    ...   Fail  "{{ eepg_name }} health score degraded from ${previous["health"]} to ${health}"
{% endif %}
{% endfor %}

{% endfor %}
