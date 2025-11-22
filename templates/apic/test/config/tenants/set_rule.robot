{# iterate_list apic.tenants name item[2] #}
*** Settings ***
Documentation   Verify Set Rule
Suite Setup     Login APIC
Default Tags    apic   day2   config   tenants
Resource        ../../../apic_common.resource

*** Test Cases ***
{% set tenant = ((apic | default()) | community.general.json_query('tenants[?name==`' ~ item[2] ~ '`]'))[0] %}
{% for rule in tenant.policies.set_rules | default([]) %}
{% set rule_name = rule.name ~ defaults.apic.tenants.policies.set_rules.name_suffix %}

Verify Set Rule {{ rule_name }}
    ${r}=   GET On Session   apic   /api/mo/uni/tn-{{ tenant.name }}/attr-{{ rule_name }}.json   params=rsp-subtree=full
    Set Suite Variable   $r   ${r.json()}
    Should Be Equal JMESPath Json   ${r}   imdata[0].rtctrlAttrP.attributes.name   {{ rule_name }}
    Should Be Equal JMESPath Json   ${r}   imdata[0].rtctrlAttrP.attributes.descr   {{ rule.description | default() }}
{% if rule.community is defined %}
    Should Be Equal JMESPath Json   ${r}   imdata[0].rtctrlAttrP.children[?rtctrlSetComm] | [0].rtctrlSetComm.attributes.community   {{ rule.community }}
    Should Be Equal JMESPath Json   ${r}   imdata[0].rtctrlAttrP.children[?rtctrlSetComm] | [0].rtctrlSetComm.attributes.setCriteria   {{ rule.community_mode | default(defaults.apic.tenants.policies.set_rules.community_mode) }}
{% endif %}
{% if rule.tag is defined %}
    Should Be Equal JMESPath Json   ${r}   imdata[0].rtctrlAttrP.children[?rtctrlSetTag] | [0].rtctrlSetTag.attributes.tag   {{ rule.tag }}
{% endif %}
{% if rule.dampening is defined %}
    Should Be Equal JMESPath Json   ${r}   imdata[0].rtctrlAttrP.children[?rtctrlSetDamp] | [0].rtctrlSetDamp.attributes.halfLife   {{ rule.dampening.half_life | default(defaults.apic.tenants.policies.set_rules.dampening.half_life ) }}
    Should Be Equal JMESPath Json   ${r}   imdata[0].rtctrlAttrP.children[?rtctrlSetDamp] | [0].rtctrlSetDamp.attributes.maxSuppressTime   {{ rule.dampening.max_suppress_time | default(defaults.apic.tenants.policies.set_rules.dampening.max_suppress_time ) }}
    Should Be Equal JMESPath Json   ${r}   imdata[0].rtctrlAttrP.children[?rtctrlSetDamp] | [0].rtctrlSetDamp.attributes.reuse   {{ rule.dampening.reuse_limit | default(defaults.apic.tenants.policies.set_rules.dampening.reuse_limit ) }}
    Should Be Equal JMESPath Json   ${r}   imdata[0].rtctrlAttrP.children[?rtctrlSetDamp] | [0].rtctrlSetDamp.attributes.suppress   {{ rule.dampening.suppress_limit | default(defaults.apic.tenants.policies.set_rules.dampening.suppress_limit ) }}
{% endif %}
{% if rule.weight is defined %}
    Should Be Equal JMESPath Json   ${r}   imdata[0].rtctrlAttrP.children[?rtctrlSetWeight] | [0].rtctrlSetWeight.attributes.weight   {{ rule.weight }}
{% endif %}
{% if rule.next_hop is defined %}
    Should Be Equal JMESPath Json   ${r}   imdata[0].rtctrlAttrP.children[?rtctrlSetNh] | [0].rtctrlSetNh.attributes.addr   {{ rule.next_hop }}
{% endif %}
{% if rule.preference is defined %}
    Should Be Equal JMESPath Json   ${r}   imdata[0].rtctrlAttrP.children[?rtctrlSetPref] | [0].rtctrlSetPref.attributes.localPref   {{ rule.preference }}
{% endif %}
{% if rule.metric is defined %}
    Should Be Equal JMESPath Json   ${r}   imdata[0].rtctrlAttrP.children[?rtctrlSetRtMetric] | [0].rtctrlSetRtMetric.attributes.metric   {{ rule.metric }}
{% endif %}
{% if rule.metric_type is defined %}
    Should Be Equal JMESPath Json   ${r}   imdata[0].rtctrlAttrP.children[?rtctrlSetRtMetricType] | [0].rtctrlSetRtMetricType.attributes.metricType   {{ rule.metric_type }}
{% endif %}
{% if rule.set_as_paths is defined %}
{% for as_path_criteria_item in rule.set_as_paths | default([]) %}
{% if as_path_criteria_item.criteria == 'prepend' %}
{% for asn_item in as_path_criteria_item.asns | default([]) %}
    Should Be Equal JMESPath Json   ${r}   imdata[0].rtctrlAttrP.children[?rtctrlSetASPath] | [0].rtctrlSetASPath.children[?rtctrlSetASPathASN.attributes.asn =='{{ asn_item.number }}'] | [0]
    Should Be Equal JMESPath Json   ${r}   imdata[0].rtctrlAttrP.children[?rtctrlSetASPath] | [0].rtctrlSetASPath.children[?rtctrlSetASPathASN.attributes.order =='{{ asn_item.order | default(defaults.apic.tenants.policies.set_rules.set_as_paths.asns.order) }}'] | [0]
{% endfor %}
{% endif %}
{% if as_path_criteria_item.criteria == 'prepend-last-as' %}
    Should Be Equal JMESPath Json   ${r}   imdata[0].rtctrlAttrP.children[?rtctrlSetASPath.attributes.lastnum =='{{ as_path_criteria_item.count | default(defaults.apic.tenants.policies.set_rules.set_as_paths.count) }}'] | [0]
{% endif %}
{% endfor %}
{% endif %}
{% if (rule.next_hop_propagation | default(defaults.apic.tenants.policies.set_rules.next_hop_propagation)) or (rule.multipath | default(defaults.apic.tenants.policies.set_rules.multipath)) %}
    Should Be Equal JMESPath Json   ${r}   imdata[0].rtctrlAttrP.children[?rtctrlSetNhUnchanged] | [0].rtctrlSetNhUnchanged.attributes.type   nh-unchanged
{% endif %}
{% if rule.multipath | default(defaults.apic.tenants.policies.set_rules.multipath) %}
    Should Be Equal JMESPath Json   ${r}   imdata[0].rtctrlAttrP.children[?rtctrlSetRedistMultipath] | [0].rtctrlSetRedistMultipath.attributes.type   redist-multipath
{% endif %}
{% if rule.external_endpoint_group is defined %}
    {% set l3out_name = rule.external_endpoint_group.l3out ~ defaults.apic.tenants.l3outs.name_suffix %}
    {% set eepg_name = rule.external_endpoint_group.name ~ defaults.apic.tenants.l3outs.external_endpoint_groups.name_suffix %}
    Should Be Equal JMESPath Json   ${r}   imdata[0].rtctrlAttrP.children[?rtctrlSetPolicyTag] | [0].rtctrlSetPolicyTag.attributes.type   policy-tag
    Should Be Equal JMESPath Json   ${r}   imdata[0].rtctrlAttrP.children[?rtctrlSetPolicyTag] | [0].rtctrlSetPolicyTag.children[?rtctrlRsSetPolicyTagToInstP] | [0].rtctrlRsSetPolicyTagToInstP.attributes.tDn   uni/tn-{{ rule.external_endpoint_group.tenant | default(tenant) }}/out-{{ l3out_name }}/instP-{{ eepg_name }}
{% endif %}

{% for add_comm in rule.additional_communities | default([]) %}
Verify Set Rule {{ rule_name }} Additional Community {{ add_comm.community  }}
    ${comm}=   Set Variable   imdata[0].rtctrlAttrP.children[?rtctrlSetAddComm.attributes.community=='{{ add_comm.community }}'] | [0].rtctrlSetAddComm
    Should Be Equal JMESPath Json   ${r}   ${comm}.attributes.community   {{ add_comm.community }}
    Should Be Equal JMESPath Json   ${r}   ${comm}.attributes.descr   {{ add_comm.description | default() }}
{% endfor %}

{% endfor %}
