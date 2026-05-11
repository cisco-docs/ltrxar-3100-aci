*** Settings ***
Documentation   Verify Site
Suite Setup     Login NDO
Default Tags    ndo   config   day1
Resource        ../../ndo_common.resource

*** Test Cases ***
Get Sites
    ${r}=   GET On Session   ndo   /mso/api/v2/sites
    Set Suite Variable   $r   ${r.json()}

{% for site in ndo.sites | default([]) %}

Verify Site {{ site.name }}
    ${site}=   Set Variable   sites[?common.name=='{{ site.name }}'] | [0]
    Should Be Equal JMESPath Json   ${r}   ${site}.common.name   {{ site.name }}
{% for url in site.apic_urls | default([]) %}
    Should Be Equal JMESPath Json   ${r}   ${site}.common.urls[{{ loop.index - 1 }}]   {{ url }}   {{ url }}:443
{% endfor %}
    Should Be Equal JMESPath Json   ${r}   ${site}.common.siteId   {{ site.id }}

{% endfor %}
