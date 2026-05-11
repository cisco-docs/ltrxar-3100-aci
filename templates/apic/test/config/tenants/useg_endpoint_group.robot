{# iterate_list apic.tenants name item[2] #}
*** Settings ***
Documentation   Verify uSeg Endpoint Group
Suite Setup     Login APIC
Default Tags    apic   day2   config   tenants
Resource        ../../../apic_common.resource

*** Test Cases ***
{%- macro get_nlb_mode(name) -%}
    {%- set modes = {"mode-mcast-static":"mode-mcast--static"} -%}
    {{ modes[name] | default(name)}}
{%- endmacro -%}

{% set tenant = ((apic | default()) | community.general.json_query('tenants[?name==`' ~ item[2] ~ '`]'))[0] %}
{% for ap in tenant.application_profiles | default([]) %}
{% set ap_name = ap.name ~ defaults.apic.tenants.application_profiles.name_suffix %}
{% for epg in ap.useg_endpoint_groups | default([]) %}
{% set epg_name = epg.name ~ defaults.apic.tenants.application_profiles.useg_endpoint_groups.name_suffix %}
{% set bd_name = epg.bridge_domain ~ defaults.apic.tenants.bridge_domains.name_suffix %}

Verify uSeg Endpoint Group {{ epg_name }}
    ${r}=   GET On Session   apic   /api/mo/uni/tn-{{ tenant.name }}/ap-{{ ap_name }}/epg-{{ epg_name }}.json   params=rsp-subtree=full
    Set Suite Variable   $r   ${r.json()}
    Should Be Equal JMESPath Json   ${r}   imdata[0].fvAEPg.attributes.name   {{ epg_name }}
    Should Be Equal JMESPath Json   ${r}   imdata[0].fvAEPg.attributes.descr   {{ epg.description | default() }}
    Should Be Equal JMESPath Json   ${r}   imdata[0].fvAEPg.attributes.nameAlias   {{ epg.alias | default() }}
    Should Be Equal JMESPath Json   ${r}   imdata[0].fvAEPg.attributes.floodOnEncap   {{ 'enabled' if epg.flood_in_encap | default(defaults.apic.tenants.application_profiles.useg_endpoint_groups.flood_in_encap) else 'disabled' }}
    Should Be Equal JMESPath Json   ${r}   imdata[0].fvAEPg.attributes.pcEnfPref   {{ 'enforced' if epg.intra_epg_isolation | default(defaults.apic.tenants.application_profiles.useg_endpoint_groups.intra_epg_isolation) else 'unenforced' }}
    Should Be Equal JMESPath Json   ${r}   imdata[0].fvAEPg.attributes.prefGrMemb   {{ 'include' if epg.preferred_group | default(defaults.apic.tenants.application_profiles.useg_endpoint_groups.preferred_group) else 'exclude' }}
    Should Be Equal JMESPath Json   ${r}   imdata[0].fvAEPg.children[?fvRsBd] | [0].fvRsBd.attributes.tnFvBDName   {{ bd_name }}
    Should Be Equal JMESPath Json   ${r}   imdata[0].fvAEPg.attributes.prio   {{ epg.qos_class | default(defaults.apic.tenants.application_profiles.useg_endpoint_groups.qos_class) }}
    Should Be Equal JMESPath Json   ${r}   imdata[0].fvAEPg.attributes.isAttrBasedEPg   yes

{% for vmm in epg.vmware_vmm_domains | default([]) %}
{% set vmm_name = vmm.name ~ defaults.apic.tenants.application_profiles.useg_endpoint_groups.vmware_vmm_domains.name_suffix %}

Verify uSeg Endpoint Group {{ epg_name }} VMM Domain {{ vmm_name }}
    ${conn}=   Set Variable   imdata[0].fvAEPg.children[?fvRsDomAtt.attributes.tDn=='uni/vmmp-VMware/dom-{{ vmm_name }}'] | [0]

    Should Be Equal JMESPath Json   ${r}   ${conn}.fvRsDomAtt.attributes.instrImedcy   {{ vmm.deployment_immediacy  | default(defaults.apic.tenants.application_profiles.useg_endpoint_groups.vmware_vmm_domains.deployment_immediacy) }}
    Should Be Equal JMESPath Json   ${r}   ${conn}.fvRsDomAtt.attributes.netflowPref   {{ 'enabled' if vmm.netflow | default(defaults.apic.tenants.application_profiles.useg_endpoint_groups.vmware_vmm_domains.netflow) else 'disabled' }}
{% set port_binding_val = vmm.port_binding | default(defaults.apic.tenants.application_profiles.useg_endpoint_groups.vmware_vmm_domains.port_binding) %}
{% set binding_type_map = {'dynamic': 'dynamicBinding', 'ephemeral': 'ephemeral', 'static': 'staticBinding', 'default': 'none'} %}
    Should Be Equal JMESPath Json   ${r}   ${conn}.fvRsDomAtt.attributes.bindingType   {{ binding_type_map[port_binding_val] | default('none') }}
{% if vmm.active_uplinks_order is defined or vmm.standby_uplinks is defined %}
    Should Be Equal JMESPath Json   ${r}   ${conn}.fvRsDomAtt.children[?fvUplinkOrderCont] | [0].fvUplinkOrderCont.attributes.active   {{ vmm.active_uplinks_order | default() }}
    Should Be Equal JMESPath Json   ${r}   ${conn}.fvRsDomAtt.children[?fvUplinkOrderCont] | [0].fvUplinkOrderCont.attributes.standby   {{ vmm.standby_uplinks | default() }}
{% endif %}
{% if vmm.elag is defined %}
    Should Be Equal JMESPath Json   ${r}   ${conn}.fvRsDomAtt.children[?fvAEPgLagPolAtt] | [0].fvAEPgLagPolAtt.children[?fvRsVmmVSwitchEnhancedLagPol] | [0].fvRsVmmVSwitchEnhancedLagPol.attributes.tDn   uni/vmmp-VMware/dom-{{ vmm_name }}/vswitchpolcont/enlacplagp-{{ vmm.elag }}
{% endif %}
{% endfor %}

{% for sl in epg.static_leafs | default([]) %}
{% set query = "nodes[?id==`" ~ sl.node_id ~ "`].pod" %}
{% set pod = sl.pod_id | default(((apic.node_policies | default()) | community.general.json_query(query))[0] | default('1')) %}

Verify uSeg Endpoint Group {{ epg_name }} Static Leaf {{ sl.node_id }}
    ${sl}=   Set Variable   imdata[0].fvAEPg.children[?fvRsNodeAtt.attributes.tDn=='topology/pod-{{ pod }}/node-{{ sl.node_id }}'] | [0]
    Should Be Equal JMESPath Json   ${r}   ${sl}.fvRsNodeAtt.attributes.instrImedcy   immediate
    Should Be Equal JMESPath Json   ${r}   ${sl}.fvRsNodeAtt.attributes.tDn   topology/pod-{{ pod }}/node-{{ sl.node_id }}

{% endfor %}

{% for master in epg.contracts.masters | default([]) %}
    {% set app_profile_name = (master.application_profile | default(ap_name)) %}
Verify EPG Contract Master 'uni/tn-{{ tenant.name }}/ap-{{ app_profile_name }}/epg-{{ master.endpoint_group }}'
    ${con_master}=   Set Variable   imdata[0].fvAEPg.children[?fvRsSecInherited.attributes.tDn=='uni/tn-{{ tenant.name }}/ap-{{ app_profile_name }}/epg-{{ master.endpoint_group }}'] | [0]
    Should Be Equal JMESPath Json   ${r}   ${con_master}.fvRsSecInherited.attributes.tDn   uni/tn-{{ tenant.name }}/ap-{{ app_profile_name }}/epg-{{ master.endpoint_group }}
{% endfor %}

{% for contract in epg.contracts.providers | default([]) %}
{% set contract_name = contract ~ defaults.apic.tenants.contracts.name_suffix %}

Verify uSeg Endpoint Group {{ epg_name }} Contract Provider {{ contract_name }}
    ${con}=   Set Variable   imdata[0].fvAEPg.children[?fvRsProv.attributes.tnVzBrCPName=='{{ contract_name }}'] | [0]
    Should Be Equal JMESPath Json   ${r}   ${con}.fvRsProv.attributes.tnVzBrCPName   {{ contract_name }}

{% endfor %}

{% for contract in epg.contracts.consumers | default([]) %}
{% set contract_name = contract ~ defaults.apic.tenants.contracts.name_suffix %}

Verify uSeg Endpoint Group {{ epg_name }} Contract Consumers {{ contract_name }}
    ${con}=   Set Variable   imdata[0].fvAEPg.children[?fvRsCons.attributes.tnVzBrCPName=='{{ contract_name }}'] | [0]
    Should Be Equal JMESPath Json   ${r}   ${con}.fvRsCons.attributes.tnVzBrCPName   {{ contract_name }}

{% endfor %}

{% for contract in epg.contracts.imported_consumers | default([]) %}
{% set contract_name = contract ~ defaults.apic.tenants.imported_contracts.name_suffix %}

Verify uSeg Endpoint Group {{ epg_name }} Imported Contract {{ contract_name }}
    ${con}=   Set Variable   imdata[0].fvAEPg.children[?fvRsConsIf.attributes.tnVzCPIfName=='{{ contract_name }}'] | [0]
    Should Be Equal JMESPath Json   ${r}   ${con}.fvRsConsIf.attributes.tnVzCPIfName   {{ contract_name }}

{% endfor %}

{% for contract in epg.contracts.intra_epgs | default([]) %}
{% set contract_name = contract ~ defaults.apic.tenants.contracts.name_suffix %}

Verify uSeg Endpoint Group {{ epg_name }} Intra-EPG Contract {{ contract_name }}
    ${con}=   Set Variable   imdata[0].fvAEPg.children[?fvRsIntraEpg.attributes.tnVzBrCPName=='{{ contract_name }}'] | [0]
    Should Be Equal JMESPath Json   ${r}   ${con}.fvRsIntraEpg.attributes.tnVzBrCPName   {{ contract_name }}

{% endfor %}

{% for pd in epg.physical_domains | default([]) %}
{% set domain_name = pd ~ defaults.apic.access_policies.physical_domains.name_suffix %}

Verify Endpoint Group {{ epg_name }} Physical Domain {{ domain_name }}
    ${conn}=   Set Variable   imdata[0].fvAEPg.children[?fvRsDomAtt.attributes.tDn=='uni/phys-{{ domain_name }}'] | [0]
    Should Be Equal JMESPath Json   ${r}   ${conn}.fvRsDomAtt.attributes.tDn   uni/phys-{{ domain_name }}

{% endfor %}

Verify uSeg Endpoint Group {{ epg_name }} uSeg Attributes
    Should Be Equal JMESPath Json   ${r}   imdata[0].fvAEPg.children[?fvCrtrn] | [0].fvCrtrn.attributes.match   {{ epg.useg_attributes.match_type | default(defaults.apic.tenants.application_profiles.useg_endpoint_groups.useg_attributes.match_type) }}

{% for ip_statement in epg.useg_attributes.ip_statements | default([]) %}
Verify uSeg Endpoint Group {{ epg_name }} uSeg Attributes IP Statement {{ ip_statement.name }}
    ${statement}=   Set Variable   imdata[0].fvAEPg.children[?fvCrtrn] | [0].fvCrtrn.children[?fvIpAttr.attributes.name=='{{ ip_statement.name }}'] | [0]
    Should Be Equal JMESPath Json   ${r}   ${statement}.fvIpAttr.attributes.name   {{ ip_statement.name }}
    Should Be Equal JMESPath Json   ${r}   ${statement}.fvIpAttr.attributes.usefvSubnet   {{ 'yes' if ip_statement.use_epg_subnet | default(defaults.apic.tenants.application_profiles.useg_endpoint_groups.useg_attributes.ip_statements.use_epg_subnet) else 'no' }}
    Should Be Equal JMESPath Json   ${r}   ${statement}.fvIpAttr.attributes.ip   {{ '0.0.0.0' if ip_statement.use_epg_subnet | default(defaults.apic.tenants.application_profiles.useg_endpoint_groups.useg_attributes.ip_statements.use_epg_subnet) else ip_statement.ip }}

{% endfor %}

{% for mac_statement in epg.useg_attributes.mac_statements | default([]) %}
Verify uSeg Endpoint Group {{ epg_name }} uSeg Attributes MAC Statement {{ mac_statement.name }}
    ${statement}=   Set Variable   imdata[0].fvAEPg.children[?fvCrtrn] | [0].fvCrtrn.children[?fvMacAttr.attributes.name=='{{ mac_statement.name }}'] | [0]
    Should Be Equal JMESPath Json   ${r}   ${statement}.fvMacAttr.attributes.name   {{ mac_statement.name }}
    Should Be Equal JMESPath Json   ${r}   ${statement}.fvMacAttr.attributes.mac   {{ mac_statement.mac | upper }}

{% endfor %}

{% for vm_statement in epg.useg_attributes.vm_statements | default([]) %}
Verify uSeg Endpoint Group {{ epg_name }} uSeg Attributes VM Statement {{ vm_statement.name }}
    ${statement}=   Set Variable   imdata[0].fvAEPg.children[?fvCrtrn] | [0].fvCrtrn.children[?fvVmAttr.attributes.name=='{{ vm_statement.name }}'] | [0]
    Should Be Equal JMESPath Json   ${r}   ${statement}.fvVmAttr.attributes.name   {{ vm_statement.name }}
    Should Be Equal JMESPath Json   ${r}   ${statement}.fvVmAttr.attributes.type   {{ vm_statement.type | default(defaults.apic.tenants.application_profiles.useg_endpoint_groups.useg_attributes.vm_statements.type) }}
    Should Be Equal JMESPath Json   ${r}   ${statement}.fvVmAttr.attributes.operator   {{ vm_statement.operator | default(defaults.apic.tenants.application_profiles.useg_endpoint_groups.useg_attributes.vm_statements.operator) }}
    Should Be Equal JMESPath Json   ${r}   ${statement}.fvVmAttr.attributes.value   {{ vm_statement.value }}
    Should Be Equal JMESPath Json   ${r}   ${statement}.fvVmAttr.attributes.category   {{ vm_statement.category | default() }}
    Should Be Equal JMESPath Json   ${r}   ${statement}.fvVmAttr.attributes.labelName   {{ vm_statement.label | default() }}

{% endfor %}

{% for subnet in epg.subnets | default([]) %}
{% set scope = [] %}
{% if subnet.public | default(defaults.apic.tenants.application_profiles.useg_endpoint_groups.subnets.public) %}{% set scope = scope + [("public")] %}{% else %}{% set scope = scope + [("private")] %}{% endif %}
{% if subnet.shared | default(defaults.apic.tenants.application_profiles.useg_endpoint_groups.subnets.shared) %}{% set scope = scope + [("shared")] %}{% endif %}
{% set ctrl = [] %}
{% if subnet.nd_ra_prefix | default(defaults.apic.tenants.application_profiles.useg_endpoint_groups.subnets.nd_ra_prefix) %}{% set ctrl = ctrl + [("nd")] %}{% endif %}
{% if subnet.no_default_gateway | default(defaults.apic.tenants.application_profiles.useg_endpoint_groups.subnets.no_default_gateway) %}{% set ctrl = ctrl + [("no-default-gateway")] %}{% endif %}
{% if subnet.igmp_querier | default(defaults.apic.tenants.application_profiles.useg_endpoint_groups.subnets.igmp_querier) %}{% set ctrl = ctrl + [("querier")] %}{% endif %}
Verify uSeg Endpoint Group {{ epg_name }} Subnet {{ subnet.ip }}
    ${subnet}=   Set Variable   imdata[0].fvAEPg.children[?fvSubnet.attributes.ip=='{{ subnet.ip }}'] | [0]
    Should Be Equal JMESPath Json   ${r}   ${subnet}.fvSubnet.attributes.ip   {{ subnet.ip }}
    Should Be Equal JMESPath Json   ${r}   ${subnet}.fvSubnet.attributes.ctrl   {{ ctrl | join(',') }}
    Should Be Equal JMESPath Json   ${r}   ${subnet}.fvSubnet.attributes.descr   {{ subnet.description | default() }}
    Should Be Equal JMESPath Json   ${r}   ${subnet}.fvSubnet.attributes.scope   {{ scope | join(',') }}
    Should Be Equal JMESPath Json   ${r}   ${subnet}.fvSubnet.attributes.virtual   {{ 'yes' if subnet.virtual | default(defaults.apic.tenants.application_profiles.useg_endpoint_groups.subnets.virtual) else 'no' }}
{% if subnet.next_hop_ip is defined %}
    Should Be Equal JMESPath Json   ${r}   ${subnet}.fvSubnet.children[?fvEpReachability] | [0].fvEpReachability.children[?ipNexthopEpP] | [0].ipNexthopEpP.attributes.nhAddr   {{ subnet.next_hop_ip }}
{% elif subnet.anycast_mac is defined %}
    Should Be Equal JMESPath Json   ${r}   ${subnet}.fvSubnet.children[?fvEpAnycast] | [0].fvEpAnycast.attributes.mac   {{ subnet.anycast_mac }}
{% elif subnet.nlb_mode is defined %}
    Should Be Equal JMESPath Json   ${r}   ${subnet}.fvSubnet.children[?fvEpNlb] | [0].fvEpNlb.attributes.group   {{ subnet.nlb_group | default(defaults.apic.tenants.application_profiles.useg_endpoint_groups.subnets.nlb_group) }}
    Should Be Equal JMESPath Json   ${r}   ${subnet}.fvSubnet.children[?fvEpNlb] | [0].fvEpNlb.attributes.mac   {{ subnet.nlb_mac | default(defaults.apic.tenants.application_profiles.useg_endpoint_groups.subnets.nlb_mac) }}
    Should Be Equal JMESPath Json   ${r}   ${subnet}.fvSubnet.children[?fvEpNlb] | [0].fvEpNlb.attributes.mode   {{ get_nlb_mode(subnet.nlb_mode) }}
{% endif %}
{% if subnet.nd_ra_prefix_policy is defined %}
{% set nd_ra_prefix_policy_name = subnet.nd_ra_prefix_policy ~ defaults.apic.tenants.policies.nd_ra_prefix_policies.name_suffix %}
    Should Be Equal JMESPath Json   ${r}   imdata[0].fvAEPg.children[?fvSubnet.attributes.ip=='{{ subnet.ip }}'] | [0].fvSubnet.children[?fvRsNdPfxPol] | [0].fvRsNdPfxPol.attributes.tnNdPfxPolName   {{ nd_ra_prefix_policy_name }}
{% endif %}

{% for pool in subnet.ip_pools | default([]) %}
{% set pool_name = pool.name ~ defaults.apic.tenants.application_profiles.useg_endpoint_groups.subnets.ip_pools.name_suffix %}
Verify uSeg Endpoint Group {{ epg_name }} Subnet {{ subnet.ip }} IP Address Pool {{ pool_name }}
    ${subnet}=   Set Variable   imdata[0].fvAEPg.children[?fvSubnet.attributes.ip=='{{ subnet.ip }}'] | [0].fvSubnet
    ${pool}=   Set Variable   ${subnet}.children[?fvCepNetCfgPol.attributes.name=='{{ pool_name }}'] | [0]
    Should Be Equal JMESPath Json   ${r}   ${pool}.fvCepNetCfgPol.attributes.name   {{ pool_name }}
    Should Be Equal JMESPath Json   ${r}   ${pool}.fvCepNetCfgPol.attributes.startIp   {{ pool.start_ip | default(defaults.apic.tenants.application_profiles.useg_endpoint_groups.subnets.ip_pools.start_ip) }}
    Should Be Equal JMESPath Json   ${r}   ${pool}.fvCepNetCfgPol.attributes.endIp   {{ pool.end_ip | default(defaults.apic.tenants.application_profiles.useg_endpoint_groups.subnets.ip_pools.end_ip) }}
    Should Be Equal JMESPath Json   ${r}   ${pool}.fvCepNetCfgPol.attributes.dnsSearchSuffix   {{ pool.dns_search_suffix | default() }}
    Should Be Equal JMESPath Json   ${r}   ${pool}.fvCepNetCfgPol.attributes.dnsServers   {{ pool.dns_server | default() }}
    Should Be Equal JMESPath Json   ${r}   ${pool}.fvCepNetCfgPol.attributes.dnsSuffix   {{ pool.dns_suffix | default() }}
    Should Be Equal JMESPath Json   ${r}   ${pool}.fvCepNetCfgPol.attributes.winsServers   {{ pool.wins_server | default() }}

{% endfor %}

{% endfor %}

{% if epg.custom_qos_policy is defined %}
{% set custom_qos_policy_name = epg.custom_qos_policy ~ defaults.apic.tenants.policies.custom_qos.name_suffix %}
Verify Endpoint Group {{ epg_name }} Custom QoS Policy
    Should Be Equal JMESPath Json   ${r}   imdata[0].fvAEPg.children[?fvRsCustQosPol] | [0].fvRsCustQosPol.attributes.tnQosCustomPolName   {{ custom_qos_policy_name }}
{% endif %}

{% if epg.tags is defined %}
Verify uSeg Endpoint Group {{ epg_name }} Tags
{% for tag in epg.tags | default([]) %}

    ${tag}=   Set Variable   imdata[0].fvAEPg.children[?tagInst.attributes.name=='{{ tag }}'] | [0]
    Should Be Equal JMESPath Json   ${r}   ${tag}.tagInst.attributes.name   {{ tag }}

{% endfor %}

{% endif %}

{% for pool in epg.l4l7_address_pools | default([]) %}
Verify uSeg Endpoint Group {{ epg_name }} L4-L7 IP Address Pool {{ pool.name }}
    ${pool}=   Set Variable   imdata[0].fvAEPg.children[?vnsAddrInst.attributes.name=='{{ pool.name }}'] | [0]
    Should Be Equal JMESPath Json   ${r}   ${pool}.vnsAddrInst.attributes.name   {{ pool.name }}
    Should Be Equal JMESPath Json   ${r}   ${pool}.vnsAddrInst.attributes.addr   {{ pool.gateway_address }}
{% if pool.from is defined and pool.to is defined %}
    Should Be Equal JMESPath Json   ${r}   ${pool}.vnsAddrInst.children[?fvnsUcastAddrBlk] | [0].fvnsUcastAddrBlk.attributes.from   {{ pool.from }}
    Should Be Equal JMESPath Json   ${r}   ${pool}.vnsAddrInst.children[?fvnsUcastAddrBlk] | [0].fvnsUcastAddrBlk.attributes.to   {{ pool.to }}
{% endif %}

{% endfor %}

{% if epg.trust_control_policy is defined %}
{% set trust_control_policy_name = epg.trust_control_policy ~ defaults.apic.tenants.policies.trust_control_policies.name_suffix %}
Verify Endpoint Group {{ epg_name }} Trust Control Policy {{ trust_control_policy_name }}
    Should Be Equal JMESPath Json   ${r}   imdata[0].fvAEPg.children[?fvRsTrustCtrl] | [0].fvRsTrustCtrl.attributes.tnFhsTrustCtrlPolName   {{ trust_control_policy_name }}
{% endif %}

{% endfor %}

{% endfor %}
