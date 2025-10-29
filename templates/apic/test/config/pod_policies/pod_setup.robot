*** Settings ***
Documentation   Verify Pod Setup
Suite Setup     Login APIC
Default Tags    apic   day1   config   pod_policies
Resource        ../../apic_common.resource

*** Test Cases ***
{% for pod in apic.pod_policies.pods | default([]) %}

Verify Pod {{ pod.id }} Setup
    ${r}=   GET On Session   apic   /api/mo/uni/controller/setuppol/setupp-{{ pod.id }}.json   params=rsp-subtree=full
    Set Suite Variable   $r   ${r.json()}
    Should Be Equal Value Json String   ${r}    $..fabricSetupP.attributes.podId   {{ pod.id }}
{% if pod.id != 1 %}
    Should Be Equal Value Json String   ${r}    $..fabricSetupP.attributes.tepPool   {{ pod.tep_pool }}
{% endif %}
{% for rlpool in pod.remote_pools | default([]) %}
    ${rl}=    Set Variable    $..fabricSetupP.children[?(@.fabricExtSetupP.attributes.extPoolId=={{ rlpool.id }})]
    Should Be Equal Value Json String   ${r}    ${rl}..fabricExtSetupP.attributes.extPoolId   {{ rlpool.id }}
    Should Be Equal Value Json String   ${r}    ${rl}..fabricExtSetupP.attributes.tepPool   {{ rlpool.remote_pool }}
{% endfor %}
{% for extpool in pod.external_tep_pools | default([]) %}
    ${el}=    Set Variable    $..fabricSetupP.children[?(@.fabricExtRoutablePodSubnet.attributes.pool=="{{ extpool.prefix }}")]
    Should Be Equal Value Json String   ${r}    ${el}..fabricExtRoutablePodSubnet.attributes.pool   {{ extpool.prefix }}
    Should Be Equal Value Json String   ${r}    ${el}..fabricExtRoutablePodSubnet.attributes.reserveAddressCount   {{ extpool.reserved_address_count }}
{% endfor %}

{% endfor %}
