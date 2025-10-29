{# iterate_list apic.tenants name item[2] #}
*** Settings ***
Documentation   Verify Endpoint Retention Policy
Suite Setup     Login APIC
Default Tags    apic   day2   config   tenants
Resource        ../../../apic_common.resource

*** Test Cases ***
{% set tenant = ((apic | default()) | community.general.json_query('tenants[?name==`' ~ item[2] ~ '`]'))[0] %}
{% for endpoint_retention in tenant.policies.endpoint_retention_policies | default([]) %}
{% set endpoint_retention_name = endpoint_retention.name ~ defaults.apic.tenants.policies.endpoint_retention_policies.name_suffix %}

Verify Endpoint Retention Policy {{ endpoint_retention_name }}
    ${r}=   GET On Session   apic   /api/node/mo/uni/tn-{{ tenant.name }}/epRPol-{{ endpoint_retention_name }}.json   params=rsp-subtree=full
    Set Suite Variable   $r   ${r.json()}
    Should Be Equal Value Json String   ${r}   $..fvEpRetPol.attributes.name   {{ endpoint_retention_name }}
    Should Be Equal Value Json String   ${r}   $..fvEpRetPol.attributes.descr   {{ endpoint_retention.description | default() }}
    Should Be Equal Value Json String   ${r}   $..fvEpRetPol.attributes.holdIntvl   {{ endpoint_retention.hold_interval | default(defaults.apic.tenants.policies.endpoint_retention_policies.hold_interval) }}
    Should Be Equal Value Json String   ${r}   $..fvEpRetPol.attributes.bounceAgeIntvl   {{ 'infinite' if endpoint_retention.bounce_entry_aging_interval | default(defaults.apic.tenants.policies.endpoint_retention_policies.bounce_entry_aging_interval) == 0 else endpoint_retention.bounce_entry_aging_interval | default(defaults.apic.tenants.policies.endpoint_retention_policies.bounce_entry_aging_interval) }}
    Should Be Equal Value Json String   ${r}   $..fvEpRetPol.attributes.localEpAgeIntvl   {{ 'infinite' if endpoint_retention.local_endpoint_aging_interval | default(defaults.apic.tenants.policies.endpoint_retention_policies.local_endpoint_aging_interval) == 0 else endpoint_retention.local_endpoint_aging_interval | default(defaults.apic.tenants.policies.endpoint_retention_policies.local_endpoint_aging_interval) }}
    Should Be Equal Value Json String   ${r}   $..fvEpRetPol.attributes.remoteEpAgeIntvl   {{ 'infinite' if endpoint_retention.remote_endpoint_aging_interval | default(defaults.apic.tenants.policies.endpoint_retention_policies.remote_endpoint_aging_interval) == 0 else endpoint_retention.remote_endpoint_aging_interval | default(defaults.apic.tenants.policies.endpoint_retention_policies.remote_endpoint_aging_interval) }}
    Should Be Equal Value Json String   ${r}   $..fvEpRetPol.attributes.moveFreq   {{ 'none' if endpoint_retention.move_frequency | default(defaults.apic.tenants.policies.endpoint_retention_policies.move_frequency) == 0 else endpoint_retention.move_frequency | default(defaults.apic.tenants.policies.endpoint_retention_policies.move_frequency) }}
{% endfor %}
