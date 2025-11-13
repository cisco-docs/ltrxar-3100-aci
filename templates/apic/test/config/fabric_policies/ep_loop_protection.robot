*** Settings ***
Documentation   Verify EP Loop Protection
Suite Setup     Login APIC
Default Tags    apic   day0   config   fabric_policies
Resource        ../../apic_common.resource

*** Test Cases ***
{% set action = [] %}
{% if apic.fabric_policies.ep_loop_protection.action is defined %}
{% if apic.fabric_policies.ep_loop_protection.action == 'bd-learn-disable' %}{% set action = action + [("bd-learn-disable")] %}
{% elif apic.fabric_policies.ep_loop_protection.action == 'port-disable' %}{% set action = action + [("port-disable")] %}
{% endif %}
{% elif defaults.apic.fabric_policies.ep_loop_protection.action is defined %}
{% if defaults.apic.fabric_policies.ep_loop_protection.action == 'bd-learn-disable' %}{% set action = action + [("bd-learn-disable")] %}
{% elif defaults.apic.fabric_policies.ep_loop_protection.action == 'port-disable' %}{% set action = action + [("port-disable")] %}
{% endif %}
{% else %}
{% if apic.fabric_policies.ep_loop_protection.bd_learn_disable | default(defaults.apic.fabric_policies.ep_loop_protection.bd_learn_disable) %}{% set action = action + [("bd-learn-disable")] %}{% endif %}
{% if apic.fabric_policies.ep_loop_protection.port_disable | default(defaults.apic.fabric_policies.ep_loop_protection.port_disable) %}{% set action = action + [("port-disable")] %}{% endif %}
{% endif %}

Verify EP Loop Protection
    ${r}=   GET On Session   apic   /api/mo/uni/infra/epLoopProtectP-default.json
    Set Suite Variable   $r   ${r.json()}
    Should Be Equal JMESPath Json   ${r}    imdata[0].epLoopProtectP.attributes.action   {{ action | join(',') }}
    Should Be Equal JMESPath Json   ${r}    imdata[0].epLoopProtectP.attributes.adminSt   {{ 'enabled' if apic.fabric_policies.ep_loop_protection.admin_state | default(defaults.apic.fabric_policies.ep_loop_protection.admin_state) else 'disabled' }}
    Should Be Equal JMESPath Json   ${r}    imdata[0].epLoopProtectP.attributes.loopDetectIntvl   {{ apic.fabric_policies.ep_loop_protection.detection_interval | default(defaults.apic.fabric_policies.ep_loop_protection.detection_interval) }}
    Should Be Equal JMESPath Json   ${r}    imdata[0].epLoopProtectP.attributes.loopDetectMult   {{ apic.fabric_policies.ep_loop_protection.detection_multiplier | default(defaults.apic.fabric_policies.ep_loop_protection.detection_multiplier) }}
