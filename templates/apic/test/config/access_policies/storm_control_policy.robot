*** Settings ***
Documentation   Verify Storm Control Policy
Suite Setup     Login APIC
Default Tags    apic   day1   config   access_policies
Resource        ../../apic_common.resource

*** Test Cases ***
{% macro get_float_rate(rate) %}
{%- if rate -%}
{{ "%.6f"|format(rate|float) }}
{%- else -%}
{{ rate }}
{%- endif -%}
{% endmacro %}


{% for policy in apic.access_policies.interface_policies.storm_control_policies | default([]) %}
{% set storm_control_policy_name = policy.name ~ defaults.apic.access_policies.interface_policies.storm_control_policies.name_suffix %}

Verify Storm Control Policy {{ storm_control_policy_name }}
    ${r}=   GET On Session   apic   /api/mo/uni/infra/stormctrlifp-{{ storm_control_policy_name }}.json
    Set Suite Variable   $r   ${r.json()}
    Should Be Equal JMESPath Json   ${r}    imdata[0].stormctrlIfPol.attributes.name   {{ storm_control_policy_name }}
    Should Be Equal JMESPath Json   ${r}    imdata[0].stormctrlIfPol.attributes.nameAlias   {{ policy.alias | default() }}
    Should Be Equal JMESPath Json   ${r}    imdata[0].stormctrlIfPol.attributes.descr   {{ policy.description | default() }}
    Should Be Equal JMESPath Json   ${r}    imdata[0].stormctrlIfPol.attributes.stormCtrlAction   {{ policy.action | default(defaults.apic.access_policies.interface_policies.storm_control_policies.action) }}
    Should Be Equal JMESPath Json   ${r}    imdata[0].stormctrlIfPol.attributes.bcBurstPps   {{ policy.broadcast_burst_pps | default(defaults.apic.access_policies.interface_policies.storm_control_policies.broadcast_burst_pps) }}
    Should Be Equal JMESPath Json   ${r}    imdata[0].stormctrlIfPol.attributes.bcBurstRate   {{ get_float_rate(policy.broadcast_burst_rate | default(defaults.apic.access_policies.interface_policies.storm_control_policies.broadcast_burst_rate)) }}
    Should Be Equal JMESPath Json   ${r}    imdata[0].stormctrlIfPol.attributes.bcRate   {{ get_float_rate(policy.broadcast_rate | default(defaults.apic.access_policies.interface_policies.storm_control_policies.broadcast_rate)) }}
    Should Be Equal JMESPath Json   ${r}    imdata[0].stormctrlIfPol.attributes.bcRatePps   {{ policy.broadcast_pps | default(defaults.apic.access_policies.interface_policies.storm_control_policies.broadcast_pps) }}
    Should Be Equal JMESPath Json   ${r}    imdata[0].stormctrlIfPol.attributes.mcBurstPps   {{ policy.multicast_burst_pps | default(defaults.apic.access_policies.interface_policies.storm_control_policies.multicast_burst_pps) }}
    Should Be Equal JMESPath Json   ${r}    imdata[0].stormctrlIfPol.attributes.mcBurstRate   {{ get_float_rate(policy.multicast_burst_rate | default(defaults.apic.access_policies.interface_policies.storm_control_policies.multicast_burst_rate)) }}
    Should Be Equal JMESPath Json   ${r}    imdata[0].stormctrlIfPol.attributes.mcRate   {{ get_float_rate(policy.multicast_rate | default(defaults.apic.access_policies.interface_policies.storm_control_policies.multicast_rate)) }}
    Should Be Equal JMESPath Json   ${r}    imdata[0].stormctrlIfPol.attributes.mcRatePps   {{ policy.multicast_pps | default(defaults.apic.access_policies.interface_policies.storm_control_policies.multicast_pps) }}
    Should Be Equal JMESPath Json   ${r}    imdata[0].stormctrlIfPol.attributes.uucBurstPps   {{ policy.unknown_unicast_burst_pps | default(defaults.apic.access_policies.interface_policies.storm_control_policies.unknown_unicast_burst_pps) }}
    Should Be Equal JMESPath Json   ${r}    imdata[0].stormctrlIfPol.attributes.uucBurstRate   {{ get_float_rate(policy.unknown_unicast_burst_rate | default(defaults.apic.access_policies.interface_policies.storm_control_policies.unknown_unicast_burst_rate)) }}
    Should Be Equal JMESPath Json   ${r}    imdata[0].stormctrlIfPol.attributes.uucRate   {{ get_float_rate(policy.unknown_unicast_rate | default(defaults.apic.access_policies.interface_policies.storm_control_policies.unknown_unicast_rate)) }}
    Should Be Equal JMESPath Json   ${r}    imdata[0].stormctrlIfPol.attributes.uucRatePps   {{ policy.unknown_unicast_pps | default(defaults.apic.access_policies.interface_policies.storm_control_policies.unknown_unicast_pps) }}
    Should Be Equal JMESPath Json   ${r}    imdata[0].stormctrlIfPol.attributes.burstPps   {{ policy.burst_pps | default(defaults.apic.access_policies.interface_policies.storm_control_policies.burst_pps) }}
    Should Be Equal JMESPath Json   ${r}    imdata[0].stormctrlIfPol.attributes.burstRate   {{ get_float_rate(policy.burst_rate | default(defaults.apic.access_policies.interface_policies.storm_control_policies.burst_rate)) }}
    Should Be Equal JMESPath Json   ${r}    imdata[0].stormctrlIfPol.attributes.rate   {{ get_float_rate(policy.rate | default(defaults.apic.access_policies.interface_policies.storm_control_policies.rate)) }}
    Should Be Equal JMESPath Json   ${r}    imdata[0].stormctrlIfPol.attributes.ratePps   {{ policy.rate_pps | default(defaults.apic.access_policies.interface_policies.storm_control_policies.rate_pps) }}

{% endfor %}
