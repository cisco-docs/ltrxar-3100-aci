{# iterate_list apic.tenants name item[2] #}
*** Settings ***
Documentation   Verify Contract
Suite Setup     Login APIC
Default Tags    apic   day2   config   tenants
Resource        ../../../apic_common.resource

*** Test Cases ***
{% set tenant = ((apic | default()) | community.general.json_query('tenants[?name==`' ~ item[2] ~ '`]'))[0] %}
{% for contract in tenant.contracts | default([]) %}
{% set contract_name = contract.name ~ defaults.apic.tenants.contracts.name_suffix %}

Verify Contract {{ contract_name }}
    ${r}=   GET On Session   apic   /api/mo/uni/tn-{{ tenant.name }}/brc-{{ contract_name }}.json   params=rsp-subtree=full
    Set Suite Variable   $r   ${r.json()}
    Should Be Equal Value Json String   ${r}   $..vzBrCP.attributes.name   {{ contract_name }}
    Should Be Equal Value Json String   ${r}   $..vzBrCP.attributes.nameAlias   {{ contract.alias  | default() }}
    Should Be Equal Value Json String   ${r}   $..vzBrCP.attributes.descr   {{ contract.description | default() }}
    Should Be Equal Value Json String   ${r}   $..vzBrCP.attributes.scope   {{ contract.scope | default(defaults.apic.tenants.contracts.scope) }}
    Should Be Equal Value Json String   ${r}   $..vzBrCP.attributes.prio   {{ contract.qos_class | default(defaults.apic.tenants.contracts.qos_class) }}
    Should Be Equal Value Json String   ${r}   $..vzBrCP.attributes.targetDscp   {{ contract.target_dscp | default(defaults.apic.tenants.contracts.target_dscp) }}

{% for subject in contract.subjects | default([]) %}
{% set subject_name = subject.name ~ defaults.apic.tenants.contracts.subjects.name_suffix %}

Verify Contract {{ contract_name }} Subject {{ subject_name }}
    ${subject}=   Set Variable   $..vzBrCP.children[?(@.vzSubj.attributes.name=='{{ subject_name }}')]
    Should Be Equal Value Json String   ${r}   ${subject}..vzSubj.attributes.name   {{ subject_name }}
    Should Be Equal Value Json String   ${r}   ${subject}..vzSubj.attributes.nameAlias   {{ subject.alias | default() }}
    Should Be Equal Value Json String   ${r}   ${subject}..vzSubj.attributes.descr   {{ subject.description | default() }}
    Should Be Equal Value Json String   ${r}   ${subject}..vzSubj.attributes.prio   {{ subject.qos_class | default(defaults.apic.tenants.contracts.subjects.qos_class) }}
    Should Be Equal Value Json String   ${r}   ${subject}..vzSubj.attributes.revFltPorts   {{ ('yes' if (subject.reverse_filter_ports | default(defaults.apic.tenants.contracts.subjects.reverse_filter_ports)) else 'no') if subject.filters is defined  else 'no' }}
    Should Be Equal Value Json String   ${r}   ${subject}..vzSubj.attributes.targetDscp   {{ subject.target_dscp | default(defaults.apic.tenants.contracts.subjects.target_dscp) }}
{% if subject.service_graph is defined and subject.filters is defined %}
    Should Be Equal Value Json String   ${r}   ${subject}..vzRsSubjGraphAtt.attributes.tnVnsAbsGraphName   {{ subject.service_graph }}
{% endif %}

{% for filter in subject.filters | default([]) %}
{% set filter_name = filter.filter ~ defaults.apic.tenants.filters.name_suffix %}
{% set directives = [] %}
{% if filter.log | default(defaults.apic.tenants.contracts.subjects.filters.log) %}{% set directives = directives + [("log")] %}{% endif %}
{% if filter.no_stats | default(defaults.apic.tenants.contracts.subjects.filters.no_stats) %}{% set directives = directives + [("no_stats")] %}{% endif %}

Verify Contract {{ contract_name }} Subject {{ subject_name }} Filter {{ filter_name }}
    ${filter}=   Set Variable   $..vzBrCP.children[?(@.vzSubj.attributes.name=='{{ subject_name }}')].vzSubj.children[?(@.vzRsSubjFiltAtt.attributes.tnVzFilterName=='{{ filter_name }}')]
    Should Be Equal Value Json String   ${r}   ${filter}..vzRsSubjFiltAtt.attributes.tnVzFilterName   {{ filter_name }}
    Should Be Equal Value Json String   ${r}   ${filter}..vzRsSubjFiltAtt.attributes.action   {{ filter.action | default(defaults.apic.tenants.contracts.subjects.filters.action) }}
    Should Be Equal Value Json String   ${r}   ${filter}..vzRsSubjFiltAtt.attributes.directives   {{ directives | join(',') }}
    Should Be Equal Value Json String   ${r}   ${filter}..vzRsSubjFiltAtt.attributes.priorityOverride   {{ filter.priority | default(defaults.apic.tenants.contracts.subjects.filters.priority) }}

{% endfor %}

{% if subject.filters is not defined and subject.consumer_to_provider.filters is defined %}
Verify Contract {{ contract_name }} Subject {{ subject_name }} Consumer_to_Provider
    ${consumer_to_provider}=   Set Variable   $..vzBrCP.children[?(@.vzSubj.attributes.name=='{{ subject_name }}')].vzSubj.children[?(@.vzInTerm)].vzInTerm
    Should Be Equal Value Json String   ${r}   ${consumer_to_provider}..attributes.prio   {{ subject.consumer_to_provider.qos_class | default(defaults.apic.tenants.contracts.subjects.consumer_to_provider.qos_class)}}
    Should Be Equal Value Json String   ${r}   ${consumer_to_provider}..attributes.targetDscp   {{ subject.consumer_to_provider.target_dscp | default(defaults.apic.tenants.contracts.subjects.consumer_to_provider.target_dscp) }}
 {% if subject.consumer_to_provider.service_graph is defined and subject.consumer_to_provider.filters is defined %}
    Should Be Equal Value Json String   ${r}   ${consumer_to_provider}..vzRsInTermGraphAtt.attributes.tnVnsAbsGraphName   {{ subject.consumer_to_provider.service_graph | default(defaults.apic.tenants.services.service_graph_templates.name_suffix) }}
{% endif %}

{% for filter in subject.consumer_to_provider.filters | default([]) %}
{% set filter_name = filter.filter ~ defaults.apic.tenants.filters.name_suffix %}
{% set directives = [] %}
{% if filter.log | default(defaults.apic.tenants.contracts.subjects.consumer_to_provider.filters.log) %}{% set directives = directives + [("log")] %}{% endif %}
{% if filter.no_stats | default(defaults.apic.tenants.contracts.subjects.consumer_to_provider.filters.no_stats) %}{% set directives = directives + [("no_stats")] %}{% endif %}

Verify Contract {{ contract_name }} Subject {{ subject_name }} Consumer_to_Provider Filter {{ filter_name }}
    ${filter}=   Set Variable   $..vzBrCP.children[?(@.vzSubj.attributes.name=='{{ subject_name }}')].vzSubj.children[?(@.vzInTerm)].vzInTerm.children[?(@.vzRsFiltAtt.attributes.tnVzFilterName=='{{ filter_name }}')]
    Should Be Equal Value Json String   ${r}   ${filter}..vzRsFiltAtt.attributes.tnVzFilterName   {{ filter_name }}
    Should Be Equal Value Json String   ${r}   ${filter}..vzRsFiltAtt.attributes.action   {{ filter.action | default(defaults.apic.tenants.contracts.subjects.consumer_to_provider.filters.action) }}
    Should Be Equal Value Json String   ${r}   ${filter}..vzRsFiltAtt.attributes.directives   {{ directives | join(',') }}
    Should Be Equal Value Json String   ${r}   ${filter}..vzRsFiltAtt.attributes.priorityOverride   {{ filter.priority | default(defaults.apic.tenants.contracts.subjects.consumer_to_provider.filters.priority) }}
{% endfor %}
{% endif %}

{% if subject.filters is not defined and subject.provider_to_consumer.filters is defined %}
Verify Contract {{ contract_name }} Subject {{ subject_name }} Unidirectional Provider_to_Consumer
    ${provider_to_consumer}=   Set Variable   $..vzBrCP.children[?(@.vzSubj.attributes.name=='{{ subject_name }}')].vzSubj.children[?(@.vzOutTerm)].vzOutTerm
    Should Be Equal Value Json String   ${r}   ${provider_to_consumer}..attributes.prio   {{ subject.provider_to_consumer.qos_class | default(defaults.apic.tenants.contracts.subjects.provider_to_consumer.qos_class) }}
    Should Be Equal Value Json String   ${r}   ${provider_to_consumer}..attributes.targetDscp   {{ subject.provider_to_consumer.target_dscp | default(defaults.apic.tenants.contracts.subjects.provider_to_consumer.target_dscp) }}
 {% if subject.provider_to_consumer.service_graph is defined and subject.provider_to_consumer.filters is defined %}
    Should Be Equal Value Json String   ${r}   ${provider_to_consumer}..vzRsOutTermGraphAtt.attributes.tnVnsAbsGraphName   {{ subject.provider_to_consumer.service_graph | default(defaults.apic.tenants.services.service_graph_templates.name_suffix) }}
{% endif %}

{% for filter in subject.provider_to_consumer.filters | default([]) %}
{% set filter_name = filter.filter ~ defaults.apic.tenants.filters.name_suffix %}
{% set directives = [] %}
{% if filter.log | default(defaults.apic.tenants.contracts.subjects.provider_to_consumer.filters.log) %}{% set directives = directives + [("log")] %}{% endif %}
{% if filter.no_stats | default(defaults.apic.tenants.contracts.subjects.provider_to_consumer.filters.no_stats) %}{% set directives = directives + [("no_stats")] %}{% endif %}

Verify Contract {{ contract_name }} Subject {{ subject_name }} Provider_to_Consumer Filter {{ filter_name }}
    ${filter}=   Set Variable   $..vzBrCP.children[?(@.vzSubj.attributes.name=='{{ subject_name }}')].vzSubj.children[?(@.vzOutTerm)].vzOutTerm.children[?(@.vzRsFiltAtt.attributes.tnVzFilterName=='{{ filter_name }}')]
    Should Be Equal Value Json String   ${r}   ${filter}..vzRsFiltAtt.attributes.tnVzFilterName   {{ filter_name }}
    Should Be Equal Value Json String   ${r}   ${filter}..vzRsFiltAtt.attributes.action   {{ filter.action | default(defaults.apic.tenants.contracts.subjects.provider_to_consumer.filters.action) }}
    Should Be Equal Value Json String   ${r}   ${filter}..vzRsFiltAtt.attributes.directives   {{ directives | join(',') }}
    Should Be Equal Value Json String   ${r}   ${filter}..vzRsFiltAtt.attributes.priorityOverride   {{ filter.priority | default(defaults.apic.tenants.contracts.subjects.provider_to_consumer.filters.priority) }}
{% endfor %}


{% endif %}

{% endfor %}

{% endfor %}
