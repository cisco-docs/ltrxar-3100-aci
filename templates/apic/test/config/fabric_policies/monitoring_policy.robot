*** Settings ***
Documentation   Verify Monitoring Policy
Suite Setup     Login APIC
Default Tags    apic   day0   config   fabric_policies
Resource        ../../apic_common.resource

*** Test Cases ***
{% for policy in apic.fabric_policies.monitoring.policies | default([]) if ( policy.name == "common" ) %}
{% for snmp in policy.snmp_traps | default([]) %}
{% set snmp_policy_name = snmp.name ~ defaults.apic.fabric_policies.monitoring.policies.snmp_traps.name_suffix %}

Verify Common Monitoring Policy SNMP Trap Policy {{ snmp_policy_name }}
    ${r}=   GET On Session   apic   /api/mo/uni/fabric/moncommon/snmpsrc-{{ snmp_policy_name }}.json   params=rsp-subtree=full
    Set Suite Variable   $r   ${r.json()}
    Should Be Equal JMESPath Json   ${r}    imdata[0].snmpSrc.attributes.name   {{ snmp_policy_name }}
{% if snmp.destination_group is defined %}
{% set destination_group_name = snmp.destination_group ~ defaults.apic.fabric_policies.monitoring.snmp_traps.name_suffix %}
    Should Be Equal JMESPath Json   ${r}    imdata[0].snmpSrc.children[?snmpRsDestGroup] | [0].snmpRsDestGroup.attributes.tDn   uni/fabric/snmpgroup-{{ destination_group_name }}
{% endif %}

{% endfor %}


{% for syslog in policy.syslogs | default([]) %}
{% set syslog_policy_name = syslog.name ~ defaults.apic.fabric_policies.monitoring.policies.syslogs.name_suffix %}
{% set include = [] %}
{% if syslog.audit | default(defaults.apic.fabric_policies.monitoring.policies.syslogs.audit) %}{% set include = include + [("audit")] %}{% endif %}
{% if syslog.events | default(defaults.apic.fabric_policies.monitoring.policies.syslogs.events) %}{% set include = include + [("events")] %}{% endif %}
{% if syslog.faults | default(defaults.apic.fabric_policies.monitoring.policies.syslogs.faults) %}{% set include = include + [("faults")] %}{% endif %}
{% if syslog.session | default(defaults.apic.fabric_policies.monitoring.policies.syslogs.session) %}{% set include = include + [("session")] %}{% endif %}
{% if include == ['audit', 'events', 'faults', 'session'] %}{% set include = [("all")] + include %}{% endif %}

Verify Common Monitoring Policy Syslog Policy {{ syslog_policy_name }}
    ${r}=   GET On Session   apic   /api/mo/uni/fabric/moncommon/slsrc-{{ syslog_policy_name }}.json   params=rsp-subtree=full
    Set Suite Variable   $r   ${r.json()}
    Should Be Equal JMESPath Json   ${r}    imdata[0].syslogSrc.attributes.name   {{ syslog_policy_name }}
    Should Be Equal JMESPath Json   ${r}    imdata[0].syslogSrc.attributes.incl   {{ include | join(',') }}
    Should Be Equal JMESPath Json   ${r}    imdata[0].syslogSrc.attributes.minSev   {{ syslog.minimum_severity | default(defaults.apic.fabric_policies.monitoring.policies.syslogs.minimum_severity) }}
{% if syslog.destination_group is defined %}
    {% set destination_group_name = syslog.destination_group ~ defaults.apic.fabric_policies.monitoring.syslogs.name_suffix %}
    Should Be Equal JMESPath Json   ${r}    imdata[0].syslogSrc.children[?syslogRsDestGroup] | [0].syslogRsDestGroup.attributes.tDn   uni/fabric/slgroup-{{ destination_group_name }}
{% endif %}

{% endfor %}
{% endfor %}

{% for policy in apic.fabric_policies.monitoring.policies | default([]) if ( policy.name != "common" ) %}
{% set policy_name = policy.name ~ defaults.apic.fabric_policies.monitoring.policies.name_suffix %}

Verify User-Defined Monitoring Policy {{ policy_name }}
    ${r}=   GET On Session   apic   /api/mo/uni/fabric/monfab-{{ policy_name }}.json   params=rsp-subtree=full
    Set Suite Variable   $r   ${r.json()}
    Should Be Equal JMESPath Json   ${r}    imdata[0].monFabricPol.attributes.name   {{ policy_name }}
    Should Be Equal JMESPath Json   ${r}    imdata[0].monFabricPol.attributes.descr   {{ policy.description | default() }}

{% for snmp in policy.snmp_traps | default([]) %}
{% set snmp_policy_name = snmp.name ~ defaults.apic.fabric_policies.monitoring.policies.snmp_traps.name_suffix %}

Verify User-Defined Monitoring Policy {{ policy_name }} SNMP Trap Policy {{ snmp_policy_name }}
    ${mon}=   Set Variable    imdata[0].monFabricPol.children[?(@.snmpSrc.attributes.name=='{{ snmp_policy_name }}')] | [0]
    Should Be Equal JMESPath Json   ${r}    ${mon}.snmpSrc.attributes.name  {{ snmp_policy_name }}
{% if snmp.destination_group is defined %}
{% set destination_group_name = snmp.destination_group ~ defaults.apic.fabric_policies.monitoring.snmp_traps.name_suffix %}
    Should Be Equal JMESPath Json   ${r}    ${mon}.snmpSrc.children[?snmpRsDestGroup] | [0].snmpRsDestGroup.attributes.tDn  uni/fabric/snmpgroup-{{ destination_group_name }}
{% endif %}

{% endfor %}

{% for syslog in policy.syslogs | default([]) %}
{% set syslog_policy_name = syslog.name ~ defaults.apic.fabric_policies.monitoring.policies.syslogs.name_suffix %}
{% set include = [] %}
{% if syslog.audit | default(defaults.apic.fabric_policies.monitoring.policies.syslogs.audit) %}{% set include = include + [("audit")] %}{% endif %}
{% if syslog.events | default(defaults.apic.fabric_policies.monitoring.policies.syslogs.events) %}{% set include = include + [("events")] %}{% endif %}
{% if syslog.faults | default(defaults.apic.fabric_policies.monitoring.policies.syslogs.faults) %}{% set include = include + [("faults")] %}{% endif %}
{% if syslog.session | default(defaults.apic.fabric_policies.monitoring.policies.syslogs.session) %}{% set include = include + [("session")] %}{% endif %}
{% if include == ['audit', 'events', 'faults', 'session'] %}{% set include = [("all")] + include %}{% endif %}

Verify User-Defined Monitoring Policy {{ policy_name }} Syslog Policy {{ syslog_policy_name }}
    ${sysl}=   Set Variable    imdata[0].monFabricPol.children[?(@.syslogSrc.attributes.name=='{{ syslog_policy_name }}')] | [0]
    Should Be Equal JMESPath Json   ${r}    ${sysl}.syslogSrc.attributes.name  {{ syslog_policy_name }}
    Should Be Equal JMESPath Json   ${r}    ${sysl}.syslogSrc.attributes.incl   {{ include | join(',') }}
    Should Be Equal JMESPath Json   ${r}    ${sysl}.syslogSrc.attributes.minSev   {{ syslog.minimum_severity | default(defaults.apic.fabric_policies.monitoring.policies.syslogs.minimum_severity) }}
{% if syslog.destination_group is defined %}
{% set destination_group_name = syslog.destination_group ~ defaults.apic.fabric_policies.monitoring.syslogs.name_suffix %}
    Should Be Equal JMESPath Json   ${r}    ${sysl}.syslogSrc.children[?syslogRsDestGroup] | [0].syslogRsDestGroup.attributes.tDn   uni/fabric/slgroup-{{ destination_group_name }}
{% endif %}

{% endfor %}

{% for cl in policy.fault_severity_policies | default([]) %}

Verify User-Defined Monitoring Policy {{ policy_name }} Fault Severity Policy {{ cl.class }}
    Should Be Equal JMESPath Json   ${r}    imdata[0].monFabricPol.children[?monFabricTarget.attributes.scope=='{{ cl.class }}'] | [0].monFabricTarget.attributes.scope  {{ cl.class }}
{% for fault in cl.faults | default([]) %}
Verify User-Defined Monitoring Policy {{ policy_name }} Fault Severity Policy Class {{ cl.class }} Fault {{ fault.fault_id }}
    ${sev}=   Set Variable    imdata[0].monFabricPol.children[?monFabricTarget.attributes.scope=='{{ cl.class }}'] | [0].monFabricTarget.children[?faultSevAsnP.attributes.code=='{{ fault.fault_id }}'] | [0]
    Should Be Equal JMESPath Json   ${r}    ${sev}.faultSevAsnP.attributes.code  {{ fault.fault_id }}
    Should Be Equal JMESPath Json   ${r}    ${sev}.faultSevAsnP.attributes.initial  {{ fault.initial_severity | default(defaults.apic.fabric_policies.monitoring.policies.fault_severity_policies.faults.initial_severity) }}
    Should Be Equal JMESPath Json   ${r}    ${sev}.faultSevAsnP.attributes.target  {{ fault.target_severity | default(defaults.apic.fabric_policies.monitoring.policies.fault_severity_policies.faults.target_severity) }}
    Should Be Equal JMESPath Json   ${r}    ${sev}.faultSevAsnP.attributes.descr  {{ fault.description | default() }}

{% endfor %}

{% endfor %}

{% endfor %}
