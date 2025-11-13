*** Settings ***
Documentation   Verify RADIUS Provider Health
Suite Setup     Login APIC
Default Tags    apic   day0   health   fabric_policies   non-critical
Resource        ../../apic_common.resource

*** Test Cases ***
{% for prov in apic.fabric_policies.aaa.radius_providers | default([]) %}

{% if prov.expected_state.maximum_critical_faults is defined or prov.expected_state.maximum_major_faults is defined or prov.expected_state.maximum_minor_faults is defined %}
Verify RADIUS Provider {{ prov.hostname_ip }} Faults
    ${r}=   GET On Session   apic   /api/mo/uni/userext/radiusext/radiusprovider-{{ prov.hostname_ip }}/fltCnts.json
    Set Suite Variable   $r   ${r.json()}
    ${critical}=   Json Search String   ${r}   imdata[0].faultCounts.attributes.crit
    ${major}=   Json Search String   ${r}   imdata[0].faultCounts.attributes.maj
    ${minor}=   Json Search String   ${r}   imdata[0].faultCounts.attributes.minor
{% if prov.expected_state.maximum_critical_faults is defined %}
    Run Keyword If   ${critical} > {{ prov.expected_state.maximum_critical_faults }}   Run Keyword And Continue On Failure
    ...   Fail  "{{ prov.hostname_ip }} has ${critical} critical faults"
{% endif %}
{% if prov.expected_state.maximum_major_faults is defined %}
    Run Keyword If   ${major} > {{ prov.expected_state.maximum_major_faults }}   Run Keyword And Continue On Failure
    ...   Fail  "{{ prov.hostname_ip }} has ${major} major faults"
{% endif %}
{% if prov.expected_state.maximum_minor_faults is defined %}
    Run Keyword If   ${minor} > {{ prov.expected_state.maximum_minor_faults }}   Run Keyword And Continue On Failure
    ...   Fail  "{{ prov.hostname_ip }} has ${minor} minor faults"
{% endif %}
{% endif %}

{% if 'pre-check' in robot_include_tags | default() %}
Verify RADIUS Provider {{ prov.hostname_ip }} Faults Pre-Check
    [Tags]   pre-check
    ${r}=   GET On Session   apic   /api/mo/uni/userext/radiusext/radiusprovider-{{ prov.hostname_ip }}/fltCnts.json
    Set Suite Variable   $r   ${r.json()}
    ${critical}=   Json Search String   ${r}   imdata[0].faultCounts.attributes.crit
    ${major}=   Json Search String   ${r}   imdata[0].faultCounts.attributes.maj
    ${minor}=   Json Search String   ${r}   imdata[0].faultCounts.attributes.minor
    &{json}=    Create Dictionary   critical=${critical}   major=${major}   minor=${minor}
    Create Directory   ${STATE_PATH}
    evaluate   json.dump($json, open('${STATE_PATH}radius_{{ prov.hostname_ip }}_faults.json', 'w'))   modules=json
{% endif %}

{% if 'post-check' in robot_include_tags | default() %}
Verify RADIUS Provider {{ prov.hostname_ip }} Faults Post-Check
    [Tags]   post-check
    ${r}=   GET On Session   apic   /api/mo/uni/userext/radiusext/radiusprovider-{{ prov.hostname_ip }}/fltCnts.json
    Set Suite Variable   $r   ${r.json()}
    ${critical}=   Json Search String   ${r}   imdata[0].faultCounts.attributes.crit
    ${major}=   Json Search String   ${r}   imdata[0].faultCounts.attributes.maj
    ${minor}=   Json Search String   ${r}   imdata[0].faultCounts.attributes.minor
    &{previous}=   evaluate   json.load(open('${STATE_PATH}radius_{{ prov.hostname_ip }}_faults.json'))   modules=json
    Run Keyword If   ${critical} > ${previous["critical"]}   Run Keyword And Continue On Failure
    ...   Fail  "Number of critical faults increased from ${previous["critical"]} to ${critical}"
    Run Keyword If   ${major} > ${previous["major"]}   Run Keyword And Continue On Failure
    ...   Fail  "Number of major faults increased from ${previous["major"]} to ${major}"
    Run Keyword If   ${minor} > ${previous["minor"]}   Run Keyword And Continue On Failure
    ...   Fail  "Number of minor faults increased from ${previous["minor"]} to ${minor}"
{% endif %}

{% endfor %}
