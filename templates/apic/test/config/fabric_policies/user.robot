*** Settings ***
Documentation   Verify User
Suite Setup     Login APIC
Default Tags    apic   day0   config   fabric_policies
Resource        ../../apic_common.resource

*** Test Cases ***
{% for user in apic.fabric_policies.aaa.users | default([]) %}
Verify User {{ user.username }}
    ${r}=   GET On Session   apic   /api/mo/uni/userext/user-{{ user.username }}.json   params=rsp-subtree=full
    Set Suite Variable   $r   ${r.json()}
    Should Be Equal JMESPath Json   ${r}    imdata[0].aaaUser.attributes.accountStatus   {{ user.status | default(defaults.apic.fabric_policies.aaa.users.status) }}
    Should Be Equal JMESPath Json   ${r}    imdata[0].aaaUser.attributes.certAttribute   {{ user.certificate_name | default() }}
    Should Be Equal JMESPath Json   ${r}    imdata[0].aaaUser.attributes.descr   {{ user.description | default() }}
    Should Be Equal JMESPath Json   ${r}    imdata[0].aaaUser.attributes.email   {{ user.email | default() }}
    Should Be Equal JMESPath Json   ${r}    imdata[0].aaaUser.attributes.expires   {{ 'yes' if user.expires | default(defaults.apic.fabric_policies.aaa.users.expires) else 'no' }}
{% if user.expires | default(defaults.apic.fabric_policies.aaa.users.expires) %}
    Should Be Equal JMESPath Json   ${r}    imdata[0].aaaUser.attributes.expiration   {{ user.expire_date | default() }}
{% endif %}
    Should Be Equal JMESPath Json   ${r}    imdata[0].aaaUser.attributes.firstName   {{ user.first_name | default() }}
    Should Be Equal JMESPath Json   ${r}    imdata[0].aaaUser.attributes.lastName   {{ user.last_name | default() }}
    Should Be Equal JMESPath Json   ${r}    imdata[0].aaaUser.attributes.phone   {{ user.phone | default() }}

{% for domain in user.domains | default([]) %}

Verify User {{ user.username }} Domain {{ domain.name }}
    ${domain}=   Set Variable   imdata[0].aaaUser.children[?aaaUserDomain.attributes.name=='{{ domain.name }}'] | [0]
    Should Be Equal JMESPath Json   ${r}    ${domain}.aaaUserDomain.attributes.name   {{ domain.name }}

{% for role in domain.roles | default([]) %}

Verify User {{ user.username }} Domain {{ domain.name }} Role {{ role.name }}
    ${domain}=   Set Variable   imdata[0].aaaUser.children[?aaaUserDomain.attributes.name=='{{ domain.name }}'] | [0].aaaUserDomain
    ${role}=   Set Variable   ${domain}.children[?aaaUserRole.attributes.name=='{{ role.name }}'] | [0].aaaUserRole
    Should Be Equal JMESPath Json   ${r}    ${role}.attributes.name   {{ role.name }}
    Should Be Equal JMESPath Json   ${r}    ${role}.attributes.privType   {{ 'writePriv' if role.privilege_type | default(defaults.apic.fabric_policies.aaa.users.domains.roles.privilege_type) == "write" else 'readPriv' }}

{% endfor %}

{% endfor %}

{% for cert in user.certificates | default([]) %}

Verify User {{ user.username }} Certificate {{ cert.name }}
    ${cert}=   Set Variable   imdata[0].aaaUser.children[?aaaUserCert.attributes.name=='{{ cert.name }}'] | [0]
    Should Be Equal JMESPath Json   ${r}    ${cert}.aaaUserCert.attributes.name   {{ cert.name }}

{% endfor %}

{% for key in user.ssh_keys | default([]) %}

Verify User {{ user.username }} SSH Keys {{ key.name }}
    ${cert}=   Set Variable   imdata[0].aaaUser.children[?aaaSshAuth.attributes.name=='{{ key.name }}'] | [0]
    Should Be Equal JMESPath Json   ${r}    ${cert}.aaaSshAuth.attributes.name   {{ key.name }}

{% endfor %}

{% endfor %}
