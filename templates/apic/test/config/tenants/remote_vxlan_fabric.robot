{# iterate_list apic.tenants name item[2] #}
*** Settings ***
Documentation   Verify Remote VXLAN Fabric
Suite Setup     Login APIC
Default Tags    apic   day2   config   tenants
Resource        ../../../apic_common.resource

*** Test Cases ***
{% set tenant = ((apic | default()) | community.general.json_query('tenants[?name==`' ~ item[2] ~ '`]'))[0] %}
{% if tenant.name == "infra" %}
{% for fabric in tenant.policies.remote_vxlan_fabrics | default([]) %}
{% set fabric_name = fabric.name ~ defaults.apic.tenants.policies.remote_vxlan_fabrics.name_suffix %}

Verify Remote VXLAN Fabric {{ fabric_name }}
    ${r}=   GET On Session   apic   /api/mo/uni/tn-infra/vxlanremotefabric-{{ fabric_name }}.json   params=rsp-subtree=full
    Set Suite Variable   $r   ${r.json()}
    Should Be Equal JMESPath Json   ${r}   imdata[0].vxlanRemoteFabric.attributes.name   {{ fabric_name }}

{% for peer in fabric.remote_evpn_peers | default([]) %}
{% set ctrl = [] %}
{% if peer.allow_self_as | default(defaults.apic.tenants.policies.remote_vxlan_fabrics.remote_evpn_peers.allow_self_as) %}{% set ctrl = ctrl + [("allow-self-as")] %}{% endif %}
{% if peer.disable_peer_as_check | default(defaults.apic.tenants.policies.remote_vxlan_fabrics.remote_evpn_peers.disable_peer_as_check) %}{% set ctrl = ctrl + [("dis-peer-as-check")] %}{% endif %}
{% set ctrl = ctrl + [("send-com")] %}
{% set ctrl = ctrl + [("send-ext-com")] %}

Verify Remote VXLAN Fabric {{ fabric_name }} BGP Peer {{ peer.ip }}
    ${bgppeer}=   Set Variable   imdata[0].vxlanRemoteFabric.children[?bgpInfraPeerP.attributes.addr=='{{ peer.ip }}'] | [0].bgpInfraPeerP
    Should Be Equal JMESPath Json   ${r}   ${bgppeer}.attributes.addr   {{ peer.ip }}
    Should Be Equal JMESPath Json   ${r}   ${bgppeer}.attributes.adminSt   {{'enabled' if peer.admin_state | default(defaults.apic.tenants.policies.remote_vxlan_fabrics.remote_evpn_peers.admin_state) else 'disabled' }}
    Should Be Equal JMESPath Json   ${r}   ${bgppeer}.attributes.ctrl    {{ ctrl | join(',') }}
    Should Be Equal JMESPath Json   ${r}   ${bgppeer}.attributes.descr   {{ peer.description | default() }}
    Should Be Equal JMESPath Json   ${r}   ${bgppeer}.attributes.peerT   vxlan-bgw
    Should Be Equal JMESPath Json   ${r}   ${bgppeer}.attributes.ttl   {{ peer.ttl | default(defaults.apic.tenants.policies.remote_vxlan_fabrics.remote_evpn_peers.ttl) }}

Verify Remote VXLAN Fabric {{ fabric_name }} BGP Peer {{ peer.ip }} AS Policy
    ${bgppeer}=   Set Variable   imdata[0].vxlanRemoteFabric.children[?bgpInfraPeerP.attributes.addr=='{{ peer.ip }}'] | [0].bgpInfraPeerP
    Should Be Equal JMESPath Json   ${r}   ${bgppeer}.children[?bgpAsP] | [0].bgpAsP.attributes.asn   {{ peer.remote_as }}

{% if peer.local_as is defined %}
Verify Remote VXLAN Fabric {{ fabric_name }} BGP Peer {{ peer.ip }} Local ASN Policy
    ${bgppeer}=   Set Variable   imdata[0].vxlanRemoteFabric.children[?bgpInfraPeerP.attributes.addr=='{{ peer.ip }}'] | [0].bgpInfraPeerP
    Should Be Equal JMESPath Json   ${r}   ${bgppeer}.children[?bgpLocalAsnP] | [0].bgpLocalAsnP.attributes.localAsn   {{ peer.local_as }}
    Should Be Equal JMESPath Json   ${r}   ${bgppeer}.children[?bgpLocalAsnP] | [0].bgpLocalAsnP.attributes.asnPropagate   {{ peer.as_propagate | default(defaults.apic.tenants.policies.remote_vxlan_fabrics.remote_evpn_peers.as_propagate) }}
{% endif %}

{% if peer.peer_prefix_policy is defined %}
{% set peer_prefix_policy_name = peer.peer_prefix_policy ~ defaults.apic.tenants.policies.bgp_peer_prefix_policies.name_suffix %}
Verify Remote VXLAN Fabric {{ fabric_name }} BGP Peer {{ peer.ip }} Prefix Policy
    ${bgppeer}=   Set Variable   imdata[0].vxlanRemoteFabric.children[?bgpInfraPeerP.attributes.addr=='{{ peer.ip }}'] | [0].bgpInfraPeerP
    Should Be Equal JMESPath Json   ${r}   ${bgppeer}.children[?bgpRsPeerPfxPol] | [0].bgpRsPeerPfxPol.attributes.tnBgpPeerPfxPolName   {{ peer_prefix_policy_name }}
{% endif %}
{% endfor %}

{% if fabric.border_gateway_set_policy is defined %}
{% set border_gateway_set_policy = fabric.border_gateway_set_policy ~ defaults.apic.tenants.policies.border_gateway_set_policy.name_suffix%}
Verify Remote VXLAN Fabric {{ fabric_name }} Border Gateway Set Policy
    Should Be Equal JMESPath Json   ${r}   imdata[0].vxlanRemoteFabric.children[?vxlanRsRemoteFabricToBgwSet] | [0].vxlanRsRemoteFabricToBgwSet.attributes.tDn   uni/tn-infra/vxlanbgwset-{{ border_gateway_set_policy }}
{% endif %}

{% endfor %}
{% endif %}
