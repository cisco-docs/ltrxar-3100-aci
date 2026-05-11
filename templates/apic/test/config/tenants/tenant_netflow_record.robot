{# iterate_list apic.tenants name item[2] #}
*** Settings ***
Documentation   Verify Tenant Monitoring Policy
Suite Setup     Login APIC
Default Tags    apic   day2   config   tenants
Resource        ../../../apic_common.resource

*** Test Cases ***
{% set tenant = ((apic | default()) | community.general.json_query('tenants[?name==`' ~ item[2] ~ '`]'))[0] %}
{% for record in tenant.policies.netflow_records | default([]) %}
{% set record_name = record.name ~ defaults.apic.tenants.policies.netflow_records.name_suffix %}

Verify Netflow Record {{ record_name }}
    ${r}=   GET On Session   apic   /api/mo/uni/tn-{{ tenant.name }}/recordpol-{{ record_name }}.json   params=rsp-subtree=full
    Set Suite Variable   ${r}   ${r.json()}
    Should Be Equal JMESPath Json   ${r}    imdata[0].netflowRecordPol.attributes.name   {{ record_name }}
    Should Be Equal JMESPath Json   ${r}    imdata[0].netflowRecordPol.attributes.descr   {{ record.description | default() }}
    Should Be Equal JMESPath Json   ${r}    imdata[0].netflowRecordPol.attributes.match   {{ record.match_parameters | default() | sort() | join(',') }}

{% endfor %}
