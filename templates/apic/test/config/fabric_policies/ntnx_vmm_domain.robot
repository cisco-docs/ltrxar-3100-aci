*** Settings ***
Documentation   Verify Nutanix VMM Domain
Suite Setup     Login APIC
Default Tags    apic   day1   config   fabric_policies
Resource        ../../apic_common.resource

*** Test Cases ***
{% for vmm in apic.fabric_policies.nutanix_vmm_domains | default([]) %}
{% set vmm_name = vmm.name ~ defaults.apic.fabric_policies.nutanix_vmm_domains.name_suffix %}

Verify Nutanix VMM Domain {{ vmm_name }}
    ${r}=   GET On Session   apic   /api/mo/uni/vmmp-Nutanix/dom-{{ vmm_name }}.json   params=rsp-subtree=full
    Set Suite Variable   ${r}   ${r.json()}
    Should Be Equal JMESPath Json   ${r}    imdata[0].vmmDomP.attributes.name   {{ vmm_name }}
    Should Be Equal JMESPath Json   ${r}    imdata[0].vmmDomP.attributes.accessMode   {{ vmm.access_mode | default(defaults.apic.fabric_policies.nutanix_vmm_domains.access_mode) }}
{% if vmm.custom_vswitch_name is defined %}
    Should Be Equal JMESPath Json   ${r}    imdata[0].vmmDomP.attributes.customSwitchName   {{ vmm.custom_vswitch_name | default() }}
{% endif %}
{% if vmm.vlan_pool is defined %}
    Should Be Equal JMESPath Json   ${r}    imdata[0].vmmDomP.children[?infraRsVlanNs] | [0].infraRsVlanNs.attributes.tDn   uni/infra/vlanns-[{{ vmm.vlan_pool }}]-{{ vmm.allocation | default(defaults.apic.fabric_policies.nutanix_vmm_domains.allocation) }}
{% endif %}

{% for cp in vmm.credential_policies | default([]) %}
{% set policy_name = cp.name ~ defaults.apic.fabric_policies.nutanix_vmm_domains.credential_policies.name_suffix %}
Verify Nutanix VMM Domain {{ vmm_name }} Credential Policy {{ policy_name }}
    ${cp}=   Set Variable   imdata[0].vmmDomP.children[?vmmUsrAccP.attributes.name=='{{ policy_name }}'] | [0]
    Should Be Equal JMESPath Json   ${r}    ${cp}.vmmUsrAccP.attributes.name   {{ policy_name }}
    Should Be Equal JMESPath Json   ${r}    ${cp}.vmmUsrAccP.attributes.usr   {{ cp.username }}
{% endfor %}

{% for sd in vmm.security_domains | default([]) %}
Verify Nutanix VMM Domain {{ vmm_name }} Security Domain {{ sd }}
    Should Be Equal JMESPath Json   ${r}   imdata[0].vmmDomP.children[?aaaDomainRef.attributes.name=='{{ sd }}'] | [0].aaaDomainRef.attributes.name   {{ sd }}
{% endfor %}

{% if vmm.controller_profile.name is defined %}
{% set controller_profile_name = vmm.controller_profile.name ~ defaults.apic.fabric_policies.nutanix_vmm_domains.controller_profile.name_suffix %}
Verify Nutanix VMM Domain {{ vmm_name }} Controller Profile {{ controller_profile_name }}
    ${cp}=   Set Variable   imdata[0].vmmDomP.children[?vmmCtrlrP.attributes.name=='{{ controller_profile_name }}'] | [0]
    Should Be Equal JMESPath Json   ${r}    ${cp}.vmmCtrlrP.attributes.name   {{ controller_profile_name }}
    Should Be Equal JMESPath Json   ${r}    ${cp}.vmmCtrlrP.attributes.aosVersion   {{ vmm.controller_profile.aos_version | default(defaults.apic.fabric_policies.nutanix_vmm_domains.controller_profile.aos_version) }}
    Should Be Equal JMESPath Json   ${r}    ${cp}.vmmCtrlrP.attributes.hostOrIp   {{ vmm.controller_profile.hostname_ip }}
    Should Be Equal JMESPath Json   ${r}    ${cp}.vmmCtrlrP.attributes.rootContName   {{ vmm.controller_profile.datacenter }}
    Should Be Equal JMESPath Json   ${r}    ${cp}.vmmCtrlrP.attributes.statsMode   {{ 'enabled' if vmm.controller_profile.statistics | default(defaults.apic.fabric_policies.nutanix_vmm_domains.controller_profile.statistics) else 'disabled' }}
{% set ctrl_policy_name = vmm.controller_profile.credentials ~ defaults.apic.fabric_policies.nutanix_vmm_domains.credential_policies.name_suffix %}
    Should Be Equal JMESPath Json   ${r}    ${cp}.vmmCtrlrP.children[?vmmRsAcc] | [0].vmmRsAcc.attributes.tDn   uni/vmmp-Nutanix/dom-{{ vmm_name }}/usracc-{{ ctrl_policy_name }}

{% if vmm.controller_profile.cluster_controller is defined %}
{% set cluster_controller_name = vmm.controller_profile.cluster_controller.name ~ defaults.apic.fabric_policies.nutanix_vmm_domains.controller_profile.name_suffix %}
Verify Nutanix VMM Domain {{ vmm_name }} Cluster Controller {{ cluster_controller_name }}
    ${cp}=   Set Variable   imdata[0].vmmDomP.children[?vmmCtrlrP.attributes.name=='{{ controller_profile_name }}'] | [0].vmmCtrlrP
    Should Be Equal JMESPath Json   ${r}    ${cp}.children[?vmmClusterCtrlrP] | [0].vmmClusterCtrlrP.attributes.name   {{ cluster_controller_name }}
    Should Be Equal JMESPath Json   ${r}    ${cp}.children[?vmmClusterCtrlrP] | [0].vmmClusterCtrlrP.attributes.hostOrIp   {{ vmm.controller_profile.cluster_controller.hostname_ip }}
    Should Be Equal JMESPath Json   ${r}    ${cp}.children[?vmmClusterCtrlrP] | [0].vmmClusterCtrlrP.attributes.port   {{ vmm.controller_profile.cluster_controller.port | default(defaults.apic.fabric_policies.nutanix_vmm_domains.controller_profile.cluster_controller.port) }}
    Should Be Equal JMESPath Json   ${r}    ${cp}.children[?vmmClusterCtrlrP] | [0].vmmClusterCtrlrP.attributes.rootContName   {{ vmm.controller_profile.cluster_controller.cluster_name }}
{% set ctrl_policy_name = vmm.controller_profile.cluster_controller.credentials ~ defaults.apic.fabric_policies.nutanix_vmm_domains.credential_policies.name_suffix %}
    Should Be Equal JMESPath Json   ${r}    ${cp}.children[?vmmClusterCtrlrP] | [0].vmmClusterCtrlrP.children[?vmmRsClusterAcc] | [0].vmmRsClusterAcc.attributes.tDn   uni/vmmp-Nutanix/dom-{{ vmm_name }}/usracc-{{ ctrl_policy_name }}
{% endif %}
{% endif %}
{% endfor %}
