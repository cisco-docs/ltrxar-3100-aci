*** Settings ***
Documentation   Verify Interface Type
Suite Setup     Login APIC
Default Tags    apic   day1   config   fabric_policies
Resource        ../../apic_common.resource

*** Test Cases ***
Verify Port Interface Type
    ${r}=   GET On Session   apic   /api/mo/uni/infra/prtdirec.json   params=rsp-subtree=full
    Set Suite Variable   $r   ${r.json()}
{% for node in apic.interface_policies.nodes | default([]) %}
{% set query = "nodes[?id==`" ~ node.id ~ "`]" %}
{% set full_node = (apic.node_policies | community.general.json_query(query))[0] %}
{% if full_node.role == "leaf" %}
{% for interface in node.interfaces | default([]) %}
{% if interface.type is defined %}
    ${port}=   Set Variable   imdata[0].infraPortDirecPol.children[?infraRsPortDirection.attributes.tDn=='topology/pod-{{ full_node.pod | default(defaults.apic.node_policies.nodes.pod) }}/paths-{{ node.id }}/pathep-[eth{{ interface.module | default(defaults.apic.interface_policies.nodes.interfaces.module) }}/{{ interface.port }}]'] | [0].infraRsPortDirection
    Should Be Equal JMESPath Json   ${r}    ${port}.attributes.tDn   topology/pod-{{ full_node.pod | default(defaults.apic.node_policies.nodes.pod) }}/paths-{{ node.id }}/pathep-[eth{{ interface.module | default(defaults.apic.interface_policies.nodes.interfaces.module) }}/{{ interface.port }}]
    Should Be Equal JMESPath Json   ${r}    ${port}.attributes.direc   {{ 'UpLink' if interface.type == "uplink" else 'DownLink' }}


{% endif %}
{% endfor %}
{% endif %}
{% endfor %}
