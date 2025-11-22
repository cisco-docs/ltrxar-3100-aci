*** Settings ***
Documentation   Verify MACsec Fabric Keychain Policy
Suite Setup     Login APIC
Default Tags    apic   day1   config   fabric_policies
Resource        ../../apic_common.resource

*** Test Cases ***
{% for policy in apic.fabric_policies.macsec_keychain_policies | default([]) %}
{% set policy_name = policy.name ~ defaults.apic.fabric_policies.macsec_keychain_policies.name_suffix %}

Verify MACsec Fabric Keychain Policy {{ policy_name }}
    ${r}=   GET On Session   apic   /api/mo/uni/fabric/macsecpcontfab/keychainp-{{ policy_name }}.json   params=rsp-subtree=full
    Set Suite Variable   $r   ${r.json()}
    Should Be Equal JMESPath Json   ${r}    imdata[0].macsecKeyChainPol.attributes.name   {{ policy_name }}
    Should Be Equal JMESPath Json   ${r}    imdata[0].macsecKeyChainPol.attributes.descr   {{ policy.description | default() }}

{% for key_policy in policy.key_policies | default([]) %}

Verify MACsec Fabric Keychain {{ policy_name }} Key Policy {{ key_policy.key_name }}
    ${key}=   Set Variable   imdata[0].macsecKeyChainPol.children[?macsecKeyPol.attributes.keyName=='{{ key_policy.key_name }}'] | [0].macsecKeyPol
    Should Be Equal JMESPath Json   ${r}    ${key}.attributes.name   {{ key_policy.name | default() }}
    Should Be Equal JMESPath Json   ${r}    ${key}.attributes.descr   {{ key_policy.description | default() }}
    Should Be Equal JMESPath Json   ${r}    ${key}.attributes.keyName   {{ key_policy.key_name }}
    {% if key_policy.start_time | default(defaults.apic.fabric_policies.macsec_keychain_policies.key_policies.start_time) != "now" %}
    Should Be Equal JMESPath Json   ${r}    ${key}.attributes.startTime   {{ key_policy.start_time | default(defaults.apic.fabric_policies.macsec_keychain_policies.key_policies.start_time) }}
    {% endif %}
    Should Be Equal JMESPath Json   ${r}    ${key}.attributes.endTime   {{ key_policy.end_time | default(defaults.apic.fabric_policies.macsec_keychain_policies.key_policies.end_time) }}

{% endfor %}
{% endfor %}
