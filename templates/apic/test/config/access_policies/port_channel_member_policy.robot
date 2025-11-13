*** Settings ***
Documentation   Verify Port Channel Member Interface Policy
Suite Setup     Login APIC
Default Tags    apic   day1   config   access_policies
Resource        ../../apic_common.resource

*** Test Cases ***
{% for policy in apic.access_policies.interface_policies.port_channel_member_policies | default([]) %}
{% set port_channel_member_policy_name = policy.name ~ defaults.apic.access_policies.interface_policies.port_channel_member_policies.name_suffix %}

Verify Port Channel Member Interface Policy {{port_channel_member_policy_name }}
    ${r}=   GET On Session   apic   /api/mo/uni/infra/lacpifp-{{port_channel_member_policy_name }}.json
    Set Suite Variable   $r   ${r.json()}
    Should Be Equal JMESPath Json   ${r}    imdata[0].lacpIfPol.attributes.name   {{ port_channel_member_policy_name }}
    Should Be Equal JMESPath Json   ${r}    imdata[0].lacpIfPol.attributes.prio   {{ policy.priority | default(defaults.apic.access_policies.interface_policies.port_channel_member_policies.priority) }}
    Should Be Equal JMESPath Json   ${r}    imdata[0].lacpIfPol.attributes.txRate   {{ policy.rate | default(defaults.apic.access_policies.interface_policies.port_channel_member_policies.rate) }}

{% endfor %}
