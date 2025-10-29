*** Settings ***
Documentation   Verify LLDP Interface Policy
Suite Setup     Login APIC
Default Tags    apic   day1   config   access_policies
Resource        ../../apic_common.resource

*** Test Cases ***
{% for policy in apic.access_policies.interface_policies.lldp_policies | default([]) %}
{% set lldp_policy_name = policy.name ~ defaults.apic.access_policies.interface_policies.lldp_policies.name_suffix %}

Verify LLDP Interface Policy {{ lldp_policy_name }}
    ${r}=   GET On Session   apic   /api/mo/uni/infra/lldpIfP-{{ lldp_policy_name }}.json
    Set Suite Variable   $r   ${r.json()}
    Should Be Equal Value Json String   ${r}    $..lldpIfPol.attributes.name   {{ lldp_policy_name }}
    Should Be Equal Value Json String   ${r}    $..lldpIfPol.attributes.adminRxSt   {{ 'enabled' if policy.admin_rx_state else 'disabled' }}
    Should Be Equal Value Json String   ${r}    $..lldpIfPol.attributes.adminTxSt   {{ 'enabled' if policy.admin_tx_state else 'disabled' }}
    {% if policy.dcbxp_version is defined %}
    Should Be Equal Value Json String   ${r}    $..lldpIfPol.attributes.portDCBXPVer   {{ policy.dcbxp_version }}
    {% endif %}
{% endfor %}
