{# iterate_list apic.node_policies.nodes id item[1] #}
*** Settings ***
Documentation   Verify Access FEX Interface Selector
Suite Setup     Login APIC
Default Tags    apic   day2   config   interface_policies
Resource        ../../../apic_common.resource

*** Test Cases ***
{% if apic.auto_generate_switch_pod_profiles | default(defaults.apic.auto_generate_switch_pod_profiles) or apic.auto_generate_access_leaf_switch_interface_profiles | default(defaults.apic.auto_generate_access_leaf_switch_interface_profiles) %}
{% if apic.new_interface_configuration | default(defaults.apic.new_interface_configuration) is false %}
{% for _node in apic.node_policies.nodes | default([]) %}
{% if _node.role == "leaf" and _node.id | string == item[1] %}
{% set query = "nodes[?id==`" ~ _node.id ~ "`].fexes[]" %}
{% if apic.interface_policies is defined %}

{% for fex in (apic.interface_policies | default() | community.general.json_query(query) | default([])) %}
{% set fex_profile_name = (_node.id ~ ":" ~ _node.name~ ":" ~ fex.id) | regex_replace("^(?P<id>.+):(?P<name>.+):(?P<fex>.+)$", (apic.access_policies.fex_profile_name | default(defaults.apic.access_policies.fex_profile_name))) %}

{% for int in fex.interfaces | default([]) %}
{% set module = int.module | default(defaults.apic.interface_policies.nodes.fexes.interfaces.module) %}
{% set fex_interface_selector_name = (module ~ ":" ~ int.port) | regex_replace("^(?P<mod>.+):(?P<port>.+)$", (apic.access_policies.fex_interface_selector_name | default(defaults.apic.access_policies.fex_interface_selector_name))) %}

Verify Access FEX Interface Profile {{ fex_profile_name }} Selector {{ fex_interface_selector_name }}
    ${r}=   GET On Session   apic   /api/mo/uni/infra/fexprof-{{ fex_profile_name }}/hports-{{ fex_interface_selector_name }}-typ-range.json   params=rsp-subtree=full
    Set Suite Variable   $r   ${r.json()}
    Should Be Equal JMESPath Json   ${r}    imdata[0].infraHPortS.attributes.name   {{ fex_interface_selector_name }}
{% if apic.interface_selector_description | default(defaults.apic.interface_selector_description) is true %}
    Should Be Equal JMESPath Json   ${r}    imdata[0].infraHPortS.attributes.descr   {{ int.description | default() }}
{% endif %}
{% if int.policy_group is defined %}
{% set query = "leaf_interface_policy_groups[?name=='" ~ int.policy_group ~ "'].type[]" %}
{% set type = (apic.access_policies | community.general.json_query(query)) %}
{% set policy_group_name = int.policy_group ~ defaults.apic.access_policies.leaf_interface_policy_groups.name_suffix %}
{% if type[0] in ["pc", "vpc"] %}
    Should Be Equal JMESPath Json   ${r}    imdata[0].infraHPortS.children[?infraRsAccBaseGrp] | [0].infraRsAccBaseGrp.attributes.tDn   uni/infra/funcprof/accbundle-{{ policy_group_name }}
{% else %}
    Should Be Equal JMESPath Json   ${r}    imdata[0].infraHPortS.children[?infraRsAccBaseGrp] | [0].infraRsAccBaseGrp.attributes.tDn   uni/infra/funcprof/accportgrp-{{ policy_group_name }}
{% endif %}
{% endif %}
    Should Be Equal JMESPath Json   ${r}    imdata[0].infraHPortS.children[?infraPortBlk] | [0].infraPortBlk.attributes.descr   {{ int.description | default() }}
    Should Be Equal JMESPath Json   ${r}    imdata[0].infraHPortS.children[?infraPortBlk] | [0].infraPortBlk.attributes.fromCard   {{ module }}
    Should Be Equal JMESPath Json   ${r}    imdata[0].infraHPortS.children[?infraPortBlk] | [0].infraPortBlk.attributes.fromPort   {{ int.port }}
    Should Be Equal JMESPath Json   ${r}    imdata[0].infraHPortS.children[?infraPortBlk] | [0].infraPortBlk.attributes.name   {{ module }}-{{ int.port }}
    Should Be Equal JMESPath Json   ${r}    imdata[0].infraHPortS.children[?infraPortBlk] | [0].infraPortBlk.attributes.toCard   {{ module }}
    Should Be Equal JMESPath Json   ${r}    imdata[0].infraHPortS.children[?infraPortBlk] | [0].infraPortBlk.attributes.toPort   {{ int.port }}

{% endfor %}

{% endfor %}

{% else %}

{% for fex in (apic.interface_policies | default() | community.general.json_query(query) | default([])) %}
{% for int in fex.interfaces | default([]) %}

Verify Access Leaf Interface {{ int.port }} Fex {{ fex.id }} Port {{ module }}/{{ int.port }}
    ${r}=   GET On Session   apic   /api/mo/uni/infra/portconfnode-{{ _node.id }}-card-{{ fex.id }}-port-1-sub-{{ int.port}}.json
    Set Suite Variable   $r   ${r.json()}
{% if int.policy_group is defined %}
{% set query = "leaf_interface_policy_groups[?name=='" ~ int.policy_group ~ "'].type[]" %}
{% set type = (apic.access_policies | community.general.json_query(query)) %}
{% set policy_group_name = int.policy_group ~ defaults.apic.access_policies.leaf_interface_policy_groups.name_suffix %}
{% if type[0] in ["pc", "vpc"] %}
    Should Be Equal JMESPath Json   ${r}    imdata[0].attributes.assocGrp   uni/infra/funcprof/accbundle-{{ policy_group_name }}
{% else %}
    Should Be Equal JMESPath Json   ${r}    imdata[0].attributes.assocGrp   uni/infra/funcprof/accportgrp-{{ policy_group_name }}
{% endif %}
{% endif %}
    Should Be Equal JMESPath Json   ${r}    imdata[0].attributes.card   {{ fex.id }}
    Should Be Equal JMESPath Json   ${r}    imdata[0].attributes.description   {{ int.description }}
    Should Be Equal JMESPath Json   ${r}    imdata[0].attributes.node   {{ _node.id }}
    Should Be Equal JMESPath Json   ${r}    imdata[0].attributes.port   1
    Should Be Equal JMESPath Json   ${r}    imdata[0].attributes.subPort   {{ int.port }}

{% endfor %}
{% endfor %}

{% endif %}
{% endif %}
{% endfor %}
{% endif %}
{% endif %}
