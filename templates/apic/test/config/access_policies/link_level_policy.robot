*** Settings ***
Documentation   Verify Link Level Interface Policy
Suite Setup     Login APIC
Default Tags    apic   day1   config   access_policies
Resource        ../../apic_common.resource

*** Test Cases ***
{% for policy in apic.access_policies.interface_policies.link_level_policies | default([]) %}
{% set link_level_policy_name = policy.name ~ defaults.apic.access_policies.interface_policies.link_level_policies.name_suffix %}

Verify Link Level Interface Policy {{ link_level_policy_name }}
    ${r}=   GET On Session   apic   /api/mo/uni/infra/hintfpol-{{ link_level_policy_name }}.json
    Set Suite Variable   $r   ${r.json()}
    Should Be Equal Value Json String   ${r}    $..fabricHIfPol.attributes.name   {{ link_level_policy_name }}
    Should Be Equal Value Json String   ${r}    $..fabricHIfPol.attributes.speed   {{ policy.speed | default(defaults.apic.access_policies.interface_policies.link_level_policies.speed) }}
{% if policy.link_delay_interval is defined %}
    Should Be Equal Value Json String   ${r}    $..fabricHIfPol.attributes.dfeDelayMs   {{ policy.link_delay_interval }}
{% endif %}
    Should Be Equal Value Json String   ${r}    $..fabricHIfPol.attributes.linkDebounce   {{ policy.link_debounce_interval | default(defaults.apic.access_policies.interface_policies.link_level_policies.link_debounce_interval) }}
    Should Be Equal Value Json String   ${r}    $..fabricHIfPol.attributes.autoNeg   {{ 'on' if policy.auto | default(defaults.apic.access_policies.interface_policies.link_level_policies.auto) else 'off' }}
    Should Be Equal Value Json String   ${r}    $..fabricHIfPol.attributes.fecMode   {{ policy.fec_mode | default(defaults.apic.access_policies.interface_policies.link_level_policies.fec_mode) }}
{% if policy.physical_media_type is defined %}
    Should Be Equal Value Json String   ${r}    $..fabricHIfPol.attributes.portPhyMediaType   {{ policy.physical_media_type }}
{% endif %}

{% endfor %}
