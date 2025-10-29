*** Settings ***
Documentation   Verify Interface Shutdown
Suite Setup     Login APIC
Default Tags    apic   day1   config   fabric_policies
Resource        ../../apic_common.resource

*** Test Cases ***

{% if apic.new_interface_configuration | default(defaults.apic.new_interface_configuration) is false %}
{% for node in apic.interface_policies.nodes | default([]) %}
{% set query = "nodes[?id==`" ~ node.id ~ "`]" %}
{% set full_node = (apic.node_policies | community.general.json_query(query))[0] %}
{% set query = "nodes[?id==`" ~ node.id ~ "`].fexes[]" %}
{% for fex in (apic.interface_policies | default() | community.general.json_query(query) | default([])) %}
{% for int in fex.interfaces | default([]) %}
{% if int.shutdown | default(defaults.apic.interface_policies.nodes.fexes.interfaces.shutdown) %}
{% set module = int.module | default(defaults.apic.interface_policies.nodes.fexes.interfaces.module) %}
Verify Interface Shutdown State for Node-{{ node.id }} Fex-{{ fex.id }} eth{{ module }}/{{ int.port }}
    ${r}=   GET On Session   apic   /api/mo/uni/fabric/outofsvc/rsoosPath-[topology/pod-{{ full_node.pod | default(defaults.apic.node_policies.nodes.pod) }}/paths-{{ node.id }}/extpaths-{{fex.id}}/pathep-[eth{{ module }}/{{ int.port }}]].json   params=rsp-subtree=full
    Set Suite Variable   $r   ${r.json()}
    Should Be Equal Value Json String   ${r}    $..fabricRsOosPath.attributes.lc   blacklist
{% endif %}
{% endfor %}
{% endfor %}

{% for interface in node.interfaces | default([]) %}
{% if interface.shutdown | default(defaults.apic.interface_policies.nodes.interfaces.shutdown) %}
{% set module = interface.module | default(defaults.apic.interface_policies.nodes.interfaces.module) %}
Verify Interface Shutdown State for Node-{{ node.id }} eth{{ module }}/{{ interface.port }}
    ${r}=   GET On Session   apic   /api/mo/uni/fabric/outofsvc/rsoosPath-[topology/pod-{{ full_node.pod | default(defaults.apic.node_policies.nodes.pod) }}/paths-{{ node.id }}/pathep-[eth{{ module }}/{{ interface.port }}]].json   params=rsp-subtree=full
    Set Suite Variable   $r   ${r.json()}
    Should Be Equal Value Json String   ${r}    $..fabricRsOosPath.attributes.lc   blacklist
{% endif %}

{% for sub_port in interface.sub_ports | default([]) %}
{% if sub_port.shutdown | default(defaults.apic.interface_policies.nodes.interfaces.sub_ports.shutdown) %}
{% set module = interface.module | default(defaults.apic.interface_policies.nodes.interfaces.module) %}
Verify Interface Shutdown State for Node-{{ node.id }} eth{{ module }}/{{ interface.port }}/{{ sub_port.port }}
    ${r}=   GET On Session   apic   /api/mo/uni/fabric/outofsvc/rsoosPath-[topology/pod-{{ full_node.pod | default(defaults.apic.node_policies.nodes.pod) }}/paths-{{ node.id }}/pathep-[eth{{ module }}/{{ interface.port }}/{{ sub_port.port }}]].json   params=rsp-subtree=full
    Set Suite Variable   $r   ${r.json()}
    Should Be Equal Value Json String   ${r}    $..fabricRsOosPath.attributes.lc   blacklist
{% endif %}
{% endfor %}
{% endfor %}
{% endfor %}
{% endif %}
