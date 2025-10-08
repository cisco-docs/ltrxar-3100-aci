*** Settings ***
Documentation   Verify MCP Global Instance
Suite Setup     Login APIC
Default Tags    apic   day0   config   access_policies
Resource        ../../apic_common.resource

*** Test Cases ***
Verify MCP Global Instance
    ${r}=   GET On Session   apic   /api/mo/uni/infra/mcpInstP-default.json
    Should Be Equal Value Json String   ${r.json()}    $..mcpInstPol.attributes.adminSt   {{ 'enabled' if apic.access_policies.mcp.admin_state | default(defaults.apic.access_policies.mcp.admin_state) else 'disabled' }}
    Should Be Equal Value Json String   ${r.json()}    $..mcpInstPol.attributes.ctrl   {% if apic.access_policies.mcp.per_vlan | default(defaults.apic.access_policies.mcp.per_vlan) %}pdu-per-vlan{% endif %}
    Should Be Equal Value Json String   ${r.json()}    $..mcpInstPol.attributes.initDelayTime   {{ apic.access_policies.mcp.initial_delay | default(defaults.apic.access_policies.mcp.initial_delay) }}
    Should Be Equal Value Json String   ${r.json()}    $..mcpInstPol.attributes.loopDetectMult   {{ apic.access_policies.mcp.loop_detection | default(defaults.apic.access_policies.mcp.loop_detection) }}
    Should Be Equal Value Json String   ${r.json()}    $..mcpInstPol.attributes.loopProtectAct   {% if apic.access_policies.mcp.action | default(defaults.apic.access_policies.mcp.action) %}port-disable{% endif %}
    Should Be Equal Value Json String   ${r.json()}    $..mcpInstPol.attributes.txFreq   {{ apic.access_policies.mcp.frequency_sec | default(defaults.apic.access_policies.mcp.frequency_sec) }}
    Should Be Equal Value Json String   ${r.json()}    $..mcpInstPol.attributes.txFreqMsec   {{ apic.access_policies.mcp.frequency_msec | default(defaults.apic.access_policies.mcp.frequency_msec) }}
