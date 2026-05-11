*** Settings ***
Documentation   Verify Port Security Policy
Suite Setup     Login APIC
Default Tags    apic   day1   config   access_policies
Resource        ../../apic_common.resource

*** Test Cases ***
{% for policy in apic.access_policies.interface_policies.port_security_policies | default([]) %}
{% set port_security_policy_name = policy.name ~ defaults.apic.access_policies.interface_policies.port_security_policies.name_suffix %}

Verify Port Security Policy {{ port_security_policy_name }}
    ${r}=   GET On Session   apic   /api/mo/uni/infra/portsecurityP-{{ port_security_policy_name }}.json
    Set Suite Variable   $r   ${r.json()}
    Should Be Equal JMESPath Json   ${r}    imdata[0].l2PortSecurityPol.attributes.name   {{ port_security_policy_name }}
    Should Be Equal JMESPath Json   ${r}    imdata[0].l2PortSecurityPol.attributes.descr   {{ policy.description | default() }}
    Should Be Equal JMESPath Json   ${r}    imdata[0].l2PortSecurityPol.attributes.maximum   {{ policy.maximum_endpoints | default(defaults.apic.access_policies.interface_policies.port_security_policies.maximum_endpoints) }}
    Should Be Equal JMESPath Json   ${r}    imdata[0].l2PortSecurityPol.attributes.timeout   {{ policy.timeout | default(defaults.apic.access_policies.interface_policies.port_security_policies.timeout) }}

{% endfor %}
