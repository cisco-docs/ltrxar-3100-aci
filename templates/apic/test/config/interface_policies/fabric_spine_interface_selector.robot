{# iterate_list apic.node_policies.nodes id item[1] #}
*** Settings ***
Documentation   Verify Fabric Spine Interface Selector
Suite Setup     Login APIC
Default Tags    apic   day2   config   interface_policies
Resource        ../../../apic_common.resource

*** Test Cases ***
{% if apic.auto_generate_switch_pod_profiles | default(defaults.apic.auto_generate_switch_pod_profiles) or apic.auto_generate_fabric_spine_switch_interface_profiles | default(defaults.apic.auto_generate_fabric_spine_switch_interface_profiles) %}
{% if apic.new_interface_configuration | default(defaults.apic.new_interface_configuration) is false %}
{% for _node in apic.node_policies.nodes | default([]) %}
{% if _node.role == "spine" and _node.id | string == item[1] %}

{% set spine_interface_profile_name = (_node.id ~ ":" ~ _node.name) | regex_replace("^(?P<id>.+):(?P<name>.+)$", (apic.fabric_policies.spine_interface_profile_name | default(defaults.apic.fabric_policies.spine_interface_profile_name))) %}
{% set query = "nodes[?id==`" ~ _node.id ~ "`].interfaces[]" %}
{% if apic.interface_policies is defined %}

{% for int in (apic.interface_policies | default() | community.general.json_query(query) | default([])) %}
{% if int.fabric | default(defaults.apic.interface_policies.nodes.interfaces.fabric) is true %}
{% set module = int.module | default(defaults.apic.interface_policies.nodes.interfaces.module) %}
{% set spine_interface_selector_name = (module ~ ":" ~ int.port) | regex_replace("^(?P<mod>.+):(?P<port>.+)$", (apic.fabric_policies.spine_interface_selector_name | default(defaults.apic.fabric_policies.spine_interface_selector_name))) %}

Verify Fabric Spine Interface Profile {{ spine_interface_profile_name }} Selector {{ spine_interface_selector_name }}
    ${r}=   GET On Session   apic   /api/mo/uni/fabric/spportp-{{ spine_interface_profile_name }}/spfabports-{{ spine_interface_selector_name }}-typ-range.json   params=rsp-subtree=full
    Set Suite Variable   $r   ${r.json()}
    Should Be Equal Value Json String   ${r}    $..fabricSFPortS.attributes.name   {{ spine_interface_selector_name }}
{% if apic.interface_selector_description | default(defaults.apic.interface_selector_description) is true %}
    Should Be Equal Value Json String   ${r}    $..fabricSFPortS.attributes.descr   {{ int.description | default() }}
{% endif %}
{% if int.policy_group is defined %}
{% set query = "spine_interface_policy_groups[?name=='" ~ int.policy_group ~ "'].type[]" %}
{% set type = (apic.fabric_policies | community.general.json_query(query)) %}
{% set policy_group_name = int.policy_group ~ defaults.apic.fabric_policies.spine_interface_policy_groups.name_suffix %}
    Should Be Equal Value Json String   ${r}    $..fabricRsSpPortPGrp.attributes.tDn   uni/fabric/funcprof/spportgrp-{{ policy_group_name }}
{% endif %}
    Should Be Equal Value Json String   ${r}    $..fabricPortBlk.attributes.descr   {{ int.description | default() }}
    Should Be Equal Value Json String   ${r}    $..fabricPortBlk.attributes.fromCard   {{ module }}
    Should Be Equal Value Json String   ${r}    $..fabricPortBlk.attributes.fromPort   {{ int.port }}
    Should Be Equal Value Json String   ${r}    $..fabricPortBlk.attributes.name   {{ module }}-{{ int.port }}
    Should Be Equal Value Json String   ${r}    $..fabricPortBlk.attributes.toCard   {{ module }}
    Should Be Equal Value Json String   ${r}    $..fabricPortBlk.attributes.toPort   {{ int.port }}

{% for sub in int.sub_ports | default([]) %}
{% set module = sub.module | default(defaults.apic.interface_policies.nodes.interfaces.module) %}
{% set spine_interface_selector_sub_port_name = (module ~ ":" ~ int.port ~ ":" ~ sub.port ) | regex_replace("^(?P<mod>.+):(?P<port>.+):(?P<sport>.+)$", (apic.fabric_policies.spine_interface_selector_sub_port_name | default(defaults.apic.fabric_policies.spine_interface_selector_sub_port_name))) %}
Verify Fabric Spine Interface Profile {{ spine_interface_profile_name }} Selector {{ spine_interface_selector_sub_port_name }}
    ${r}=   GET On Session   apic   /api/mo/uni/fabric/spportp-{{ spine_interface_profile_name }}/spfabports-{{ spine_interface_selector_sub_port_name }}-typ-range.json   params=rsp-subtree=full
    Set Suite Variable   $r   ${r.json()}
    Should Be Equal Value Json String   ${r}    $..fabricSFPortS.attributes.name   {{ spine_interface_selector_sub_port_name }}
{% if apic.interface_selector_description | default(defaults.apic.interface_selector_description) is true %}
    Should Be Equal Value Json String   ${r}    $..fabricSFPortS.attributes.descr   {{ sub.description | default() }}
{% endif %}
{% if sub.policy_group is defined %}
{% set query = "spine_interface_policy_groups[?name=='" ~ sub.policy_group ~ "'].type[]" %}
{% set type = (apic.fabric_policies | community.general.json_query(query)) %}
{% set policy_group_name = sub.policy_group ~ defaults.apic.fabric_policies.spine_interface_policy_groups.name_suffix %}
    Should Be Equal Value Json String   ${r}    $..fabricRsSpPortPGrp.attributes.tDn   uni/fabric/funcprof/spportgrp-{{ policy_group_name }}
{% endif %}
    Should Be Equal Value Json String   ${r}    $..fabricSubPortBlk.attributes.descr   {{ sub.description | default() }}
    Should Be Equal Value Json String   ${r}    $..fabricSubPortBlk.attributes.fromCard   {{ module }}
    Should Be Equal Value Json String   ${r}    $..fabricSubPortBlk.attributes.fromPort   {{ int.port }}
    Should Be Equal Value Json String   ${r}    $..fabricSubPortBlk.attributes.name   {{ module }}-{{int.port}}-{{ sub.port }}
    Should Be Equal Value Json String   ${r}    $..fabricSubPortBlk.attributes.toCard   {{ module }}
    Should Be Equal Value Json String   ${r}    $..fabricSubPortBlk.attributes.toPort   {{ int.port }}
    Should Be Equal Value Json String   ${r}    $..fabricSubPortBlk.attributes.fromSubPort   {{ sub.port }}
    Should Be Equal Value Json String   ${r}    $..fabricSubPortBlk.attributes.toSubPort   {{ sub.port }}

{% endfor %}

{% endif %}

{% endfor %}

{% endif %}

{% endif %}
{% endfor %}
{% endif %}
{% endif %}
