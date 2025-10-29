{# iterate_list apic.tenants name item[2] #}
*** Settings ***
Documentation   Verify Service Graph Template
Suite Setup     Login APIC
Default Tags    apic   day2   config   tenants
Resource        ../../../apic_common.resource

*** Test Cases ***
{% set tenant = ((apic | default()) | community.general.json_query('tenants[?name==`' ~ item[2] ~ '`]'))[0] %}
{% for sgt in tenant.services.service_graph_templates | default([]) %}
{% set sgt_name = sgt.name ~ defaults.apic.tenants.services.service_graph_templates.name_suffix %}
{% set ten = sgt.device.tenant | default(tenant.name) %}
{% set query1 = "tenants[?name==`" ~ ten ~ "`]" %}
{% set query2 = "services.l4l7_devices[?name==`" ~ sgt.device.name ~ "`]" %}
{% set t = (apic | community.general.json_query(query1))[0] %}
{% set dev = (t | community.general.json_query(query2))[0] %}
{% set dev_name = sgt.device.name  ~ defaults.apic.tenants.services.l4l7_devices.name_suffix %}

Verify Service Graph Template {{ sgt_name }}
    ${r}=   GET On Session   apic   /api/mo/uni/tn-{{ tenant.name }}/AbsGraph-{{ sgt_name }}.json   params=rsp-subtree=full
    Set Suite Variable   $r   ${r.json()}
    Should Be Equal Value Json String   ${r}   $..vnsAbsGraph.attributes.name   {{ sgt_name }}
    Should Be Equal Value Json String   ${r}   $..vnsAbsGraph.attributes.nameAlias   {{ sgt.alias  | default() }}
    Should Be Equal Value Json String   ${r}   $..vnsAbsGraph.attributes.descr   {{ sgt.description | default() }}
    Should Be Equal Value Json String   ${r}   $..vnsAbsNode.attributes.funcTemplateType   {{ sgt.template_type | default(defaults.apic.tenants.services.service_graph_templates.template_type) }}
    Should Be Equal Value Json String   ${r}   $..vnsAbsNode.attributes.funcType   {{ dev.function | default(defaults.apic.tenants.services.l4l7_devices.function) }}
    Should Be Equal Value Json String   ${r}   $..vnsAbsNode.attributes.isCopy   {{ 'yes' if dev.copy_device | default(defaults.apic.tenants.services.l4l7_devices.copy_device) else 'no' }}
    Should Be Equal Value Json String   ${r}   $..vnsAbsNode.attributes.managed   {{ 'yes' if dev.managed | default(defaults.apic.tenants.services.l4l7_devices.managed) else 'no' }}
    Should Be Equal Value Json String   ${r}   $..vnsAbsNode.attributes.name   {{ sgt.device.node_name | default("CP1") if dev.copy_device | default(defaults.apic.tenants.services.l4l7_devices.copy_device) else sgt.device.node_name | default("N1") }}
    Should Be Equal Value Json String   ${r}   $..vnsAbsNode.attributes.routingMode   {{ 'Redirect' if sgt.redirect | default(defaults.apic.tenants.services.service_graph_templates.redirect) else 'unspecified' }}
    Should Be Equal Value Json String   ${r}   $..vnsAbsNode.attributes.shareEncap   {{ 'yes' if sgt.share_encapsulation | default(defaults.apic.tenants.services.service_graph_templates.share_encapsulation) else 'no' }}
{% if tenant.name == sgt.device.tenant | default(tenant.name) %}
    Should Be Equal Value Json String   ${r}   $..vnsRsNodeToLDev.attributes.tDn   uni/tn-{{ sgt.device.tenant | default(tenant.name) }}/lDevVip-{{ dev_name }}
{% else %}
    Should Be Equal Value Json String   ${r}   $..vnsRsNodeToLDev.attributes.tDn   uni/tn-{{ tenant.name }}/lDevIf-[uni/tn-{{sgt.device.tenant }}/lDevVip-{{ dev_name }}]
{% endif %}
{% if dev.copy_device | default(defaults.apic.tenants.services.l4l7_devices.copy_device) %}
    Should Be Equal Value Json String   ${r}   $..vnsAbsGraph.children[?(@.vnsAbsConnection.attributes.name=='C1')].vnsAbsConnection.attributes.directConnect   {{ 'yes' if sgt.consumer.direct_connect | default(defaults.apic.tenants.services.service_graph_templates.consumer.direct_connect) else 'no' }}
    Should Be Equal Value Json String   ${r}   $..vnsAbsGraph.children[?(@.vnsAbsConnection.attributes.name=='C1')].vnsAbsConnection.attributes.adjType   L2
{% else %}
    Should Be Equal Value Json String   ${r}   $..vnsAbsGraph.children[?(@.vnsAbsConnection.attributes.name=='C1')].vnsAbsConnection.attributes.directConnect   {{ 'yes' if sgt.consumer.direct_connect | default(defaults.apic.tenants.services.service_graph_templates.consumer.direct_connect) else 'no' }}
    Should Be Equal Value Json String   ${r}   $..vnsAbsGraph.children[?(@.vnsAbsConnection.attributes.name=='C2')].vnsAbsConnection.attributes.directConnect   {{ 'yes' if sgt.provider.direct_connect | default(defaults.apic.tenants.services.service_graph_templates.provider.direct_connect) else 'no' }}
{% endif %}
{% endfor %}
