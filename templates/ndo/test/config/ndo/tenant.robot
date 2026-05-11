*** Settings ***
Documentation   Verify Tenant
Suite Setup     Login NDO
Default Tags    ndo   config   day2
Resource        ../../ndo_common.resource

*** Test Cases ***
Get Tenants
    ${r}=   GET On Session   ndo   /api/v1/tenants
    Set Suite Variable   $r   ${r.json()}

{% for tenant in ndo.tenants | default([]) %}

Verify Tenant {{ tenant.name }}
    ${tenant}=   Set Variable   tenants[?name=='{{ tenant.name }}'] | [0]
    Should Be Equal JMESPath Json   ${r}   ${tenant}.name   {{ tenant.name }}
    Should Be Equal JMESPath Json   ${r}   ${tenant}.displayName   {{ tenant.name }}
    Should Be Equal JMESPath Json   ${r}   ${tenant}.description   {{ tenant.description | default() }}

{% for site in tenant.sites | default([]) %}

Verify Tenant {{ tenant.name }} Site {{ site.name }}
    ${site_id}=   NDO Lookup   sites   {{ site.name }}
    ${site}=   Set Variable   tenants[?name=='{{ tenant.name }}'] | [0].siteAssociations[?siteId=='${site_id}'] | [0]
    Should Be Equal JMESPath Json   ${r}   ${site}.siteId   ${site_id}
{% if site.azure_subscription_id is defined %}
    Should Be Equal JMESPath Json   ${r}   ${site}.cloudAccount   uni/tn-{{ site.azure_shared_tenant | default(tenant.name) }}/act-[{{ site.azure_subscription_id }}]-vendor-azure
{% if site.azure_shared_tenant is not defined %}
    Should Be Equal JMESPath Json   ${r}   ${site}.cloudSubscriptionId   {{ site.azure_subscription_id }}
{% endif %}
{% endif %}

{% endfor %}

{% for user in tenant.users | default([]) %}

Verify Tenant {{ tenant.name }} User {{ user.name }}
    ${user_id}=   NDO Lookup   users   {{ user.name }}
    ${user}=   Set Variable   tenants[?name=='{{ tenant.name }}'] | [0].userAssociations[?userId=='${user_id}'] | [0]
    Should Be Equal JMESPath Json   ${r}   ${user}.userId   ${user_id}

{% endfor %}

{% endfor %}
