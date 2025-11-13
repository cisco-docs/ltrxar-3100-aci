*** Settings ***
Documentation   Verify BGP Policy
Suite Setup     Login APIC
Default Tags    apic   day0   config   fabric_policies
Resource        ../../apic_common.resource

*** Test Cases ***
{% if apic.fabric_policies is defined %}
Retrieve BGP config
    ${r}=   GET On Session   apic   /api/mo/uni/fabric/bgpInstP-default.json   params=rsp-subtree=full
    Set Suite Variable   $r   ${r.json()}

{% if apic.fabric_policies.fabric_bgp_rr is defined %}
{% for item in apic.fabric_policies.fabric_bgp_rr | default([]) %}
{% set query = "nodes[?id==`" ~ item ~ "`].pod" %}
{% set pod = (apic.node_policies | community.general.json_query(query))[0] | default(defaults.apic.fabric_policies.fabric_bgp_ext_rr.pod_id) %}

Verify BGP Route Reflector {{ item }}
    ${rr}=   Set Variable   imdata[0].bgpInstPol.children[?bgpRRP] | [0].bgpRRP.children[?bgpRRNodePEp.attributes.id=='{{ item }}'] | [0].bgpRRNodePEp
    Should Be Equal JMESPath Json   ${r}    ${rr}.attributes.id   {{ item }}
    Should Be Equal JMESPath Json   ${r}    ${rr}.attributes.podId   {{ pod }}

{% endfor %}
{% endif %}

{% if apic.fabric_policies.fabric_bgp_ext_rr is defined %}
{% for item in apic.fabric_policies.fabric_bgp_ext_rr | default([]) %}
{% set query = "nodes[?id==`" ~ item ~ "`].pod" %}
{% set pod = (apic.node_policies | community.general.json_query(query))[0] | default(defaults.apic.fabric_policies.fabric_bgp_ext_rr.pod_id) %}

Verify External BGP Route Reflector {{ item }}
    ${extrr}=   Set Variable   imdata[0].bgpInstPol.children[?bgpExtRRP] | [0].bgpExtRRP.children[?bgpRRNodePEp.attributes.id=='{{ item }}'] | [0].bgpRRNodePEp
    Should Be Equal JMESPath Json   ${r}    ${extrr}.attributes.id   {{ item }}
    Should Be Equal JMESPath Json   ${r}    ${extrr}.attributes.podId   {{ pod }}

{% endfor %}
{% endif %}

{% if apic.fabric_policies.fabric_bgp_as is defined %}
Verify BGP AS Number
    Should Be Equal JMESPath Json   ${r}    imdata[0].bgpInstPol.children[?bgpAsP] | [0].bgpAsP.attributes.asn   {{ apic.fabric_policies.fabric_bgp_as }}
{% else %}

{% endif %}

{% endif %}
