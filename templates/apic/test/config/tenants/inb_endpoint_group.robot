{# iterate_list apic.tenants name item[2] #}
*** Settings ***
Documentation   Verify Inband Endpoint Group
Suite Setup     Login APIC
Default Tags    apic   day2   config   tenants
Resource        ../../../apic_common.resource

*** Test Cases ***
{% set tenant = ((apic | default()) | community.general.json_query('tenants[?name==`' ~ item[2] ~ '`]'))[0] %}
{% for epg in tenant.inb_endpoint_groups | default([]) %}
{% set epg_name = epg.name ~ defaults.apic.tenants.inb_endpoint_groups.name_suffix %}
{% set bd_name = epg.bridge_domain ~ defaults.apic.tenants.bridge_domains.name_suffix %}

Verify Inband Endpoint Group {{ epg_name }}
    ${r}=   GET On Session   apic   /api/mo/uni/tn-mgmt/mgmtp-default/inb-{{ epg_name }}.json   params=rsp-subtree=full
    Set Suite Variable   $r   ${r.json()}
    Should Be Equal JMESPath Json   ${r}   imdata[0].mgmtInB.attributes.name   {{ epg_name }}
    Should Be Equal JMESPath Json   ${r}   imdata[0].mgmtInB.attributes.encap   vlan-{{ epg.vlan }}
    Should Be Equal JMESPath Json   ${r}   imdata[0].mgmtInB.children[?mgmtRsMgmtBD] | [0].mgmtRsMgmtBD.attributes.tnFvBDName   {{ bd_name }}

{%- set comma2 = joiner(",") %}
{%- for subnet in epg.subnets | default([]) %}{{ comma2() }}
{% set scope = [] %}
{% if subnet.public | default(defaults.apic.tenants.inb_endpoint_groups.subnets.public) %}{% set scope = scope + [("public")] %}{% else %}{% set scope = scope + [("private")] %}{% endif %}
{% if subnet.shared | default(defaults.apic.tenants.inb_endpoint_groups.subnets.shared) %}{% set scope = scope + [("shared")] %}{% endif %}

Verify Endpoint Group {{ epg_name }} Subnet {{ subnet.ip }}
    ${subnet}=   Set Variable   imdata[0].mgmtInB.children[?fvSubnet.attributes.ip=='{{ subnet.ip }}'] | [0]
    Should Be Equal JMESPath Json   ${r}   ${subnet}.fvSubnet.attributes.ip   {{ subnet.ip }}
    Should Be Equal JMESPath Json   ${r}   ${subnet}.fvSubnet.attributes.scope   {{ scope | join(',') }}

{% endfor %}

{% for contract in epg.contracts.providers | default([]) %}
{% set contract_name = contract ~ defaults.apic.tenants.contracts.name_suffix %}

Verify Inband Endpoint Group {{ epg_name }} Contract Provider {{ contract_name }}
    ${con}=   Set Variable   imdata[0].mgmtInB.children[?fvRsProv.attributes.tnVzBrCPName=='{{ contract_name }}'] | [0]
    Should Be Equal JMESPath Json   ${r}   ${con}.fvRsProv.attributes.tnVzBrCPName   {{ contract_name }}

{% endfor %}

{% for contract in epg.contracts.consumers | default([]) %}
{% set contract_name = contract ~ defaults.apic.tenants.contracts.name_suffix %}

Verify Inband Endpoint Group {{ epg_name }} Contract consumers {{ contract_name }}
    ${con}=   Set Variable   imdata[0].mgmtInB.children[?fvRsCons.attributes.tnVzBrCPName=='{{ contract_name }}'] | [0]
    Should Be Equal JMESPath Json   ${r}   ${con}.fvRsCons.attributes.tnVzBrCPName   {{ contract_name }}

{% endfor %}

{% for contract in epg.contracts.imported_consumers | default([]) %}
{% set contract_name = contract ~ defaults.apic.tenants.imported_contracts.name_suffix %}

Verify Inband Endpoint Group {{ epg_name }} Imported Contract {{ contract_name }}
    ${con}=   Set Variable   imdata[0].mgmtInB.children[?fvRsConsIf.attributes.tnVzCPIfName=='{{ contract_name }}'] | [0]
    Should Be Equal JMESPath Json   ${r}   ${con}.fvRsConsIf.attributes.tnVzCPIfName   {{ contract_name }}

{% endfor %}

{% for prefix in epg.static_routes | default([]) %}
Verify Inband Endpoint Group {{ epg_name }} Static Route {{ prefix }}
    ${con}=   Set Variable   imdata[0].mgmtInB.children[?mgmtStaticRoute.attributes.prefix=='{{ prefix }}'] | [0]
    Should Be Equal JMESPath Json   ${r}   ${con}.mgmtStaticRoute.attributes.prefix   {{ prefix }}
{% endfor %}

{% endfor %}
