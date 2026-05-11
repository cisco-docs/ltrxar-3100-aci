{# iterate_list apic.tenants name item[2] #}
*** Settings ***
Documentation   Verify Redirect Policy
Suite Setup     Login APIC
Default Tags    apic   day2   config   tenants
Resource        ../../../apic_common.resource

*** Test Cases ***
{% set tenant = ((apic | default()) | community.general.json_query('tenants[?name==`' ~ item[2] ~ '`]'))[0] %}
{% for pol in tenant.services.redirect_policies | default([]) %}
{% set pol_name = pol.name ~ defaults.apic.tenants.services.redirect_policies.name_suffix %}

Verify Redirect Policy {{ pol_name }}
    ${r}=   GET On Session   apic   /api/mo/uni/tn-{{ tenant.name }}/svcCont/svcRedirectPol-{{ pol_name }}.json   params=rsp-subtree=full
    Set Suite Variable   $r   ${r.json()}
    Should Be Equal JMESPath Json   ${r}   imdata[0].vnsSvcRedirectPol.attributes.descr   {{ pol.description | default() }}
    Should Be Equal JMESPath Json   ${r}   imdata[0].vnsSvcRedirectPol.attributes.name   {{ pol_name }}
    Should Be Equal JMESPath Json   ${r}   imdata[0].vnsSvcRedirectPol.attributes.nameAlias   {{ pol.alias | default() }}
    Should Be Equal JMESPath Json   ${r}   imdata[0].vnsSvcRedirectPol.attributes.destType   {{ pol.type | default(defaults.apic.tenants.services.redirect_policies.type) }}
    Should Be Equal JMESPath Json   ${r}   imdata[0].vnsSvcRedirectPol.attributes.hashingAlgorithm   {{ pol.hashing | default(defaults.apic.tenants.services.redirect_policies.hashing) }}
    Should Be Equal JMESPath Json   ${r}   imdata[0].vnsSvcRedirectPol.attributes.maxThresholdPercent   {{ pol.max_threshold | default(defaults.apic.tenants.services.redirect_policies.max_threshold) }}
    Should Be Equal JMESPath Json   ${r}   imdata[0].vnsSvcRedirectPol.attributes.minThresholdPercent   {{ pol.min_threshold | default(defaults.apic.tenants.services.redirect_policies.min_threshold) }}
{% if pol.rewrite_source_mac is defined %}
    Should Be Equal JMESPath Json   ${r}   imdata[0].vnsSvcRedirectPol.attributes.srcMacRewriteEnabled   {{ 'yes' if pol.rewrite_source_mac else 'no' }}
{% endif %}
    Should Be Equal JMESPath Json   ${r}   imdata[0].vnsSvcRedirectPol.attributes.thresholdDownAction   {{ pol.threshold_down_action | default(defaults.apic.tenants.services.redirect_policies.threshold_down_action) }}
    Should Be Equal JMESPath Json   ${r}   imdata[0].vnsSvcRedirectPol.attributes.programLocalPodOnly   {{ 'yes' if pol.pod_aware | default(defaults.apic.tenants.services.redirect_policies.pod_aware) else 'no' }}
    Should Be Equal JMESPath Json   ${r}   imdata[0].vnsSvcRedirectPol.attributes.resilientHashEnabled   {{ 'yes' if pol.resilient_hashing | default(defaults.apic.tenants.services.redirect_policies.resilient_hashing) else 'no' }}
    Should Be Equal JMESPath Json   ${r}   imdata[0].vnsSvcRedirectPol.attributes.AnycastEnabled   {{ 'yes' if pol.anycast | default(defaults.apic.tenants.services.redirect_policies.anycast) else 'no' }}
    Should Be Equal JMESPath Json   ${r}   imdata[0].vnsSvcRedirectPol.attributes.thresholdEnable   {{ 'yes' if pol.threshold | default(defaults.apic.tenants.services.redirect_policies.threshold) else 'no' }}

{% if pol.ip_sla_policy is defined %}
{% set ip_sla_name = pol.ip_sla_policy ~ defaults.apic.tenants.policies.ip_sla_policies.name_suffix %}
{% set current_tenant_query = "policies.ip_sla_policies[?name=='" ~ ip_sla_name ~ "']" %}
{% set common_tenant_query = "tenants[?name=='common'] | [0].policies.ip_sla_policies[?name=='" ~ ip_sla_name ~ "']" %}
{% set current_tenant_ip_sla_policy = ((tenant | community.general.json_query(current_tenant_query)) or []) | length > 0 %}
{% set common_tenant_ip_sla_policy = ((apic | community.general.json_query(common_tenant_query)) or []) | length > 0 %}
{% set ip_sla_tenant = "common" if (not current_tenant_ip_sla_policy and common_tenant_ip_sla_policy) else tenant.name %}
Verify Redirect Policy {{ pol_name }} IP SLA Policy
    Should Be Equal JMESPath Json   ${r}   imdata[0].vnsSvcRedirectPol.children[?vnsRsIPSLAMonitoringPol] | [0].vnsRsIPSLAMonitoringPol.attributes.tDn   uni/tn-{{ ip_sla_tenant }}/ipslaMonitoringPol-{{ ip_sla_name }}

{% endif %}

{% if pol.resilient_hashing | default(defaults.apic.tenants.services.redirect_policies.resilient_hashing) and pol.redirect_backup_policy is defined %}
{% set backup_pol_name = pol.redirect_backup_policy ~ defaults.apic.tenants.services.redirect_backup_policies.name_suffix %}

Verify Redirect Policy {{ pol_name }} Backup Policy
    Should Be Equal JMESPath Json   ${r}   imdata[0].vnsSvcRedirectPol.children[?vnsRsBackupPol] | [0].vnsRsBackupPol.attributes.tDn   uni/tn-{{ tenant.name }}/svcCont/backupPol-{{ backup_pol_name }}

{% endif %}

{% for dest in pol.l3_destinations | default([]) %}

Verify Redirect Policy {{ pol_name }} L3 Destination {{ dest.ip }}
    ${dest}=   Set Variable   imdata[0].vnsSvcRedirectPol.children[?vnsRedirectDest.attributes.ip=='{{ dest.ip }}'] | [0].vnsRedirectDest
    Should Be Equal JMESPath Json   ${r}   ${dest}.attributes.descr   {{ dest.description | default() }}
    Should Be Equal JMESPath Json   ${r}   ${dest}.attributes.destName   {{ dest.name | default() }}
    Should Be Equal JMESPath Json   ${r}   ${dest}.attributes.ip   {{ dest.ip }}
    Should Be Equal JMESPath Json   ${r}   ${dest}.attributes.ip2   {{ dest.ip_2 | default() }}
    Should Be Equal JMESPath Json   ${r}   ${dest}.attributes.mac   {{ dest.mac | default("00:00:00:00:00:00") }}
    Should Be Equal JMESPath Json   ${r}   ${dest}.attributes.podId   {{ dest.pod | default(defaults.apic.tenants.services.redirect_policies.l3_destinations.pod) }}
{% if dest.redirect_health_group is defined %}
{% set health_group_name = dest.redirect_health_group ~ defaults.apic.tenants.services.redirect_health_groups.name_suffix %}
    Should Be Equal JMESPath Json   ${r}   ${dest}.children[?vnsRsRedirectHealthGroup] | [0].vnsRsRedirectHealthGroup.attributes.tDn   uni/tn-{{ tenant.name }}/svcCont/redirectHealthGroup-{{ health_group_name }}
{% endif %}
{% endfor %}

{% for dest in pol.l1l2_destinations | default([]) %}

Verify Redirect Policy {{ pol_name }} L1/L2 Destination {{ dest.name }}
    ${dest}=   Set Variable   imdata[0].vnsSvcRedirectPol.children[?vnsL1L2RedirectDest.attributes.destName=='{{ dest.name }}'] | [0].vnsL1L2RedirectDest
    Should Be Equal JMESPath Json   ${r}   ${dest}.attributes.descr   {{ dest.description | default()  }}
    Should Be Equal JMESPath Json   ${r}   ${dest}.attributes.destName   {{ dest.name }}
{% if dest.mac is defined %}
    Should Be Equal JMESPath Json   ${r}   ${dest}.attributes.mac   {{ dest.mac }}
{% endif %}
{% if dest.weight is defined %}
    Should Be Equal JMESPath Json   ${r}   ${dest}.attributes.weight   {{ dest.weight }}
{% endif %}
{% if dest.pod is defined %}
    Should Be Equal JMESPath Json   ${r}   ${dest}.attributes.podId   {{ dest.pod }}
{% endif %}
{% if dest.redirect_health_group is defined %}
{% set health_group_name = dest.redirect_health_group ~ defaults.apic.tenants.services.redirect_health_groups.name_suffix %}
    Should Be Equal JMESPath Json   ${r}   ${dest}.children[?vnsRsL1L2RedirectHealthGroup] | [0].vnsRsL1L2RedirectHealthGroup.attributes.tDn   uni/tn-{{ tenant.name }}/svcCont/redirectHealthGroup-{{ health_group_name }}
{% endif %}
{% set l4l7_device = dest.concrete_interface.l4l7_device ~ defaults.apic.tenants.services.l4l7_devices.name_suffix %}
{% set concrete_device = dest.concrete_interface.concrete_device ~ defaults.apic.tenants.services.l4l7_devices.concrete_devices.name_suffix %}
{% set interface = dest.concrete_interface.interface ~ defaults.apic.tenants.services.l4l7_devices.concrete_devices.interfaces.name_suffix %}
    Should Be Equal JMESPath Json   ${r}   ${dest}.children[?vnsRsToCIf] | [0].vnsRsToCIf.attributes.tDn   uni/tn-{{ tenant.name }}/lDevVip-{{ l4l7_device }}/cDev-{{ concrete_device }}/cIf-[{{ interface }}]
{% endfor %}

{% endfor %}
