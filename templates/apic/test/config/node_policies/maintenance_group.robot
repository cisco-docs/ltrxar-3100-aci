*** Settings ***
Documentation   Verify Maintenance Group
Suite Setup     Login APIC
Default Tags    apic   day1   config   node_policies
Resource        ../../apic_common.resource

*** Test Cases ***
{% for group in apic.node_policies.update_groups | default([]) %}
{% set update_group_name = group.name ~ defaults.apic.node_policies.update_groups.name_suffix %}

Verify Maintenance Policy {{ update_group_name }}
    ${r}=   GET On Session   apic   /api/mo/uni/fabric/maintpol-{{ update_group_name }}.json   params=rsp-subtree=full
    Set Suite Variable   $r   ${r.json()}
    Should Be Equal JMESPath Json   ${r}    imdata[0].maintMaintP.attributes.name   {{ update_group_name }}

{% if group.target_version is defined%}
    Should Be Equal JMESPath Json   ${r}    imdata[0].maintMaintP.attributes.version   {{ group.target_version }}
{% endif %}

{% if group.scheduler is defined%}
    {% set scheduler_name = group.scheduler ~ defaults.apic.fabric_policies.schedulers.name_suffix %}
{% endif %}
    Should Be Equal JMESPath Json   ${r}    imdata[0].maintMaintP.children[?maintRsPolScheduler] | [0].maintRsPolScheduler.attributes.tnTrigSchedPName   {{ scheduler_name | default(defaults.apic.node_policies.update_groups.scheduler) }}

Verify Maintenance Group {{ update_group_name }}
    ${r}=   GET On Session   apic   /api/mo/uni/fabric/maintgrp-{{ update_group_name }}.json   params=rsp-subtree=full
    Set Suite Variable   $r   ${r.json()}
    Should Be Equal JMESPath Json   ${r}    imdata[0].maintMaintGrp.attributes.name   {{ update_group_name }}
    Should Be Equal JMESPath Json   ${r}    imdata[0].maintMaintGrp.children[?maintRsMgrpp] | [0].maintRsMgrpp.attributes.tnMaintMaintPName   {{ update_group_name }}

{% for node in apic.node_policies.nodes | default([]) %}
{% if node.update_group is defined and node.update_group == update_group_name %}

Verify Maintenance Group {{ update_group_name }} Node {{ node.id }}
    ${node}=   Set Variable   imdata[0].maintMaintGrp.children[?fabricNodeBlk.attributes.name=='blk{{ node.id }}-{{ node.id }}'] | [0]
    Should Be Equal JMESPath Json   ${r}    ${node}.fabricNodeBlk.attributes.name   blk{{ node.id }}-{{ node.id }}
    Should Be Equal JMESPath Json   ${r}    ${node}.fabricNodeBlk.attributes.from_   {{ node.id }}
    Should Be Equal JMESPath Json   ${r}    ${node}.fabricNodeBlk.attributes.to_   {{ node.id }}

{% endif %}
{% endfor %}

{% endfor %}
