{# iterate_list apic.tenants name item[2] #}
*** Settings ***
Documentation   Verify HSRP Interface Policy
Suite Setup     Login APIC
Default Tags    apic   day2   config   tenants
Resource        ../../../apic_common.resource

*** Test Cases ***
{% set tenant = ((apic | default()) | community.general.json_query('tenants[?name==`' ~ item[2] ~ '`]'))[0] %}
{% for policy in tenant.policies.hsrp_interface_policies | default([]) %}
{% set policy_name = policy.name ~ defaults.apic.tenants.policies.hsrp_interface_policies.name_suffix %}

Verify HSRP Interface Policy {{ policy_name }}
    ${r}=   GET On Session   apic   /api/mo/uni/tn-{{ tenant.name }}/hsrpIfPol-{{ policy_name }}.json
    Set Suite Variable   ${r}   ${r.json()}
    Should Be Equal JMESPath Json   ${r}   imdata[0].hsrpIfPol.attributes.name   {{ policy_name }}
    Should Be Equal JMESPath Json   ${r}   imdata[0].hsrpIfPol.attributes.descr   {{ policy.description | default() }}
{% set expected_ctrl = [] %}
{% if policy.bfd_enable | default(defaults.apic.tenants.policies.hsrp_interface_policies.bfd_enable) %}
{%   set _ = expected_ctrl.append('bfd') %}
{% endif %}
{% if policy.use_bia | default(defaults.apic.tenants.policies.hsrp_interface_policies.use_bia) %}
{%   set _ = expected_ctrl.append('bia') %}
{% endif %}
{% if expected_ctrl | length > 0 %}
    Should Be Equal JMESPath Json   ${r}   imdata[0].hsrpIfPol.attributes.ctrl   {{ expected_ctrl | join(',') }}
{% endif %}
    Should Be Equal JMESPath Json   ${r}   imdata[0].hsrpIfPol.attributes.delay   {{ policy.delay | default(defaults.apic.tenants.policies.hsrp_interface_policies.delay) }}
    Should Be Equal JMESPath Json   ${r}   imdata[0].hsrpIfPol.attributes.reloadDelay   {{ policy.reload_delay | default(defaults.apic.tenants.policies.hsrp_interface_policies.reload_delay) }}

{% endfor %}
