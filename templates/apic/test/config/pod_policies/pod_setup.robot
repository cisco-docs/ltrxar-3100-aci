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
    Should Be Equal JMESPath Json   ${r}    imdata[0].fabricSetupP.attributes.podId   {{ pod.id }}
{% if pod.id != 1 %}
    Should Be Equal JMESPath Json   ${r}    imdata[0].fabricSetupP.attributes.tepPool   {{ pod.tep_pool }}
{% endif %}
{% for rlpool in pod.remote_pools | default([]) %}
    ${rl}=    Set Variable    imdata[0].fabricSetupP.children[?fabricExtSetupP.attributes.extPoolId=={{ rlpool.id }}] | [0]
    Should Be Equal JMESPath Json   ${r}    ${rl}.fabricExtSetupP.attributes.extPoolId   {{ rlpool.id }}
    Should Be Equal JMESPath Json   ${r}    ${rl}.fabricExtSetupP.attributes.tepPool   {{ rlpool.remote_pool }}
{% endfor %}
{% for extpool in pod.external_tep_pools | default([]) %}
    ${el}=    Set Variable    imdata[0].fabricSetupP.children[?fabricExtRoutablePodSubnet.attributes.pool=="{{ extpool.prefix }}"] | [0]
    Should Be Equal JMESPath Json   ${r}    ${el}.fabricExtRoutablePodSubnet.attributes.pool   {{ extpool.prefix }}
    Should Be Equal JMESPath Json   ${r}    ${el}.fabricExtRoutablePodSubnet.attributes.reserveAddressCount   {{ extpool.reserved_address_count }}
{% endfor %}

{% endfor %}
