*** Settings ***
Documentation   Verify Firmware Group
Suite Setup     Login APIC
Default Tags    apic   day1   config   node_policies
Resource        ../../apic_common.resource

*** Test Cases ***
{% for group in apic.node_policies.update_groups | default([]) %}
{% set update_group_name = group.name ~ defaults.apic.node_policies.update_groups.name_suffix %}

Verify Firmware Policy {{ update_group_name }}
    ${r}=   GET On Session   apic   /api/mo/uni/fabric/fwpol-{{ update_group_name }}.json
    Set Suite Variable   $r   ${r.json()}
    Should Be Equal JMESPath Json   ${r}    imdata[0].firmwareFwP.attributes.name   {{ update_group_name }}

Verify Firmware Group {{ update_group_name }}
    ${r}=   GET On Session   apic   /api/mo/uni/fabric/fwgrp-{{ update_group_name }}.json   params=rsp-subtree=full
    Set Suite Variable   $r   ${r.json()}
    Should Be Equal JMESPath Json   ${r}    imdata[0].firmwareFwGrp.attributes.name   {{ update_group_name }}
    Should Be Equal JMESPath Json   ${r}    imdata[0].firmwareFwGrp.children[?firmwareRsFwgrpp] | [0].firmwareRsFwgrpp.attributes.tnFirmwareFwPName   {{ update_group_name }}

{% for node in apic.node_policies.nodes | default([]) %}
{% if node.update_group is defined and node.update_group == update_group_name %}

Verify Firmware Group {{ update_group_name }} Node {{ node.id }}
    ${node}=   Set Variable   imdata[0].firmwareFwGrp.children[?fabricNodeBlk.attributes.name=='blk{{ node.id }}-{{ node.id }}'] | [0]
    Should Be Equal JMESPath Json   ${r}    ${node}.fabricNodeBlk.attributes.name   blk{{ node.id }}-{{ node.id }}
    Should Be Equal JMESPath Json   ${r}    ${node}.fabricNodeBlk.attributes.from_   {{ node.id }}
    Should Be Equal JMESPath Json   ${r}    ${node}.fabricNodeBlk.attributes.to_   {{ node.id }}

{% endif %}
{% endfor %}

{% endfor %}
