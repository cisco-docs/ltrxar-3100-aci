{# iterate_list apic.tenants name item[2] #}
*** Settings ***
Documentation   Verify VXLAN Custom QoS Policy
Suite Setup     Login APIC
Default Tags    apic   day2   config   tenants
Resource        ../../../apic_common.resource

*** Test Cases ***
{% set tenant = ((apic | default()) | community.general.json_query('tenants[?name==`' ~ item[2] ~ '`]'))[0] %}
{% for qos_policy in tenant.policies.vxlan_custom_qos_policies | default([]) %}
{% set policy_name = qos_policy.name ~ defaults.apic.tenants.policies.vxlan_custom_qos_policies.name_suffix %}

Verify VXLAN Custom QoS Policy {{ policy_name }}
    ${r}=   GET On Session   apic   /api/mo/uni/tn-{{ tenant.name }}/qosvxlancustom-{{ policy_name }}.json   params=rsp-subtree=full
    Set Suite Variable   $r   ${r.json()}
    Should Be Equal JMESPath Json   ${r}   imdata[0].qosVxlanCustomPol.attributes.name   {{ policy_name }}
    Should Be Equal JMESPath Json   ${r}   imdata[0].qosVxlanCustomPol.attributes.descr   {{ qos_policy.description | default() }}

{% for ir in qos_policy.ingress_rules | default([]) %}
Verify VXLAN Custom QoS Policy {{ policy_name }} Ingress Rule {{ ir.dscp_from }}-{{ ir.dscp_to }}
    ${irule}=   Set Variable   imdata[0].qosVxlanCustomPol.children[?qosVxlanIngressRule.attributes.from=='{{ ir.dscp_from | default(defaults.apic.tenants.policies.vxlan_custom_qos_policies.ingress_rules.dscp_from) }}' && qosVxlanIngressRule.attributes.to=='{{ ir.dscp_to }}'] | [0].qosVxlanIngressRule
    Should Be Equal JMESPath Json   ${r}   ${irule}.attributes.from   {{ ir.dscp_from | default(defaults.apic.tenants.policies.vxlan_custom_qos_policies.ingress_rules.dscp_from) }}
    Should Be Equal JMESPath Json   ${r}   ${irule}.attributes.to   {{ ir.dscp_to }}
    Should Be Equal JMESPath Json   ${r}   ${irule}.attributes.prio   {{ ir.priority | default(defaults.apic.tenants.policies.vxlan_custom_qos_policies.ingress_rules.priority) }}
    Should Be Equal JMESPath Json   ${r}   ${irule}.attributes.target   {{ ir.dscp_target | default(defaults.apic.tenants.policies.vxlan_custom_qos_policies.ingress_rules.dscp_target) }}
    Should Be Equal JMESPath Json   ${r}   ${irule}.attributes.targetCos   {{ ir.cos_target | default(defaults.apic.tenants.policies.vxlan_custom_qos_policies.ingress_rules.cos_target) }}
{% endfor %}

{% for er in qos_policy.egress_rules | default([]) %}
Verify VXLAN Custom QoS Policy {{ policy_name }} Egress Rule {{ er.dscp_from }}-{{ er.dscp_to }}
    ${erule}=   Set Variable   imdata[0].qosVxlanCustomPol.children[?qosVxlanEgressRule.attributes.from=='{{ er.dscp_from }}' && qosVxlanEgressRule.attributes.to=='{{ er.dscp_to }}'] | [0].qosVxlanEgressRule
    Should Be Equal JMESPath Json   ${r}   ${erule}.attributes.from   {{ er.dscp_from }}
    Should Be Equal JMESPath Json   ${r}   ${erule}.attributes.to   {{ er.dscp_to }}
    Should Be Equal JMESPath Json   ${r}   ${erule}.attributes.target   {{ er.dscp_target | default(defaults.apic.tenants.policies.vxlan_custom_qos_policies.egress_rules.dscp_target) }}
    Should Be Equal JMESPath Json   ${r}   ${erule}.attributes.targetCos   {{ er.cos_target | default(defaults.apic.tenants.policies.vxlan_custom_qos_policies.egress_rules.cos_target) }}
{% endfor %}

{% endfor %}
