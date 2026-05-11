{# iterate_list apic.tenants name item[2] #}
*** Settings ***
Documentation   Verify VXLAN L3out
Suite Setup     Login APIC
Default Tags    apic   day2   config   tenants
Resource        ../../../apic_common.resource

*** Test Cases ***
{% set tenant = ((apic | default()) | community.general.json_query('tenants[?name==`' ~ item[2] ~ '`]'))[0] %}
{% if tenant.name == "infra" %}
{% for l3out in tenant.vxlan_l3outs | default([]) %}
{% set l3out_name = l3out.name ~ defaults.apic.tenants.vxlan_l3outs.name_suffix %}

Verify VXLAN L3out {{ l3out_name }}
    ${r}=   GET On Session   apic   /api/mo/uni/tn-{{ tenant.name }}/out-{{ l3out_name }}.json   params=rsp-subtree=full&rsp-prop-include=config-only
    Set Suite Variable   $r   ${r.json()}
    Should Be Equal JMESPath Json   ${r}   imdata[0].l3extOut.attributes.name   {{ l3out_name }}
    Should Be Equal JMESPath Json   ${r}   imdata[0].l3extOut.attributes.nameAlias   {{ l3out.alias | default() }}
    Should Be Equal JMESPath Json   ${r}   imdata[0].l3extOut.attributes.descr   {{ l3out.description | default() }}

Verify VXLAN L3out {{ l3out_name }} VXLAN External Profile
    Should Be Equal JMESPath Json   ${r}   length(imdata[0].l3extOut.children[?vxlanExtP])   1

Verify VXLAN L3out {{ l3out_name }} Border Gateway Set Policy
    Should Be Equal JMESPath Json   ${r}   imdata[0].l3extOut.children[?l3extRsProvBgwSet] | [0].l3extRsProvBgwSet.attributes.tDn   uni/tn-infra/vxlanbgwset-{{ l3out.border_gateway_set_policy ~ defaults.apic.tenants.policies.border_gateway_set_policy.name_suffix }}

Verify VXLAN L3out {{ l3out_name }} BGP External Profile
    Should Be Equal JMESPath Json   ${r}   length(imdata[0].l3extOut.children[?bgpExtP])   1

Verify VXLAN L3out {{ l3out_name }} VRF Relation
    Should Be Equal JMESPath Json   ${r}   imdata[0].l3extOut.children[?l3extRsEctx] | [0].l3extRsEctx.attributes.tnFvCtxName   overlay-1

Verify VXLAN L3out {{ l3out_name }} Instance Profile
    Should Be Equal JMESPath Json   ${r}   imdata[0].l3extOut.children[?l3extInstP] | [0].l3extInstP.attributes.name   {{ l3out_name }}_vxlanInstP

{% for np in l3out.node_profiles | default([]) %}
{% set l3out_np_name = np.name ~ defaults.apic.tenants.vxlan_l3outs.node_profiles.name_suffix %}

Verify VXLAN L3out {{ l3out_name }} Node Profile {{ l3out_np_name }}
    ${nodeprof}=   Set Variable   imdata[0].l3extOut.children[?l3extLNodeP.attributes.name=='{{ l3out_np_name }}'] | [0].l3extLNodeP
    Should Be Equal JMESPath Json   ${r}   ${nodeprof}.attributes.name   {{ l3out_np_name }}
{% if np.vxlan_custom_qos_policy is defined %}
    ${nodeprof}=   Set Variable   imdata[0].l3extOut.children[?l3extLNodeP.attributes.name=='{{ l3out_np_name }}'] | [0].l3extLNodeP
    Should Be Equal JMESPath Json   ${r}   ${nodeprof}.children[?l3extRsLNodePVxlanCustQosPol] | [0].l3extRsLNodePVxlanCustQosPol.attributes.tDn   uni/tn-infra/qosvxlancustom-{{ np.vxlan_custom_qos_policy }}
{% endif %}

{% for node in np.nodes | default([]) %}
{% set query = "nodes[?id==`" ~ node.node_id ~ "`].pod" %}
{% set pod = node.pod_id | default(((apic.node_policies | default()) | community.general.json_query(query))[0] | default('1')) %}

Verify VXLAN L3out {{ l3out_name }} Node Profile {{ l3out_np_name }} Node {{ node.node_id }}
    ${nodeprof}=   Set Variable   imdata[0].l3extOut.children[?l3extLNodeP.attributes.name=='{{ l3out_np_name }}'] | [0].l3extLNodeP
    ${nodeatt}=   Set Variable   ${nodeprof}.children[?l3extRsNodeL3OutAtt.attributes.tDn=='topology/pod-{{ pod | default(defaults.apic.tenants.vxlan_l3outs.node_profiles.nodes.pod) }}/node-{{ node.node_id }}'] | [0].l3extRsNodeL3OutAtt
    Should Be Equal JMESPath Json   ${r}   ${nodeatt}.attributes.tDn   topology/pod-{{ pod | default(defaults.apic.tenants.vxlan_l3outs.node_profiles.nodes.pod) }}/node-{{ node.node_id }}
    Should Be Equal JMESPath Json   ${r}   ${nodeatt}.attributes.rtrId   {{ node.router_id | default('0.0.0.0') }}
    Should Be Equal JMESPath Json   ${r}   ${nodeatt}.attributes.rtrIdLoopBack   no

Verify VXLAN L3out {{ l3out_name }} Node Profile {{ l3out_np_name }} Node {{ node.node_id }} Loopback
    ${nodeprof}=   Set Variable   imdata[0].l3extOut.children[?l3extLNodeP.attributes.name=='{{ l3out_np_name }}'] | [0].l3extLNodeP
    ${nodeatt}=   Set Variable   ${nodeprof}.children[?l3extRsNodeL3OutAtt.attributes.tDn=='topology/pod-{{ pod | default(defaults.apic.tenants.vxlan_l3outs.node_profiles.nodes.pod) }}/node-{{ node.node_id }}'] | [0].l3extRsNodeL3OutAtt
    Should Be Equal JMESPath Json   ${r}   ${nodeatt}.children[?l3extLoopBackIfP] | [0].l3extLoopBackIfP.attributes.addr   {{ node.loopback }}
{% endfor %}

{% for ip in np.interface_profiles | default([]) %}
{% set l3out_ip_name = ip.name ~ defaults.apic.tenants.vxlan_l3outs.node_profiles.interface_profiles.name_suffix %}

Verify VXLAN L3out {{ l3out_name }} Node Profile {{ l3out_np_name }} Interface Profile {{ l3out_ip_name }}
    ${nodeprof}=   Set Variable   imdata[0].l3extOut.children[?l3extLNodeP.attributes.name=='{{ l3out_np_name }}'] | [0].l3extLNodeP
    ${intprof}=   Set Variable   ${nodeprof}.children[?l3extLIfP.attributes.name=='{{ l3out_ip_name }}'] | [0].l3extLIfP
    Should Be Equal JMESPath Json   ${r}   ${intprof}.attributes.name   {{ l3out_ip_name }}
    Should Be Equal JMESPath Json   ${r}   ${intprof}.attributes.descr   {{ ip.description | default() }}

{% if ip.bfd_policy is defined %}
{% set bfd_name = ip.bfd_policy ~ defaults.apic.tenants.policies.bfd_interface_policies.name_suffix %}
Verify VXLAN L3out {{ l3out_name }} Interface Profile {{ l3out_ip_name }} BFD Policy
    ${nodeprof}=   Set Variable   imdata[0].l3extOut.children[?l3extLNodeP.attributes.name=='{{ l3out_np_name }}'] | [0].l3extLNodeP
    ${intprof}=   Set Variable   ${nodeprof}.children[?l3extLIfP.attributes.name=='{{ l3out_ip_name }}'] | [0].l3extLIfP
    Should Be Equal JMESPath Json   ${r}   ${intprof}.children[?bfdIfP] | [0].bfdIfP.attributes.type   none
    Should Be Equal JMESPath Json   ${r}   ${intprof}.children[?bfdIfP] | [0].bfdIfP.children[?bfdRsIfPol] | [0].bfdRsIfPol.attributes.tnBfdIfPolName   {{ bfd_name }}
{% endif %}

{% for int in ip.interfaces | default([]) %}
{% if int.port is defined %}
    {% set type = 'ap' %}
    {% set query = "nodes[?id==`" ~ int.node_id ~ "`].pod" %}
    {% set pod = int.pod_id | default(((apic.node_policies | default()) | community.general.json_query(query))[0] | default('1')) %}
{% else %}
    {% set policy_group_name = int.channel ~ defaults.apic.access_policies.leaf_interface_policy_groups.name_suffix %}
    {% set query = "leaf_interface_policy_groups[?name==`" ~ int.channel ~ "`].type" %}
    {% set type = (apic.access_policies | community.general.json_query(query))[0] %}
    {% if int.node_id is defined %}
        {% set node = int.node_id %}
    {% else %}
        {% set query = "nodes[?interfaces[?policy_group==`" ~ int.channel ~ "`]].id" %}
        {% set node = (apic.interface_policies | default() | community.general.json_query(query))[0] %}
    {% endif %}
    {% set query = "nodes[?id==`" ~ node ~ "`].pod" %}
    {% set pod = int.pod_id | default(((apic.node_policies | default()) | community.general.json_query(query))[0] | default('1')) %}
{% endif %}

Verify VXLAN L3out {{ l3out_name }} Interface Profile {{ l3out_ip_name }} Interface {{ int.ip }}
    ${nodeprof}=   Set Variable   imdata[0].l3extOut.children[?l3extLNodeP.attributes.name=='{{ l3out_np_name }}'] | [0].l3extLNodeP
    ${intprof}=   Set Variable   ${nodeprof}.children[?l3extLIfP.attributes.name=='{{ l3out_ip_name }}'] | [0].l3extLIfP
    ${intatt}=   Set Variable   ${intprof}.children[?l3extRsPathL3OutAtt.attributes.addr=='{{ int.ip }}'] | [0].l3extRsPathL3OutAtt
    Should Be Equal JMESPath Json   ${r}   ${intatt}.attributes.addr   {{ int.ip }}
    Should Be Equal JMESPath Json   ${r}   ${intatt}.attributes.autostate   disabled
    Should Be Equal JMESPath Json   ${r}   ${intatt}.attributes.descr   {{ int.description | default() }}
    Should Be Equal JMESPath Json   ${r}   ${intatt}.attributes.encapScope   local
    {% if int.vlan is defined %}
    Should Be Equal JMESPath Json   ${r}   ${intatt}.attributes.ifInstT   sub-interface
    Should Be Equal JMESPath Json   ${r}   ${intatt}.attributes.encap   vlan-{{ int.vlan }}
    {% else %}
    Should Be Equal JMESPath Json   ${r}   ${intatt}.attributes.ifInstT   l3-port
    {% endif %}
    Should Be Equal JMESPath Json   ${r}   ${intatt}.attributes.ipv6Dad   enabled
    Should Be Equal JMESPath Json   ${r}   ${intatt}.attributes.llAddr   ::
    Should Be Equal JMESPath Json   ${r}   ${intatt}.attributes.mac   {{ int.mac | default(defaults.apic.tenants.vxlan_l3outs.node_profiles.interface_profiles.interfaces.mac) }}
    Should Be Equal JMESPath Json   ${r}   ${intatt}.attributes.mode   regular
    Should Be Equal JMESPath Json   ${r}   ${intatt}.attributes.mtu   {{ int.mtu | default(defaults.apic.tenants.vxlan_l3outs.node_profiles.interface_profiles.interfaces.mtu) }}
    {% if type == 'ap' %}
    Should Be Equal JMESPath Json   ${r}   ${intatt}.attributes.tDn   topology/pod-{{ pod | default(defaults.apic.tenants.vxlan_l3outs.node_profiles.interface_profiles.interfaces.pod) }}/paths-{{ int.node_id }}/pathep-[eth{{ int.module | default(defaults.apic.tenants.vxlan_l3outs.node_profiles.interface_profiles.interfaces.module) }}/{{ int.port }}]
    {% elif type == 'pc' %}
    Should Be Equal JMESPath Json   ${r}   ${intatt}.attributes.tDn   topology/pod-{{ pod | default(defaults.apic.tenants.vxlan_l3outs.node_profiles.interface_profiles.interfaces.pod) }}/paths-{{ node }}/pathep-[{{ policy_group_name }}]
    {% endif %}

{% for peer in int.bgp_peers | default([]) %}
{% set peer_ctrl = [] %}
{% if peer.bfd | default(defaults.apic.tenants.vxlan_l3outs.node_profiles.interface_profiles.interfaces.bgp_peers.bfd) %}{% set peer_ctrl = peer_ctrl + [("bfd")] %}{% endif %}

Verify VXLAN L3out {{ l3out_name }} Interface {{ int.ip }} BGP Peer {{ peer.ip }}
    ${nodeprof}=   Set Variable   imdata[0].l3extOut.children[?l3extLNodeP.attributes.name=='{{ l3out_np_name }}'] | [0].l3extLNodeP
    ${intprof}=   Set Variable   ${nodeprof}.children[?l3extLIfP.attributes.name=='{{ l3out_ip_name }}'] | [0].l3extLIfP
    ${intatt}=   Set Variable   ${intprof}.children[?l3extRsPathL3OutAtt.attributes.addr=='{{ int.ip }}'] | [0].l3extRsPathL3OutAtt
    ${bgppeer}=   Set Variable   ${intatt}.children[?bgpPeerP.attributes.addr=='{{ peer.ip }}'] | [0].bgpPeerP
    Should Be Equal JMESPath Json   ${r}   ${bgppeer}.attributes.addr   {{ peer.ip }}
    Should Be Equal JMESPath Json   ${r}   ${bgppeer}.attributes.addrTCtrl   af-ucast
    Should Be Equal JMESPath Json   ${r}   ${bgppeer}.attributes.adminSt   {{ 'enabled' if peer.admin_state | default(defaults.apic.tenants.vxlan_l3outs.node_profiles.interface_profiles.interfaces.bgp_peers.admin_state) else 'disabled' }}
    Should Be Equal JMESPath Json   ${r}   ${bgppeer}.attributes.descr   {{ peer.description | default() }}
    Should Be Equal JMESPath Json   ${r}   ${bgppeer}.attributes.peerCtrl   {{ peer_ctrl | join(',') }}

Verify VXLAN L3out {{ l3out_name }} BGP Peer {{ peer.ip }} AS Policy
    ${nodeprof}=   Set Variable   imdata[0].l3extOut.children[?l3extLNodeP.attributes.name=='{{ l3out_np_name }}'] | [0].l3extLNodeP
    ${intprof}=   Set Variable   ${nodeprof}.children[?l3extLIfP.attributes.name=='{{ l3out_ip_name }}'] | [0].l3extLIfP
    ${intatt}=   Set Variable   ${intprof}.children[?l3extRsPathL3OutAtt.attributes.addr=='{{ int.ip }}'] | [0].l3extRsPathL3OutAtt
    ${bgppeer}=   Set Variable   ${intatt}.children[?bgpPeerP.attributes.addr=='{{ peer.ip }}'] | [0].bgpPeerP
    Should Be Equal JMESPath Json   ${r}   ${bgppeer}.children[?bgpAsP] | [0].bgpAsP.attributes.asn   {{ peer.remote_as }}

{% if peer.local_as is defined %}
Verify VXLAN L3out {{ l3out_name }} BGP Peer {{ peer.ip }} Local ASN Policy
    ${nodeprof}=   Set Variable   imdata[0].l3extOut.children[?l3extLNodeP.attributes.name=='{{ l3out_np_name }}'] | [0].l3extLNodeP
    ${intprof}=   Set Variable   ${nodeprof}.children[?l3extLIfP.attributes.name=='{{ l3out_ip_name }}'] | [0].l3extLIfP
    ${intatt}=   Set Variable   ${intprof}.children[?l3extRsPathL3OutAtt.attributes.addr=='{{ int.ip }}'] | [0].l3extRsPathL3OutAtt
    ${bgppeer}=   Set Variable   ${intatt}.children[?bgpPeerP.attributes.addr=='{{ peer.ip }}'] | [0].bgpPeerP
    Should Be Equal JMESPath Json   ${r}   ${bgppeer}.children[?bgpLocalAsnP] | [0].bgpLocalAsnP.attributes.localAsn   {{ peer.local_as }}
    Should Be Equal JMESPath Json   ${r}   ${bgppeer}.children[?bgpLocalAsnP] | [0].bgpLocalAsnP.attributes.asnPropagate   {{ peer.as_propagate | default(defaults.apic.tenants.vxlan_l3outs.node_profiles.interface_profiles.interfaces.bgp_peers.as_propagate) }}
{% endif %}

{% if peer.peer_prefix_policy is defined %}
{% set peer_prefix_policy_name = peer.peer_prefix_policy ~ defaults.apic.tenants.policies.bgp_peer_prefix_policies.name_suffix %}
Verify VXLAN L3out {{ l3out_name }} BGP Peer {{ peer.ip }} Prefix Policy
    ${nodeprof}=   Set Variable   imdata[0].l3extOut.children[?l3extLNodeP.attributes.name=='{{ l3out_np_name }}'] | [0].l3extLNodeP
    ${intprof}=   Set Variable   ${nodeprof}.children[?l3extLIfP.attributes.name=='{{ l3out_ip_name }}'] | [0].l3extLIfP
    ${intatt}=   Set Variable   ${intprof}.children[?l3extRsPathL3OutAtt.attributes.addr=='{{ int.ip }}'] | [0].l3extRsPathL3OutAtt
    ${bgppeer}=   Set Variable   ${intatt}.children[?bgpPeerP.attributes.addr=='{{ peer.ip }}'] | [0].bgpPeerP
    Should Be Equal JMESPath Json   ${r}   ${bgppeer}.children[?bgpRsPeerPfxPol] | [0].bgpRsPeerPfxPol.attributes.tnBgpPeerPfxPolName   {{ peer_prefix_policy_name }}
{% endif %}
{% endfor %}
{% endfor %}
{% endfor %}
{% endfor %}

{% endfor %}
{% endif %}
