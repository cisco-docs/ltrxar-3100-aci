*** Settings ***
Documentation   Verify Access Monitoring Policy
Suite Setup     Login APIC
Default Tags    apic   day2   config   access_policies
Resource        ../../apic_common.resource

*** Test Cases ***
{% for policy in apic.access_policies.monitoring.policies | default([]) %}
{% set policy_name = policy.name ~ defaults.apic.access_policies.monitoring.policies.name_suffix %}

Verify Monitoring Policy {{ policy_name }}
    ${r}=   GET On Session   apic   /api/mo/uni/infra/moninfra-{{policy_name}}.json   params=rsp-subtree=full
    Set Suite Variable   $r   ${r.json()}
    Should Be Equal JMESPath Json   ${r}    imdata[0].monInfraPol.attributes.name   {{ policy_name }}

{% for snmp in policy.snmp_traps | default([]) %}
{% set snmp_policy_name = snmp.name ~ defaults.apic.access_policies.monitoring.policies.snmp_traps.name_suffix %}

Verify Monitoring Policy {{ policy_name }} SNMP Policy {{ snmp_policy_name }}
    ${mon}=   Set Variable    imdata[0].monInfraPol.children[?snmpSrc.attributes.name=='{{ snmp_policy_name }}'] | [0]
    Should Be Equal JMESPath Json   ${r}    ${mon}.snmpSrc.attributes.name  {{ snmp_policy_name }}
{% if snmp.destination_group is defined %}
    Should Be Equal JMESPath Json   ${r}    ${mon}.snmpSrc.children[?snmpRsDestGroup] | [0].snmpRsDestGroup.attributes.tDn   uni/fabric/snmpgroup-{{ snmp.destination_group ~ defaults.apic.access_policies.monitoring.policies.snmp_traps.name_suffix }}
{% endif %}
{% endfor %}

{% for syslog in policy.syslogs | default([]) %}
{% set syslog_policy_name = syslog.name ~ defaults.apic.access_policies.monitoring.policies.syslogs.name_suffix %}
{% set include = [] %}
{% if syslog.audit | default(defaults.apic.access_policies.monitoring.policies.syslogs.audit) %}{% set include = include + [("audit")] %}{% endif %}
{% if syslog.events | default(defaults.apic.access_policies.monitoring.policies.syslogs.events) %}{% set include = include + [("events")] %}{% endif %}
{% if syslog.faults | default(defaults.apic.access_policies.monitoring.policies.syslogs.faults) %}{% set include = include + [("faults")] %}{% endif %}
{% if syslog.session | default(defaults.apic.access_policies.monitoring.policies.syslogs.session) %}{% set include = include + [("session")] %}{% endif %}
{% if include == ['audit', 'events', 'faults', 'session'] %}{% set include = [("all")] + include %}{% endif %}

Verify Monitoring Policy {{ policy_name }} Syslog Policy {{ syslog_policy_name }}
    ${sysl}=   Set Variable    imdata[0].monInfraPol.children[?syslogSrc.attributes.name=='{{ syslog_policy_name }}'] | [0]
    Should Be Equal JMESPath Json   ${r}    ${sysl}.syslogSrc.attributes.name  {{ syslog_policy_name }}
    Should Be Equal JMESPath Json   ${r}    ${sysl}.syslogSrc.attributes.incl   {{ include | join(',') }}
    Should Be Equal JMESPath Json   ${r}    ${sysl}.syslogSrc.attributes.minSev   {{ syslog.minimum_severity | default(defaults.apic.access_policies.monitoring.policies.syslogs.minimum_severity) }}
{% if syslog.destination_group is defined %}
    Should Be Equal JMESPath Json   ${r}    ${sysl}.syslogSrc.children[?syslogRsDestGroup] | [0].syslogRsDestGroup.attributes.tDn   uni/fabric/slgroup-{{ syslog.destination_group ~ defaults.apic.access_policies.monitoring.policies.syslogs.name_suffix }}
{% endif %}
{% endfor %}

{% for cl in policy.fault_severity_policies | default([]) %}
{% for fault in cl.faults | default([]) %}
Verify Monitoring Policy {{ policy_name }} Fault Severity Policy Class {{ cl.class }} Fault {{ fault.fault_id }}
    ${fault_class}=   Set Variable    imdata[0].monInfraPol.children[?monInfraTarget.attributes.scope=='{{ cl.class }}'] | [0]
    ${sev}=   Set Variable    ${fault_class}.monInfraTarget.children[?faultSevAsnP.attributes.code=='{{ fault.fault_id }}'] | [0]
    Should Be Equal JMESPath Json   ${r}    ${sev}.faultSevAsnP.attributes.code  {{ fault.fault_id }}
    Should Be Equal JMESPath Json   ${r}    ${sev}.faultSevAsnP.attributes.initial  {{ fault.initial_severity | default(defaults.apic.access_policies.monitoring.policies.fault_severity_policies.initial_severity) }}
    Should Be Equal JMESPath Json   ${r}    ${sev}.faultSevAsnP.attributes.target  {{ fault.target_severity | default(defaults.apic.access_policies.monitoring.policies.fault_severity_policies.target_severity) }}
    Should Be Equal JMESPath Json   ${r}    ${sev}.faultSevAsnP.attributes.descr  {{ fault.description | default("") }}
{% endfor %}

{% endfor %}

{% endfor %}
