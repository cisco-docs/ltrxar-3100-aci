*** Settings ***
Documentation   Verify Port Channel Interface Policy
Suite Setup     Login APIC
Default Tags    apic   day1   config   access_policies
Resource        ../../apic_common.resource

*** Test Cases ***
{% for policy in apic.access_policies.interface_policies.port_channel_policies | default([]) %}
{% set port_channel_policy_name = policy.name ~ defaults.apic.access_policies.interface_policies.port_channel_policies.name_suffix %}
{% set ctrl = [] %}
{% if policy.fast_select_standby | default(defaults.apic.access_policies.interface_policies.port_channel_policies.fast_select_standby) %}{% set ctrl = ctrl + [("fast-sel-hot-stdby")] %}{% endif %}
{% if policy.graceful_convergence | default(defaults.apic.access_policies.interface_policies.port_channel_policies.graceful_convergence) %}{% set ctrl = ctrl + [("graceful-conv")] %}{% endif %}
{% if policy.load_defer | default(defaults.apic.access_policies.interface_policies.port_channel_policies.load_defer) %}{% set ctrl = ctrl + [("load-defer")] %}{% endif %}
{% if policy.suspend_individual | default(defaults.apic.access_policies.interface_policies.port_channel_policies.suspend_individual) %}{% set ctrl = ctrl + [("susp-individual")] %}{% endif %}
{% if policy.symmetric_hash | default(defaults.apic.access_policies.interface_policies.port_channel_policies.symmetric_hash) %}{% set ctrl = ctrl + [("symmetric-hash")] %}{% endif %}

Verify Port Channel Interface Policy {{port_channel_policy_name }}
    ${r}=   GET On Session   apic   /api/mo/uni/infra/lacplagp-{{port_channel_policy_name }}.json   params=rsp-subtree=full
    Set Suite Variable   $r   ${r.json()}
    Should Be Equal JMESPath Json   ${r}    imdata[0].lacpLagPol.attributes.name   {{ port_channel_policy_name }}
    Should Be Equal JMESPath Json   ${r}    imdata[0].lacpLagPol.attributes.ctrl   {{ ctrl | join(',') }}
    Should Be Equal JMESPath Json   ${r}    imdata[0].lacpLagPol.attributes.maxLinks   {{ policy.max_links | default(defaults.apic.access_policies.interface_policies.port_channel_policies.max_links) }}
    Should Be Equal JMESPath Json   ${r}    imdata[0].lacpLagPol.attributes.minLinks   {{ policy.min_links | default(defaults.apic.access_policies.interface_policies.port_channel_policies.min_links) }}
    Should Be Equal JMESPath Json   ${r}    imdata[0].lacpLagPol.attributes.mode   {{ policy.mode }}
{% if policy.symmetric_hash | default(defaults.apic.access_policies.interface_policies.port_channel_policies.symmetric_hash) and policy.hash_key is defined %}
    Should Be Equal JMESPath Json   ${r}    imdata[0].l2LoadBalancePol.attributes.hashFields   {{ policy.hash_key }}
{% endif %}

{% endfor %}
