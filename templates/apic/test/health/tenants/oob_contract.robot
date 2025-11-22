{# iterate_list apic.tenants name item[2] #}
*** Settings ***
Documentation   Verify OOB Contract Health
Suite Setup     Login APIC
Default Tags    apic   day2   health   tenants   non-critical
Resource        ../../../apic_common.resource

*** Test Cases ***
{% set tenant = ((apic | default()) | community.general.json_query('tenants[?name==`' ~ item[2] ~ '`]'))[0] %}
{% for contract in tenant.oob_contracts | default([]) %}
{% set contract_name = contract.name ~ defaults.apic.tenants.oob_contracts.name_suffix %}

{% if contract.expected_state.maximum_critical_faults is defined or contract.expected_state.maximum_major_faults is defined or contract.expected_state.maximum_minor_faults is defined %}
Verify OOB Contract {{ contract_name }} Faults
    ${r}=   GET On Session   apic   /api/mo/uni/tn-{{ tenant.name }}/oobbrc-{{ contract_name }}/fltCnts.json
    Set Suite Variable   $r   ${r.json()}
    ${critical}=   Json Search String   ${r}   imdata[0].faultCounts.attributes.crit
    ${major}=   Json Search String   ${r}   imdata[0].faultCounts.attributes.maj
    ${minor}=   Json Search String   ${r}   imdata[0].faultCounts.attributes.minor
{% if contract.expected_state.maximum_critical_faults is defined %}
    Run Keyword If   ${critical} > {{ contract.expected_state.maximum_critical_faults }}   Run Keyword And Continue On Failure
    ...   Fail  "{{ contract_name }} has ${critical} critical faults"
{% endif %}
{% if contract.expected_state.maximum_major_faults is defined %}
    Run Keyword If   ${major} > {{ contract.expected_state.maximum_major_faults }}   Run Keyword And Continue On Failure
    ...   Fail  "{{ contract_name }} has ${major} major faults"
{% endif %}
{% if contract.expected_state.maximum_minor_faults is defined %}
    Run Keyword If   ${minor} > {{ contract.expected_state.maximum_minor_faults }}   Run Keyword And Continue On Failure
    ...   Fail  "{{ contract_name }} has ${minor} minor faults"
{% endif %}
{% endif %}

{% if 'pre-check' in robot_include_tags | default() %}
Verify OOB Contract {{ contract_name }} Faults Pre-Check
    [Tags]   pre-check
    ${r}=   GET On Session   apic   /api/mo/uni/tn-{{ tenant.name }}/oobbrc-{{ contract_name }}/fltCnts.json
    Set Suite Variable   $r   ${r.json()}
    ${critical}=   Json Search String   ${r}   imdata[0].faultCounts.attributes.crit
    ${major}=   Json Search String   ${r}   imdata[0].faultCounts.attributes.maj
    ${minor}=   Json Search String   ${r}   imdata[0].faultCounts.attributes.minor
    &{json}=    Create Dictionary   critical=${critical}   major=${major}   minor=${minor}
    Create Directory   ${STATE_PATH}
    evaluate   json.dump($json, open('${STATE_PATH}tenant_{{ tenant.name }}_oob_contract_{{ contract_name }}_faults.json', 'w'))   modules=json
{% endif %}

{% if 'post-check' in robot_include_tags | default() %}
Verify OOB Contract {{ contract_name }} Faults Post-Check
    [Tags]   post-check
    ${r}=   GET On Session   apic   /api/mo/uni/tn-{{ tenant.name }}/oobbrc-{{ contract_name }}/fltCnts.json
    Set Suite Variable   $r   ${r.json()}
    ${critical}=   Json Search String   ${r}   imdata[0].faultCounts.attributes.crit
    ${major}=   Json Search String   ${r}   imdata[0].faultCounts.attributes.maj
    ${minor}=   Json Search String   ${r}   imdata[0].faultCounts.attributes.minor
    &{previous}=   evaluate   json.load(open('${STATE_PATH}tenant_{{ tenant.name }}_oob_contract_{{ contract_name }}_faults.json'))   modules=json
    Run Keyword If   ${critical} > ${previous["critical"]}   Run Keyword And Continue On Failure
    ...   Fail  "Number of critical faults increased from ${previous["critical"]} to ${critical}"
    Run Keyword If   ${major} > ${previous["major"]}   Run Keyword And Continue On Failure
    ...   Fail  "Number of major faults increased from ${previous["major"]} to ${major}"
    Run Keyword If   ${minor} > ${previous["minor"]}   Run Keyword And Continue On Failure
    ...   Fail  "Number of minor faults increased from ${previous["minor"]} to ${minor}"
{% endif %}

{% endfor %}
