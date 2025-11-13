*** Settings ***
Documentation   Verify Leaf Interface Policy Group
Suite Setup     Login APIC
Default Tags    apic   day2   config   access_policies
Resource        ../../apic_common.resource

*** Test Cases ***
{% for pg in apic.access_policies.leaf_interface_policy_groups | default([]) %}
{% set policy_group_name = pg.name ~ defaults.apic.access_policies.leaf_interface_policy_groups.name_suffix %}

Verify Leaf Interface Policy Group {{ policy_group_name }}
{% if pg.type == "breakout" %}
    ${r}=   GET On Session   apic   /api/mo/uni/infra/funcprof/brkoutportgrp-{{ policy_group_name }}.json   params=rsp-subtree=full
    Set Suite Variable   $r   ${r.json()}
    Should Be Equal JMESPath Json   ${r}    imdata[0].infraBrkoutPortGrp.attributes.name   {{ policy_group_name }}
    Should Be Equal JMESPath Json   ${r}    imdata[0].infraBrkoutPortGrp.attributes.descr   {{ pg.description | default() }}
    Should Be Equal JMESPath Json   ${r}    imdata[0].infraBrkoutPortGrp.attributes.brkoutMap   {{ pg.map | default(defaults.apic.access_policies.leaf_interface_policy_groups.map)}}
{% elif pg.type in ["vpc", "pc"] %}
    ${r}=   GET On Session   apic   /api/mo/uni/infra/funcprof/accbundle-{{ policy_group_name }}.json   params=rsp-subtree=full
    Set Suite Variable   $r   ${r.json()}
    Should Be Equal JMESPath Json   ${r}    imdata[0].infraAccBndlGrp.attributes.name   {{ policy_group_name }}
    Should Be Equal JMESPath Json   ${r}    imdata[0].infraAccBndlGrp.attributes.descr   {{ pg.description | default() }}
{% if pg.type == "vpc" %}
    Should Be Equal JMESPath Json   ${r}    imdata[0].infraAccBndlGrp.attributes.lagT   node
{% elif pg.type == "pc" %}
    Should Be Equal JMESPath Json   ${r}    imdata[0].infraAccBndlGrp.attributes.lagT   link
{% endif %}
{% else %}
    ${r}=   GET On Session   apic   /api/mo/uni/infra/funcprof/accportgrp-{{ policy_group_name }}.json   params=rsp-subtree=full
    Set Suite Variable   $r   ${r.json()}
    Should Be Equal JMESPath Json   ${r}    imdata[0].infraAccPortGrp.attributes.name   {{ policy_group_name }}
    Should Be Equal JMESPath Json   ${r}    imdata[0].infraAccPortGrp.attributes.descr   {{ pg.description | default() }}
{% endif %}
{% if pg.link_level_policy is defined %}
{% set link_level_policy_name = pg.link_level_policy ~ defaults.apic.access_policies.interface_policies.link_level_policies.name_suffix %}
{% if pg.type == "breakout" %}
    Should Be Equal JMESPath Json   ${r}    imdata[0].infraBrkoutPortGrp.children[?infraRsHIfPol] | [0].infraRsHIfPol.attributes.tnFabricHIfPolName   {{ link_level_policy_name }}
{% elif pg.type in ["vpc", "pc"] %}
    Should Be Equal JMESPath Json   ${r}    imdata[0].infraAccBndlGrp.children[?infraRsHIfPol] | [0].infraRsHIfPol.attributes.tnFabricHIfPolName   {{ link_level_policy_name }}
{% else %}
    Should Be Equal JMESPath Json   ${r}    imdata[0].infraAccPortGrp.children[?infraRsHIfPol] | [0].infraRsHIfPol.attributes.tnFabricHIfPolName   {{ link_level_policy_name }}
{% endif %}
{% endif %}
{% if pg.cdp_policy is defined %}
{% set cdp_policy_name = pg.cdp_policy ~ defaults.apic.access_policies.interface_policies.cdp_policies.name_suffix %}
{% if pg.type == "breakout" %}
    Should Be Equal JMESPath Json   ${r}    imdata[0].infraBrkoutPortGrp.children[?infraRsCdpIfPol] | [0].infraRsCdpIfPol.attributes.tnCdpIfPolName   {{ cdp_policy_name }}
{% elif pg.type in ["vpc", "pc"] %}
    Should Be Equal JMESPath Json   ${r}    imdata[0].infraAccBndlGrp.children[?infraRsCdpIfPol] | [0].infraRsCdpIfPol.attributes.tnCdpIfPolName   {{ cdp_policy_name }}
{% else %}
    Should Be Equal JMESPath Json   ${r}    imdata[0].infraAccPortGrp.children[?infraRsCdpIfPol] | [0].infraRsCdpIfPol.attributes.tnCdpIfPolName   {{ cdp_policy_name }}
{% endif %}
{% endif %}
{% if pg.lldp_policy is defined %}
{% set lldp_policy_name = pg.lldp_policy ~ defaults.apic.access_policies.interface_policies.lldp_policies.name_suffix %}
{% if pg.type == "breakout" %}
    Should Be Equal JMESPath Json   ${r}    imdata[0].infraBrkoutPortGrp.children[?infraRsLldpIfPol] | [0].infraRsLldpIfPol.attributes.tnLldpIfPolName   {{ lldp_policy_name }}
{% elif pg.type in ["vpc", "pc"] %}
    Should Be Equal JMESPath Json   ${r}    imdata[0].infraAccBndlGrp.children[?infraRsLldpIfPol] | [0].infraRsLldpIfPol.attributes.tnLldpIfPolName   {{ lldp_policy_name }}
{% else %}
    Should Be Equal JMESPath Json   ${r}    imdata[0].infraAccPortGrp.children[?infraRsLldpIfPol] | [0].infraRsLldpIfPol.attributes.tnLldpIfPolName   {{ lldp_policy_name }}
{% endif %}
{% endif %}
{% if pg.spanning_tree_policy is defined %}
{% set spanning_tree_policy_name = pg.spanning_tree_policy ~ defaults.apic.access_policies.interface_policies.spanning_tree_policies.name_suffix %}
{% if pg.type == "breakout" %}
    Should Be Equal JMESPath Json   ${r}    imdata[0].infraBrkoutPortGrp.children[?infraRsStpIfPol] | [0].infraRsStpIfPol.attributes.tnStpIfPolName   {{ spanning_tree_policy_name }}
{% elif pg.type in ["vpc", "pc"] %}
    Should Be Equal JMESPath Json   ${r}    imdata[0].infraAccBndlGrp.children[?infraRsStpIfPol] | [0].infraRsStpIfPol.attributes.tnStpIfPolName   {{ spanning_tree_policy_name }}
{% else %}
    Should Be Equal JMESPath Json   ${r}    imdata[0].infraAccPortGrp.children[?infraRsStpIfPol] | [0].infraRsStpIfPol.attributes.tnStpIfPolName   {{ spanning_tree_policy_name }}
{% endif %}
{% endif %}
{% if pg.mcp_policy is defined %}
{% set mcp_policy_name = pg.mcp_policy ~ defaults.apic.access_policies.interface_policies.mcp_policies.name_suffix %}
{% if pg.type == "breakout" %}
    Should Be Equal JMESPath Json   ${r}    imdata[0].infraBrkoutPortGrp.children[?infraRsMcpIfPol] | [0].infraRsMcpIfPol.attributes.tnMcpIfPolName   {{ mcp_policy_name }}
{% elif pg.type in ["vpc", "pc"] %}
    Should Be Equal JMESPath Json   ${r}    imdata[0].infraAccBndlGrp.children[?infraRsMcpIfPol] | [0].infraRsMcpIfPol.attributes.tnMcpIfPolName   {{ mcp_policy_name }}
{% else %}
    Should Be Equal JMESPath Json   ${r}    imdata[0].infraAccPortGrp.children[?infraRsMcpIfPol] | [0].infraRsMcpIfPol.attributes.tnMcpIfPolName   {{ mcp_policy_name }}
{% endif %}
{% endif %}
{% if pg.l2_policy is defined %}
{% set l2_policy_name = pg.l2_policy ~ defaults.apic.access_policies.interface_policies.l2_policies.name_suffix %}
{% if pg.type == "breakout" %}
    Should Be Equal JMESPath Json   ${r}    imdata[0].infraBrkoutPortGrp.children[?infraRsL2IfPol] | [0].infraRsL2IfPol.attributes.tnL2IfPolName   {{ l2_policy_name }}
{% elif pg.type in ["vpc", "pc"] %}
    Should Be Equal JMESPath Json   ${r}    imdata[0].infraAccBndlGrp.children[?infraRsL2IfPol] | [0].infraRsL2IfPol.attributes.tnL2IfPolName   {{ l2_policy_name }}
{% else %}
    Should Be Equal JMESPath Json   ${r}    imdata[0].infraAccPortGrp.children[?infraRsL2IfPol] | [0].infraRsL2IfPol.attributes.tnL2IfPolName   {{ l2_policy_name }}
{% endif %}
{% endif %}
{% if pg.storm_control_policy is defined %}
{% set storm_control_policy_name = pg.storm_control_policy ~ defaults.apic.access_policies.interface_policies.storm_control_policies.name_suffix %}
{% if pg.type == "breakout" %}
    Should Be Equal JMESPath Json   ${r}    imdata[0].infraBrkoutPortGrp.children[?infraRsStormctrlIfPol] | [0].infraRsStormctrlIfPol.attributes.tnStormctrlIfPolName   {{ storm_control_policy_name }}
{% elif pg.type in ["vpc", "pc"] %}
    Should Be Equal JMESPath Json   ${r}    imdata[0].infraAccBndlGrp.children[?infraRsStormctrlIfPol] | [0].infraRsStormctrlIfPol.attributes.tnStormctrlIfPolName   {{ storm_control_policy_name }}
{% else %}
    Should Be Equal JMESPath Json   ${r}    imdata[0].infraAccPortGrp.children[?infraRsStormctrlIfPol] | [0].infraRsStormctrlIfPol.attributes.tnStormctrlIfPolName   {{ storm_control_policy_name }}
{% endif %}
{% endif %}
{% if pg.port_channel_policy is defined and pg.type in ["vpc", "pc"] %}
{% set port_channel_policy_name = pg.port_channel_policy ~ defaults.apic.access_policies.interface_policies.port_channel_policies.name_suffix %}
    Should Be Equal JMESPath Json   ${r}    imdata[0].infraAccBndlGrp.children[?infraRsLacpPol] | [0].infraRsLacpPol.attributes.tnLacpLagPolName   {{ port_channel_policy_name }}
{% endif %}
{% if pg.port_channel_member_policy is defined and pg.type in ["vpc", "pc"] %}
{% set port_channel_member_policy_name = pg.port_channel_member_policy ~ defaults.apic.access_policies.interface_policies.port_channel_member_policies.name_suffix %}
    Should Be Equal JMESPath Json   ${r}    imdata[0].infraAccBndlGrp.children[?infraAccBndlSubgrp] | [0].infraAccBndlSubgrp.attributes.name   {{ policy_group_name }}
    Should Be Equal JMESPath Json   ${r}    imdata[0].infraAccBndlGrp.children[?infraAccBndlSubgrp] | [0].infraAccBndlSubgrp.children[?infraRsLacpInterfacePol] | [0].infraRsLacpInterfacePol.attributes.tnLacpIfPolName   {{ port_channel_member_policy_name }}
{% endif %}
{% if pg.aaep is defined %}
{% set aaep_name = pg.aaep ~ defaults.apic.access_policies.aaeps.name_suffix %}
{% if pg.type == "breakout" %}
    Should Be Equal JMESPath Json   ${r}    imdata[0].infraBrkoutPortGrp.children[?infraRsAttEntP] | [0].infraRsAttEntP.attributes.tDn   uni/infra/attentp-{{ aaep_name }}
{% elif pg.type in ["vpc", "pc"] %}
    Should Be Equal JMESPath Json   ${r}    imdata[0].infraAccBndlGrp.children[?infraRsAttEntP] | [0].infraRsAttEntP.attributes.tDn   uni/infra/attentp-{{ aaep_name }}
{% else %}
    Should Be Equal JMESPath Json   ${r}    imdata[0].infraAccPortGrp.children[?infraRsAttEntP] | [0].infraRsAttEntP.attributes.tDn   uni/infra/attentp-{{ aaep_name }}
{% endif %}
{% endif %}
{% for monitor in pg.netflow_monitor_policies | default([]) %}
{% set monitor_name = monitor.name ~ defaults.apic.access_policies.interface_policies.netflow_monitors.name_suffix %}
{% if pg.type == "breakout" %}
    ${mon}=   Set Variable   imdata[0].infraBrkoutPortGrp.children[?infraRsNetflowMonitorPol.attributes.tnNetflowMonitorPolName=='{{ monitor_name }}'] | [0].infraRsNetflowMonitorPol
{% elif pg.type in ["vpc", "pc"] %}
    ${mon}=   Set Variable   imdata[0].infraAccBndlGrp.children[?infraRsNetflowMonitorPol.attributes.tnNetflowMonitorPolName=='{{ monitor_name }}'] | [0].infraRsNetflowMonitorPol
{% else %}
    ${mon}=   Set Variable   imdata[0].infraAccPortGrp.children[?infraRsNetflowMonitorPol.attributes.tnNetflowMonitorPolName=='{{ monitor_name }}'] | [0].infraRsNetflowMonitorPol
{% endif %}
    Should Be Equal JMESPath Json   ${r}    ${mon}.attributes.tnNetflowMonitorPolName   {{ monitor_name }}
    Should Be Equal JMESPath Json   ${r}    ${mon}.attributes.fltType   {{ monitor.ip_filter_type | default(defaults.apic.access_policies.leaf_interface_policy_groups.netflow_monitor_policies.ip_filter_type) }}
{% endfor %}
{% if pg.macsec_interface_policy is defined %}
{% set macsec_policy_name = pg.macsec_interface_policy ~ defaults.apic.access_policies.interface_policies.macsec_interfaces_policies.name_suffix %}
{% if pg.type == "breakout" %}
    Should Be Equal JMESPath Json   ${r}    imdata[0].infraBrkoutPortGrp.children[?infraRsMacsecIfPol] | [0].infraRsMacsecIfPol.attributes.tDn   uni/infra/macsecifp-{{ macsec_policy_name }}
{% elif pg.type in ["vpc", "pc"] %}
    Should Be Equal JMESPath Json   ${r}    imdata[0].infraAccBndlGrp.children[?infraRsMacsecIfPol] | [0].infraRsMacsecIfPol.attributes.tDn   uni/infra/macsecifp-{{ macsec_policy_name }}
{% else %}
    Should Be Equal JMESPath Json   ${r}    imdata[0].infraAccPortGrp.children[?infraRsMacsecIfPol] | [0].infraRsMacsecIfPol.attributes.tDn   uni/infra/macsecifp-{{ macsec_policy_name }}
{% endif %}
{% endif %}
{% if pg.ingress_data_plane_policing_policy is defined %}
    {% set dpp_name = pg.ingress_data_plane_policing_policy ~ defaults.apic.access_policies.interface_policies.data_plane_policing_policies.name_suffix %}
{% if pg.type == "breakout" %}
    Should Be Equal JMESPath Json   ${r}   imdata[0].infraBrkoutPortGrp.children[?infraRsQosIngressDppIfPol] | [0].infraRsQosIngressDppIfPol.attributes.tnQosDppPolName   {{ dpp_name }}
{% elif pg.type in ["vpc", "pc"] %}
    Should Be Equal JMESPath Json   ${r}   imdata[0].infraAccBndlGrp.children[?infraRsQosIngressDppIfPol] | [0].infraRsQosIngressDppIfPol.attributes.tnQosDppPolName   {{ dpp_name }}
{% else %}
    Should Be Equal JMESPath Json   ${r}   imdata[0].infraAccPortGrp.children[?infraRsQosIngressDppIfPol] | [0].infraRsQosIngressDppIfPol.attributes.tnQosDppPolName   {{ dpp_name }}
{% endif %}
{% endif %}
{% if pg.egress_data_plane_policing_policy is defined %}
    {% set dpp_name = pg.egress_data_plane_policing_policy ~ defaults.apic.access_policies.interface_policies.data_plane_policing_policies.name_suffix %}
{% if pg.type == "breakout" %}
    Should Be Equal JMESPath Json   ${r}   imdata[0].infraBrkoutPortGrp.children[?infraRsQosEgressDppIfPol] | [0].infraRsQosEgressDppIfPol.attributes.tnQosDppPolName   {{ dpp_name }}
{% elif pg.type in ["vpc", "pc"] %}
    Should Be Equal JMESPath Json   ${r}   imdata[0].infraAccBndlGrp.children[?infraRsQosEgressDppIfPol] | [0].infraRsQosEgressDppIfPol.attributes.tnQosDppPolName   {{ dpp_name }}
{% else %}
    Should Be Equal JMESPath Json   ${r}   imdata[0].infraAccPortGrp.children[?infraRsQosEgressDppIfPol] | [0].infraRsQosEgressDppIfPol.attributes.tnQosDppPolName   {{ dpp_name }}
{% endif %}
{% endif %}

{% endfor %}
