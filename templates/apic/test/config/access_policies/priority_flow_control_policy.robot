*** Settings ***
Documentation   Verify Priority Flow Control Policy
Suite Setup     Login APIC
Default Tags    apic   day1   config   access_policies
Resource        ../../apic_common.resource

*** Test Cases ***
{% for policy in apic.access_policies.interface_policies.priority_flow_control_policies | default([]) %}
{% set priority_flow_control_policy_name = policy.name ~ defaults.apic.access_policies.interface_policies.priority_flow_control_policies.name_suffix %}
{% set auto_state = policy.auto_state | default(defaults.apic.access_policies.interface_policies.priority_flow_control_policies.auto_state) %}
{% set admin_state = policy.admin_state | default(defaults.apic.access_policies.interface_policies.priority_flow_control_policies.admin_state) %}

Verify Priority Flow Control Policy {{ priority_flow_control_policy_name }}
    ${r}=   GET On Session   apic   /api/mo/uni/infra/pfc-{{ priority_flow_control_policy_name }}.json
    Set Suite Variable   $r   ${r.json()}
    Should Be Equal JMESPath Json   ${r}    imdata[0].qosPfcIfPol.attributes.name   {{ priority_flow_control_policy_name }}
    Should Be Equal JMESPath Json   ${r}    imdata[0].qosPfcIfPol.attributes.descr   {{ policy.description | default() }}
    Should Be Equal JMESPath Json   ${r}    imdata[0].qosPfcIfPol.attributes.adminSt   {% if auto_state %}auto{% elif admin_state %}on{% else %}off{% endif %}

{% endfor %}
