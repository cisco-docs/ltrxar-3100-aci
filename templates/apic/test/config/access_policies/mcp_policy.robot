*** Settings ***
Documentation   Verify MCP Interface Policy
Suite Setup     Login APIC
Default Tags    apic   day1   config   access_policies
Resource        ../../apic_common.resource

*** Test Cases ***
{% for policy in apic.access_policies.interface_policies.mcp_policies | default([]) %}
{% set mcp_policy_name = policy.name ~ defaults.apic.access_policies.interface_policies.mcp_policies.name_suffix %}

Verify MCP Interface Policy {{ mcp_policy_name }}
    ${r}=   GET On Session   apic   /api/mo/uni/infra/mcpIfP-{{ mcp_policy_name }}.json
    Set Suite Variable   $r   ${r.json()}
    Should Be Equal JMESPath Json   ${r}    imdata[0].mcpIfPol.attributes.name   {{ mcp_policy_name }}
    Should Be Equal JMESPath Json   ${r}    imdata[0].mcpIfPol.attributes.adminSt   {{ 'enabled' if policy.admin_state else 'disabled' }}

{% endfor %}
