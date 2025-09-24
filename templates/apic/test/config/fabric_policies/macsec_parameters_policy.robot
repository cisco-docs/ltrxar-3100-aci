*** Settings ***
Documentation   Verify MACsec Fabric Parameters Policy
Suite Setup     Login APIC
Default Tags    apic   day1   config   fabric_policies
Resource        ../../apic_common.resource

*** Test Cases ***
{% for policy in apic.fabric_policies.macsec_parameters_policies | default([]) %}
{% set policy_name = policy.name ~ defaults.apic.fabric_policies.macsec_parameters_policies.name_suffix %}

Verify MACsec Fabric Parameters Policy {{ policy_name }}
    ${r}=   GET On Session   apic   /api/mo/uni/fabric/macsecpcontfab/fabparamp-{{ policy_name }}.json
    Should Be Equal Value Json String   ${r.json()}    $..macsecFabParamPol.attributes.name   {{ policy_name }}
    Should Be Equal Value Json String   ${r.json()}    $..macsecFabParamPol.attributes.descr   {{ policy.description | default() }}
    Should Be Equal Value Json String   ${r.json()}    $..macsecFabParamPol.attributes.cipherSuite   {{ policy.cipher_suite | default(defaults.apic.fabric_policies.macsec_parameters_policies.cipher_suite) }}
    Should Be Equal Value Json String   ${r.json()}    $..macsecFabParamPol.attributes.replayWindow   {{ policy.window_size | default(defaults.apic.fabric_policies.macsec_parameters_policies.window_size) }}
    Should Be Equal Value Json String   ${r.json()}    $..macsecFabParamPol.attributes.sakExpiryTime   {{ policy.key_expiry_time | default(defaults.apic.fabric_policies.macsec_parameters_policies.key_expiry_time) }}
    Should Be Equal Value Json String   ${r.json()}    $..macsecFabParamPol.attributes.secPolicy   {{ policy.security_policy | default(defaults.apic.fabric_policies.macsec_parameters_policies.security_policy) }}

{% endfor %}
