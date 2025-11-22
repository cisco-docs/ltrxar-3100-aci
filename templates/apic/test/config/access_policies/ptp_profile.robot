*** Settings ***
Documentation   Verify PTP Profiles
Suite Setup     Login APIC
Default Tags    apic   day1   config   access_policies
Resource        ../../apic_common.resource

*** Test Cases ***
{% for ptp_profile in apic.access_policies.ptp_profiles | default([]) %}
{% set ptp_profile_name = ptp_profile.name %}

Verify PTP Profile {{ ptp_profile_name }}
    ${r}=   GET On Session   apic   /api/mo/uni/infra/ptpprofile-{{ ptp_profile_name }}.json   params=rsp-subtree=full
    Set Suite Variable   $r   ${r.json()}
    Should Be Equal JMESPath Json   ${r}    imdata[0].ptpProfile.attributes.name   {{ ptp_profile_name }}
    Should Be Equal JMESPath Json   ${r}    imdata[0].ptpProfile.attributes.announceIntvl   {{ ptp_profile.announce_interval | default(defaults.apic.access_policies.ptp_profiles.announce_interval) }}
    Should Be Equal JMESPath Json   ${r}    imdata[0].ptpProfile.attributes.announceTimeout   {{ ptp_profile.announce_timeout | default(defaults.apic.access_policies.ptp_profiles.announce_timeout) }}
    Should Be Equal JMESPath Json   ${r}    imdata[0].ptpProfile.attributes.delayIntvl   {{ ptp_profile.delay_interval | default(defaults.apic.access_policies.ptp_profiles.delay_interval) }}
    Should Be Equal JMESPath Json   ${r}    imdata[0].ptpProfile.attributes.syncIntvl   {{ ptp_profile.sync_interval | default(defaults.apic.access_policies.ptp_profiles.sync_interval) }}
    Should Be Equal JMESPath Json   ${r}    imdata[0].ptpProfile.attributes.profileTemplate   {{ 'telecom_full_path' if ptp_profile.template | default(defaults.apic.access_policies.ptp_profiles.template) == "telecom" else ('smpte' if ptp_profile.template | default(defaults.apic.access_policies.ptp_profiles.template) == "smpte" else 'aes67') }}
    {% if ptp_profile.template | default(defaults.apic.access_policies.ptp_profiles.template) == "telecom" %}
    Should Be Equal JMESPath Json   ${r}    imdata[0].ptpProfile.attributes.ptpoeDstMacType   {{ 'forwardable' if ptp_profile.forwardable | default(defaults.apic.access_policies.ptp_profiles.forwardable) else 'non-forwardable' }}
    Should Be Equal JMESPath Json   ${r}    imdata[0].ptpProfile.attributes.ptpoeDstMacRxNoMatch   {{ 'replyWithCfgMac' if prof.mismatch_handling | default(defaults.apic.access_policies.ptp_profiles.mismatch_handling) == 'configured' else ('replyWithRxMac' if prof.mismatch_handling | default(defaults.apic.access_policies.ptp_profiles.mismatch_handling) == 'received' else 'drop') }}
    Should Be Equal JMESPath Json   ${r}    imdata[0].ptpProfile.attributes.localPriority   {{ ptp_profile.priority | default(defaults.apic.access_policies.ptp_profiles.priority) }}
    {% endif %}
{% endfor %}
