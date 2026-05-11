*** Settings ***
Documentation   Verify Pod Profile
Suite Setup     Login APIC
Default Tags    apic   day1   config   fabric_policies
Resource        ../../apic_common.resource

*** Test Cases ***
{% if apic.auto_generate_switch_pod_profiles | default(defaults.apic.auto_generate_switch_pod_profiles) or apic.auto_generate_pod_profiles | default(defaults.apic.auto_generate_pod_profiles) %}
{% for pod in apic.pod_policies.pods | default([]) %}
{% set pod_profile_name = (pod.id) | regex_replace("^(?P<id>.+)$", (apic.fabric_policies.pod_profile_name | default(defaults.apic.fabric_policies.pod_profile_name))) %}
{% set pod_profile_pod_selector_name = (pod.id) | regex_replace("^(?P<id>.+)$", (apic.fabric_policies.pod_profile_pod_selector_name | default(defaults.apic.fabric_policies.pod_profile_pod_selector_name))) %}

Verify (Auto-Generated) Pod Profile {{ pod_profile_name }}
    ${r}=   GET On Session   apic   /api/mo/uni/fabric/podprof-{{ pod_profile_name }}.json   params=rsp-subtree=full
    Set Suite Variable   $r   ${r.json()}
    Should Be Equal JMESPath Json   ${r}    imdata[0].fabricPodP.attributes.name   {{ pod_profile_name }}
    Should Be Equal JMESPath Json   ${r}    imdata[0].fabricPodP.children[?fabricPodS.attributes.name=='{{ pod_profile_pod_selector_name }}'] | [0].fabricPodS.attributes.name   {{ pod_profile_pod_selector_name }}
{% if pod.policy is defined %}
{% set pod_policy_group_name = pod.policy ~ defaults.apic.fabric_policies.pod_policy_groups.name_suffix %}
    Should Be Equal JMESPath Json   ${r}    imdata[0].fabricPodP.children[?fabricPodS] | [0].fabricPodS.children[?fabricRsPodPGrp] | [0].fabricRsPodPGrp.attributes.tDn   uni/fabric/funcprof/podpgrp-{{ pod_policy_group_name }}
{% endif %}
    Should Be Equal JMESPath Json   ${r}    imdata[0].fabricPodP.children[?fabricPodS] | [0].fabricPodS.children[?fabricPodBlk.attributes.name=='{{ pod.id }}'] | [0].fabricPodBlk.attributes.name   {{ pod.id }}
    Should Be Equal JMESPath Json   ${r}    imdata[0].fabricPodP.children[?fabricPodS] | [0].fabricPodS.children[?fabricPodBlk.attributes.name=='{{ pod.id }}'] | [0].fabricPodBlk.attributes.from_   {{ pod.id }}
    Should Be Equal JMESPath Json   ${r}    imdata[0].fabricPodP.children[?fabricPodS] | [0].fabricPodS.children[?fabricPodBlk.attributes.name=='{{ pod.id }}'] | [0].fabricPodBlk.attributes.to_   {{ pod.id }}

{% endfor %}
{% endif %}

{% for prof in apic.fabric_policies.pod_profiles | default([]) %}
{% set pod_profile_name = prof.name ~ defaults.apic.fabric_policies.pod_profiles.name_suffix %}

Verify Pod Profile {{ pod_profile_name }}
    ${r}=   GET On Session   apic   /api/mo/uni/fabric/podprof-{{ pod_profile_name }}.json   params=rsp-subtree=full
    Set Suite Variable   $r   ${r.json()}
    Should Be Equal JMESPath Json   ${r}    imdata[0].fabricPodP.attributes.name   {{ pod_profile_name }}

{% for sel in prof.selectors | default([]) %}
{% set selector_name = sel.name ~ defaults.apic.fabric_policies.pod_profiles.selectors.name_suffix %}

Verify Pod Profile {{ pod_profile_name }} Selector {{ selector_name }}
    ${sel}=   Set Variable   imdata[0].fabricPodP.children[?fabricPodS.attributes.name=='{{ selector_name }}'] | [0].fabricPodS
    Should Be Equal JMESPath Json   ${r}    ${sel}.attributes.name   {{ selector_name }}
{% if sel.type | default(defaults.apic.fabric_policies.pod_profiles.selectors.type) == "all" %}
    Should Be Equal JMESPath Json   ${r}    ${sel}.attributes.type   ALL
{% else %}
    Should Be Equal JMESPath Json   ${r}    ${sel}.attributes.type   range
{% endif %}
{% if sel.policy is defined %}
{% set pod_policy_group_name = sel.policy ~ defaults.apic.fabric_policies.pod_policy_groups.name_suffix %}
    Should Be Equal JMESPath Json   ${r}    ${sel}.children[?fabricRsPodPGrp] | [0].fabricRsPodPGrp.attributes.tDn   uni/fabric/funcprof/podpgrp-{{ pod_policy_group_name }}
{% endif %}

{% for blk in sel.pod_blocks | default([]) %}
{% set pod_block_name = blk.name ~ defaults.apic.fabric_policies.pod_profiles.selectors.pod_blocks.name_suffix %}

Verify Pod Profile {{ pod_profile_name }} Selector {{ selector_name }} Node Block {{ pod_block_name }}
    ${blk}=   Set Variable   imdata[0].fabricPodP.children[?fabricPodS.attributes.name=='{{ selector_name }}'] | [0].fabricPodS.children[?fabricPodBlk.attributes.name=='{{ pod_block_name }}'] | [0].fabricPodBlk
    Should Be Equal JMESPath Json   ${r}    ${blk}.attributes.name   {{ pod_block_name }}
    Should Be Equal JMESPath Json   ${r}    ${blk}.attributes.from_   {{ blk.from }}
    Should Be Equal JMESPath Json   ${r}    ${blk}.attributes.to_   {{ blk.to | default(blk.from) }}

{% endfor %}
{% endfor %}
{% endfor %}
