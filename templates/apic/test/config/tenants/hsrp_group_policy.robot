{# iterate_list apic.tenants name item[2] #}
*** Settings ***
Documentation   Verify HSRP Group Policy
Suite Setup     Login APIC
Default Tags    apic   day2   config   tenants
Resource        ../../../apic_common.resource

*** Test Cases ***
{% set tenant = ((apic | default()) | community.general.json_query('tenants[?name==`' ~ item[2] ~ '`]'))[0] %}
{% for policy in tenant.policies.hsrp_group_policies | default([]) %}
{% set policy_name = policy.name ~ defaults.apic.tenants.policies.hsrp_group_policies.name_suffix %}

Verify HSRP Group Policy {{ policy_name }}
    ${r}=   GET On Session   apic   /api/mo/uni/tn-{{ tenant.name }}/hsrpGroupPol-{{ policy_name }}.json
    Set Suite Variable   ${r}   ${r.json()}
    Should Be Equal JMESPath Json   ${r}   imdata[0].hsrpGroupPol.attributes.name   {{ policy_name }}
    Should Be Equal JMESPath Json   ${r}   imdata[0].hsrpGroupPol.attributes.descr   {{ policy.description | default() }}
{% if policy.preempt | default(defaults.apic.tenants.policies.hsrp_group_policies.preempt) %}
    Should Be Equal JMESPath Json   ${r}   imdata[0].hsrpGroupPol.attributes.ctrl   preempt
{% endif %}
    Should Be Equal JMESPath Json   ${r}   imdata[0].hsrpGroupPol.attributes.helloIntvl   {{ policy.hello_interval | default(defaults.apic.tenants.policies.hsrp_group_policies.hello_interval) }}
    Should Be Equal JMESPath Json   ${r}   imdata[0].hsrpGroupPol.attributes.holdIntvl   {{ policy.hold_interval | default(defaults.apic.tenants.policies.hsrp_group_policies.hold_interval) }}
    Should Be Equal JMESPath Json   ${r}   imdata[0].hsrpGroupPol.attributes.prio   {{ policy.priority | default(defaults.apic.tenants.policies.hsrp_group_policies.priority) }}
    Should Be Equal JMESPath Json   ${r}   imdata[0].hsrpGroupPol.attributes.type   {{ policy.auth_type | default(defaults.apic.tenants.policies.hsrp_group_policies.auth_type) }}
    Should Be Equal JMESPath Json   ${r}   imdata[0].hsrpGroupPol.attributes.preemptDelayMin   {{ policy.preempt_delay_min | default(defaults.apic.tenants.policies.hsrp_group_policies.preempt_delay_min) }}
    Should Be Equal JMESPath Json   ${r}   imdata[0].hsrpGroupPol.attributes.preemptDelayReload   {{ policy.preempt_delay_reload | default(defaults.apic.tenants.policies.hsrp_group_policies.preempt_delay_reload) }}
    Should Be Equal JMESPath Json   ${r}   imdata[0].hsrpGroupPol.attributes.preemptDelaySync   {{ policy.preempt_delay_max | default(defaults.apic.tenants.policies.hsrp_group_policies.preempt_delay_max) }}
    Should Be Equal JMESPath Json   ${r}   imdata[0].hsrpGroupPol.attributes.timeout   {{ policy.timeout | default(defaults.apic.tenants.policies.hsrp_group_policies.timeout) }}

{% endfor %}
