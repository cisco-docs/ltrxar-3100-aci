*** Settings ***
Documentation   Verify VMware VMM Domain
Suite Setup     Login APIC
Default Tags    apic   day1   config   fabric_policies
Resource        ../../apic_common.resource

*** Test Cases ***
{% for vmm in apic.fabric_policies.vmware_vmm_domains | default([]) %}
{% set vmm_name = vmm.name ~ defaults.apic.fabric_policies.vmware_vmm_domains.name_suffix %}

Verify VMware VMM Domain {{ vmm_name }}
    ${r}=   GET On Session   apic   /api/mo/uni/vmmp-VMware/dom-{{ vmm_name }}.json   params=rsp-subtree=full
    Set Suite Variable   $r   ${r.json()}
    Should Be Equal JMESPath Json   ${r}    imdata[0].vmmDomP.attributes.name   {{ vmm_name }}
    Should Be Equal JMESPath Json   ${r}    imdata[0].vmmDomP.attributes.accessMode   {{ vmm.access_mode | default(defaults.apic.fabric_policies.vmware_vmm_domains.access_mode) }}
    Should Be Equal JMESPath Json   ${r}    imdata[0].vmmDomP.attributes.enableTag   {{ 'yes' if vmm.tag_collection | default(defaults.apic.fabric_policies.vmware_vmm_domains.tag_collection) else 'no' }}
{% if vmm.vswitch.cdp_policy is defined %}
{% set cdp_policy_name = vmm.vswitch.cdp_policy ~ defaults.apic.access_policies.interface_policies.cdp_policies.name_suffix %}
    Should Be Equal JMESPath Json   ${r}    imdata[0].vmmDomP.children[?vmmVSwitchPolicyCont] | [0].vmmVSwitchPolicyCont.children[?vmmRsVswitchOverrideCdpIfPol] | [0].vmmRsVswitchOverrideCdpIfPol.attributes.tDn   uni/infra/cdpIfP-{{ cdp_policy_name }}
{% endif %}
{% if vmm.vswitch.lldp_policy is defined %}
{% set lldp_policy_name = vmm.vswitch.lldp_policy ~ defaults.apic.access_policies.interface_policies.lldp_policies.name_suffix %}
    Should Be Equal JMESPath Json   ${r}    imdata[0].vmmDomP.children[?vmmVSwitchPolicyCont] | [0].vmmVSwitchPolicyCont.children[?vmmRsVswitchOverrideLldpIfPol] | [0].vmmRsVswitchOverrideLldpIfPol.attributes.tDn   uni/infra/lldpIfP-{{ lldp_policy_name }}
{% endif %}
{% if vmm.vswitch.port_channel_policy is defined %}
{% set port_channel_policy_name = vmm.vswitch.port_channel_policy ~ defaults.apic.access_policies.interface_policies.port_channel_policies.name_suffix %}
    Should Be Equal JMESPath Json   ${r}    imdata[0].vmmDomP.children[?vmmVSwitchPolicyCont] | [0].vmmVSwitchPolicyCont.children[?vmmRsVswitchOverrideLacpPol] | [0].vmmRsVswitchOverrideLacpPol.attributes.tDn   uni/infra/lacplagp-{{ port_channel_policy_name }}
{% endif %}
{% if vmm.vswitch.mtu_policy is defined %}
{% set mtu_policy_name = vmm.vswitch.mtu_policy ~ defaults.apic.fabric_policies.l2_mtu_policies.name_suffix %}
    Should Be Equal JMESPath Json   ${r}    imdata[0].vmmDomP.children[?vmmVSwitchPolicyCont] | [0].vmmVSwitchPolicyCont.children[?vmmRsVswitchOverrideMtuPol] | [0].vmmRsVswitchOverrideMtuPol.attributes.tDn   uni/fabric/l2pol-{{ mtu_policy_name }}
{% endif %}
{% if vmm.vswitch.netflow_exporter_policy is defined %}
{% set exporter_policy_name = vmm.vswitch.netflow_exporter_policy ~ defaults.apic.access_policies.interface_policies.netflow_vmm_exporters.name_suffix %}
    Should Be Equal JMESPath Json   ${r}    imdata[0].vmmDomP.children[?vmmVSwitchPolicyCont] | [0].vmmVSwitchPolicyCont.children[?vmmRsVswitchExporterPol] | [0].vmmRsVswitchExporterPol.attributes.tDn   uni/infra/vmmexporterpol-{{ exporter_policy_name }}
{% endif %}
{% if vmm.vlan_pool is defined %}
    Should Be Equal JMESPath Json   ${r}    imdata[0].vmmDomP.children[?infraRsVlanNs] | [0].infraRsVlanNs.attributes.tDn   uni/infra/vlanns-[{{ vmm.vlan_pool }}]-{{ vmm.allocation | default(defaults.apic.fabric_policies.vmware_vmm_domains.allocation) }}
{% endif %}

{% for elag in vmm.vswitch.enhanced_lags | default([]) %}
{% set elag_name = elag.name ~ defaults.apic.fabric_policies.vmware_vmm_domains.vswitch.enhanced_lags.name_suffix %}
Verify VMware VMM Domain {{ vmm_name }} vSwitch Enhanced Lag Policy {{ elag_name }}
   ${cp}=   Set Variable   imdata[0].vmmDomP.children[?vmmVSwitchPolicyCont] | [0].vmmVSwitchPolicyCont.children[?lacpEnhancedLagPol.attributes.name=='{{ elag_name }}'] | [0].lacpEnhancedLagPol
    Should Be Equal JMESPath Json   ${r}    ${cp}.attributes.name   {{ elag_name }}
    Should Be Equal JMESPath Json   ${r}    ${cp}.attributes.lbmode   {{ elag.lb_mode | default(defaults.apic.fabric_policies.vmware_vmm_domains.vswitch.enhanced_lags.lb_mode) }}
    Should Be Equal JMESPath Json   ${r}    ${cp}.attributes.numLinks   {{ elag.num_links | default(defaults.apic.fabric_policies.vmware_vmm_domains.vswitch.enhanced_lags.num_links) }}
    Should Be Equal JMESPath Json   ${r}    ${cp}.attributes.mode   {{ elag.mode | default(defaults.apic.fabric_policies.vmware_vmm_domains.vswitch.enhanced_lags.mode) }}
{% endfor %}

{% for cp in vmm.credential_policies | default([]) %}
{% set policy_name = cp.name ~ defaults.apic.fabric_policies.vmware_vmm_domains.credential_policies.name_suffix %}

Verify VMware VMM Domain {{ vmm_name }} Credential Policy {{ policy_name }}
    ${cp}=   Set Variable   imdata[0].vmmDomP.children[?vmmUsrAccP.attributes.name=='{{ policy_name }}'] | [0].vmmUsrAccP
    Should Be Equal JMESPath Json   ${r}    ${cp}.attributes.name   {{ policy_name }}
    Should Be Equal JMESPath Json   ${r}    ${cp}.attributes.usr   {{ cp.username }}

{% endfor %}

{% for sd in vmm.security_domains | default([]) %}
Verify VMM Domain {{ vmm_name }} Security Domain {{ sd }}
    Should Be Equal JMESPath Json   ${r}   imdata[0].vmmDomP.children[?aaaDomainRef.attributes.name=='{{ sd }}'] | [0].aaaDomainRef.attributes.name   {{ sd }}
{% endfor %}

{% for vc in vmm.vcenters| default([]) %}
{% set vc_name = vc.name ~ defaults.apic.fabric_policies.vmware_vmm_domains.vcenters.name_suffix %}
{% set vc_policy_name = vc.credential_policy ~ defaults.apic.fabric_policies.vmware_vmm_domains.credential_policies.name_suffix %}

Verify VMware VMM Domain {{ vmm_name }} vCenter {{ vc_name }}
    ${cp}=   Set Variable   imdata[0].vmmDomP.children[?vmmCtrlrP.attributes.name=='{{ vc_name }}'] | [0].vmmCtrlrP
    Should Be Equal JMESPath Json   ${r}    ${cp}.attributes.name   {{ vc_name }}
    Should Be Equal JMESPath Json   ${r}    ${cp}.attributes.dvsVersion   {{ vc.dvs_version | default(defaults.apic.fabric_policies.vmware_vmm_domains.vcenters.dvs_version) }}
    Should Be Equal JMESPath Json   ${r}    ${cp}.attributes.hostOrIp   {{ vc.hostname_ip }}
    Should Be Equal JMESPath Json   ${r}    ${cp}.attributes.rootContName   {{ vc.datacenter }}
    Should Be Equal JMESPath Json   ${r}    ${cp}.attributes.statsMode   {{ 'enabled' if vc.statistics | default(defaults.apic.fabric_policies.vmware_vmm_domains.vcenters.statistics) else 'disabled' }}
    Should Be Equal JMESPath Json   ${r}    ${cp}.children[?vmmRsAcc] | [0].vmmRsAcc.attributes.tDn   uni/vmmp-VMware/dom-{{ vmm_name }}/usracc-{{ vc_policy_name }}
{% set mgmt_epg = vc.mgmt_epg | default(defaults.apic.fabric_policies.vmware_vmm_domains.vcenters.mgmt_epg) %}
{% if mgmt_epg == "inb" %}
    Should Be Equal JMESPath Json   ${r}    ${cp}.children[?vmmRsMgmtEPg] | [0].vmmRsMgmtEPg.attributes.tDn   uni/tn-mgmt/mgmtp-default/inb-{{ apic.node_policies.inb_endpoint_group | default(defaults.apic.node_policies.inb_endpoint_group) }}
{% endif %}

{% endfor %}

{% if vmm.uplinks is defined %}
Verify VMware VMM Domain {{ vmm_name }} Number of Uplinks
    ${cp}=   Set Variable   imdata[0].vmmDomP.children[?vmmUplinkPCont.attributes.id=='0'] | [0]
    Should Be Equal JMESPath Json   ${r}    ${cp}.vmmUplinkPCont.attributes.numOfUplinks   {{ vmm.uplinks | length }}
{% for ul in vmm.uplinks | default([]) %}
Verify VMware VMM Domain {{ vmm_name }} Uplink {{ ul.name }}
    ${cp}=   Set Variable   imdata[0].vmmDomP.children[?vmmUplinkPCont.attributes.id=='0'] | [0].vmmUplinkPCont.children[?vmmUplinkP.attributes.uplinkId=='{{ ul.id }}'] | [0].vmmUplinkP
    Should Be Equal JMESPath Json   ${r}    ${cp}.attributes.uplinkId   {{ ul.id }}
    Should Be Equal JMESPath Json   ${r}    ${cp}.attributes.uplinkName   {{ ul.name }}
{% endfor %}
{% endif %}

{% for tpg in vmm.trunk_port_groups | default([]) %}
{% set tpg_name = tpg.name ~ defaults.apic.fabric_policies.vmware_vmm_domains.trunk_port_groups.name_suffix %}
Verify VMware VMM Domain {{ vmm_name }} Trunk Port Group {{ tpg_name }}
    ${cp}=   Set Variable   imdata[0].vmmDomP.children[?vmmUsrAggr.attributes.name=='{{ tpg_name }}'] | [0].vmmUsrAggr
    Should Be Equal JMESPath Json   ${r}    ${cp}.attributes.name   {{ tpg_name }}
    Should Be Equal JMESPath Json   ${r}    ${cp}.attributes.aggrImedcy   {{ tpg.immediacy | default(defaults.apic.fabric_policies.vmware_vmm_domains.trunk_port_groups.immediacy) }}
    Should Be Equal JMESPath Json   ${r}    ${cp}.attributes.forgedTransmit   {{ 'Enabled' if tpg.forged_transmit | default(defaults.apic.fabric_policies.vmware_vmm_domains.trunk_port_groups.forged_transmit) else 'Disabled' }}
    Should Be Equal JMESPath Json   ${r}    ${cp}.attributes.macChange   {{ 'Enabled' if tpg.mac_change | default(defaults.apic.fabric_policies.vmware_vmm_domains.trunk_port_groups.mac_change) else 'Disabled' }}
    Should Be Equal JMESPath Json   ${r}    ${cp}.attributes.promMode   {{ 'Enabled' if tpg.promiscuous_mode | default(defaults.apic.fabric_policies.vmware_vmm_domains.trunk_port_groups.promiscuous_mode) else 'Disabled' }}
{% if tpg.enhanced_lag_policy is defined %}
{% set elag_name = tpg.enhanced_lag_policy ~ defaults.apic.fabric_policies.vmware_vmm_domains.vswitch.enhanced_lags.name_suffix %}
    Should Be Equal JMESPath Json   ${r}    ${cp}.children[?vmmRsUsrAggrLagPolAtt] | [0].vmmRsUsrAggrLagPolAtt.attributes.tDn   uni/vmmp-VMware/dom-{{ vmm_name }}/vswitchpolcont/enlacplagp-{{ elag_name }}
{% endif %}
{% for vlan_range in tpg.vlan_ranges | default([]) %}
Verify VMware VMM Domain {{ vmm_name }} Trunk Port Group {{ tpg_name }} Range From {{ vlan_range.from }} To {{ vlan_range.to | default(vlan_range.from) }}
    ${cp}=   Set Variable   imdata[0].vmmDomP.children[?vmmUsrAggr.attributes.name=='{{ tpg_name }}'] | [0].vmmUsrAggr
    ${range}=   Set Variable   ${cp}.children[?fvnsEncapBlk.attributes.from=='vlan-{{ vlan_range.from }}'] | [0].fvnsEncapBlk
    Should Be Equal JMESPath Json   ${r}    ${range}.attributes.from   vlan-{{ vlan_range.from }}
    Should Be Equal JMESPath Json   ${r}    ${range}.attributes.to   vlan-{{ vlan_range.to }}
{% endfor %}

{% endfor %}

{% endfor %}
