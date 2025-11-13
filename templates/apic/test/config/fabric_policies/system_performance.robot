*** Settings ***
Documentation   Verify System Perfomance
Suite Setup     Login APIC
Default Tags    apic   day0   config   fabric_policies
Resource        ../../apic_common.resource

*** Test Cases ***
{% if apic.fabric_policies.system_performance.admin_state is defined %}
Verify System Perfomance
    ${r}=   GET On Session   apic   /api/mo/uni/fabric/comm-default/apiResp.json
    Set Suite Variable   $r   ${r.json()}
    Should Be Equal JMESPath Json   ${r}    imdata[0].commApiRespTime.attributes.enableCalculation   {{ 'enabled' if apic.fabric_policies.system_performance.admin_state | default(defaults.apic.fabric_policies.system_performance.admin_state) else 'disabled' }}
    Should Be Equal JMESPath Json   ${r}    imdata[0].commApiRespTime.attributes.respTimeThreshold   {{ apic.fabric_policies.system_performance.response_threshold | default(defaults.apic.fabric_policies.system_performance.response_threshold) }}
    Should Be Equal JMESPath Json   ${r}    imdata[0].commApiRespTime.attributes.topNRequests   {{ apic.fabric_policies.system_performance.top_slowest_requests | default(defaults.apic.fabric_policies.system_performance.top_slowest_requests) }}
    Should Be Equal JMESPath Json   ${r}    imdata[0].commApiRespTime.attributes.calcWindow   {{ apic.fabric_policies.system_performance.calculation_window | default(defaults.apic.fabric_policies.system_performance.calculation_window ) }}
{% endif %}
