{# iterate_list apic.tenants name item[2] #}
*** Settings ***
Documentation   Verify VXLAN Stretch
Suite Setup     Login APIC
Default Tags    apic   day2   config   tenants
Resource        ../../../apic_common.resource

*** Test Cases ***
{% set tenant = ((apic | default()) | community.general.json_query('tenants[?name==`' ~ item[2] ~ '`]'))[0] %}
{% if tenant.name != "infra" %}
{% for vrf in tenant.vrfs | default([]) %}
{% if vrf.vxlan_stretch is defined %}
{% set vrf_name = vrf.name ~ defaults.apic.tenants.vrfs.name_suffix %}
{% set stretch_l3out_name = "vxlan_vrf_" ~ tenant.name ~ "_" ~ vrf_name %}

Verify VXLAN Stretch L3out {{ stretch_l3out_name }}
    ${r}=   GET On Session   apic   /api/mo/uni/tn-{{ tenant.name }}/out-{{ stretch_l3out_name }}.json   params=rsp-subtree=full&rsp-prop-include=config-only
    Set Suite Variable   $r   ${r.json()}
    Should Be Equal JMESPath Json   ${r}   imdata[0].l3extOut.attributes.name   {{ stretch_l3out_name }}

Verify VXLAN Stretch L3out {{ stretch_l3out_name }} VXLAN External Profile
    Should Be Equal JMESPath Json   ${r}   length(imdata[0].l3extOut.children[?vxlanExtP])   1

Verify VXLAN Stretch L3out {{ stretch_l3out_name }} VRF Relation
    Should Be Equal JMESPath Json   ${r}   imdata[0].l3extOut.children[?l3extRsEctx] | [0].l3extRsEctx.attributes.tnFvCtxName   {{ vrf_name }}

Verify VXLAN Stretch L3out {{ stretch_l3out_name }} Gateway Fabrics
    Should Be Equal JMESPath Json   ${r}   imdata[0].l3extOut.children[?l3extVxGwFabrics] | [0].l3extVxGwFabrics.attributes.remoteVni   {{ vrf.vxlan_stretch.normalized_vni }}

{% if vrf.vxlan_stretch.border_gateway_set_policy is defined %}
Verify VXLAN Stretch L3out {{ stretch_l3out_name }} Border Gateway Set
    Should Be Equal JMESPath Json   ${r}   imdata[0].l3extOut.children[?l3extVxGwFabrics] | [0].l3extVxGwFabrics.children[?l3extConsBgwSet] | [0].l3extConsBgwSet.attributes.name   {{ vrf.vxlan_stretch.border_gateway_set_policy }}
{% endif %}

{% if vrf.vxlan_stretch.export_route_map is defined %}
Verify VXLAN Stretch L3out {{ stretch_l3out_name }} Outbound Route Map
    Should Be Equal JMESPath Json   ${r}   imdata[0].l3extOut.children[?l3extVxGwFabrics] | [0].l3extVxGwFabrics.children[?l3extRsVxGwToRtProfile].l3extRsVxGwToRtProfile | [?attributes.direction=='export'] | [0].attributes.tDn   uni/tn-{{ tenant.name }}/prof-{{ vrf.vxlan_stretch.export_route_map }}
{% endif %}

{% if vrf.vxlan_stretch.import_route_map is defined %}
Verify VXLAN Stretch L3out {{ stretch_l3out_name }} Inbound Route Map
    Should Be Equal JMESPath Json   ${r}   imdata[0].l3extOut.children[?l3extVxGwFabrics] | [0].l3extVxGwFabrics.children[?l3extRsVxGwToRtProfile].l3extRsVxGwToRtProfile | [?attributes.direction=='import'] | [0].attributes.tDn   uni/tn-{{ tenant.name }}/prof-{{ vrf.vxlan_stretch.import_route_map }}

{% endif %}

{% endif %}
{% endfor %}

{% endif %}
