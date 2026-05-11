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

Verify Service Graph Template {{ sgt_name }}
    ${r}=   GET On Session   apic   /api/mo/uni/tn-{{ tenant.name }}/AbsGraph-{{ sgt_name }}.json   params=rsp-subtree=full
    Set Suite Variable   $r   ${r.json()}
    Should Be Equal JMESPath Json   ${r}   imdata[0].vnsAbsGraph.attributes.name   {{ sgt_name }}
    Should Be Equal JMESPath Json   ${r}   imdata[0].vnsAbsGraph.attributes.nameAlias   {{ sgt.alias  | default() }}
    Should Be Equal JMESPath Json   ${r}   imdata[0].vnsAbsGraph.attributes.descr   {{ sgt.description | default() }}

{% if sgt.device is defined %}
{% set ten = sgt.device.tenant | default(tenant.name) %}
{% set query1 = "tenants[?name==`" ~ ten ~ "`]" %}
{% set query2 = "services.l4l7_devices[?name==`" ~ sgt.device.name ~ "`]" %}
{% set t = (apic | community.general.json_query(query1))[0] %}
{% set dev = (t | community.general.json_query(query2))[0] %}
{% set dev_name = sgt.device.name  ~ defaults.apic.tenants.services.l4l7_devices.name_suffix %}

Verify Service Graph Template {{ sgt_name }} - Single Device Node
    Should Be Equal JMESPath Json   ${r}   imdata[0].vnsAbsGraph.children[?vnsAbsNode] | [0].vnsAbsNode.attributes.funcTemplateType   {{ sgt.template_type | default(defaults.apic.tenants.services.service_graph_templates.template_type) }}
    Should Be Equal JMESPath Json   ${r}   imdata[0].vnsAbsGraph.children[?vnsAbsNode] | [0].vnsAbsNode.attributes.funcType   {{ dev.function | default(defaults.apic.tenants.services.l4l7_devices.function) }}
    Should Be Equal JMESPath Json   ${r}   imdata[0].vnsAbsGraph.children[?vnsAbsNode] | [0].vnsAbsNode.attributes.isCopy   {{ 'yes' if dev.copy_device | default(defaults.apic.tenants.services.l4l7_devices.copy_device) else 'no' }}
    Should Be Equal JMESPath Json   ${r}   imdata[0].vnsAbsGraph.children[?vnsAbsNode] | [0].vnsAbsNode.attributes.managed   {{ 'yes' if dev.managed | default(defaults.apic.tenants.services.l4l7_devices.managed) else 'no' }}
    Should Be Equal JMESPath Json   ${r}   imdata[0].vnsAbsGraph.children[?vnsAbsNode] | [0].vnsAbsNode.attributes.name   {{ sgt.device.node_name | default("CP1") if dev.copy_device | default(defaults.apic.tenants.services.l4l7_devices.copy_device) else sgt.device.node_name | default("N1") }}
    Should Be Equal JMESPath Json   ${r}   imdata[0].vnsAbsGraph.children[?vnsAbsNode] | [0].vnsAbsNode.attributes.routingMode   {{ 'Redirect' if sgt.redirect | default(defaults.apic.tenants.services.service_graph_templates.redirect) else 'unspecified' }}
    Should Be Equal JMESPath Json   ${r}   imdata[0].vnsAbsGraph.children[?vnsAbsNode] | [0].vnsAbsNode.attributes.shareEncap   {{ 'yes' if sgt.share_encapsulation | default(defaults.apic.tenants.services.service_graph_templates.share_encapsulation) else 'no' }}
{% if tenant.name == sgt.device.tenant | default(tenant.name) %}
    Should Be Equal JMESPath Json   ${r}   imdata[0].vnsAbsGraph.children[?vnsAbsNode] | [0].vnsAbsNode.children[?vnsRsNodeToLDev] | [0].vnsRsNodeToLDev.attributes.tDn   uni/tn-{{ sgt.device.tenant | default(tenant.name) }}/lDevVip-{{ dev_name }}
{% else %}
    Should Be Equal JMESPath Json   ${r}   imdata[0].vnsAbsGraph.children[?vnsAbsNode] | [0].vnsAbsNode.children[?vnsRsNodeToLDev] | [0].vnsRsNodeToLDev.attributes.tDn   uni/tn-{{ tenant.name }}/lDevIf-[uni/tn-{{sgt.device.tenant }}/lDevVip-{{ dev_name }}]
{% endif %}

Verify Service Graph Template {{ sgt_name }} - Single Device Connections
{% if dev.copy_device | default(defaults.apic.tenants.services.l4l7_devices.copy_device) %}
    Should Be Equal JMESPath Json   ${r}   imdata[0].vnsAbsGraph.children[?vnsAbsConnection.attributes.name=='C1'] | [0].vnsAbsConnection.attributes.directConnect   {{ 'yes' if sgt.consumer.direct_connect | default(defaults.apic.tenants.services.service_graph_templates.consumer.direct_connect) else 'no' }}
{% else %}
    Should Be Equal JMESPath Json   ${r}   imdata[0].vnsAbsGraph.children[?vnsAbsConnection.attributes.name=='C1'] | [0].vnsAbsConnection.attributes.directConnect   {{ 'yes' if sgt.consumer.direct_connect | default(defaults.apic.tenants.services.service_graph_templates.consumer.direct_connect) else 'no' }}
    Should Be Equal JMESPath Json   ${r}   imdata[0].vnsAbsGraph.children[?vnsAbsConnection.attributes.name=='C2'] | [0].vnsAbsConnection.attributes.directConnect   {{ 'yes' if sgt.provider.direct_connect | default(defaults.apic.tenants.services.service_graph_templates.provider.direct_connect) else 'no' }}
    Should Be Equal JMESPath Json   ${r}   imdata[0].vnsAbsGraph.children[?vnsAbsConnection.attributes.name=='C2'] | [0].vnsAbsConnection.attributes.adjType   {{ sgt.device.adjacency_type | default(defaults.apic.tenants.services.service_graph_templates.device.adjacency_type) }}
{% endif %}
    Should Be Equal JMESPath Json   ${r}   imdata[0].vnsAbsGraph.children[?vnsAbsConnection.attributes.name=='C1'] | [0].vnsAbsConnection.attributes.adjType   {{ sgt.device.adjacency_type | default(defaults.apic.tenants.services.service_graph_templates.device.adjacency_type) }}

{% else %}
{% for device in sgt.devices | default([]) %}
{% set dev_ten = device.tenant | default(tenant.name) %}
{% set query1 = "tenants[?name==`" ~ dev_ten ~ "`]" %}
{% set query2 = "services.l4l7_devices[?name==`" ~ device.name ~ "`]" %}
{% set t = (apic | community.general.json_query(query1))[0] %}
{% set dev = (t | community.general.json_query(query2))[0] %}
{% set dev_name = device.name ~ defaults.apic.tenants.services.l4l7_devices.name_suffix %}
{% set node_name = device.node_name | default(device.name) %}

Verify Service Graph Template {{ sgt_name }} - Device {{ node_name }}
    Should Be Equal JMESPath Json   ${r}   imdata[0].vnsAbsGraph.children[?vnsAbsNode.attributes.name=='{{ node_name }}'] | [0].vnsAbsNode.attributes.funcTemplateType   {{ device.template_type | default(sgt.template_type) | default(defaults.apic.tenants.services.service_graph_templates.devices.template_type) }}
    Should Be Equal JMESPath Json   ${r}   imdata[0].vnsAbsGraph.children[?vnsAbsNode.attributes.name=='{{ node_name }}'] | [0].vnsAbsNode.attributes.funcType   {{ dev.function | default(defaults.apic.tenants.services.l4l7_devices.function) }}
    Should Be Equal JMESPath Json   ${r}   imdata[0].vnsAbsGraph.children[?vnsAbsNode.attributes.name=='{{ node_name }}'] | [0].vnsAbsNode.attributes.isCopy   {{ 'yes' if dev.copy_device | default(defaults.apic.tenants.services.l4l7_devices.copy_device) else 'no' }}
    Should Be Equal JMESPath Json   ${r}   imdata[0].vnsAbsGraph.children[?vnsAbsNode.attributes.name=='{{ node_name }}'] | [0].vnsAbsNode.attributes.managed   {{ 'yes' if dev.managed | default(defaults.apic.tenants.services.l4l7_devices.managed) else 'no' }}
    Should Be Equal JMESPath Json   ${r}   imdata[0].vnsAbsGraph.children[?vnsAbsNode.attributes.name=='{{ node_name }}'] | [0].vnsAbsNode.attributes.name   {{ node_name }}
    Should Be Equal JMESPath Json   ${r}   imdata[0].vnsAbsGraph.children[?vnsAbsNode.attributes.name=='{{ node_name }}'] | [0].vnsAbsNode.attributes.routingMode   {{ 'Redirect' if sgt.redirect | default(defaults.apic.tenants.services.service_graph_templates.redirect) else 'unspecified' }}
    Should Be Equal JMESPath Json   ${r}   imdata[0].vnsAbsGraph.children[?vnsAbsNode.attributes.name=='{{ node_name }}'] | [0].vnsAbsNode.attributes.shareEncap   {{ 'yes' if sgt.share_encapsulation | default(defaults.apic.tenants.services.service_graph_templates.share_encapsulation) else 'no' }}
    Should Be Equal JMESPath Json   ${r}   imdata[0].vnsAbsGraph.children[?vnsAbsNode.attributes.name=='{{ node_name }}'] | [0].vnsAbsNode.attributes.sequenceNumber   {{ loop.index0 }}
{% if tenant.name == dev_ten %}
    Should Be Equal JMESPath Json   ${r}   imdata[0].vnsAbsGraph.children[?vnsAbsNode.attributes.name=='{{ node_name }}'] | [0].vnsAbsNode.children[?vnsRsNodeToLDev] | [0].vnsRsNodeToLDev.attributes.tDn   uni/tn-{{ dev_ten }}/lDevVip-{{ dev_name }}
{% else %}
    Should Be Equal JMESPath Json   ${r}   imdata[0].vnsAbsGraph.children[?vnsAbsNode.attributes.name=='{{ node_name }}'] | [0].vnsAbsNode.children[?vnsRsNodeToLDev] | [0].vnsRsNodeToLDev.attributes.tDn   uni/tn-{{ tenant.name }}/lDevIf-[uni/tn-{{ dev_ten }}/lDevVip-{{ dev_name }}]
{% endif %}
{% endfor %}

{% for conn in sgt.connections | default([]) %}
{% set conn_name = "C" ~ loop.index %}
{%  set ns = namespace(copy_node=none, consumer_node=conn.consumer_node, provider_node=conn.provider_node) %}
{% if conn.copy_node is defined %}
{%   set ns.copy_node = conn.copy_node %}
{%   for device in sgt.devices | default([]) %}
{%     if device.name == conn.copy_node %}
{%       set ns.copy_node = device.node_name | default(device.name) %}
{%     endif %}
{%   endfor %}
{% endif %}
{% if conn.consumer_node != "EPG-Consumer" %}
{%   for device in sgt.devices | default([]) %}
{%     if device.name == conn.consumer_node %}
{%       set ns.consumer_node = device.node_name | default(device.name) %}
{%     endif %}
{%   endfor %}
{% endif %}
{% if conn.provider_node != "EPG-Provider" %}
{%   for device in sgt.devices | default([]) %}
{%     if device.name == conn.provider_node %}
{%       set ns.provider_node = device.node_name | default(device.name) %}
{%     endif %}
{%   endfor %}
{% endif %}
Verify Service Graph Template {{ sgt_name }} - Connection {{ conn_name }}
    Should Be Equal JMESPath Json   ${r}   imdata[0].vnsAbsGraph.children[?vnsAbsConnection.attributes.name=='{{ conn_name }}'] | [0].vnsAbsConnection.attributes.adjType   {{ conn.adjacency_type | default(defaults.apic.tenants.services.service_graph_templates.connections.adjacency_type) }}
    Should Be Equal JMESPath Json   ${r}   imdata[0].vnsAbsGraph.children[?vnsAbsConnection.attributes.name=='{{ conn_name }}'] | [0].vnsAbsConnection.attributes.directConnect   {{ 'yes' if conn.direct_connect | default(defaults.apic.tenants.services.service_graph_templates.connections.direct_connect) else 'no' }}
    Should Be Equal JMESPath Json   ${r}   imdata[0].vnsAbsGraph.children[?vnsAbsConnection.attributes.name=='{{ conn_name }}'] | [0].vnsAbsConnection.attributes.unicastRoute   {{ 'yes' if conn.unicast_route | default(defaults.apic.tenants.services.service_graph_templates.connections.unicast_route) else 'no' }}
{% if ns.copy_node is not none %}
    Should Be Equal JMESPath Json   ${r}   imdata[0].vnsAbsGraph.children[?vnsAbsConnection.attributes.name=='{{ conn_name }}'] | [0].vnsAbsConnection.children[?vnsRsAbsCopyConnection] | [0].vnsRsAbsCopyConnection.attributes.tDn   uni/tn-{{ tenant.name }}/AbsGraph-{{ sgt_name }}/AbsNode-{{ ns.copy_node }}/AbsFConn-copy
{% endif %}
{% if conn.consumer_node == "EPG-Consumer" %}
{%   set consumer_tdn = "uni/tn-" ~ tenant.name ~ "/AbsGraph-" ~ sgt_name ~ "/AbsTermNodeCon-T1/AbsTConn" %}
{% else %}
{%   set consumer_tdn = "uni/tn-" ~ tenant.name ~ "/AbsGraph-" ~ sgt_name ~ "/AbsNode-" ~ ns.consumer_node ~ "/AbsFConn-consumer" %}
{% endif %}
{% if conn.provider_node == "EPG-Provider" %}
{%   set provider_tdn = "uni/tn-" ~ tenant.name ~ "/AbsGraph-" ~ sgt_name ~ "/AbsTermNodeProv-T2/AbsTConn" %}
{% else %}
{%   set provider_tdn = "uni/tn-" ~ tenant.name ~ "/AbsGraph-" ~ sgt_name ~ "/AbsNode-" ~ ns.provider_node ~ "/AbsFConn-provider" %}
{% endif %}
    Should Be Equal JMESPath Json   ${r}   imdata[0].vnsAbsGraph.children[?vnsAbsConnection.attributes.name=='{{ conn_name }}'] | [0].vnsAbsConnection.children[?vnsRsAbsConnectionConns.attributes.tDn=='{{ consumer_tdn }}'] | [0].vnsRsAbsConnectionConns.attributes.tDn   {{ consumer_tdn }}
    Should Be Equal JMESPath Json   ${r}   imdata[0].vnsAbsGraph.children[?vnsAbsConnection.attributes.name=='{{ conn_name }}'] | [0].vnsAbsConnection.children[?vnsRsAbsConnectionConns.attributes.tDn=='{{ provider_tdn }}'] | [0].vnsRsAbsConnectionConns.attributes.tDn   {{ provider_tdn }}
{% endfor %}

{% endif %}
{% endfor %}
