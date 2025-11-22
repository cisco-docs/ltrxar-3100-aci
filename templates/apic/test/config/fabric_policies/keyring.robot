*** Settings ***
Documentation   Verify Keyrings
Suite Setup     Login APIC
Default Tags    apic   day0   config   fabric_policies
Resource        ../../apic_common.resource

*** Test Cases ***
{% for keyring in apic.fabric_policies.aaa.key_rings | default([]) %}
{% set keyring_name = keyring.name ~ defaults.apic.fabric_policies.aaa.key_rings.name_suffix %}

Verify Keyring {{ keyring_name }}
    ${r}=   GET On Session   apic   api/node/mo/uni/userext/pkiext/keyring-{{ keyring_name }}.json
    Set Suite Variable   $r   ${r.json()}
    Should Be Equal JMESPath Json   ${r}    imdata[0].pkiKeyRing.attributes.name  {{ keyring_name }}
    Should Be Equal JMESPath Json   ${r}    imdata[0].pkiKeyRing.attributes.descr  {{ keyring.description | default() }}
{% if keyring.ca_certificate is defined %}
    Should Be Equal JMESPath Json   ${r}    imdata[0].pkiKeyRing.attributes.tp  {{ keyring.ca_certificate }}
{% endif %}
    Should Be Equal JMESPath Json   ${r}    imdata[0].pkiKeyRing.attributes.modulus  {{ keyring.modulus | default(defaults.apic.fabric_policies.aaa.key_rings.modulus) }}

{% endfor %}
