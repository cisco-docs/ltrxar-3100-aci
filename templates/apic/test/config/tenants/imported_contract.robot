{# iterate_list apic.tenants name item[2] #}
*** Settings ***
Documentation   Verify Imported Contract
Suite Setup     Login APIC
Default Tags    apic   day2   config   tenants
Resource        ../../../apic_common.resource

*** Test Cases ***
{% set tenant = ((apic | default()) | community.general.json_query('tenants[?name==`' ~ item[2] ~ '`]'))[0] %}
{% for con in tenant.imported_contracts | default([]) %}
{% set imported_con_name = con.name ~ defaults.apic.tenants.imported_contracts.name_suffix %}
{% set con_name = con.contract ~ defaults.apic.tenants.contracts.name_suffix %}

Verify Imported Contract {{ imported_con_name }}
    ${r}=   GET On Session   apic   /api/mo/uni/tn-{{ tenant.name }}/cif-{{ imported_con_name }}.json   params=rsp-subtree=full
    Set Suite Variable   $r   ${r.json()}
    Should Be Equal JMESPath Json   ${r}   imdata[0].vzCPIf.attributes.name   {{ imported_con_name }}
    Should Be Equal JMESPath Json   ${r}   imdata[0].vzCPIf.children[?vzRsIf] | [0].vzRsIf.attributes.tDn   uni/tn-{{ con.tenant }}/brc-{{ con_name }}

{% endfor %}
