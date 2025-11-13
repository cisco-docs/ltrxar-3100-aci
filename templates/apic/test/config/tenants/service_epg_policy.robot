{# iterate_list apic.tenants name item[2] #}
*** Settings ***
Documentation   Verify Service EPG Policy
Suite Setup     Login APIC
Default Tags    apic   day2   config   tenants
Resource        ../../../apic_common.resource

*** Test Cases ***
{% set tenant = ((apic | default()) | community.general.json_query('tenants[?name==`' ~ item[2] ~ '`]'))[0] %}
{% for pol in tenant.services.service_epg_policies | default([]) %}
{% set pol_name = pol.name ~ defaults.apic.tenants.services.service_epg_policies.name_suffix %}

Verify Service EPG Policy {{ pol_name }}
    ${r}=   GET On Session   apic   /api/mo/uni/tn-{{ tenant.name }}/svcCont/svcEPgPol-{{ pol_name }}.json   params=rsp-subtree=full
    Set Suite Variable   $r   ${r.json()}
    Should Be Equal JMESPath Json   ${r}   imdata[0].vnsSvcEPgPol.attributes.descr   {{ pol.description | default() }}
    Should Be Equal JMESPath Json   ${r}   imdata[0].vnsSvcEPgPol.attributes.name   {{ pol_name }}
    Should Be Equal JMESPath Json   ${r}   imdata[0].vnsSvcEPgPol.attributes.prefGrMemb   {{ 'include' if pol.preferred_group | default(defaults.apic.tenants.services.service_epg_policies.preferred_group) else 'exclude' }}

{% endfor %}
