*** Settings ***
Documentation   Verify LDAP Configuration
Suite Setup     Login APIC
Default Tags    apic   day0   config   fabric_policies   ldap
Resource        ../../apic_common.resource

*** Test Cases ***
{% for prov in apic.fabric_policies.aaa.ldap.providers | default([]) %}

Verify LDAP Provider {{ prov.hostname_ip }}
    ${r}=   GET On Session   apic   /api/mo/uni/userext/ldapext/ldapprovider-{{ prov.hostname_ip }}.json   params=rsp-subtree=full
    Set Suite Variable   $r   ${r.json()}
    Should Be Equal JMESPath Json   ${r}    imdata[0].aaaLdapProvider.attributes.name   {{ prov.hostname_ip }}
    Should Be Equal JMESPath Json   ${r}    imdata[0].aaaLdapProvider.attributes.SSLValidationLevel   {{ prov.ssl_validation_level | default(defaults.apic.fabric_policies.aaa.ldap.providers.ssl_validation_level) }}
    Should Be Equal JMESPath Json   ${r}    imdata[0].aaaLdapProvider.attributes.attribute   {{ prov.attribute | default() }}
    Should Be Equal JMESPath Json   ${r}    imdata[0].aaaLdapProvider.attributes.basedn   {{ prov.base_dn | default() }}
    Should Be Equal JMESPath Json   ${r}    imdata[0].aaaLdapProvider.attributes.descr   {{ prov.description | default() }}
    Should Be Equal JMESPath Json   ${r}    imdata[0].aaaLdapProvider.attributes.enableSSL   {{ 'yes' if prov.enable_ssl | default(defaults.apic.fabric_policies.aaa.ldap.providers.enable_ssl) else 'no' }}
    Should Be Equal JMESPath Json   ${r}    imdata[0].aaaLdapProvider.attributes.filter   {{ prov.filter | default() }}
    Should Be Equal JMESPath Json   ${r}    imdata[0].aaaLdapProvider.attributes.monitorServer   {{ 'enabled' if prov.server_monitoring | default(defaults.apic.fabric_policies.aaa.ldap.providers.server_monitoring) else 'disabled' }}
    Should Be Equal JMESPath Json   ${r}    imdata[0].aaaLdapProvider.attributes.port   {{ prov.port | default(defaults.apic.fabric_policies.aaa.ldap.providers.port) }}
    Should Be Equal JMESPath Json   ${r}    imdata[0].aaaLdapProvider.attributes.retries   {{ prov.retries | default(defaults.apic.fabric_policies.aaa.ldap.providers.retries) }}
    Should Be Equal JMESPath Json   ${r}    imdata[0].aaaLdapProvider.attributes.rootdn   {{ prov.rootdn | default() }}
    Should Be Equal JMESPath Json   ${r}    imdata[0].aaaLdapProvider.attributes.timeout   {{ prov.timeout | default(defaults.apic.fabric_policies.aaa.ldap.providers.timeout) }}
{% if prov.monitoring | default(defaults.apic.fabric_policies.aaa.ldap.providers.server_monitoring) %}
    Should Be Equal JMESPath Json   ${r}    imdata[0].aaaLdapProvider.attributes.monitoringUser   {{ prov.monitoring_username | default(defaults.apic.fabric_policies.aaa.ldap.providers.monitoring_username) }}
{% endif %}
{% set mgmt_epg = prov.mgmt_epg | default(defaults.apic.fabric_policies.aaa.ldap.providers.mgmt_epg) %}
{% if mgmt_epg == "oob" %}
    Should Be Equal JMESPath Json   ${r}    imdata[0].aaaLdapProvider.children[?aaaRsSecProvToEpg] | [0].aaaRsSecProvToEpg.attributes.tDn   uni/tn-mgmt/mgmtp-default/oob-{{ apic.node_policies.oob_endpoint_group | default(defaults.apic.node_policies.oob_endpoint_group) }}
{% elif mgmt_epg == "inb" %}
    Should Be Equal JMESPath Json   ${r}    imdata[0].aaaLdapProvider.children[?aaaRsSecProvToEpg] | [0].aaaRsSecProvToEpg.attributes.tDn   uni/tn-mgmt/mgmtp-default/inb-{{ apic.node_policies.inb_endpoint_group | default(defaults.apic.node_policies.inb_endpoint_group) }}
{% endif %}

{% endfor %}

{% for rule in apic.fabric_policies.aaa.ldap.group_map_rules | default([]) %}
Verify LDAP Group Map Rule {{ rule.name }}
    ${r}=   GET On Session   apic   /api/mo/uni/userext/ldapext/ldapgroupmaprule-{{ rule.name }}.json   params=rsp-subtree=full
    Set Suite Variable   $r   ${r.json()}
    Should Be Equal JMESPath Json   ${r}    imdata[0].aaaLdapGroupMapRule.attributes.name   {{ rule.name }}
    Should Be Equal JMESPath Json   ${r}    imdata[0].aaaLdapGroupMapRule.attributes.descr   {{ rule.description | default() }}
    Should Be Equal JMESPath Json   ${r}    imdata[0].aaaLdapGroupMapRule.attributes.groupdn   {{ rule.group_dn | default() }}
{% for dom in rule.security_domains | default([]) %}
    ${r}=   GET On Session   apic   /api/mo/uni/userext/ldapext/ldapgroupmaprule-{{ rule.name }}/userdomain-{{ dom.name }}.json
    Set Suite Variable   $r   ${r.json()}
    Should Be Equal JMESPath Json   ${r}    imdata[0].aaaUserDomain.attributes.name   {{ dom.name }}

{% for role in dom.roles | default([]) %}

Verify LDAP Group {{ rule.name }} Domain {{ dom.name }} Role {{ role.name }}
    ${r}=   GET On Session   apic   /api/mo/uni/userext/ldapext/ldapgroupmaprule-{{ rule.name }}.json   params=rsp-subtree=full
    Set Suite Variable   $r   ${r.json()}
    ${role}=   Set Variable   imdata[0].aaaLdapGroupMapRule.children[?aaaUserDomain.attributes.name=='{{ dom.name }}'] | [0].aaaUserDomain.children[?aaaUserRole.attributes.name=='{{ role.name }}'] | [0].aaaUserRole
    Should Be Equal JMESPath Json   ${r}    ${role}.attributes.name   {{ role.name }}
    Should Be Equal JMESPath Json   ${r}    ${role}.attributes.privType   {{ 'writePriv' if role.privilege_type | default(defaults.apic.fabric_policies.aaa.ldap.group_map_rules.security_domains.roles.privilege_type) == "write" else 'readPriv' }}

{% endfor %}

{% endfor %}

{% endfor %}

{% for group in apic.fabric_policies.aaa.ldap.group_maps | default([]) %}
Verify LDAP Group Map {{ group.name }}
    ${r}=   GET On Session   apic   /api/mo/uni/userext/ldapext/ldapgroupmap-{{ group.name }}.json   params=rsp-subtree=full
    Set Suite Variable   $r   ${r.json()}
    Should Be Equal JMESPath Json   ${r}    imdata[0].aaaLdapGroupMap.attributes.name   {{ group.name }}
    Should Be Equal JMESPath Json   ${r}    imdata[0].aaaLdapGroupMap.attributes.descr   {{ group.description | default()  }}
{% for rule in group.rules | default([]) %}
    Should Be Equal JMESPath Json   ${r}    imdata[0].aaaLdapGroupMap.children[?aaaLdapGroupMapRuleRef.attributes.name=='{{ rule.name }}'] | [0].aaaLdapGroupMapRuleRef.attributes.name   {{ rule.name }}
{% endfor %}

{% endfor %}
