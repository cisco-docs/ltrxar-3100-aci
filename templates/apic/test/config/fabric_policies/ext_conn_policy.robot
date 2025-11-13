*** Settings ***
Documentation   Verify External Connectivity Policy
Suite Setup     Login APIC
Default Tags    apic   day1   config   fabric_policies
Resource        ../../apic_common.resource

*** Test Cases ***
{% if apic.fabric_policies is defined and apic.fabric_policies.external_connectivity_policy is defined %}
{% set policy_name = apic.fabric_policies.external_connectivity_policy.name ~ defaults.apic.fabric_policies.external_connectivity_policy.name_suffix %}
Verify External Connectivity Policy
    ${r}=   GET On Session   apic   /api/mo/uni/tn-infra/fabricExtConnP-{{ apic.fabric_policies.external_connectivity_policy.fabric_id | default(defaults.apic.fabric_policies.external_connectivity_policy.fabric_id) }}.json   params=rsp-subtree=full
    Set Suite Variable   $r   ${r.json()}
    Should Be Equal JMESPath Json   ${r}    imdata[0].fvFabricExtConnP.attributes.name   {{ policy_name }}
    Should Be Equal JMESPath Json   ${r}    imdata[0].fvFabricExtConnP.attributes.rt   {{ apic.fabric_policies.external_connectivity_policy.route_target | default(defaults.apic.fabric_policies.external_connectivity_policy.route_target) }}
    Should Be Equal JMESPath Json   ${r}    imdata[0].fvFabricExtConnP.attributes.id   {{ apic.fabric_policies.external_connectivity_policy.fabric_id | default(defaults.apic.fabric_policies.external_connectivity_policy.fabric_id) }}
    Should Be Equal JMESPath Json   ${r}    imdata[0].fvFabricExtConnP.attributes.siteId   {{ apic.fabric_policies.external_connectivity_policy.site_id | default(defaults.apic.fabric_policies.external_connectivity_policy.site_id) }}
    {% set peering_type = apic.fabric_policies.external_connectivity_policy.peering_type | default(defaults.apic.fabric_policies.external_connectivity_policy.peering_type) %}
    {% if peering_type == "full_mesh" %}{% set type = "automatic_with_full_mesh" %}
    {% elif peering_type == "route_reflector" %}{% set type = "automatic_with_rr" %}
    {% endif %}
    Should Be Equal JMESPath Json   ${r}    imdata[0].fvFabricExtConnP.children[?fvPeeringP] | [0].fvPeeringP.attributes.type   {{ type }}

{% for routing_profile in apic.fabric_policies.external_connectivity_policy.routing_profiles | default([]) %}
{% set routing_profile_name = routing_profile.name ~ defaults.apic.fabric_policies.external_connectivity_policy.routing_profiles.name_suffix %}

Verify External Connectivity Policy Routing Profile {{ routing_profile_name }}
    ${profile}=   Set Variable   imdata[0].fvFabricExtConnP.children[?l3extFabricExtRoutingP.attributes.name=='{{ routing_profile_name }}'] | [0].l3extFabricExtRoutingP
    Should Be Equal JMESPath Json   ${r}    ${profile}.attributes.name   {{ routing_profile_name }}
{%- for subnet in routing_profile.subnets | default([]) %}

Verify External Connectivity Policy Routing Profile {{ routing_profile_name }} Subnet {{ subnet }}
    ${profile}=   Set Variable   imdata[0].fvFabricExtConnP.children[?l3extFabricExtRoutingP.attributes.name=='{{ routing_profile_name }}'] | [0].l3extFabricExtRoutingP
    ${subnet}=   Set Variable    ${profile}.children[?l3extSubnet.attributes.ip=='{{ subnet }}'] | [0].l3extSubnet
    Should Be Equal JMESPath Json   ${r}    ${subnet}.attributes.ip   {{ subnet }}

{% endfor %}

{% endfor %}

{% for pod in apic.pod_policies.pods | default([]) %}

Verify External Connectivity Policy Pod {{ pod.id }}
    ${pod}=   Set Variable   imdata[0].fvFabricExtConnP.children[?fvPodConnP.attributes.id=='{{ pod.id }}'] | [0].fvPodConnP
    Should Be Equal JMESPath Json   ${r}    ${pod}.attributes.id   {{ pod.id }}
    Should Be Equal JMESPath Json   ${r}    ${pod}.children[?fvIp] | [0].fvIp.attributes.addr   {{ pod.data_plane_tep }}

{% endfor %}

{% endif %}
