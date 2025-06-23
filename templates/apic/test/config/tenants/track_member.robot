{# iterate_list apic.tenants name item[2] #}
*** Settings ***
Documentation   Verify Track Member
Suite Setup     Login APIC
Default Tags    apic   day2   config   tenants
Resource        ../../../apic_common.resource

*** Test Cases ***
{% set tenant = ((apic | default()) | community.general.json_query('tenants[?name==`' ~ item[2] ~ '`]'))[0] %}
{% for member in tenant.policies.track_members | default([]) %}
{% set member_name = member.name ~ defaults.apic.tenants.policies.track_members.name_suffix %}
{% set ip_sla_name = member.ip_sla_policy ~ defaults.apic.tenants.policies.ip_sla_policies.name_suffix %}

Verify Track Member {{ member.name }}
    ${r}=   GET On Session   apic   /api/mo/uni/tn-{{ tenant.name }}/trackmember-{{ member_name }}.json    params=rsp-subtree=full
    Should Be Equal Value Json String   ${r.json()}   $..fvTrackMember.attributes.name   {{ member_name }}
    Should Be Equal Value Json String   ${r.json()}   $..fvTrackMember.attributes.descr   {{ member.description | default() }}
    Should Be Equal Value Json String   ${r.json()}   $..fvTrackMember.attributes.dstIpAddr   {{ member.destination_ip }}
{% if member.scope_type == "l3out" %}
    Should Be Equal Value Json String   ${r.json()}   $..fvTrackMember.attributes.scopeDn   uni/tn-{{ tenant.name }}/out-{{ member.scope }}
{% elif member.scope_type == "bd" %}
    Should Be Equal Value Json String   ${r.json()}   $..fvTrackMember.attributes.scopeDn   uni/tn-{{ tenant.name }}/BD-{{ member.scope }}
{% endif %}
    Should Be Equal Value Json String   ${r.json()}   $..fvRsIpslaMonPol.attributes.tDn   uni/tn-{{ tenant.name }}/ipslaMonitoringPol-{{ ip_sla_name }}

{% endfor %}

{% for l3out in tenant.l3outs | default([]) %}
{% set l3out_name = l3out.name ~ defaults.apic.tenants.l3outs.name_suffix %}
{% set vrf_name = l3out.vrf ~ ('' if l3out.vrf in ('inb', 'obb', 'overlay-1') else defaults.apic.tenants.vrfs.name_suffix) %}

{# manual node profiles #}
{% if ((l3out.node_profiles| default([])) | length) > 0 %}
{% for np in l3out.node_profiles | default([]) %}
{% for node in np.nodes | default([]) %}
{% for sr in node.static_routes | default([]) %}
{% for nh in sr.next_hops | default([]) %}
{% if nh.ip_sla_policy is defined %}
{% set member_name = vrf_name ~ "_" ~ nh.ip %}
{% set ip_sla_name = nh.ip_sla_policy ~ defaults.apic.tenants.policies.ip_sla_policies.name_suffix %}

Verify Track Member for for L3out {{ l3out_name }} Node {{ node.node_id }} Static Route {{ sr.prefix }} Next Hop {{ nh.ip }}
    ${r}=   GET On Session   apic   /api/mo/uni/tn-{{ tenant.name }}/trackmember-{{ member_name }}.json    params=rsp-subtree=full
    Should Be Equal Value Json String   ${r.json()}   $..fvTrackMember.attributes.name  {{ member_name }}
    Should Be Equal Value Json String   ${r.json()}   $..fvTrackMember.attributes.dstIpAddr   {{ nh.ip }}
    Should Be Equal Value Json String   ${r.json()}   $..fvTrackMember.attributes.scopeDn   uni/tn-{{ tenant.name }}/out-{{ l3out_name }}
    Should Be Equal Value Json String   ${r.json()}   $..fvRsIpslaMonPol.attributes.tDn   uni/tn-{{ tenant.name }}/ipslaMonitoringPol-{{ ip_sla_name }}
{% endif %}
{% endfor %}
{% endfor %}
{% endfor %}
{% endfor %}
{% endif %}

{# auto generated node profiles #}
{% if ((l3out.nodes | default([])) | length) > 0 %}
{% for node in l3out.nodes | default([]) %}
{% for sr in node.static_routes | default([]) %}
{% for nh in sr.next_hops | default([]) %}
{% if nh.ip_sla_policy is defined %}
{% set member_name = vrf_name ~ "_" ~ nh.ip %}
{% set ip_sla_name = nh.ip_sla_policy ~ defaults.apic.tenants.policies.ip_sla_policies.name_suffix %}

Verify Track Member for L3out {{ l3out_name }} Node {{ node.node_id }} Static Route {{ sr.prefix }} Next Hop {{ nh.ip }}
    ${r}=   GET On Session   apic   /api/mo/uni/tn-{{ tenant.name }}/trackmember-{{ member_name }}.json    params=rsp-subtree=full
    Should Be Equal Value Json String   ${r.json()}   $..fvTrackMember.attributes.name  {{ member_name }}
    Should Be Equal Value Json String   ${r.json()}   $..fvTrackMember.attributes.dstIpAddr   {{ nh.ip }}
    Should Be Equal Value Json String   ${r.json()}   $..fvTrackMember.attributes.scopeDn   uni/tn-{{ tenant.name }}/out-{{ l3out_name }}
    Should Be Equal Value Json String   ${r.json()}   $..fvRsIpslaMonPol.attributes.tDn   uni/tn-{{ tenant.name }}/ipslaMonitoringPol-{{ ip_sla_name }}
{% endif %}
{% endfor %}
{% endfor %}
{% endfor %}
{% endif %}

{% endfor %}
