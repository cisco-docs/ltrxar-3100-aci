*** Settings ***
Documentation   Verify Tenant Policies
Suite Setup     Login NDO
Default Tags    ndo   config   day2
Resource        ../../ndo_common.resource

*** Test Cases ***
{% for tenant_policy in ndo.tenant_templates.tenant_policies | default([]) %}

Get Tenant Policy Template {{ tenant_policy.name }}
    ${tenant_policy_id}=   NDO Lookup   templates/summaries   {{ tenant_policy.name }}
    ${r}=   GET On Session   ndo   /mso/api/v1/templates/${tenant_policy_id}
    Set Suite Variable   ${r}    ${r.json()}

Verify Tenant Policy {{ tenant_policy.name }}
    Should Be Equal Value Json String   ${r}   $.displayName   {{ tenant_policy.name }}

{% for policy in tenant_policy.dhcp_relay_policies | default([]) %}
{% set policy_name = policy.name ~ defaults.ndo.tenant_templates.tenant_policies.dhcp_relay_policies.name_suffix %}

Verify Tenant Policy {{ tenant_policy.name }} DHCP Relay Policy {{ policy_name }}
    ${dhcp_policy}=   Set Variable   $.tenantPolicyTemplate.template.dhcpRelayPolicies[?(@.name=='{{ policy_name }}')]
    Should Be Equal Value Json String   ${r}   ${dhcp_policy}.name   {{ policy_name }}
    Should Be Equal Value Json String   ${r}   ${dhcp_policy}.description   {{ policy.description | default() }}

{% for provider in policy.providers | default([]) %}

Verify Tenant Policy {{ tenant_policy.name }} DHCP Relay Policy {{ policy_name }} Provider {{ provider.ip }}
    ${provider}=   Set Variable   $.tenantPolicyTemplate.template.dhcpRelayPolicies[?(@.name=='{{ policy_name }}')].providers[?(@.ip=='{{ provider.ip }}')]
    Should Be Equal Value Json String   ${r}   ${provider}.ip   {{ provider.ip }}
    Should Be Equal Value Json Boolean   ${r}   ${provider}.useServerVrf   {{ provider.use_server_vrf | default(defaults.ndo.tenant_templates.tenant_policies.dhcp_relay_policies.providers.use_server_vrf) }}
{% if provider.type | default() == 'epg' %}
    {% set ap_name = provider.application_profile ~ defaults.ndo.schemas.templates.application_profiles.name_suffix %}
    {% set epg_name = provider.endpoint_group ~ defaults.ndo.schemas.templates.application_profiles.endpoint_groups.name_suffix %}
    ${epg_id}=   NDO Lookup   schemas/templates/anps/epgs   {{ provider.schema }}/{{ provider.template }}/{{ ap_name }}/{{ epg_name }}
    Should Be Equal Value Json String   ${r}   ${provider}.epgRef   ${epg_id}
{% elif provider.type | default() == 'external_epg' %}
    {% set extepg_name = provider.external_endpoint_group ~ defaults.ndo.schemas.templates.external_endpoint_groups.name_suffix %}
    ${ext_epg_id}=   NDO Lookup   schemas/templates/externalEpgs   {{ provider.schema }}/{{ provider.template }}/{{ extepg_name }}
    Should Be Equal Value Json String   ${r}   ${provider}.externalEpgRef   ${ext_epg_id}
{% endif %}

{% endfor %}
{% endfor %}

{% for policy in tenant_policy.multicast_route_maps | default([]) %}
{% set policy_name = policy.name ~ defaults.ndo.tenant_templates.tenant_policies.multicast_route_maps.name_suffix %}

Verify Tenant Policy {{ tenant_policy.name }} Multicast Route Map Policy {{ policy_name }}
    ${mcast_policy}=   Set Variable   $.tenantPolicyTemplate.template.mcastRouteMapPolicies[?(@.name=='{{ policy_name }}')]
    Should Be Equal Value Json String   ${r}   ${mcast_policy}.name   {{ policy_name }}
    Should Be Equal Value Json String   ${r}   ${mcast_policy}.description   {{ policy.description | default() }}

{% for entry in policy.entries | default([]) %}

Verify Tenant Policy {{ tenant_policy.name }} Multicast Route Map Policy {{ policy_name }} Entry Order {{ entry.order }}
    ${entry}=   Set Variable   $.tenantPolicyTemplate.template.mcastRouteMapPolicies[?(@.name=='{{ policy_name }}')].mcastRtMapEntryList[?(@.order=={{ entry.order }})]
    Should Be Equal Value Json String   ${r}   ${entry}.source   {{ entry.source_ip }}
    Should Be Equal Value Json String   ${r}   ${entry}.group   {{ entry.group_ip }}
    Should Be Equal Value Json Number   ${r}   ${entry}.order   {{ entry.order }}
    Should Be Equal Value Json String   ${r}   ${entry}.rp   {{ entry.rp_ip | default(defaults.ndo.tenant_templates.tenant_policies.multicast_route_maps.entries.rp_ip) }}
    Should Be Equal Value Json String   ${r}   ${entry}.action   {{ entry.action | default(defaults.ndo.tenant_templates.tenant_policies.multicast_route_maps.entries.action) }}

{% endfor %}
{% endfor %}

{% for policy in tenant_policy.ip_sla_policies | default([]) %}
{% set ip_sla_policy_name = policy.name ~ defaults.ndo.tenant_templates.tenant_policies.ip_sla_policies.name_suffix %}

Verify Tenant Policy {{ tenant_policy.name }} IP SLA Monitoring Policy {{ ip_sla_policy_name }}
    ${ipsla_policy}=   Set Variable   $.tenantPolicyTemplate.template.ipslaMonitoringPolicies[?(@.name=='{{ ip_sla_policy_name }}')]
    Should Be Equal Value Json String   ${r}   ${ipsla_policy}.name   {{ ip_sla_policy_name }}
    Should Be Equal Value Json String   ${r}   ${ipsla_policy}.description   {{ policy.description | default() }}
    Should Be Equal Value Json String   ${r}   ${ipsla_policy}.slaType   {{ policy.sla_type | default(defaults.ndo.tenant_templates.tenant_policies.ip_sla_policies.sla_type) }}
    {% if policy.sla_type | default(defaults.ndo.tenant_templates.tenant_policies.ip_sla_policies.sla_type) == 'http' %}
    Should Be Equal Value Json Number   ${r}   ${ipsla_policy}.slaPort   80
    {% else %}
    Should Be Equal Value Json Number   ${r}   ${ipsla_policy}.slaPort   {{ policy.port | default(defaults.ndo.tenant_templates.tenant_policies.ip_sla_policies.port) }}
    {% endif %}
    Should Be Equal Value Json String   ${r}   ${ipsla_policy}.httpVersion   {{ policy.http_version | default(defaults.ndo.tenant_templates.tenant_policies.ip_sla_policies.http_version) }}
    Should Be Equal Value Json String   ${r}   ${ipsla_policy}.httpUri   {{ policy.http_uri | default(defaults.ndo.tenant_templates.tenant_policies.ip_sla_policies.http_uri) }}
    Should Be Equal Value Json Number   ${r}   ${ipsla_policy}.slaFrequency   {{ policy.frequency | default(defaults.ndo.tenant_templates.tenant_policies.ip_sla_policies.frequency) }}
    Should Be Equal Value Json Number   ${r}   ${ipsla_policy}.slaDetectMultiplier   {{ policy.multiplier | default(defaults.ndo.tenant_templates.tenant_policies.ip_sla_policies.multiplier) }}
    Should Be Equal Value Json Number   ${r}   ${ipsla_policy}.reqDataSize   {{ policy.request_data_size | default(defaults.ndo.tenant_templates.tenant_policies.ip_sla_policies.request_data_size) }}
    Should Be Equal Value Json Number   ${r}   ${ipsla_policy}.ipv4ToS   {{ policy.type_of_service | default(defaults.ndo.tenant_templates.tenant_policies.ip_sla_policies.type_of_service) }}
    Should Be Equal Value Json Number   ${r}   ${ipsla_policy}.timeout   {{ policy.timeout | default(defaults.ndo.tenant_templates.tenant_policies.ip_sla_policies.timeout) }}
    Should Be Equal Value Json Number   ${r}   ${ipsla_policy}.threshold   {{ policy.threshold | default(defaults.ndo.tenant_templates.tenant_policies.ip_sla_policies.threshold) }}
    Should Be Equal Value Json Number   ${r}   ${ipsla_policy}.ipv6TrfClass   {{ policy.ipv6_traffic_class | default(defaults.ndo.tenant_templates.tenant_policies.ip_sla_policies.ipv6_traffic_class) }}

{% endfor %}

{% if tenant_policy.sites is defined %}
Verify Tenant Policy {{ tenant_policy.name }} Site Associations
{% for site in tenant_policy.sites | default([]) %}
    ${site_id}=   NDO Lookup   sites   {{ site }}
    ${site}=   Set Variable   $.tenantPolicyTemplate.sites[?(@.siteId=='${site_id}')]
    Should Be Equal Value Json String   ${r}   ${site}.siteId   ${site_id}
{% endfor %}

{% endif %}
{% endfor %}
