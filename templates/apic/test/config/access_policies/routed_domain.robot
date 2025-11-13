*** Settings ***
Documentation   Verify Routed Domain
Suite Setup     Login APIC
Default Tags    apic   day1   config   access_policies
Resource        ../../apic_common.resource

*** Test Cases ***
{% for domain in apic.access_policies.routed_domains | default([]) %}
{% set domain_name = domain.name ~ defaults.apic.access_policies.routed_domains.name_suffix %}

Verify Routed Domain {{ domain_name }}
    ${r}=   GET On Session   apic   /api/mo/uni/l3dom-{{ domain_name }}.json   params=rsp-subtree=full
    Set Suite Variable   $r   ${r.json()}
    Should Be Equal JMESPath Json   ${r}    imdata[0].l3extDomP.attributes.name   {{ domain_name }}
    {% if domain.vlan_pool is defined %}
    {% set vlan_pool_name = domain.vlan_pool ~ defaults.apic.access_policies.vlan_pools.name_suffix %}
    {% set query = "vlan_pools[?name==`" ~ vlan_pool_name ~ "`].allocation[]" %}
    {% set allocation = (apic.access_policies | community.general.json_query(query))[0] | default(defaults.apic.access_policies.routed_domains.allocation) %}
    Should Be Equal JMESPath Json   ${r}    imdata[0].l3extDomP.children[?infraRsVlanNs] | [0].infraRsVlanNs.attributes.tDn   uni/infra/vlanns-[{{ vlan_pool_name }}]-{{ allocation }}
    {% endif %}

Verify Routed Domain {{ domain_name }} Security Domains
    ${r}=   GET On Session   apic   /api/mo/uni/l3dom-{{ domain.name }}.json    params=query-target=children&target-subtree-class=aaaDomainRef
    Set Suite Variable   $r   ${r.json()}
{% for sd in domain.security_domains | default([]) %}
    Should Be Equal JMESPath Json   ${r}   imdata[?aaaDomainRef.attributes.name=='{{ sd }}'] | [0].aaaDomainRef.attributes.name   {{ sd }}
{% endfor %}

{% endfor %}
