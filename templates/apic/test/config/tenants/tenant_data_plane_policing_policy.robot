{# iterate_list apic.tenants name item[2] #}
*** Settings ***
Documentation   Verify Tenant Data Plane Policing Policy
Suite Setup     Login APIC
Default Tags    apic   day2   config   tenants
Resource        ../../../apic_common.resource

*** Test Cases ***
{% set tenant = ((apic | default()) | community.general.json_query('tenants[?name==`' ~ item[2] ~ '`]'))[0] %}
{% for dpp in tenant.policies.data_plane_policing_policies | default([]) %}
{% set dpp_policy_name = dpp.name ~ defaults.apic.tenants.policies.data_plane_policing_policies.name_suffix %}

Verify Tenant Data Plange Policing Policy {{ dpp_policy_name }}
    ${r}=   GET On Session   apic   /api/mo/uni/tn-{{ tenant.name }}/qosdpppol-{{ dpp_policy_name }}.json
    Set Suite Variable   $r   ${r.json()}
    Should Be Equal JMESPath Json   ${r}   imdata[0].qosDppPol.attributes.name   {{ dpp_policy_name }}
    Should Be Equal JMESPath Json   ${r}   imdata[0].qosDppPol.attributes.adminSt   {{ 'enabled' if dpp.admin_state | default(defaults.apic.tenants.policies.data_plane_policing_policies.admin_state) else 'disabled' }}
    Should Be Equal JMESPath Json   ${r}   imdata[0].qosDppPol.attributes.mode   {{ dpp.mode | default(defaults.apic.tenants.policies.data_plane_policing_policies.mode) }}
    Should Be Equal JMESPath Json   ${r}   imdata[0].qosDppPol.attributes.type   {{ dpp.type | default(defaults.apic.tenants.policies.data_plane_policing_policies.type) }}
    Should Be Equal JMESPath Json   ${r}   imdata[0].qosDppPol.attributes.sharingMode   {{ dpp.sharing_mode | default(defaults.apic.tenants.policies.data_plane_policing_policies.sharing_mode) }}
    Should Be Equal JMESPath Json   ${r}   imdata[0].qosDppPol.attributes.conformAction   {{ dpp.conform_action | default(defaults.apic.tenants.policies.data_plane_policing_policies.conform_action) }}
    Should Be Equal JMESPath Json   ${r}   imdata[0].qosDppPol.attributes.conformMarkCos   {{ dpp.conform_mark_cos | default(defaults.apic.tenants.policies.data_plane_policing_policies.conform_mark_cos) }}
    Should Be Equal JMESPath Json   ${r}   imdata[0].qosDppPol.attributes.conformMarkDscp   {{ dpp.conform_mark_dscp | default(defaults.apic.tenants.policies.data_plane_policing_policies.conform_mark_dscp) }}
    Should Be Equal JMESPath Json   ${r}   imdata[0].qosDppPol.attributes.exceedAction   {{ dpp.exceed_action | default(defaults.apic.tenants.policies.data_plane_policing_policies.exceed_action) }}
    Should Be Equal JMESPath Json   ${r}   imdata[0].qosDppPol.attributes.exceedMarkCos   {{ dpp.exceed_mark_cos | default(defaults.apic.tenants.policies.data_plane_policing_policies.exceed_mark_cos) }}
    Should Be Equal JMESPath Json   ${r}   imdata[0].qosDppPol.attributes.exceedMarkDscp   {{ dpp.exceed_mark_dscp | default(defaults.apic.tenants.policies.data_plane_policing_policies.exceed_mark_dscp) }}
    Should Be Equal JMESPath Json   ${r}   imdata[0].qosDppPol.attributes.violateAction   {{ dpp.violate_action | default(defaults.apic.tenants.policies.data_plane_policing_policies.violate_action) }}
    Should Be Equal JMESPath Json   ${r}   imdata[0].qosDppPol.attributes.violateMarkCos   {{ dpp.violate_mark_cos | default(defaults.apic.tenants.policies.data_plane_policing_policies.violate_mark_cos) }}
    Should Be Equal JMESPath Json   ${r}   imdata[0].qosDppPol.attributes.violateMarkDscp   {{ dpp.violate_mark_dscp | default(defaults.apic.tenants.policies.data_plane_policing_policies.violate_mark_dscp) }}
    Should Be Equal JMESPath Json   ${r}   imdata[0].qosDppPol.attributes.rate   {{ dpp.rate | default(defaults.apic.tenants.policies.data_plane_policing_policies.rate) }}
    Should Be Equal JMESPath Json   ${r}   imdata[0].qosDppPol.attributes.rateUnit   {{ dpp.rate_unit | default(defaults.apic.tenants.policies.data_plane_policing_policies.rate_unit) }}
    Should Be Equal JMESPath Json   ${r}   imdata[0].qosDppPol.attributes.burst   {{ dpp.burst | default(defaults.apic.tenants.policies.data_plane_policing_policies.burst) }}
    Should Be Equal JMESPath Json   ${r}   imdata[0].qosDppPol.attributes.burstUnit   {{ dpp.burst_unit | default(defaults.apic.tenants.policies.data_plane_policing_policies.burst_unit) }}
    Should Be Equal JMESPath Json   ${r}   imdata[0].qosDppPol.attributes.pir   {{ dpp.peak_rate | default(defaults.apic.tenants.policies.data_plane_policing_policies.peak_rate) }}
    Should Be Equal JMESPath Json   ${r}   imdata[0].qosDppPol.attributes.pirUnit   {{ dpp.peak_rate_unit | default(defaults.apic.tenants.policies.data_plane_policing_policies.peak_rate_unit) }}
    Should Be Equal JMESPath Json   ${r}   imdata[0].qosDppPol.attributes.be   {{ dpp.burst_excessive | default(defaults.apic.tenants.policies.data_plane_policing_policies.burst_excessive) }}
    Should Be Equal JMESPath Json   ${r}   imdata[0].qosDppPol.attributes.beUnit   {{ dpp.burst_excessive_unit | default(defaults.apic.tenants.policies.data_plane_policing_policies.burst_excessive_unit) }}
{% endfor %}
