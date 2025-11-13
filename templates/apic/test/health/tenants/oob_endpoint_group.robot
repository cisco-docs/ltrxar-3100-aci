{# iterate_list apic.tenants name item[2] #}
*** Settings ***
Documentation   Verify OOB Endpoint Group Health
Suite Setup     Login APIC
Default Tags    apic   day2   health   tenants   non-critical
Resource        ../../../apic_common.resource

*** Test Cases ***
{% set tenant = ((apic | default()) | community.general.json_query('tenants[?name==`' ~ item[2] ~ '`]'))[0] %}
{% for epg in tenant.oob_endpoint_groups | default([]) %}
{% if epg.name is not defined %}
{% set epg_name = defaults.apic.tenants.oob_endpoint_groups.name %}
{% else %}
{% set epg_name = epg.name ~ defaults.apic.tenants.oob_endpoint_groups.name_suffix %}
{% endif %}

{% if epg.expected_state.maximum_critical_faults is defined or epg.expected_state.maximum_major_faults is defined or epg.expected_state.maximum_minor_faults is defined %}
Verify OOB Endpoint Group {{ epg_name }} Faults
    ${r}=   GET On Session   apic   /api/mo/uni/tn-mgmt/mgmtp-default/oob-{{ epg_name }}/fltCnts.json
    Set Suite Variable   $r   ${r.json()}
    ${critical}=   Json Search String   ${r}   imdata[0].faultCounts.attributes.crit
    ${major}=   Json Search String   ${r}   imdata[0].faultCounts.attributes.maj
    ${minor}=   Json Search String   ${r}   imdata[0].faultCounts.attributes.minor
{% if epg.expected_state.maximum_critical_faults is defined %}
    Run Keyword If   ${critical} > {{ epg.expected_state.maximum_critical_faults }}   Run Keyword And Continue On Failure
    ...   Fail  "{{ epg_name }} has ${critical} critical faults"
{% endif %}
{% if epg.expected_state.maximum_major_faults is defined %}
    Run Keyword If   ${major} > {{ epg.expected_state.maximum_major_faults }}   Run Keyword And Continue On Failure
    ...   Fail  "{{ epg_name }} has ${major} major faults"
{% endif %}
{% if epg.expected_state.maximum_minor_faults is defined %}
    Run Keyword If   ${minor} > {{ epg.expected_state.maximum_minor_faults }}   Run Keyword And Continue On Failure
    ...   Fail  "{{ epg_name }} has ${minor} minor faults"

{% endif %}
{% endif %}

{% if 'pre-check' in robot_include_tags | default() %}
Verify OOB Endpoint Group {{ epg_name }} Faults Pre-Check
    [Tags]   pre-check
    ${r}=   GET On Session   apic   /api/mo/uni/tn-mgmt/mgmtp-default/oob-{{ epg_name }}/fltCnts.json
    Set Suite Variable   $r   ${r.json()}
    ${critical}=   Json Search String   ${r}   imdata[0].faultCounts.attributes.crit
    ${major}=   Json Search String   ${r}   imdata[0].faultCounts.attributes.maj
    ${minor}=   Json Search String   ${r}   imdata[0].faultCounts.attributes.minor
    &{json}=    Create Dictionary   critical=${critical}   major=${major}   minor=${minor}
    Create Directory   ${STATE_PATH}
    evaluate   json.dump($json, open('${STATE_PATH}tenant_{{ tenant.name }}_oob_endpoint_group_{{ epg_name }}_faults.json', 'w'))   modules=json
{% endif %}

{% if 'post-check' in robot_include_tags | default() %}
Verify OOB Endpoint Group {{ epg_name }} Faults Post-Check
    [Tags]   post-check
    ${r}=   GET On Session   apic   /api/mo/uni/tn-mgmt/mgmtp-default/oob-{{ epg_name }}/fltCnts.json
    Set Suite Variable   $r   ${r.json()}
    ${critical}=   Json Search String   ${r}   imdata[0].faultCounts.attributes.crit
    ${major}=   Json Search String   ${r}   imdata[0].faultCounts.attributes.maj
    ${minor}=   Json Search String   ${r}   imdata[0].faultCounts.attributes.minor
    &{previous}=   evaluate   json.load(open('${STATE_PATH}tenant_{{ tenant.name }}_oob_endpoint_group_{{ epg_name }}_faults.json'))   modules=json
    Run Keyword If   ${critical} > ${previous["critical"]}   Run Keyword And Continue On Failure
    ...   Fail  "Number of critical faults increased from ${previous["critical"]} to ${critical}"
    Run Keyword If   ${major} > ${previous["major"]}   Run Keyword And Continue On Failure
    ...   Fail  "Number of major faults increased from ${previous["major"]} to ${major}"
    Run Keyword If   ${minor} > ${previous["minor"]}   Run Keyword And Continue On Failure
    ...   Fail  "Number of minor faults increased from ${previous["minor"]} to ${minor}"
{% endif %}

{% endfor %}
