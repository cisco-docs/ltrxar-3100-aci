*** Settings ***
Documentation   Verify Syslog Policy
Suite Setup     Login APIC
Default Tags    apic   day0   config   fabric_policies
Resource        ../../apic_common.resource

*** Test Cases ***
{% for syslog in apic.fabric_policies.monitoring.syslogs | default([]) %}
{% set policy_name = syslog.name ~ defaults.apic.fabric_policies.monitoring.syslogs.name_suffix %}

Verify Syslog Policy {{ policy_name }}
    ${r}=   GET On Session   apic   /api/mo/uni/fabric/slgroup-{{ policy_name }}.json   params=rsp-subtree=full
    Set Suite Variable   $r   ${r.json()}
    Should Be Equal Value Json String   ${r}    $..syslogGroup.attributes.name   {{ policy_name }}
    Should Be Equal Value Json String   ${r}    $..syslogGroup.attributes.descr   {{ syslog.description | default() }}
    Should Be Equal Value Json String   ${r}    $..syslogGroup.attributes.format   {{ 'rfc5424-ts' if syslog.format | default(defaults.apic.fabric_policies.monitoring.syslogs.format) == 'enhanced-log' else syslog.format | default(defaults.apic.fabric_policies.monitoring.syslogs.format) }}
    Should Be Equal Value Json String   ${r}    $..syslogGroup.attributes.includeTimeZone    {{ 'yes' if syslog.show_timezone | default(defaults.apic.fabric_policies.monitoring.syslogs.show_timezone) else 'no' }}
    Should Be Equal Value Json String   ${r}    $..syslogGroup.attributes.includeMilliSeconds   {{ 'yes' if syslog.show_millisecond | default(defaults.apic.fabric_policies.monitoring.syslogs.show_millisecond) else 'no' }}

{% for dest in syslog.destinations | default([]) %}

Verify Syslog Policy {{ policy_name }} Destination {{ dest.hostname_ip }}
    ${dest}=   Set Variable   $..syslogGroup.children[?(@.syslogRemoteDest.attributes.host=='{{ dest.hostname_ip }}')]
    Should Be Equal Value Json String   ${r}    ${dest}..syslogRemoteDest.attributes.name   {{ dest.name | default() }}
    Should Be Equal Value Json String   ${r}    ${dest}..syslogRemoteDest.attributes.host   {{ dest.hostname_ip }}
{% if dest.protocol is defined %}
    Should Be Equal Value Json String   ${r}    ${dest}..syslogRemoteDest.attributes.protocol   {{ dest.protocol | default(defaults.apic.fabric_policies.monitoring.syslogs.destinations.protocol) }}
{% endif %}
    Should Be Equal Value Json String   ${r}    ${dest}..syslogRemoteDest.attributes.port   {{ dest.port | default(defaults.apic.fabric_policies.monitoring.syslogs.destinations.port) }}
    Should Be Equal Value Json String   ${r}    ${dest}..syslogRemoteDest.attributes.adminState   {{ 'enabled' if dest.admin_state | default(defaults.apic.fabric_policies.monitoring.syslogs.destinations.admin_state) else 'disabled' }}
    Should Be Equal Value Json String   ${r}    ${dest}..syslogRemoteDest.attributes.format   {{ 'rfc5424-ts' if syslog.format | default(defaults.apic.fabric_policies.monitoring.syslogs.format) == 'enhanced-log' else syslog.format | default(defaults.apic.fabric_policies.monitoring.syslogs.format) }}
    Should Be Equal Value Json String   ${r}    ${dest}..syslogRemoteDest.attributes.forwardingFacility   {{ dest.facility | default(defaults.apic.fabric_policies.monitoring.syslogs.destinations.facility) }}
    Should Be Equal Value Json String   ${r}    ${dest}..syslogRemoteDest.attributes.severity   {{ dest.severity | default(defaults.apic.fabric_policies.monitoring.syslogs.destinations.severity) }}
{% set mgmt_epg = dest.mgmt_epg | default(defaults.apic.fabric_policies.monitoring.syslogs.destinations.mgmt_epg) %}
{% if mgmt_epg == "oob" %}
    Should Be Equal Value Json String   ${r}    $..fileRsARemoteHostToEpg.attributes.tDn   uni/tn-mgmt/mgmtp-default/oob-{{ apic.node_policies.oob_endpoint_group | default(defaults.apic.node_policies.oob_endpoint_group) }}
{% elif mgmt_epg == "inb" %}
    Should Be Equal Value Json String   ${r}    $..fileRsARemoteHostToEpg.attributes.tDn   uni/tn-mgmt/mgmtp-default/inb-{{ apic.node_policies.inb_endpoint_group | default(defaults.apic.node_policies.inb_endpoint_group) }}
{% endif %}
    Should Be Equal Value Json String   ${r}    $..syslogProf.attributes.adminState   {{ 'enabled' if syslog.admin_state | default(defaults.apic.fabric_policies.monitoring.syslogs.admin_state) else 'disabled' }}
    Should Be Equal Value Json String   ${r}    $..syslogFile.attributes.adminState   {{ 'enabled' if syslog.local_admin_state | default(defaults.apic.fabric_policies.monitoring.syslogs.local_admin_state) else 'disabled' }}
    Should Be Equal Value Json String   ${r}    $..syslogFile.attributes.format   {{ 'rfc5424-ts' if syslog.format | default(defaults.apic.fabric_policies.monitoring.syslogs.format) == 'enhanced-log' else syslog.format | default(defaults.apic.fabric_policies.monitoring.syslogs.format) }}
    Should Be Equal Value Json String   ${r}    $..syslogFile.attributes.severity   {{ syslog.local_severity | default(defaults.apic.fabric_policies.monitoring.syslogs.local_severity) }}
    Should Be Equal Value Json String   ${r}    $..syslogConsole.attributes.adminState   {{ 'enabled' if syslog.console_admin_state | default(defaults.apic.fabric_policies.monitoring.syslogs.console_admin_state) else 'disabled' }}
    Should Be Equal Value Json String   ${r}    $..syslogConsole.attributes.format   {{ 'rfc5424-ts' if syslog.format | default(defaults.apic.fabric_policies.monitoring.syslogs.format) == 'enhanced-log' else syslog.format | default(defaults.apic.fabric_policies.monitoring.syslogs.format) }}
    Should Be Equal Value Json String   ${r}    $..syslogConsole.attributes.severity   {{ syslog.console_severity | default(defaults.apic.fabric_policies.monitoring.syslogs.console_severity) }}

{% endfor %}

{% endfor %}
