*** Settings ***
Documentation   Verify AAA Settings
Suite Setup     Login APIC
Default Tags    apic   day0   config   fabric_policies
Resource        ../../apic_common.resource

*** Test Cases ***
Verify AAA Settings
    ${r}=   GET On Session   apic   /api/mo/uni/userext/authrealm.json   params=rsp-subtree=full
    Set Suite Variable   $r   ${r.json()}
    Should Be Equal JMESPath Json   ${r}    imdata[0].aaaAuthRealm.attributes.defRolePolicy   {{ apic.fabric_policies.aaa.remote_user_login_policy | default(defaults.apic.fabric_policies.aaa.remote_user_login_policy) }}
    Should Be Equal JMESPath Json   ${r}    imdata[0].aaaAuthRealm.children[?aaaDefaultAuth] | [0].aaaDefaultAuth.attributes.fallbackCheck   {{ 'true' if apic.fabric_policies.aaa.default_fallback_check | default(defaults.apic.fabric_policies.aaa.default_fallback_check) else 'false' }}
    Should Be Equal JMESPath Json   ${r}    imdata[0].aaaAuthRealm.children[?aaaDefaultAuth] | [0].aaaDefaultAuth.attributes.realm   {{ apic.fabric_policies.aaa.default_realm | default(defaults.apic.fabric_policies.aaa.default_realm) }}
{% if apic.fabric_policies.aaa.default_realm | default(defaults.apic.fabric_policies.aaa.default_realm) in ["tacacs", "radius", "ldap"] %}
    Should Be Equal JMESPath Json   ${r}    imdata[0].aaaAuthRealm.children[?aaaDefaultAuth] | [0].aaaDefaultAuth.attributes.providerGroup   {{ apic.fabric_policies.aaa.default_login_domain | default(defaults.apic.fabric_policies.aaa.default_login_domain) }}
{% endif %}
    Should Be Equal JMESPath Json   ${r}    imdata[0].aaaAuthRealm.children[?aaaConsoleAuth] | [0].aaaConsoleAuth.attributes.realm   {{ apic.fabric_policies.aaa.console_realm | default(defaults.apic.fabric_policies.aaa.console_realm) }}
{% if apic.fabric_policies.aaa.console_realm | default(defaults.apic.fabric_policies.aaa.console_realm) in ["tacacs", "radius", "ldap"] %}
    Should Be Equal JMESPath Json   ${r}    imdata[0].aaaAuthRealm.children[?aaaConsoleAuth] | [0].aaaConsoleAuth.attributes.providerGroup   {{ apic.fabric_policies.aaa.console_login_domain | default(defaults.apic.fabric_policies.aaa.console_login_domain) }}
{% endif %}

Verify AAA Security Domains
    ${r}=   GET On Session   apic   /api/node/class/aaaDomain.json
    Set Suite Variable   $r   ${r.json()}
{% for sd in apic.fabric_policies.aaa.security_domains| default([]) %}
    Should Be Equal JMESPath Json   ${r}   imdata[?aaaDomain.attributes.name=='{{ sd.name }}'] | [0].aaaDomain.attributes.name   {{ sd.name }}
    Should Be Equal JMESPath Json   ${r}   imdata[?aaaDomain.attributes.name=='{{ sd.name }}'] | [0].aaaDomain.attributes.descr   {{ sd.description | default() }}
    Should Be Equal JMESPath Json   ${r}   imdata[?aaaDomain.attributes.name=='{{ sd.name }}'] | [0].aaaDomain.attributes.restrictedRbacDomain   {{ 'yes' if sd.restricted_rbac_domain | default(defaults.apic.fabric_policies.aaa.security_domains.restricted_rbac_domain) else 'no' }}
{% endfor %}

Verify AAA Password Strength Check
    ${r}=   GET On Session   apic   /api/mo/uni/userext.json
    Set Suite Variable   $r   ${r.json()}
    Should Be Equal JMESPath Json   ${r}    imdata[0].aaaUserEp.attributes.pwdStrengthCheck   {{ 'yes' if apic.fabric_policies.aaa.management_settings.password_strength_check | default(defaults.apic.fabric_policies.aaa.management_settings.password_strength_check) else 'no' }}

{% if apic.fabric_policies.aaa.management_settings.password_strength_check | default(defaults.apic.fabric_policies.aaa.management_settings.password_strength_check) %}
Verify AAA Password Strength Profile
    ${r}=   GET On Session   apic   /api/node/mo/uni/userext/pwdstrengthprofile.json
    Set Suite Variable   $r   ${r.json()}
    Should Be Equal JMESPath Json   ${r}    imdata[0].aaaPwdStrengthProfile.attributes.pwdMinLength   {{ apic.fabric_policies.aaa.management_settings.password_strength_profile.password_mininum_length | default(defaults.apic.fabric_policies.aaa.management_settings.password_strength_profile.password_mininum_length) }}
    Should Be Equal JMESPath Json   ${r}    imdata[0].aaaPwdStrengthProfile.attributes.pwdMaxLength   {{ apic.fabric_policies.aaa.management_settings.password_strength_profile.password_maximum_length | default(defaults.apic.fabric_policies.aaa.management_settings.password_strength_profile.password_maximum_length) }}
    Should Be Equal JMESPath Json   ${r}    imdata[0].aaaPwdStrengthProfile.attributes.pwdStrengthTestType   {{ apic.fabric_policies.aaa.management_settings.password_strength_profile.password_strength_test_type | default(defaults.apic.fabric_policies.aaa.management_settings.password_strength_profile.password_strength_test_type) }}
    Should Be Equal JMESPath Json   ${r}    imdata[0].aaaPwdStrengthProfile.attributes.pwdClassFlags  {{ apic.fabric_policies.aaa.management_settings.password_strength_profile.password_class_flags | default(defaults.apic.fabric_policies.aaa.management_settings.password_strength_profile.password_class_flags) | sort() | join(',') }}
{% endif %}

Verify AAA Password Profile
    ${r}=   GET On Session   apic   /api/node/mo/uni/userext/pwdprofile.json
    Set Suite Variable   $r   ${r.json()}
    Should Be Equal JMESPath Json   ${r}    imdata[0].aaaPwdProfile.attributes.changeDuringInterval   {{ 'enable' if apic.fabric_policies.aaa.management_settings.password_change_during_interval | default(defaults.apic.fabric_policies.aaa.management_settings.password_change_during_interval) else 'disable' }}
    Should Be Equal JMESPath Json   ${r}    imdata[0].aaaPwdProfile.attributes.changeCount   {{ apic.fabric_policies.aaa.management_settings.password_change_count | default(defaults.apic.fabric_policies.aaa.management_settings.password_change_count) }}
    Should Be Equal JMESPath Json   ${r}    imdata[0].aaaPwdProfile.attributes.changeInterval   {{ apic.fabric_policies.aaa.management_settings.password_change_interval | default(defaults.apic.fabric_policies.aaa.management_settings.password_change_interval) }}
    Should Be Equal JMESPath Json   ${r}    imdata[0].aaaPwdProfile.attributes.noChangeInterval   {{ apic.fabric_policies.aaa.management_settings.password_no_change_interval | default(defaults.apic.fabric_policies.aaa.management_settings.password_no_change_interval) }}
    Should Be Equal JMESPath Json   ${r}    imdata[0].aaaPwdProfile.attributes.historyCount   {{ apic.fabric_policies.aaa.management_settings.password_history_count | default(defaults.apic.fabric_policies.aaa.management_settings.password_history_count) }}

Verify AAA Web Token Settings
    ${r}=   GET On Session   apic   /api/mo/uni/userext/pkiext/webtokendata.json
    Set Suite Variable   $r   ${r.json()}
    Should Be Equal JMESPath Json   ${r}    imdata[0].pkiWebTokenData.attributes.webtokenTimeoutSeconds   {{ apic.fabric_policies.aaa.management_settings.web_token_timeout | default(defaults.apic.fabric_policies.aaa.management_settings.web_token_timeout) }}
    Should Be Equal JMESPath Json   ${r}    imdata[0].pkiWebTokenData.attributes.maximumValidityPeriod   {{ apic.fabric_policies.aaa.management_settings.web_token_max_validity | default(defaults.apic.fabric_policies.aaa.management_settings.web_token_max_validity) }}
    Should Be Equal JMESPath Json   ${r}    imdata[0].pkiWebTokenData.attributes.uiIdleTimeoutSeconds   {{ apic.fabric_policies.aaa.management_settings.web_session_idle_timeout | default(defaults.apic.fabric_policies.aaa.management_settings.web_session_idle_timeout) }}
    Should Be Equal JMESPath Json   ${r}    imdata[0].pkiWebTokenData.attributes.sessionRecordFlags   {{ 'login,logout,refresh' if apic.fabric_policies.aaa.management_settings.include_refresh_session_records | default(defaults.apic.fabric_policies.aaa.management_settings.include_refresh_session_records) else 'login,logout' }}

Verify AAA Block Login Profile
    ${r}=   GET On Session   apic   /api/node/mo/uni/userext/blockloginp.json
    Set Suite Variable   $r   ${r.json()}
    Should Be Equal JMESPath Json   ${r}    imdata[0].aaaBlockLoginProfile.attributes.enableLoginBlock   {{ 'enable' if apic.fabric_policies.aaa.management_settings.enable_login_block | default(defaults.apic.fabric_policies.aaa.management_settings.enable_login_block) else 'disable' }}
    Should Be Equal JMESPath Json   ${r}    imdata[0].aaaBlockLoginProfile.attributes.blockDuration   {{ apic.fabric_policies.aaa.management_settings.login_block_duration | default(defaults.apic.fabric_policies.aaa.management_settings.login_block_duration) }}
    Should Be Equal JMESPath Json   ${r}    imdata[0].aaaBlockLoginProfile.attributes.maxFailedAttempts   {{ apic.fabric_policies.aaa.management_settings.login_max_failed_attempts | default(defaults.apic.fabric_policies.aaa.management_settings.login_max_failed_attempts) }}
    Should Be Equal JMESPath Json   ${r}    imdata[0].aaaBlockLoginProfile.attributes.maxFailedAttemptsWindow   {{ apic.fabric_policies.aaa.management_settings.login_max_failed_attempts_window | default(defaults.apic.fabric_policies.aaa.management_settings.login_max_failed_attempts_window) }}
