{# iterate_list apic.tenants name item[2] #}
*** Settings ***
Documentation   Verify BGP Best Path Policy
Suite Setup     Login APIC
Default Tags    apic   day2   config   tenants
Resource        ../../../apic_common.resource

*** Test Cases ***
{% set tenant = ((apic | default()) | community.general.json_query('tenants[?name==`' ~ item[2] ~ '`]'))[0] %}
{% for bpp in tenant.policies.bgp_best_path_policies | default([]) %}
{% set bpp_name = bpp.name ~ defaults.apic.tenants.policies.bgp_best_path_policies.name_suffix %}
{% set control_type = [] %}
{% if bpp.as_path_multipath_relax | default(defaults.apic.tenants.policies.bgp_best_path_policies.as_path_multipath_relax) %}{% set control_type = control_type + [("asPathMultipathRelax")] %}{% endif %}
{% if bpp.ignore_igp_metric | default(defaults.apic.tenants.policies.bgp_best_path_policies.ignore_igp_metric) %}{% set control_type = control_type + [("ignoreIgpMetric")] %}{% endif %}

Verify BGP Best Path Policy {{ bpp_name }}
    ${r}=   GET On Session   apic   /api/mo/uni/tn-{{ tenant.name }}/bestpath-{{ bpp_name }}.json
    Set Suite Variable   $r   ${r.json()}
    Should Be Equal Value Json String   ${r}   $..bgpBestPathCtrlPol.attributes.name    {{ bpp_name }}
    Should Be Equal Value Json String   ${r}   $..bgpBestPathCtrlPol.attributes.descr    {{ bpp.description | default() }}
    Should Be Equal Value Json String   ${r}   $..bgpBestPathCtrlPol.attributes.ctrl    {{ control_type | join(',') }}
{% endfor %}
