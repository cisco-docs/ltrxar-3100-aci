*** Settings ***
Documentation   Verify Leaf Fabric Port Policy Group
Suite Setup     Login APIC
Default Tags    apic   day1   config   fabric_policies
Resource        ../../apic_common.resource

*** Test Cases ***
{% for pg in apic.fabric_policies.leaf_interface_policy_groups | default([]) %}
{% set policy_group_name = pg.name ~ defaults.apic.fabric_policies.leaf_interface_policy_groups.name_suffix %}

Verify Leaf Fabric Port Policy Group {{ policy_group_name }}
    ${r}=   GET On Session   apic   /api/mo/uni/fabric/funcprof/leportgrp-{{ policy_group_name }}.json   params=rsp-subtree=full
    Set Suite Variable   $r   ${r.json()}
    Should Be Equal JMESPath Json   ${r}    imdata[0].fabricLePortPGrp.attributes.name   {{ policy_group_name }}
    Should Be Equal JMESPath Json   ${r}    imdata[0].fabricLePortPGrp.attributes.descr   {{ pg.description | default() }}
{% if pg.link_level_policy is defined %}
{% set link_level_policy_name = pg.link_level_policy ~ defaults.apic.fabric_policies.interface_policies.link_level_policies.name_suffix %}
    Should Be Equal JMESPath Json   ${r}    imdata[0].fabricLePortPGrp.children[?fabricRsFIfPol] | [0].fabricRsFIfPol.attributes.tnFabricFIfPolName   {{ link_level_policy_name }}
{% endif %}

{% endfor %}
