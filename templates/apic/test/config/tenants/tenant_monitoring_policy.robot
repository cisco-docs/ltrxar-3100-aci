{# iterate_list apic.tenants name item[2] #}
*** Settings ***
Documentation   Verify Tenant Monitoring Policy
Suite Setup     Login APIC
Default Tags    apic   day2   config   tenants
Resource        ../../../apic_common.resource

*** Test Cases ***
{% set tenant = ((apic | default()) | community.general.json_query('tenants[?name==`' ~ item[2] ~ '`]'))[0] %}
{% for policy in tenant.policies.monitoring.policies | default([]) %}
{% set policy_name = policy.name ~ defaults.apic.tenants.policies.monitoring.policies.name_suffix %}

Verify Monitoring Policy {{ policy_name }}
    ${r}=   GET On Session   apic   /api/mo/uni/tn-{{tenant.name}}/monepg-{{policy_name}}.json   params=rsp-subtree=full
    Set Suite Variable   $r   ${r.json()}
    Should Be Equal JMESPath Json   ${r}    imdata[0].monEPGPol.attributes.name   {{ policy_name }}

{% for snmp in policy.snmp_traps | default([]) %}
{% set snmp_policy_name = snmp.name ~ defaults.apic.tenants.policies.monitoring.policies.snmp_traps.name_suffix %}

Verify Monitoring Policy {{ policy_name }} SNMP Policy {{ snmp_policy_name }}
    ${mon}=   Set Variable    imdata[0].monEPGPol.children[?snmpSrc.attributes.name=='{{ snmp_policy_name }}'] | [0]
    Should Be Equal JMESPath Json   ${r}    ${mon}.snmpSrc.attributes.name  {{ snmp_policy_name }}
{% if snmp.destination_group is defined %}
    Should Be Equal JMESPath Json   ${r}    ${mon}.snmpSrc.children[?snmpRsDestGroup] | [0].snmpRsDestGroup.attributes.tDn   uni/fabric/snmpgroup-{{ snmp.destination_group ~ defaults.apic.fabric_policies.monitoring.snmp_traps.name_suffix }}
{% endif %}
{% endfor %}

{% for syslog in policy.syslogs | default([]) %}
{% set syslog_policy_name = syslog.name ~ defaults.apic.tenants.policies.monitoring.policies.syslogs.name_suffix %}
{% set include = [] %}
{% if syslog.audit | default(defaults.apic.tenants.policies.monitoring.policies.syslogs.audit) %}{% set include = include + [("audit")] %}{% endif %}
{% if syslog.events | default(defaults.apic.tenants.policies.monitoring.policies.syslogs.events) %}{% set include = include + [("events")] %}{% endif %}
{% if syslog.faults | default(defaults.apic.tenants.policies.monitoring.policies.syslogs.faults) %}{% set include = include + [("faults")] %}{% endif %}
{% if syslog.session | default(defaults.apic.tenants.policies.monitoring.policies.syslogs.session) %}{% set include = include + [("session")] %}{% endif %}
{% if include == ['audit', 'events', 'faults', 'session'] %}{% set include = [("all")] + include %}{% endif %}

Verify Monitoring Policy {{ policy_name }} Syslog Policy {{ syslog_policy_name }}
    ${sysl}=   Set Variable    imdata[0].monEPGPol.children[?syslogSrc.attributes.name=='{{ syslog_policy_name }}'] | [0]
    Should Be Equal JMESPath Json   ${r}    ${sysl}.syslogSrc.attributes.name  {{ syslog_policy_name }}
    Should Be Equal JMESPath Json   ${r}    ${sysl}.syslogSrc.attributes.incl   {{ include | join(',') }}
    Should Be Equal JMESPath Json   ${r}    ${sysl}.syslogSrc.attributes.minSev   {{ syslog.minimum_severity | default(defaults.apic.tenants.policies.monitoring.policies.syslogs.minimum_severity) }}
{% if syslog.destination_group is defined %}
    Should Be Equal JMESPath Json   ${r}    ${sysl}.syslogSrc.children[?syslogRsDestGroup] | [0].syslogRsDestGroup.attributes.tDn   uni/fabric/slgroup-{{ syslog.destination_group ~ defaults.apic.fabric_policies.monitoring.syslogs.name_suffix }}
{% endif %}
{% endfor %}

{% for cl in policy.fault_severity_policies | default([]) %}
Verify Monitoring Policy {{ policy_name }} Fault Severity Policy Class {{ cl.class }}
    Should Be Equal JMESPath Json   ${r}    imdata[0].monEPGPol.children[?monEPGTarget.attributes.scope=='{{ cl.class }}'] | [0].monEPGTarget.attributes.scope  {{ cl.class }}

{% for fault in cl.faults | default([]) %}
Verify Monitoring Policy {{ policy_name }} Fault Severity Policy Class {{ cl.class }} Fault {{ fault.fault_id }}
    ${sev}=   Set Variable    imdata[0].monEPGPol.children[?monEPGTarget.attributes.scope=='{{ cl.class }}'] | [0].monEPGTarget.children[?faultSevAsnP.attributes.code=='{{ fault.fault_id }}'] | [0]
    Should Be Equal JMESPath Json   ${r}    ${sev}.faultSevAsnP.attributes.code  {{ fault.fault_id }}
    Should Be Equal JMESPath Json   ${r}    ${sev}.faultSevAsnP.attributes.initial  {{ fault.initial_severity | default(defaults.apic.tenants.policies.monitoring.policies.fault_severity_policies.initial_severity) }}
    Should Be Equal JMESPath Json   ${r}    ${sev}.faultSevAsnP.attributes.target  {{ fault.target_severity | default(defaults.apic.tenants.policies.monitoring.policies.fault_severity_policies.target_severity) }}
    Should Be Equal JMESPath Json   ${r}    ${sev}.faultSevAsnP.attributes.descr  {{ fault.description | default() }}

{% endfor %}

{% endfor %}

{% endfor %}
