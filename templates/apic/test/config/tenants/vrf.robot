{# iterate_list apic.tenants name item[2] #}
*** Settings ***
Documentation   Verify VRF
Suite Setup     Login APIC
Default Tags    apic   day2   config   tenants
Resource        ../../../apic_common.resource

*** Test Cases ***
{% macro reserved_entry(value) %}
    {% set reserved_map = {0: "undefined"} %}
    {{ reserved_map[value] | default(value) }}
{% endmacro %}
{% macro max_entry(value) %}
    {% set max_map = {4294967295: "unlimited"} %}
    {{ max_map[value] | default(value) }}
{% endmacro %}
{% macro expiry_entry(value) %}
    {% set expiry_map = {180: "default-timeout"} %}
    {{ expiry_map[value] | default(value) }}
{% endmacro %}

{% set tenant = ((apic | default()) | community.general.json_query('tenants[?name==`' ~ item[2] ~ '`]'))[0] %}
{% for vrf in tenant.vrfs | default([]) %}
{% set vrf_name = vrf.name ~ ('' if vrf.name in ('inb', 'obb', 'overlay-1') else defaults.apic.tenants.vrfs.name_suffix) %}

Verify VRF {{ vrf_name }}
    ${r}=   GET On Session   apic   /api/mo/uni/tn-{{ tenant.name }}/ctx-{{ vrf_name }}.json   params=rsp-subtree=full
    Set Suite Variable   $r   ${r.json()}
    Should Be Equal JMESPath Json   ${r}   imdata[0].fvCtx.attributes.name   {{ vrf_name }}
    Should Be Equal JMESPath Json   ${r}   imdata[0].fvCtx.attributes.nameAlias   {{ vrf.alias | default() }}
    Should Be Equal JMESPath Json   ${r}   imdata[0].fvCtx.attributes.descr   {{ vrf.description | default() }}
    Should Be Equal JMESPath Json   ${r}   imdata[0].fvCtx.attributes.ipDataPlaneLearning   {{ 'enabled' if vrf.data_plane_learning | default(defaults.apic.tenants.vrfs.data_plane_learning) else 'disabled' }}
{% if not vrf.ndo_managed | default(defaults.apic.tenants.vrfs.ndo_managed) %}
    Should Be Equal JMESPath Json   ${r}   imdata[0].fvCtx.attributes.pcEnfDir   {{ vrf.enforcement_direction | default(defaults.apic.tenants.vrfs.enforcement_direction) }}
{% endif %}
    Should Be Equal JMESPath Json   ${r}   imdata[0].fvCtx.attributes.pcEnfPref   {{ vrf.enforcement_preference | default(defaults.apic.tenants.vrfs.enforcement_preference) }}
    Should Be Equal JMESPath Json   ${r}   imdata[0].fvCtx.children[?vzAny] | [0].vzAny.attributes.prefGrMemb   {{ 'enabled' if vrf.preferred_group | default(defaults.apic.tenants.vrfs.preferred_group) else 'disabled' }}

{% if vrf.endpoint_retention_policy is defined %}
{% set endpoint_retention_policy_name = vrf.endpoint_retention_policy ~ defaults.apic.tenants.policies.endpoint_retention_policies.name_suffix %}
    Should Be Equal JMESPath Json   ${r}   imdata[0].fvCtx.children[?fvRsCtxToEpRet] | [0].fvRsCtxToEpRet.attributes.tnFvEpRetPolName   {{ endpoint_retention_policy_name }}
{% endif %}

{% if vrf.snmp_context is defined %}
{% set snmp_context_name = vrf.snmp_context.name ~ defaults.apic.tenants.vrfs.snmp_context.name_suffix %}

Verify VRF {{ vrf_name }} SNMP Context {{ snmp_context_name }}
    ${snmp_context}=   Set Variable   imdata[0].fvCtx.children[?snmpCtxP.attributes.name=='{{ snmp_context_name }}'] | [0].snmpCtxP
    Should Be Equal JMESPath Json   ${r}   ${snmp_context}.attributes.name   {{ snmp_context_name }}

{% for community_profile in vrf.snmp_context.community_profiles | default([]) %}
{% set community_profile_name = community_profile.name ~ defaults.apic.tenants.vrfs.snmp_context.community_profiles.name_suffix %}

Verify VRF {{ vrf_name }} SNMP Context {{ snmp_context_name }} Community Profile {{ community_profile_name }}
    ${snmp_context}=   Set Variable   imdata[0].fvCtx.children[?snmpCtxP.attributes.name=='{{ snmp_context_name }}'] | [0].snmpCtxP
    ${comm_profile}=   Set Variable   ${snmp_context}.children[?snmpCommunityP.attributes.name=='{{ community_profile_name }}'] | [0].snmpCommunityP
    Should Be Equal JMESPath Json   ${r}   ${comm_profile}.attributes.name   {{ community_profile_name }}
    Should Be Equal JMESPath Json   ${r}   ${comm_profile}.attributes.descr   {{ community_profile.description | default("") }}

{% endfor %}
{% endif %}

{% for prefix in vrf.leaked_internal_subnets | default([]) %}

Verify VRF {{ vrf_name }} Leaked Internal Subnet {{ prefix.prefix }}
    ${prefix}=   Set Variable   imdata[0].fvCtx.children[?leakRoutes] | [0].leakRoutes.children[?leakInternalSubnet.attributes.ip=='{{ prefix.prefix }}'] | [0].leakInternalSubnet
    Should Be Equal JMESPath Json   ${r}   ${prefix}.attributes.ip   {{ prefix.prefix }}
    Should Be Equal JMESPath Json   ${r}   ${prefix}.attributes.scope   {{ 'public' if prefix.public | default(defaults.apic.tenants.vrfs.leaked_internal_subnets.public) else 'private' }}

{% for destination in prefix.destinations | default([]) %}
{% set dest_vrf_name = destination.vrf ~ ('' if vrf.name in ('inb', 'obb', 'overlay-1') else defaults.apic.tenants.vrfs.name_suffix) %}

Verify VRF {{ vrf_name }} Leaked Internal Subnet {{ prefix.prefix }} Destination {{ destination.tenant }} {{ dest_vrf_name }}
    ${prefix}=   Set Variable   imdata[0].fvCtx.children[?leakRoutes] | [0].leakRoutes.children[?leakInternalSubnet.attributes.ip=='{{ prefix.prefix }}'] | [0].leakInternalSubnet
    ${dest}=   Set Variable   ${prefix}.children[?leakTo.attributes.ctxName=='{{ dest_vrf_name }}' && leakTo.attributes.tenantName=='{{ destination.tenant }}'] | [0].leakTo
    Should Be Equal JMESPath Json   ${r}   ${dest}.attributes.descr   {{ destination.description | default("") }}
    Should Be Equal JMESPath Json   ${r}   ${dest}.attributes.ctxName   {{ dest_vrf_name }}
    Should Be Equal JMESPath Json   ${r}   ${dest}.attributes.tenantName   {{ destination.tenant }}
    Should Be Equal JMESPath Json   ${r}   ${dest}.attributes.scope   {{ ('public' if destination.public else 'private') if destination.public is defined else 'inherit' }}

{% endfor %}
{% endfor %}

{# Test leaked_internal_prefixes (leakInternalPrefix) - APIC 5.2+ #}
{% for prefix in vrf.leaked_internal_prefixes | default([]) %}

Verify VRF {{ vrf_name }} Leaked Internal Prefix {{ prefix.prefix }}
    ${prefix}=   Set Variable   imdata[0].fvCtx.children[?leakRoutes] | [0].leakRoutes.children[?leakInternalPrefix.attributes.ip=='{{ prefix.prefix }}'] | [0].leakInternalPrefix
    Should Be Equal JMESPath Json   ${r}   ${prefix}.attributes.ip   {{ prefix.prefix }}
    Should Be Equal JMESPath Json   ${r}   ${prefix}.attributes.scope   {{ 'public' if prefix.public | default(defaults.apic.tenants.vrfs.leaked_internal_prefixes.public) else 'private' }}
    Should Be Equal JMESPath Json   ${r}   ${prefix}.attributes.ge   {{ prefix.from_prefix_length | default(defaults.apic.tenants.vrfs.leaked_internal_prefixes.from_prefix_length) }}
    Should Be Equal JMESPath Json   ${r}   ${prefix}.attributes.le   {{ prefix.to_prefix_length | default(defaults.apic.tenants.vrfs.leaked_internal_prefixes.to_prefix_length) }}

{% for destination in prefix.destinations | default([]) %}
{% set dest_vrf_name = destination.vrf ~ ('' if vrf.name in ('inb', 'obb', 'overlay-1') else defaults.apic.tenants.vrfs.name_suffix) %}

Verify VRF {{ vrf_name }} Leaked Internal Prefix {{ prefix.prefix }} Destination {{ destination.tenant }} {{ dest_vrf_name }}
    ${prefix}=   Set Variable   imdata[0].fvCtx.children[?leakRoutes] | [0].leakRoutes.children[?leakInternalPrefix.attributes.ip=='{{ prefix.prefix }}'] | [0].leakInternalPrefix
    ${dest}=   Set Variable   ${prefix}.children[?leakTo.attributes.ctxName=='{{ dest_vrf_name }}' && leakTo.attributes.tenantName=='{{ destination.tenant }}'] | [0].leakTo
    Should Be Equal JMESPath Json   ${r}   ${dest}.attributes.descr   {{ destination.description | default("") }}
    Should Be Equal JMESPath Json   ${r}   ${dest}.attributes.ctxName   {{ dest_vrf_name }}
    Should Be Equal JMESPath Json   ${r}   ${dest}.attributes.tenantName   {{ destination.tenant }}
    Should Be Equal JMESPath Json   ${r}   ${dest}.attributes.scope   {{ ('public' if destination.public else 'private') if destination.public is defined else 'inherit' }}

{% endfor %}
{% endfor %}

{% for prefix in vrf.leaked_external_prefixes | default([]) %}

Verify VRF {{ vrf_name }} Leaked External Prefix {{ prefix.prefix }}
    ${prefix}=   Set Variable   imdata[0].fvCtx.children[?leakRoutes] | [0].leakRoutes.children[?leakExternalPrefix.attributes.ip=='{{ prefix.prefix }}'] | [0].leakExternalPrefix
    Should Be Equal JMESPath Json   ${r}   ${prefix}.attributes.ip   {{ prefix.prefix }}
    Should Be Equal JMESPath Json   ${r}   ${prefix}.attributes.le   {{ prefix.to_prefix_length | default(defaults.apic.tenants.vrfs.leaked_external_prefixes.to_prefix_length) }}
    Should Be Equal JMESPath Json   ${r}   ${prefix}.attributes.ge   {{ prefix.from_prefix_length | default(defaults.apic.tenants.vrfs.leaked_external_prefixes.from_prefix_length) }}

{% for destination in prefix.destinations | default([]) %}
{% set vrf_name = destination.vrf ~ ('' if vrf.name in ('inb', 'obb', 'overlay-1') else defaults.apic.tenants.vrfs.name_suffix) %}

Verify VRF {{ vrf_name }} Leaked External Prefix {{ prefix.prefix }} Destination {{ destination.tenant }} {{ vrf_name }}
    ${prefix}=   Set Variable   imdata[0].fvCtx.children[?leakRoutes] | [0].leakRoutes.children[?leakExternalPrefix.attributes.ip=='{{ prefix.prefix }}'] | [0].leakExternalPrefix
    ${dest}=   Set Variable   ${prefix}.children[?leakTo.attributes.ctxName=='{{ vrf_name }}' && leakTo.attributes.tenantName=='{{ destination.tenant }}'] | [0].leakTo
    Should Be Equal JMESPath Json   ${r}   ${dest}.attributes.descr   {{ destination.description | default("") }}
    Should Be Equal JMESPath Json   ${r}   ${dest}.attributes.ctxName   {{ vrf_name }}
    Should Be Equal JMESPath Json   ${r}   ${dest}.attributes.tenantName   {{ destination.tenant }}

{% endfor %}
{% endfor %}

{% if vrf.transit_route_tag_policy is defined %}

Verify Transit Route Tag Policy {{ vrf.transit_route_tag_policy }}
{% set transit_route_tag_policy_name = vrf.transit_route_tag_policy ~ defaults.apic.tenants.policies.route_tag_policies.name_suffix %}
    ${tag_entry}=   Set Variable   imdata[0].fvCtx.children[?fvRsCtxToExtRouteTagPol.attributes.tnL3extRouteTagPolName=='{{ transit_route_tag_policy_name }}'] | [0].fvRsCtxToExtRouteTagPol
    Should Be Equal JMESPath Json   ${r}   ${tag_entry}.attributes.tnL3extRouteTagPolName   {{ transit_route_tag_policy_name }}
{% endif %}

{% if vrf.bgp.timer_policy is defined %}

Verify BGP Timer Policy {{ vrf.bgp.timer_policy }}
{% set bgp_timer_name = vrf.bgp.timer_policy + defaults.apic.tenants.policies.bgp_timer_policies.name_suffix %}
    ${bgp_entry}=   Set Variable   imdata[0].fvCtx.children[?fvRsBgpCtxPol.attributes.tnBgpCtxPolName=='{{ bgp_timer_name }}'] | [0].fvRsBgpCtxPol
    Should Be Equal JMESPath Json   ${r}   ${bgp_entry}.attributes.tnBgpCtxPolName   {{ bgp_timer_name }}
{% endif %}

{% if vrf.bgp.ipv4_address_family_context_policy is defined %}

Verify IPv4 BGP Address Family Context Policy {{ vrf.bgp.ipv4_address_family_context_policy }}
    {% set address_family_context_policy_name = vrf.bgp.ipv4_address_family_context_policy + defaults.apic.tenants.policies.bgp_address_family_context_policies.name_suffix %}
    ${bgp_entry}=   Set Variable   imdata[0].fvCtx.children[?fvRsCtxToBgpCtxAfPol.attributes.af=='ipv4-ucast'] | [0].fvRsCtxToBgpCtxAfPol
    Should Be Equal JMESPath Json   ${r}   ${bgp_entry}.attributes.tnBgpCtxAfPolName   {{ address_family_context_policy_name }}
    Should Be Equal JMESPath Json   ${r}   ${bgp_entry}.attributes.af   ipv4-ucast
{% endif %}

{% if vrf.bgp.ipv6_address_family_context_policy is defined %}

Verify IPv6 BGP Address Family Context Policy {{ vrf.bgp.ipv6_address_family_context_policy }}
    {% set address_family_context_policy_name = vrf.bgp.ipv6_address_family_context_policy + defaults.apic.tenants.policies.bgp_address_family_context_policies.name_suffix %}
    ${bgp_entry}=   Set Variable   imdata[0].fvCtx.children[?fvRsCtxToBgpCtxAfPol.attributes.af=='ipv6-ucast'] | [0].fvRsCtxToBgpCtxAfPol
    Should Be Equal JMESPath Json   ${r}   ${bgp_entry}.attributes.tnBgpCtxAfPolName   {{ address_family_context_policy_name }}
    Should Be Equal JMESPath Json   ${r}   ${bgp_entry}.attributes.af   ipv6-ucast
{% endif %}

{% if vrf.ospf.timer_policy is defined %}

Verify OSPF Timer Policy {{ vrf.ospf.timer_policy }}
{% set address_family_context_policy_name = vrf.ospf.timer_policy ~ defaults.apic.tenants.policies.ospf_timer_policies.name_suffix %}
    ${ospf_entry}=   Set Variable   imdata[0].fvCtx.children[?fvRsOspfCtxPol.attributes.tnOspfCtxPolName=='{{ address_family_context_policy_name }}'] | [0].fvRsOspfCtxPol
    Should Be Equal JMESPath Json   ${r}   ${ospf_entry}.attributes.tnOspfCtxPolName   {{ address_family_context_policy_name }}
{% endif %}

{% if vrf.ospf.ipv4_address_family_context_policy is defined %}

Verify OSPF Address Family IPv4 Context Policy {{ vrf.ospf.ipv4_address_family_context_policy }}
    {% set address_family_context_policy_name = vrf.ospf.ipv4_address_family_context_policy + defaults.apic.tenants.policies.ospf_timer_policies.name_suffix %}
    ${ospf_entry}=   Set Variable   imdata[0].fvCtx.children[?fvRsCtxToOspfCtxPol.attributes.af=='ipv4-ucast'] | [0].fvRsCtxToOspfCtxPol
    Should Be Equal JMESPath Json   ${r}   ${ospf_entry}.attributes.tnOspfCtxPolName   {{ address_family_context_policy_name }}
    Should Be Equal JMESPath Json   ${r}   ${ospf_entry}.attributes.af   ipv4-ucast
{% endif %}

{% if vrf.ospf.ipv6_address_family_context_policy is defined %}

Verify OSPF Address Family IPv6 Context Policy {{ vrf.ospf.ipv6_address_family_context_policy }}
    {% set address_family_context_policy_name = vrf.ospf.ipv6_address_family_context_policy + defaults.apic.tenants.policies.ospf_timer_policies.name_suffix %}
    ${ospf_entry}=   Set Variable   imdata[0].fvCtx.children[?fvRsCtxToOspfCtxPol.attributes.af=='ipv6-ucast'] | [0].fvRsCtxToOspfCtxPol
    Should Be Equal JMESPath Json   ${r}   ${ospf_entry}.attributes.tnOspfCtxPolName   {{ address_family_context_policy_name }}
    Should Be Equal JMESPath Json   ${r}   ${ospf_entry}.attributes.af   ipv6-ucast
{% endif %}

{% if vrf.bgp.ipv4_import_route_target is defined %}
{% for route_target in  vrf.bgp.ipv4_import_route_target%}

Verify BGP IPv4 Import Route Target {{ route_target }}
    ${bgp_entry}=   Set Variable   imdata[0].fvCtx.children[?bgpRtTargetP.attributes.af=='ipv4-ucast'] | [0].bgpRtTargetP.children[?bgpRtTarget.attributes.type=='import' && bgpRtTarget.attributes.rt=='{{route_target}}'] | [0].bgpRtTarget
    Should Be Equal JMESPath Json   ${r}   ${bgp_entry}.attributes.rt    {{route_target}}
{% endfor %}
{% endif %}

{% if vrf.bgp.ipv4_export_route_target is defined %}
{% for route_target in  vrf.bgp.ipv4_export_route_target%}

Verify BGP IPv4 Export Route Target {{ route_target }}
    ${bgp_entry}=   Set Variable   imdata[0].fvCtx.children[?bgpRtTargetP.attributes.af=='ipv4-ucast'] | [0].bgpRtTargetP.children[?bgpRtTarget.attributes.type=='export' && bgpRtTarget.attributes.rt=='{{route_target}}'] | [0].bgpRtTarget
    Should Be Equal JMESPath Json   ${r}   ${bgp_entry}.attributes.rt    {{route_target}}
{% endfor %}
{% endif %}

{% if vrf.bgp.ipv6_import_route_target is defined %}
{% for route_target in  vrf.bgp.ipv6_import_route_target%}

Verify BGP IPv6 Import Route Target {{ route_target }}
   ${bgp_entry}=   Set Variable   imdata[0].fvCtx.children[?bgpRtTargetP.attributes.af=='ipv6-ucast'] | [0].bgpRtTargetP.children[?bgpRtTarget.attributes.type=='import' && bgpRtTarget.attributes.rt=='{{route_target}}'] | [0].bgpRtTarget
    Should Be Equal JMESPath Json   ${r}   ${bgp_entry}.attributes.rt    {{route_target}}
{% endfor %}
{% endif %}

{% if vrf.bgp.ipv6_export_route_target is defined %}
{% for route_target in  vrf.bgp.ipv6_export_route_target%}

Verify BGP IPv6 Export Route Target {{ route_target }}
    ${bgp_entry}=   Set Variable   imdata[0].fvCtx.children[?bgpRtTargetP.attributes.af=='ipv6-ucast'] | [0].bgpRtTargetP.children[?bgpRtTarget.attributes.type=='export' && bgpRtTarget.attributes.rt=='{{route_target}}'] | [0].bgpRtTarget
    Should Be Equal JMESPath Json   ${r}   ${bgp_entry}.attributes.rt    {{route_target}}
{% endfor %}
{% endif %}

{% for contract in vrf.contracts.providers | default([]) %}
{% set contract_name = contract ~ defaults.apic.tenants.contracts.name_suffix %}
Verify VRF {{ vrf.name }} vzAny Contract Provider {{ contract_name }}
    ${vzany_prov}=   Set Variable   imdata[0].fvCtx.children[?vzAny] | [0].vzAny.children[?vzRsAnyToProv.attributes.tnVzBrCPName=='{{ contract_name }}'] | [0].vzRsAnyToProv
    Should Be Equal JMESPath Json   ${r}   ${vzany_prov}.attributes.tnVzBrCPName   {{ contract_name }}
{% endfor %}

{% for contract in vrf.contracts.consumers | default([]) %}
{% set contract_name = contract ~ defaults.apic.tenants.contracts.name_suffix %}

Verify VRF {{ vrf.name }} vzAny Contract consumers {{ contract_name }}
    ${vzany_cons}=   Set Variable   imdata[0].fvCtx.children[?vzAny] | [0].vzAny.children[?vzRsAnyToCons.attributes.tnVzBrCPName=='{{ contract_name }}'] | [0].vzRsAnyToCons
    Should Be Equal JMESPath Json   ${r}   ${vzany_cons}.attributes.tnVzBrCPName   {{ contract_name }}

{% endfor %}

{% for contract in vrf.contracts.imported_consumers | default([]) %}
{% set contract_name = contract ~ defaults.apic.tenants.contracts.name_suffix %}

Verify VRF {{ vrf.name }} vzAny Contract Import consumers {{ contract_name }}
    ${vzany_consIf}=   Set Variable   imdata[0].fvCtx.children[?vzAny] | [0].vzAny.children[?vzRsAnyToConsIf.attributes.tnVzCPIfName=='{{ contract_name }}'] | [0].vzRsAnyToConsIf
    Should Be Equal JMESPath Json   ${r}   ${vzany_consIf}.attributes.tnVzCPIfName   {{ contract_name }}

{% endfor %}
{% if vrf.pim is defined %}

Verify VRF {{ vrf.name }} PIM
    Should Be Equal JMESPath Json   ${r}   imdata[0].fvCtx.children[?pimCtxP] | [0].pimCtxP.attributes.mtu   {{ vrf.pim.mtu | default(defaults.apic.tenants.vrfs.pim.mtu)}}
    Should Be Equal JMESPath Json   ${r}   imdata[0].fvCtx.children[?pimCtxP] | [0].pimCtxP.children[?pimResPol] | [0].pimResPol.attributes.max   {{ max_entry(vrf.pim.max_multicast_entries | default(defaults.apic.tenants.vrfs.pim.max_multicast_entries)) }}
    Should Be Equal JMESPath Json   ${r}   imdata[0].fvCtx.children[?pimCtxP] | [0].pimCtxP.children[?pimResPol] | [0].pimResPol.attributes.rsvd   {{ reserved_entry(vrf.pim.reserved_multicast_entries | default(defaults.apic.tenants.vrfs.pim.reserved_multicast_entries)) }}
{% if vrf.pim.resource_policy_multicast_route_map is defined %}
{% set resource_policy_multicast_route_map_name = vrf.pim.resource_policy_multicast_route_map ~ defaults.apic.tenants.policies.multicast_route_maps.name_suffix %}
    Should Be Equal JMESPath Json   ${r}   imdata[0].fvCtx.children[?pimCtxP] | [0].pimCtxP.children[?pimResPol] | [0].pimResPol.children[?rtdmcRsFilterToRtMapPol] | [0].rtdmcRsFilterToRtMapPol.attributes.tDn   uni/tn-{{ tenant.name }}/rtmap-{{ resource_policy_multicast_route_map_name }}
{% endif %}

{% set ctrl = [] %}
{% if vrf.pim.bsr_forward_updates | default(defaults.apic.tenants.vrfs.pim.bsr_forward_updates) %}{% set ctrl = ctrl + [("forward")] %}{% endif %}
{% if vrf.pim.bsr_listen_updates | default(defaults.apic.tenants.vrfs.pim.bsr_listen_updates) %}{% set ctrl = ctrl + [("listen")] %}{% endif %}

Verify VRF {{ vrf.name }} PIM BSR
    Should Be Equal JMESPath Json   ${r}   imdata[0].fvCtx.children[?pimCtxP] | [0].pimCtxP.children[?pimBSRPPol] | [0].pimBSRPPol.attributes.ctrl   {{ ctrl | join(',') }}
{% if vrf.pim.bsr_filter_multicast_route_map is defined %}
{% set bsr_filter_name = vrf.pim.bsr_filter_multicast_route_map ~ defaults.apic.tenants.policies.multicast_route_maps.name_suffix %}
    Should Be Equal JMESPath Json   ${r}   imdata[0].fvCtx.children[?pimCtxP] | [0].pimCtxP.children[?pimBSRPPol] | [0].pimBSRPPol.children[?pimBSRFilterPol] | [0].pimBSRFilterPol.children[?rtdmcRsFilterToRtMapPol] | [0].rtdmcRsFilterToRtMapPol.attributes.tDn   uni/tn-{{ tenant.name }}/rtmap-{{ bsr_filter_name }}

{% endif %}
{% set ctrl = [] %}
{% if vrf.pim.auto_rp_forward_updates | default(defaults.apic.tenants.vrfs.pim.auto_rp_forward_updates) %}{% set ctrl = ctrl + [("forward")] %}{% endif %}
{% if vrf.pim.auto_rp_listen_updates | default(defaults.apic.tenants.vrfs.pim.auto_rp_listen_updates) %}{% set ctrl = ctrl + [("listen")] %}{% endif %}

Verify VRF {{ vrf.name }} PIM Auto-RP
    Should Be Equal JMESPath Json   ${r}   imdata[0].fvCtx.children[?pimCtxP] | [0].pimCtxP.children[?pimAutoRPPol] | [0].pimAutoRPPol.attributes.ctrl   {{ ctrl | join(',') }}
{% if vrf.pim.auto_rp_filter_multicast_route_map is defined %}
{% set auto_rp_filter_name = vrf.pim.auto_rp_filter_multicast_route_map ~ defaults.apic.tenants.policies.multicast_route_maps.name_suffix %}
    Should Be Equal JMESPath Json   ${r}   imdata[0].fvCtx.children[?pimCtxP] | [0].pimCtxP.children[?pimAutoRPPol] | [0].pimAutoRPPol.children[?pimMAFilterPol] | [0].pimMAFilterPol.children[?rtdmcRsFilterToRtMapPol] | [0].rtdmcRsFilterToRtMapPol.attributes.tDn   uni/tn-{{ tenant.name }}/rtmap-{{ auto_rp_filter_name }}

{% endif %}

{% if vrf.pim.static_rps is defined %}
{% for static_rp in vrf.pim.static_rps %}

Verify VRF {{ vrf.name }} PIM Static RP {{ static_rp.ip }}
    ${rp}=   Set Variable   imdata[0].fvCtx.children[?pimCtxP] | [0].pimCtxP.children[?pimStaticRPPol] | [0].pimStaticRPPol.children[?pimStaticRPEntryPol.attributes.rpIp=='{{ static_rp.ip }}'] | [0].pimStaticRPEntryPol
    Should Be Equal JMESPath Json   ${r}   ${rp}.attributes.rpIp   {{ static_rp.ip }}

{% if static_rp.multicast_route_map is defined %}
{% set static_rp_route_map_name = static_rp.multicast_route_map ~ defaults.apic.tenants.policies.multicast_route_maps.name_suffix %}
    Should Be Equal JMESPath Json   ${r}   ${rp}.children[?pimRPGrpRangePol] | [0].pimRPGrpRangePol.children[?rtdmcRsFilterToRtMapPol] | [0].rtdmcRsFilterToRtMapPol.attributes.tDn   uni/tn-{{ tenant.name }}/rtmap-{{ static_rp_route_map_name }}

{% endif %}

{% endfor %}
{% endif %}

{% if vrf.pim.fabric_rps is defined %}
{% for fabric_rp in vrf.pim.fabric_rps %}

Verify VRF {{ vrf.name }} PIM Fabric RP {{ fabric_rp.ip }}
    ${rp}=   Set Variable   imdata[0].fvCtx.children[?pimCtxP] | [0].pimCtxP.children[?pimFabricRPPol] | [0].pimFabricRPPol.children[?pimStaticRPEntryPol.attributes.rpIp=='{{ fabric_rp.ip }}'] | [0].pimStaticRPEntryPol
    Should Be Equal JMESPath Json   ${r}   ${rp}.attributes.rpIp   {{ fabric_rp.ip }}

{% if fabric_rp.multicast_route_map is defined %}

{% set fabric_rp_route_map_name = fabric_rp.multicast_route_map ~ defaults.apic.tenants.policies.multicast_route_maps.name_suffix %}
    Should Be Equal JMESPath Json   ${r}   ${rp}.children[?pimRPGrpRangePol] | [0].pimRPGrpRangePol.children[?rtdmcRsFilterToRtMapPol] | [0].rtdmcRsFilterToRtMapPol.attributes.tDn   uni/tn-{{ tenant.name }}/rtmap-{{ fabric_rp_route_map_name }}

{% endif %}

{% endfor %}
{% endif %}

Verify VRF {{ vrf.name }} PIM ASM Pattern Policy
{% if vrf.pim.asm_shared_range_multicast_route_map is defined %}
{% set asm_shared_range_multicast_route_map_name = vrf.pim.asm_shared_range_multicast_route_map ~ defaults.apic.tenants.policies.multicast_route_maps.name_suffix %}
    Should Be Equal JMESPath Json   ${r}   imdata[0].fvCtx.children[?pimCtxP] | [0].pimCtxP.children[?pimASMPatPol] | [0].pimASMPatPol.children[?pimSharedRangePol] | [0].pimSharedRangePol.children[?rtdmcRsFilterToRtMapPol] | [0].rtdmcRsFilterToRtMapPol.attributes.tDn   uni/tn-{{ tenant.name }}/rtmap-{{ asm_shared_range_multicast_route_map_name }}
{% endif %}
{% if vrf.pim.asm_sg_expiry_multicast_route_map is defined %}
{% set asm_sg_expiry_multicast_route_map_name = vrf.pim.asm_sg_expiry_multicast_route_map ~ defaults.apic.tenants.policies.multicast_route_maps.name_suffix %}
    Should Be Equal JMESPath Json   ${r}   imdata[0].fvCtx.children[?pimCtxP] | [0].pimCtxP.children[?pimASMPatPol] | [0].pimASMPatPol.children[?pimSGRangeExpPol] | [0].pimSGRangeExpPol.children[?rtdmcRsFilterToRtMapPol] | [0].rtdmcRsFilterToRtMapPol.attributes.tDn   uni/tn-{{ tenant.name }}/rtmap-{{ asm_sg_expiry_multicast_route_map_name }}
{% endif %}
    Should Be Equal JMESPath Json   ${r}   imdata[0].fvCtx.children[?pimCtxP] | [0].pimCtxP.children[?pimASMPatPol] | [0].pimASMPatPol.children[?pimRegTrPol] | [0].pimRegTrPol.attributes.maxRate   {{ vrf.pim.asm_traffic_registry_max_rate | default(defaults.apic.tenants.vrfs.pim.asm_traffic_registry_max_rate) }}
    Should Be Equal JMESPath Json   ${r}   imdata[0].fvCtx.children[?pimCtxP] | [0].pimCtxP.children[?pimASMPatPol] | [0].pimASMPatPol.children[?pimRegTrPol] | [0].pimRegTrPol.attributes.srcIp   {{ vrf.pim.asm_traffic_registry_source_ip | default(defaults.apic.tenants.vrfs.pim.asm_traffic_registry_source_ip) }}

{% if vrf.pim.ssm_group_range_multicast_route_map is defined %}
Verify VRF {{ vrf.name }} PIM SSM Pattern Policy
{% set ssm_group_range_multicast_route_map_name = vrf.pim.ssm_group_range_multicast_route_map ~ defaults.apic.tenants.policies.multicast_route_maps.name_suffix %}
    Should Be Equal JMESPath Json   ${r}   imdata[0].fvCtx.children[?pimCtxP] | [0].pimCtxP.children[?pimSSMPatPol] | [0].pimSSMPatPol.children[?pimSSMRangePol] | [0].pimSSMRangePol.children[?rtdmcRsFilterToRtMapPol] | [0].rtdmcRsFilterToRtMapPol.attributes.tDn   uni/tn-{{ tenant.name }}/rtmap-{{ ssm_group_range_multicast_route_map_name }}
{% endif %}

{% if vrf.pim.inter_vrf_policies is defined %}
{% for pol in vrf.pim.inter_vrf_policies | default([]) %}
{% set vrf_name = pol.vrf ~ defaults.apic.tenants.vrfs.name_suffix %}
Verify VRF {{ vrf.name }} Inter-VRF Multicast Tenant {{ pol.tenant}} VRF {{ vrf_name }}
     ${inter_vrf}=   Set Variable   imdata[0].fvCtx.children[?pimCtxP] | [0].pimCtxP.children[?pimInterVRFPol] | [0].pimInterVRFPol.children[?pimInterVRFEntryPol.attributes.srcVrfDn=='uni/tn-{{ pol.tenant }}/ctx-{{ vrf_name }}'] | [0].pimInterVRFEntryPol
    Should Be Equal JMESPath Json   ${r}   ${inter_vrf}.attributes.srcVrfDn   uni/tn-{{ pol.tenant }}/ctx-{{ vrf_name }}
{% if pol.multicast_route_map is defined %}
{% set multicast_route_map_name = pol.multicast_route_map ~ defaults.apic.tenants.policies.multicast_route_maps.name_suffix %}
    Should Be Equal JMESPath Json   ${r}   ${inter_vrf}.children[?rtdmcRsFilterToRtMapPol] | [0].rtdmcRsFilterToRtMapPol.attributes.tDn   uni/tn-{{ tenant.name }}/rtmap-{{ multicast_route_map_name}}
{% endif %}

{% endfor %}

{% endif %}

{% endif %}

{% if vrf.pim.igmp_context_ssm_translate_policies is defined %}
{% for pol in vrf.pim.igmp_context_ssm_translate_policies | default([]) %}
Verify VRF {{ vrf.name }} IGMP Context SSM Tranlation policies {{ pol.group_prefix }}-{{ pol.source_address }}
    ${igmp_ssn}=   Set Variable   imdata[0].fvCtx.children[?igmpCtxP] | [0].igmpCtxP.children[?igmpSSMXlateP.attributes.descr=='{{ pol.group_prefix }}-{{ pol.source_address }}'] | [0].igmpSSMXlateP
    Should Be Equal JMESPath Json   ${r}   ${igmp_ssn}.attributes.grpPfx   {{ pol.group_prefix }}
    Should Be Equal JMESPath Json   ${r}   ${igmp_ssn}.attributes.srcAddr   {{ pol.source_address }}

{% endfor %}

{% endif %}

{% if vrf.route_summarization_policies is defined %}
{% for pol in vrf.route_summarization_policies | default([]) %}
{% set rsp_name = pol.name ~ defaults.apic.tenants.vrfs.route_summarization_policies.name_suffix %}
Verify VRF {{ vrf.name }} Route Summarization Policy {{ rsp_name }}
    ${pol}=   Set Variable   imdata[0].fvCtx.children[?fvCtxRtSummPol.attributes.name=='{{ rsp_name }}'] | [0].fvCtxRtSummPol
    Should Be Equal JMESPath Json   ${r}   ${pol}.attributes.name   {{ rsp_name }}

{% for node in pol.nodes | default([]) %}
{% set query = "nodes[?id==`" ~ node.id ~ "`].pod" %}
{% set pod = node.pod | default(((apic.node_policies | default()) | community.general.json_query(query))[0] | default(defaults.apic.tenants.vrfs.route_summarization_policies.nodes.pod)) %}
Verify VRF {{ vrf.name }} Route Summarization Policy {{ rsp_name }} Node {{ node.id }}
    ${pol}=   Set Variable   imdata[0].fvCtx.children[?fvCtxRtSummPol.attributes.name=='{{ rsp_name }}'] | [0].fvCtxRtSummPol
    ${node}=   Set Variable   ${pol}.children[?fvRsNodeRtSummAtt.attributes.tDn=='topology/pod-{{ pod }}/node-{{ node.id }}'] | [0].fvRsNodeRtSummAtt
    Should Be Equal JMESPath Json   ${r}   ${node}.attributes.tDn   topology/pod-{{ pod }}/node-{{ node.id }}

{% endfor %}

{% for subnet in pol.subnets | default([]) %}
{% if subnet.bgp_route_summarization_policy is defined %}
{% set brs_tdn = "uni/tn-" + tenant.name + "/bgprtsum-" + subnet.bgp_route_summarization_policy ~ defaults.apic.tenants.policies.bgp_route_summarization_policies.name_suffix %}
{% else %}
{% set brs_tdn = "uni/tn-common/bgprtsum-default" %}
{% endif %}
Verify VRF {{ vrf.name }} Route Summarization Policy {{ rsp_name }} Subnet {{ subnet.prefix }}
    ${pol}=   Set Variable   imdata[0].fvCtx.children[?fvCtxRtSummPol.attributes.name=='{{ rsp_name }}'] | [0].fvCtxRtSummPol
    ${subnet}=   Set Variable   ${pol}.children[?fvRtSummSubnet.attributes.prefix=='{{ subnet.prefix }}'] | [0].fvRtSummSubnet
    Should Be Equal JMESPath Json   ${r}   ${subnet}.attributes.prefix   {{ subnet.prefix }}
    Should Be Equal JMESPath Json   ${r}   ${subnet}.children[?fvRsSubnetToRtSummPol] | [0].fvRsSubnetToRtSummPol.attributes.tDn   {{ brs_tdn }}

{% endfor %}

{% endfor %}
{% endif %}

{% endfor %}
