*** Settings ***
Documentation   Verify Fabric Spine Interface Profile
Suite Setup     Login APIC
Default Tags    apic   day1   config   fabric_policies
Resource        ../../apic_common.resource

*** Test Cases ***
{% if apic.new_interface_configuration | default(defaults.apic.new_interface_configuration) is false %}
{% if apic.auto_generate_switch_pod_profiles | default(defaults.apic.auto_generate_switch_pod_profiles) or apic.auto_generate_fabric_spine_switch_interface_profiles | default(defaults.apic.auto_generate_fabric_spine_switch_interface_profiles) %}
{% for node in apic.node_policies.nodes | default([]) %}
{% if node.role == "spine" %}
{% set spine_interface_profile_name = (node.id ~ ":" ~ node.name) | regex_replace("^(?P<id>.+):(?P<name>.+)$", (apic.fabric_policies.spine_interface_profile_name | default(defaults.apic.fabric_policies.spine_interface_profile_name))) %}

Verify (Auto-Generated) Fabric Spine Interface Profile {{ spine_interface_profile_name }}
    ${r}=   GET On Session   apic   /api/mo/uni/fabric/spportp-{{ spine_interface_profile_name }}.json
    Set Suite Variable   $r   ${r.json()}
    Should Be Equal JMESPath Json   ${r}    imdata[0].fabricSpPortP.attributes.name   {{ spine_interface_profile_name }}

{% endif %}
{% endfor %}
{% endif %}

{% for prof in apic.fabric_policies.spine_interface_profiles | default([]) %}
{% set spine_interface_profile_name = prof.name ~ defaults.apic.fabric_policies.spine_interface_profiles.name_suffix %}

Verify Fabric Spine Interface Profile {{ spine_interface_profile_name }}
    ${r}=   GET On Session   apic   /api/mo/uni/fabric/spportp-{{ spine_interface_profile_name }}.json   params=rsp-subtree=full
    Set Suite Variable   $r   ${r.json()}
    Should Be Equal JMESPath Json   ${r}    imdata[0].fabricSpPortP.attributes.name   {{ spine_interface_profile_name }}

{% for sel in prof.selectors | default([]) %}
{% set spine_interface_selector_name = sel.name ~ defaults.apic.fabric_policies.spine_interface_profiles.selectors.name_suffix %}

Verify Fabric Spine Interface Profile {{ spine_interface_profile_name }} Selector {{ spine_interface_selector_name }}
    ${sel}=   Set Variable   imdata[0].fabricSpPortP.children[?fabricSFPortS.attributes.name=='{{ spine_interface_selector_name }}'] | [0]
    Should Be Equal JMESPath Json   ${r}    ${sel}.fabricSFPortS.attributes.name   {{ spine_interface_selector_name }}
    Should Be Equal JMESPath Json   ${r}    ${sel}.fabricSFPortS.attributes.descr   {{ sel.description | default() }}
{% if sel.policy_group is defined %}
{% set policy_group_name = sel.policy_group ~ defaults.apic.fabric_policies.spine_interface_policy_groups.name_suffix %}
    Should Be Equal JMESPath Json   ${r}    ${sel}.fabricSFPortS.children[?fabricRsSpPortPGrp] | [0].fabricRsSpPortPGrp.attributes.tDn   uni/fabric/funcprof/spportgrp-{{ policy_group_name }}
{% endif %}

{% for blk in sel.port_blocks | default([]) %}
{% set block_name = blk.name ~ defaults.apic.fabric_policies.spine_interface_profiles.selectors.port_blocks.name_suffix %}

Verify Access Spine Interface Profile {{ spine_interface_profile_name }} Selector {{ spine_interface_selector_name }} Port Block {{ block_name }}
    ${blk}=   Set Variable   imdata[0].fabricSpPortP.children[?fabricSFPortS.attributes.name=='{{ spine_interface_selector_name }}'] | [0].fabricSFPortS.children[?fabricPortBlk.attributes.name=='{{ block_name }}'] | [0]
    Should Be Equal JMESPath Json   ${r}    ${blk}.fabricPortBlk.attributes.name   {{ block_name }}
    Should Be Equal JMESPath Json   ${r}    ${blk}.fabricPortBlk.attributes.descr   {{ blk.description | default() }}
    Should Be Equal JMESPath Json   ${r}    ${blk}.fabricPortBlk.attributes.fromCard   {{ blk.from_module | default(defaults.apic.fabric_policies.spine_interface_profiles.selectors.port_blocks.from_module) }}
    Should Be Equal JMESPath Json   ${r}    ${blk}.fabricPortBlk.attributes.fromPort   {{ blk.from_port }}
    Should Be Equal JMESPath Json   ${r}    ${blk}.fabricPortBlk.attributes.toCard   {{ blk.to_module | default(blk.from_module | default(defaults.apic.fabric_policies.spine_interface_profiles.selectors.port_blocks.from_module)) }}
    Should Be Equal JMESPath Json   ${r}    ${blk}.fabricPortBlk.attributes.toPort   {{ blk.to_port | default(blk.from_port) }}

{% endfor %}

{% for sub_blk in sel.sub_port_blocks | default([]) %}
{% set sub_block_name = sub_blk.name ~ defaults.apic.fabric_policies.spine_interface_profiles.selectors.sub_port_blocks.name_suffix %}

Verify Access Spine Interface Profile {{ spine_interface_profile_name }} Selector {{ spine_interface_selector_name }} Sub-Port Block {{ sub_block_name }}
    ${blk}=   Set Variable   imdata[0].fabricSpPortP.children[?fabricSFPortS.attributes.name=='{{ spine_interface_selector_name }}'] | [0].fabricSFPortS.children[?fabricSubPortBlk.attributes.name=='{{ sub_block_name }}'] | [0]
    Should Be Equal JMESPath Json   ${r}    ${blk}.fabricSubPortBlk.attributes.name   {{ sub_block_name }}
    Should Be Equal JMESPath Json   ${r}    ${blk}.fabricSubPortBlk.attributes.descr   {{ sub_blk.description | default() }}
    Should Be Equal JMESPath Json   ${r}    ${blk}.fabricSubPortBlk.attributes.fromCard   {{ sub_blk.from_module | default(defaults.apic.fabric_policies.spine_interface_profiles.selectors.sub_port_blocks.from_module) }}
    Should Be Equal JMESPath Json   ${r}    ${blk}.fabricSubPortBlk.attributes.fromPort   {{ sub_blk.from_port }}
    Should Be Equal JMESPath Json   ${r}    ${blk}.fabricSubPortBlk.attributes.fromSubPort   {{ sub_blk.from_sub_port }}
    Should Be Equal JMESPath Json   ${r}    ${blk}.fabricSubPortBlk.attributes.toCard   {{ sub_blk.to_module | default(sub_blk.from_module | default(defaults.apic.fabric_policies.spine_interface_profiles.selectors.sub_port_blocks.from_module)) }}
    Should Be Equal JMESPath Json   ${r}    ${blk}.fabricSubPortBlk.attributes.toPort   {{ sub_blk.to_port | default(sub_blk.from_port) }}
    Should Be Equal JMESPath Json   ${r}    ${blk}.fabricSubPortBlk.attributes.toSubPort   {{ sub_blk.to_sub_port | default(sub_blk.from_sub_port) }}

{% endfor %}

{% endfor %}

{% endfor %}
{% endif %}
