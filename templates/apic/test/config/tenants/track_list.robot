{# iterate_list apic.tenants name item[2] #}
*** Settings ***
Documentation   Verify Track List
Suite Setup     Login APIC
Default Tags    apic   day2   config   tenants
Resource        ../../../apic_common.resource

*** Test Cases ***
{% set tenant = ((apic | default()) | community.general.json_query('tenants[?name==`' ~ item[2] ~ '`]'))[0] %}
{% for track_list in tenant.policies.track_lists | default([]) %}
{% set list_name = track_list.name ~ defaults.apic.tenants.policies.track_lists.name_suffix %}

Verify Track List {{ list_name }}
    ${r}=   GET On Session   apic   /api/mo/uni/tn-{{ tenant.name }}/tracklist-{{ list_name }}.json    params=rsp-subtree=full
    Should Be Equal Value Json String   ${r.json()}   $..fvTrackList.attributes.name   {{ list_name }}
    Should Be Equal Value Json String   ${r.json()}   $..fvTrackList.attributes.descr   {{ track_list.description | default() }}
    Should Be Equal Value Json String   ${r.json()}   $..fvTrackList.attributes.type   {{ track_list.type | default(defaults.apic.tenants.policies.track_lists.type) }}
    Should Be Equal Value Json String   ${r.json()}   $..fvTrackList.attributes.percentageDown   {{ track_list.percentage_down | default(defaults.apic.tenants.policies.track_lists.percentage_down) }}
    Should Be Equal Value Json String   ${r.json()}   $..fvTrackList.attributes.percentageUp   {{ track_list.percentage_up | default(defaults.apic.tenants.policies.track_lists.percentage_up) }}
    Should Be Equal Value Json String   ${r.json()}   $..fvTrackList.attributes.weightDown   {{ track_list.weight_down | default(defaults.apic.tenants.policies.track_lists.weight_down) }}
    Should Be Equal Value Json String   ${r.json()}   $..fvTrackList.attributes.weightUp   {{ track_list.weight_up | default(defaults.apic.tenants.policies.track_lists.weight_up) }}

{% for member in track_list.track_members | default([]) %}
{% set member_name = member ~ defaults.apic.tenants.policies.track_members.name_suffix %}
    ${mem}=   Set Variable    $..fvTrackList.children[?(@.fvRsOtmListMember.attributes.tDn=='uni/tn-{{ tenant.name }}/trackmember-{{ member_name }}')]
    Should Be Equal Value Json String   ${r.json()}   ${mem}..fvRsOtmListMember.attributes.tDn   uni/tn-{{ tenant.name }}/trackmember-{{ member_name }}
{% endfor %}

{% endfor %}

{% for l3out in tenant.l3outs | default([]) %}
{% set l3out_name = l3out.name ~ defaults.apic.tenants.l3outs.name_suffix %}
{% set vrf_name = l3out.vrf ~ ('' if l3out.vrf in ('inb', 'obb', 'overlay-1') else defaults.apic.tenants.vrfs.name_suffix) %}

{# manual node profiles #}
{% if ((l3out.node_profiles | default([])) | length) > 0 %}
{% for np in l3out.node_profiles | default([]) %}
{% for node in np.nodes | default([]) %}
{% for sr in node.static_routes | default([]) %}
{% for nh in sr.next_hops | default([]) %}
{% if nh.ip_sla_policy is defined %}
{% set list_name = vrf_name ~ "_" ~ nh.ip %}

Verify Track List for L3out {{ l3out_name }} Node {{ node.node_id }} Static Route {{ sr.prefix }} Next Hop {{ nh.ip }}
    ${r}=   GET On Session   apic   /api/mo/uni/tn-{{ tenant.name }}/tracklist-{{list_name}}.json    params=rsp-subtree=full
    ${mem}=   Set Variable    $..fvTrackList.children[?(@.fvRsOtmListMember.attributes.tDn=='uni/tn-{{ tenant.name }}/trackmember-{{ list_name }}')]
    Should Be Equal Value Json String   ${r.json()}   $..fvTrackList.attributes.name  {{ list_name }}
    Should Be Equal Value Json String   ${r.json()}   ${mem}..fvRsOtmListMember.attributes.tDn   uni/tn-{{ tenant.name }}/trackmember-{{ list_name }}

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
{% set list_name = vrf_name ~ "_" ~ nh.ip ~ defaults.apic.tenants.policies.track_lists.name_suffix %}

Verify Track List for L3out {{ l3out_name }} Node {{ node.node_id }} Static Route {{ sr.prefix }} Next Hop {{ nh.ip }}
    ${r}=   GET On Session   apic   /api/mo/uni/tn-{{ tenant.name }}/tracklist-{{list_name}}.json    params=rsp-subtree=full
    ${mem}=   Set Variable    $..fvTrackList.children[?(@.fvRsOtmListMember.attributes.tDn=='uni/tn-{{ tenant.name }}/trackmember-{{ list_name }}')]
    Should Be Equal Value Json String   ${r.json()}   $..fvTrackList.attributes.name  {{ list_name }}
    Should Be Equal Value Json String   ${r.json()}   ${mem}..fvRsOtmListMember.attributes.tDn   uni/tn-{{ tenant.name }}/trackmember-{{ list_name }}

{% endif %}

{% endfor %}
{% endfor %}
{% endfor %}
{% endif %}
{% endfor %}
