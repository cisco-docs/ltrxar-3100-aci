{# iterate_list apic.tenants name item[2] #}
*** Settings ***
Documentation   Verify External Management Instance
Suite Setup     Login APIC
Default Tags    apic   day2   config   tenants
Resource        ../../../apic_common.resource

*** Test Cases ***
{% set tenant = ((apic | default()) | community.general.json_query('tenants[?name==`' ~ item[2] ~ '`]'))[0] %}
{% for ext in tenant.ext_mgmt_instances | default([]) %}
{% set ext_name = ext.name ~ defaults.apic.tenants.ext_mgmt_instances.name_suffix %}

Verify External Management Instance {{ ext_name }}
    ${r}=   GET On Session   apic   /api/mo/uni/tn-mgmt/extmgmt-default/instp-{{ ext_name }}.json   params=rsp-subtree=full
    Set Suite Variable   $r   ${r.json()}
    Should Be Equal JMESPath Json   ${r}   imdata[0].mgmtInstP.attributes.name   {{ ext_name }}

{% for subnet in ext.subnets | default([]) %}

Verify External Management Instance {{ ext_name }} Subnet {{ subnet }}
    ${subnet}=   Set Variable   imdata[0].mgmtInstP.children[?mgmtSubnet.attributes.ip=='{{ subnet }}'] | [0]
    Should Be Equal JMESPath Json   ${r}   ${subnet}.mgmtSubnet.attributes.ip   {{ subnet }}

{% endfor %}

{% for contract in ext.oob_contracts.consumers | default([]) %}
{% set contract_name = contract ~ defaults.apic.tenants.oob_contracts.name_suffix %}

Verify External Management Instance {{ ext_name }} Consumed OOB Contract {{ contract_name }}
    ${con}=   Set Variable   imdata[0].mgmtInstP.children[?mgmtRsOoBCons.attributes.tnVzOOBBrCPName=='{{ contract_name }}'] | [0]
    Should Be Equal JMESPath Json   ${r}   ${con}.mgmtRsOoBCons.attributes.tnVzOOBBrCPName   {{ contract_name }}

{% endfor %}

{% endfor %}
