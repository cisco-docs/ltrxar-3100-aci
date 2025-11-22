*** Settings ***
Documentation   Verify VMware VMM Domain Health
Suite Setup     Login APIC
Default Tags    apic   day1   health   fabric_policies   non-critical
Resource        ../../apic_common.resource

*** Test Cases ***
{% for vmm in apic.fabric_policies.vmware_vmm_domains | default([]) %}
{% set vmm_name = vmm.name ~ defaults.apic.fabric_policies.vmware_vmm_domains.name_suffix %}

{% if vmm.expected_state.maximum_critical_faults is defined or vmm.expected_state.maximum_major_faults is defined or vmm.expected_state.maximum_minor_faults is defined %}
Verify VMware VMM Domain {{ vmm_name }} Faults
    ${r}=   GET On Session   apic   /api/mo/uni/vmmp-VMware/dom-{{ vmm_name }}/fltCnts.json
    Set Suite Variable   $r   ${r.json()}
     ${critical}=   Json Search String   ${r}   imdata[0].faultCounts.attributes.crit
    ${major}=   Json Search String   ${r}   imdata[0].faultCounts.attributes.maj
    ${minor}=   Json Search String   ${r}   imdata[0].faultCounts.attributes.minor
{% if vmm.expected_state.maximum_critical_faults is defined %}
    Run Keyword If   ${critical} > {{ vmm.expected_state.maximum_critical_faults }}   Run Keyword And Continue On Failure
    ...   Fail  "{{ vmm_name }} has ${critical} critical faults"
{% endif %}
{% if vmm.expected_state.maximum_major_faults is defined %}
    Run Keyword If   ${major} > {{ vmm.expected_state.maximum_major_faults }}   Run Keyword And Continue On Failure
    ...   Fail  "{{ vmm_name }} has ${major} major faults"
{% endif %}
{% if vmm.expected_state.maximum_minor_faults is defined %}
    Run Keyword If   ${minor} > {{ vmm.expected_state.maximum_minor_faults }}   Run Keyword And Continue On Failure
    ...   Fail  "{{ vmm_name }} has ${minor} minor faults"
{% endif %}
{% endif %}

{% if 'pre-check' in robot_include_tags | default() %}
Verify VMware VMM Domain {{ vmm_name }} Faults Pre-Check
    [Tags]   pre-check
    ${r}=   GET On Session   apic   /api/mo/uni/vmmp-VMware/dom-{{ vmm_name }}/fltCnts.json
    Set Suite Variable   $r   ${r.json()}
    ${critical}=   Json Search String   ${r}   imdata[0].faultCounts.attributes.crit
    ${major}=   Json Search String   ${r}   imdata[0].faultCounts.attributes.maj
    ${minor}=   Json Search String   ${r}   imdata[0].faultCounts.attributes.minor
    &{json}=    Create Dictionary   critical=${critical}   major=${major}   minor=${minor}
    Create Directory   ${STATE_PATH}
    evaluate   json.dump($json, open('${STATE_PATH}vmw_vmm_domain_{{ vmm_name }}_faults.json', 'w'))   modules=json
{% endif %}

{% if 'post-check' in robot_include_tags | default() %}
Verify VMware VMM Domain {{ vmm_name }} Faults Post-Check
    [Tags]   post-check
    ${r}=   GET On Session   apic   /api/mo/uni/vmmp-VMware/dom-{{ vmm_name }}/fltCnts.json
    Set Suite Variable   $r   ${r.json()}
    ${critical}=   Json Search String   ${r}   imdata[0].faultCounts.attributes.crit
    ${major}=   Json Search String   ${r}   imdata[0].faultCounts.attributes.maj
    ${minor}=   Json Search String   ${r}   imdata[0].faultCounts.attributes.minor
    &{previous}=   evaluate   json.load(open('${STATE_PATH}vmw_vmm_domain_{{ vmm_name }}_faults.json'))   modules=json
    Run Keyword If   ${critical} > ${previous["critical"]}   Run Keyword And Continue On Failure
    ...   Fail  "Number of critical faults increased from ${previous["critical"]} to ${critical}"
    Run Keyword If   ${major} > ${previous["major"]}   Run Keyword And Continue On Failure
    ...   Fail  "Number of major faults increased from ${previous["major"]} to ${major}"
    Run Keyword If   ${minor} > ${previous["minor"]}   Run Keyword And Continue On Failure
    ...   Fail  "Number of minor faults increased from ${previous["minor"]} to ${minor}"
{% endif %}

{% endfor %}
