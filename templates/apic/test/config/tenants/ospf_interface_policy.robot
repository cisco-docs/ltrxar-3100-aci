{# iterate_list apic.tenants name item[2] #}
*** Settings ***
Documentation   Verify OSPF Interface Policy
Suite Setup     Login APIC
Default Tags    apic   day2   config   tenants
Resource        ../../../apic_common.resource

*** Test Cases ***
{% set tenant = ((apic | default()) | community.general.json_query('tenants[?name==`' ~ item[2] ~ '`]'))[0] %}
{% for oip in tenant.policies.ospf_interface_policies | default([]) %}
{% set policy_name = oip.name ~ defaults.apic.tenants.policies.ospf_interface_policies.name_suffix %}
{% set ctrl = [] %}
{% if oip.advertise_subnet | default(defaults.apic.tenants.policies.ospf_interface_policies.advertise_subnet) %}{% set ctrl = ctrl + [("advert-subnet")] %}{% endif %}
{% if oip.bfd | default(defaults.apic.tenants.policies.ospf_interface_policies.bfd) %}{% set ctrl = ctrl + [("bfd")] %}{% endif %}
{% if oip.mtu_ignore | default(defaults.apic.tenants.policies.ospf_interface_policies.mtu_ignore) %}{% set ctrl = ctrl + [("mtu-ignore")] %}{% endif %}
{% if oip.passive_interface | default(defaults.apic.tenants.policies.ospf_interface_policies.passive_interface) %}{% set ctrl = ctrl + [("passive")] %}{% endif %}

Verify OSPF Interface Policy {{ policy_name }}
    ${r}=   GET On Session   apic   /api/mo/uni/tn-{{ tenant.name }}/ospfIfPol-{{ policy_name }}.json
    Set Suite Variable   $r   ${r.json()}
    Should Be Equal JMESPath Json   ${r}   imdata[0].ospfIfPol.attributes.name   {{ policy_name }}
    Should Be Equal JMESPath Json   ${r}   imdata[0].ospfIfPol.attributes.descr   {{ oip.description | default() }}
    Should Be Equal JMESPath Json   ${r}   imdata[0].ospfIfPol.attributes.cost   {{ oip.cost | default(defaults.apic.tenants.policies.ospf_interface_policies.cost) }}
    Should Be Equal JMESPath Json   ${r}   imdata[0].ospfIfPol.attributes.ctrl   {{ ctrl | join(',') }}
    Should Be Equal JMESPath Json   ${r}   imdata[0].ospfIfPol.attributes.deadIntvl   {{ oip.dead_interval | default(defaults.apic.tenants.policies.ospf_interface_policies.dead_interval) }}
    Should Be Equal JMESPath Json   ${r}   imdata[0].ospfIfPol.attributes.helloIntvl   {{ oip.hello_interval | default(defaults.apic.tenants.policies.ospf_interface_policies.hello_interval) }}
    Should Be Equal JMESPath Json   ${r}   imdata[0].ospfIfPol.attributes.nwT   {{ oip.network_type | default(defaults.apic.tenants.policies.ospf_interface_policies.network_type) }}
    Should Be Equal JMESPath Json   ${r}   imdata[0].ospfIfPol.attributes.prio   {{ oip.priority | default(defaults.apic.tenants.policies.ospf_interface_policies.priority) }}
    Should Be Equal JMESPath Json   ${r}   imdata[0].ospfIfPol.attributes.rexmitIntvl   {{ oip.lsa_retransmit_interval | default(defaults.apic.tenants.policies.ospf_interface_policies.lsa_retransmit_interval) }}
    Should Be Equal JMESPath Json   ${r}   imdata[0].ospfIfPol.attributes.xmitDelay   {{ oip.lsa_transmit_delay | default(defaults.apic.tenants.policies.ospf_interface_policies.lsa_transmit_delay) }}

{% endfor %}