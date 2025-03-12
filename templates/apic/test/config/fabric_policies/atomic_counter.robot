*** Settings ***
Documentation   Verify Atomic Counter
Suite Setup     Login APIC
Default Tags    apic   day0   config   fabric_policies
Resource        ../../apic_common.resource

*** Test Cases ***
{% if apic.fabric_policies.atomic_counter.admin_state is defined %}
Verify Atomic Counter
    ${r}=   GET On Session   apic   /api/mo/uni/fabric/ogmode.json
    Should Be Equal Value Json String   ${r.json()}    $..dbgOngoingAcMode.attributes.adminSt   {{ 'enabled' if apic.fabric_policies.atomic_counter.admin_state else 'disabled' }}
    Should Be Equal Value Json String   ${r.json()}    $..dbgOngoingAcMode.attributes.mode   {{ apic.fabric_policies.atomic_counter.mode | default(defaults.apic.fabric_policies.atomic_counter.mode) }}
{% endif %}
