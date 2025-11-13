{# iterate_list apic.tenants name item[2] #}
*** Settings ***
Documentation   Verify Redirect Backup Policy
Suite Setup     Login APIC
Default Tags    apic   day2   config   tenants
Resource        ../../../apic_common.resource

*** Test Cases ***
{% set tenant = ((apic | default()) | community.general.json_query('tenants[?name==`' ~ item[2] ~ '`]'))[0] %}
{% for pol in tenant.services.redirect_backup_policies | default([]) %}
{% set pol_name = pol.name ~ defaults.apic.tenants.services.redirect_backup_policies.name_suffix %}

Verify Redirect Backup Policy {{ pol_name }}
    ${r}=   GET On Session   apic   /api/mo/uni/tn-{{ tenant.name }}/svcCont/backupPol-{{ pol_name }}.json   params=rsp-subtree=full
    Set Suite Variable   $r   ${r.json()}
    Should Be Equal JMESPath Json   ${r}   imdata[0].vnsBackupPol.attributes.descr   {{ pol.description | default() }}
    Should Be Equal JMESPath Json   ${r}   imdata[0].vnsBackupPol.attributes.name   {{ pol_name }}

{% for des in pol.l3_destinations | default([]) %}
Verify Redirect Back Policy {{ pol_name }} Destination {{ des.ip }}
    ${dest}=   Set Variable   imdata[0].vnsBackupPol.children[?vnsRedirectDest.attributes.ip=='{{ des.ip }}'] | [0].vnsRedirectDest
    Should Be Equal JMESPath Json   ${r}   ${dest}.attributes.ip   {{ des.ip }}
    Should Be Equal JMESPath Json   ${r}   ${dest}.attributes.ip2   {{ des.ip_2 | default(defaults.apic.tenants.services.redirect_backup_policies.l3_destinations.ip_2) }}
    Should Be Equal JMESPath Json   ${r}   ${dest}.attributes.mac   {{ des.mac | default("00:00:00:00:00:00") }}
    Should Be Equal JMESPath Json   ${r}   ${dest}.attributes.destName   {{ des.destination_name | default() }}

{% if des.redirect_health_group is defined %}
{% set redirect_health_group_name = des.redirect_health_group ~ defaults.apic.tenants.services.redirect_health_groups.name_suffix %}
    Should Be Equal JMESPath Json   ${r}   ${dest}.children[?vnsRsRedirectHealthGroup] | [0].vnsRsRedirectHealthGroup.attributes.tDn   uni/tn-{{ tenant.name }}/svcCont/redirectHealthGroup-{{ redirect_health_group_name }}
{% endif %}
{% endfor %}
{% endfor %}
