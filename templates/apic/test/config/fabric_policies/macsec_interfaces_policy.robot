*** Settings ***
Documentation   Verify MACsec Fabric Interfaces Policy
Suite Setup     Login APIC
Default Tags    apic   day1   config   fabric_policies
Resource        ../../apic_common.resource

*** Test Cases ***
{% for policy in apic.fabric_policies.macsec_interfaces_policies | default([]) %}
{% set policy_name = policy.name ~ defaults.apic.fabric_policies.macsec_interfaces_policies.name_suffix %}
{% set keychain_policy_name = policy.macsec_keychain_policy ~ defaults.apic.fabric_policies.macsec_keychain_policies.name_suffix %}
{% set param_policy_name = policy.macsec_parameters_policy ~ defaults.apic.fabric_policies.macsec_parameters_policies.name_suffix %}

Verify MACsec Fabric Interfaces Policy {{ policy_name }}
    ${r}=   GET On Session   apic   /api/mo/uni/fabric/macsecfabifp-{{ policy_name }}.json   params=rsp-subtree=full
    Should Be Equal Value Json String   ${r.json()}    $..macsecFabIfPol.attributes.name   {{ policy_name }}
    Should Be Equal Value Json String   ${r.json()}    $..macsecFabIfPol.attributes.descr   {{ policy.description | default() }}
    Should Be Equal Value Json String   ${r.json()}    $..macsecFabIfPol.attributes.adminSt   {{ 'enabled' if policy.admin_state | default(defaults.apic.fabric_policies.macsec_interfaces_policies.admin_state) else 'disabled' }}
    Should Be Equal Value Json String   ${r.json()}    $..macsecRsToParamPol.attributes.tDn   uni/fabric/macsecpcontfab/fabparamp-{{ param_policy_name }}
    Should Be Equal Value Json String   ${r.json()}    $..macsecRsToKeyChainPol.attributes.tDn   uni/fabric/macsecpcontfab/keychainp-{{ keychain_policy_name }}

{% endfor %}
