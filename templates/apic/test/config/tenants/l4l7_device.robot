{# iterate_list apic.tenants name item[2] #}
*** Settings ***
Documentation   Verify L4L7 Device
Suite Setup    Login APIC
Default Tags    apic   day2   config   tenants
Resource       ../../../apic_common.resource

*** Test Cases ***
{% set tenant = ((apic | default()) | community.general.json_query('tenants[?name==`' ~ item[2] ~ '`]'))[0] %}
{% for dev in tenant.services.l4l7_devices | default([]) %}
{% set dev_name = dev.name ~ defaults.apic.tenants.services.l4l7_devices.name_suffix %}

Verify L4L7 Device {{ dev_name }}
    ${r}=   GET On Session   apic   /api/mo/uni/tn-{{ tenant.name }}/lDevVip-{{ dev_name }}.json   params=rsp-subtree=full
    Set Suite Variable   $r   ${r.json()}
    Should Be Equal JMESPath Json   ${r}   imdata[0].vnsLDevVip.attributes.contextAware   {{ dev.context_aware | default(defaults.apic.tenants.services.l4l7_devices.context_aware) }}
    Should Be Equal JMESPath Json   ${r}   imdata[0].vnsLDevVip.attributes.devtype   {{ dev.type | default(defaults.apic.tenants.services.l4l7_devices.type) }}
    Should Be Equal JMESPath Json   ${r}   imdata[0].vnsLDevVip.attributes.funcType   {{ dev.function | default(defaults.apic.tenants.services.l4l7_devices.function) }}
    Should Be Equal JMESPath Json   ${r}   imdata[0].vnsLDevVip.attributes.isCopy   {{ 'yes' if dev.copy_device | default(defaults.apic.tenants.services.l4l7_devices.copy_device) else 'no' }}
    Should Be Equal JMESPath Json   ${r}   imdata[0].vnsLDevVip.attributes.managed   {{ 'yes' if dev.managed | default(defaults.apic.tenants.services.l4l7_devices.managed) else 'no' }}
    Should Be Equal JMESPath Json   ${r}   imdata[0].vnsLDevVip.attributes.name   {{ dev_name }}
    Should Be Equal JMESPath Json   ${r}   imdata[0].vnsLDevVip.attributes.nameAlias   {{ dev.alias | default() }}
    Should Be Equal JMESPath Json   ${r}   imdata[0].vnsLDevVip.attributes.promMode   {{ 'yes' if dev.promiscuous_mode | default(defaults.apic.tenants.services.l4l7_devices.promiscuous_mode) else 'no' }}
    Should Be Equal JMESPath Json   ${r}   imdata[0].vnsLDevVip.attributes.svcType   {{ dev.service_type | default(defaults.apic.tenants.services.l4l7_devices.service_type) }}
    Should Be Equal JMESPath Json   ${r}   imdata[0].vnsLDevVip.attributes.trunking   {{ 'yes' if dev.trunking | default(defaults.apic.tenants.services.l4l7_devices.trunking) else 'no' }}
{% if dev.physical_domain is defined and dev.type | default(defaults.apic.tenants.services.l4l7_devices.type) == 'PHYSICAL' %}
{% set domain_name = dev.physical_domain ~ defaults.apic.access_policies.physical_domains.name_suffix %}
    Should Be Equal JMESPath Json   ${r}   imdata[0].vnsLDevVip.children[?vnsRsALDevToPhysDomP] | [0].vnsRsALDevToPhysDomP.attributes.tDn   uni/phys-{{ domain_name }}
{% endif %}
{% if dev.vmware_vmm_domain is defined and dev.type | default(defaults.apic.tenants.services.l4l7_devices.type) == 'VIRTUAL' %}
{% set domain_name = dev.vmware_vmm_domain ~ defaults.apic.fabric_policies.vmware_vmm_domains.name_suffix %}
    Should Be Equal JMESPath Json   ${r}   imdata[0].vnsLDevVip.children[?vnsRsALDevToDomP] | [0].vnsRsALDevToDomP.attributes.tDn   uni/vmmp-VMware/dom-{{ domain_name }}
{% endif %}
{% if dev.active_active | default(defaults.apic.tenants.services.l4l7_devices.active_active) %}
    Should Be Equal JMESPath Json   ${r}   imdata[0].vnsLDevVip.attributes.activeActive   yes
{% endif %}

{% for cd in dev.concrete_devices | default([]) %}
{% set cd_name = cd.name ~ defaults.apic.tenants.services.l4l7_devices.concrete_devices.name_suffix %}

Verify L4L7 Device {{ dev_name }} Concrete Device {{ cd_name }}
    ${con}=   Set Variable   imdata[0].vnsLDevVip.children[?vnsCDev.attributes.name=='{{ cd_name }}'] | [0].vnsCDev
    Should Be Equal JMESPath Json   ${r}   ${con}.attributes.name   {{ cd_name }}
    Should Be Equal JMESPath Json   ${r}   ${con}.attributes.nameAlias   {{ cd.alias | default() }}
    Should Be Equal JMESPath Json   ${r}   ${con}.attributes.vcenterName   {{ cd.vcenter_name | default() }}
    Should Be Equal JMESPath Json   ${r}   ${con}.attributes.vmName   {{ cd.vm_name | default() }}

{% for int in cd.interfaces | default([]) %}
{% set int_name = int.name ~ defaults.apic.tenants.services.l4l7_devices.concrete_devices.interfaces.name_suffix %}

Verify L4L7 Device {{ dev_name }} Concrete Device {{ cd_name }} Interface {{ int_name }}
    ${con}=   Set Variable   imdata[0].vnsLDevVip.children[?vnsCDev.attributes.name=='{{ cd_name }}'] | [0].vnsCDev.children[?vnsCIf.attributes.name=='{{ int_name }}'] | [0].vnsCIf
    Should Be Equal JMESPath Json   ${r}   ${con}.attributes.name   {{ int_name }}
    Should Be Equal JMESPath Json   ${r}   ${con}.attributes.nameAlias   {{ int.alias | default() }}
    Should Be Equal JMESPath Json   ${r}   ${con}.attributes.vnicName   {{ int.vnic_name | default() }}
{% if dev.active_active | default(defaults.apic.tenants.services.l4l7_devices.active_active) and int.vlan is defined %}
    Should Be Equal JMESPath Json   ${r}   ${con}.attributes.encap   vlan-{{ int.vlan }}
{% endif %}
{% if int.vnic_name is not defined %}
{% if int.node_id is defined and int.channel is not defined %}
{% set query = "nodes[?id==`" ~ int.node_id ~ "`].pod" %}
{% set pod = int.pod_id | default((apic.node_policies | community.general.json_query(query))[0] | default('1')) %}
{% if int.fex_id is defined %}
    Should Be Equal JMESPath Json   ${r}   ${con}.children[?vnsRsCIfPathAtt] | [0].vnsRsCIfPathAtt.attributes.tDn   topology/pod-{{ pod }}/paths-{{ int.node_id }}/extpaths-{{ int.fex_id }}/pathep-[eth{{ int.module | default(defaults.apic.tenants.services.l4l7_devices.concrete_devices.interfaces.module) }}/{{ int.port }}]
{% else %}
    Should Be Equal JMESPath Json   ${r}   ${con}.children[?vnsRsCIfPathAtt] | [0].vnsRsCIfPathAtt.attributes.tDn   topology/pod-{{ pod }}/paths-{{ int.node_id }}/pathep-[eth{{ int.module | default(defaults.apic.tenants.services.l4l7_devices.concrete_devices.interfaces.module) }}/{{ int.port }}]
{% endif %}
{% else %}
{% set query = "leaf_interface_policy_groups[?name==`" ~ int.channel ~ "`].type" %}
{% set type = (apic.access_policies | default() | community.general.json_query(query))[0] | default('vpc' if int.node2_id is defined else 'pc') %}
{% if int.node_id is defined %}
    {% set node = int.node_id %}
{% else %}
    {% set query = "nodes[?interfaces[?policy_group==`" ~ int.channel ~ "`]].id" %}
    {% set node = (apic.interface_policies | default() | community.general.json_query(query))[0] %}
{% endif %}
{% set query = "nodes[?id==`" ~ node ~ "`].pod" %}
{% set pod = int.pod_id | default((apic.node_policies | community.general.json_query(query))[0] | default('1')) %}
{% set policy_group_name = int.channel ~ defaults.apic.access_policies.leaf_interface_policy_groups.name_suffix %}
{% if type == 'vpc' %}
{% if int.node2_id is defined %}
    {% set node2 = int.node2_id %}
{% else %}
    {% set query = "nodes[?interfaces[?policy_group==`" ~ int.channel ~ "`]].id" %}
    {% set node2 = (apic.interface_policies | default() | community.general.json_query(query))[1] %}
    {% if node2 < node %}{% set node_tmp = node %}{% set node = node2 %}{% set node2 = node_tmp %}{% endif %}
{% endif %}
    Should Be Equal JMESPath Json   ${r}   ${con}.children[?vnsRsCIfPathAtt] | [0].vnsRsCIfPathAtt.attributes.tDn   topology/pod-{{ pod }}/protpaths-{{ node }}-{{ node2 }}/pathep-[{{ policy_group_name }}]
{% else %}
    Should Be Equal JMESPath Json   ${r}   ${con}.children[?vnsRsCIfPathAtt] | [0].vnsRsCIfPathAtt.attributes.tDn   topology/pod-{{ pod }}/paths-{{ node }}/pathep-[{{ policy_group_name }}]
{% endif %}
{% endif %}
{% endif %}

{% endfor %}

{% endfor %}

{% for int in dev.logical_interfaces | default([]) %}
{% set int_name = int.name ~ defaults.apic.tenants.services.l4l7_devices.logical_interfaces.name_suffix %}

Verify L4L7 Device {{ dev_name }} Logical Interface {{ int_name }}
    ${con}=   Set Variable   imdata[0].vnsLDevVip.children[?vnsLIf.attributes.name=='{{ int_name }}'] | [0].vnsLIf
    Should Be Equal JMESPath Json   ${r}   ${con}.attributes.name   {{ int_name }}
    Should Be Equal JMESPath Json   ${r}   ${con}.attributes.nameAlias   {{ int.alias | default() }}
    Should Be Equal JMESPath Json   ${r}   ${con}.attributes.encap   {{ ('vlan-' ~ int.vlan) if int.vlan is defined else 'unknown' }}

{% for ci in int.concrete_interfaces | default([]) %}
{% set ci_name = ci.interface_name ~ defaults.apic.tenants.services.l4l7_devices.logical_interfaces.concrete_interfaces.name_suffix  %}
{% set cd_name = ci.device ~ defaults.apic.tenants.services.l4l7_devices.concrete_devices.name_suffix %}

Verify L4L7 Device {{ dev_name }} Logical Interface {{ int_name }} Concrete Interface {{ ci_name }}
    ${int}=   Set Variable   imdata[0].vnsLDevVip.children[?vnsLIf.attributes.name=='{{ int_name }}'] | [0].vnsLIf.children[?vnsRsCIfAttN.attributes.tDn=='uni/tn-{{ tenant.name }}/lDevVip-{{ dev_name }}/cDev-{{ cd_name }}/cIf-[{{ ci_name }}]'] | [0].vnsRsCIfAttN
    Should Be Equal JMESPath Json   ${r}   ${int}.attributes.tDn   uni/tn-{{ tenant.name }}/lDevVip-{{ dev_name }}/cDev-{{ cd_name }}/cIf-[{{ ci_name }}]

{% endfor %}

{% endfor %}

{% endfor %}
