*** Settings ***
Documentation   Verify Physical Domain
Suite Setup     Login APIC
Default Tags    apic   day1   config   access_policies
Resource        ../../apic_common.resource

*** Test Cases ***
{% for domain in apic.access_policies.physical_domains | default([]) %}
{% set domain_name = domain.name ~ defaults.apic.access_policies.physical_domains.name_suffix %}

Verify Physical Domain {{ domain_name }}
    ${r}=   GET On Session   apic   /api/mo/uni/phys-{{ domain_name }}.json   params=rsp-subtree=full
    Set Suite Variable   $r   ${r.json()}
    Should Be Equal JMESPath Json   ${r}    imdata[0].physDomP.attributes.name   {{ domain_name }}
    {% set vlan_pool_name = domain.vlan_pool ~ defaults.apic.access_policies.vlan_pools.name_suffix %}
    {% set query = "vlan_pools[?name==`" ~ vlan_pool_name ~ "`].allocation[]" %}
    {% set allocation = (apic.access_policies | community.general.json_query(query))[0] | default(defaults.apic.access_policies.physical_domains.allocation) %}
    Should Be Equal JMESPath Json   ${r}    imdata[0].physDomP.children[?infraRsVlanNs] | [0].infraRsVlanNs.attributes.tDn   uni/infra/vlanns-[{{ vlan_pool_name }}]-{{ allocation }}

Verify Physical Domain {{ domain_name }} Security Domains
    ${r}=   GET On Session   apic   /api/mo/uni/phys-{{ domain.name }}.json    params=query-target=children&target-subtree-class=aaaDomainRef
    Set Suite Variable   $r   ${r.json()}
{% for sd in domain.security_domains | default([]) %}
    Should Be Equal JMESPath Json   ${r}   imdata[?aaaDomainRef.attributes.name=='{{ sd }}'] | [0].aaaDomainRef.attributes.name   {{ sd }}
{% endfor %}

{% endfor %}
