{# iterate_list apic.tenants name item[2] #}
*** Settings ***
Documentation   Verify Tenant Monitoring Policy
Suite Setup     Login APIC
Default Tags    apic   day2   config   tenants
Resource        ../../../apic_common.resource

*** Test Cases ***
{% set tenant = ((apic | default()) | community.general.json_query('tenants[?name==`' ~ item[2] ~ '`]'))[0] %}
{% for monitor in tenant.policies.netflow_monitors | default([]) %}
{% set monitor_name = monitor.name ~ defaults.apic.tenants.policies.netflow_monitors.name_suffix %}

Verify Netflow Monitor {{ monitor_name }}
    ${r}=   GET On Session   apic   /api/mo/uni/tn-{{ tenant.name }}/monitorpol-{{ monitor_name }}.json   params=rsp-subtree=full
    Set Suite Variable   ${r}   ${r.json()}
    Should Be Equal JMESPath Json   ${r}    imdata[0].netflowMonitorPol.attributes.name   {{ monitor_name }}
    Should Be Equal JMESPath Json   ${r}    imdata[0].netflowMonitorPol.attributes.descr   {{ monitor.description | default() }}

{% if monitor.flow_record is defined %}
{% set record_name = monitor.flow_record ~ defaults.apic.tenants.policies.netflow_records.name_suffix %}
Verify Netflow Monitor {{ monitor_name }} Record {{ record_name }}
    Should Be Equal JMESPath Json   ${r}    imdata[0].netflowMonitorPol.children[?netflowRsMonitorToRecord] | [0].netflowRsMonitorToRecord.attributes.tnNetflowRecordPolName   {{ record_name }}
{% endif %}

{% for exporter in monitor.flow_exporters | default([]) %}
{% set exporter_name = exporter ~ defaults.apic.tenants.policies.netflow_exporters.name_suffix %}
Verify Netflow Monitor {{ monitor_name }} Exporter {{ exporter_name }}
    ${exp}=   Set Variable   imdata[0].netflowMonitorPol.children[?netflowRsMonitorToExporter.attributes.tnNetflowExporterPolName=='{{ exporter_name }}'] | [0].netflowRsMonitorToExporter
    Should Be Equal JMESPath Json   ${r}    ${exp}.attributes.tnNetflowExporterPolName   {{ exporter_name }}
{% endfor %}

{% endfor %}
