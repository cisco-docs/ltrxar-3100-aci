*** Settings ***
Documentation   Verify Error Disabled Recovery Policy
Suite Setup     Login APIC
Default Tags    apic   day0   config   fabric_policies
Resource        ../../apic_common.resource

*** Test Cases ***
Verify Error Disabled Recovery Policy
    ${r}=   GET On Session   apic   /api/mo/uni/infra/edrErrDisRecoverPol-default.json   params=rsp-subtree=full
    Set Suite Variable   $r   ${r.json()}
    Should Be Equal JMESPath Json   ${r}    imdata[0].edrErrDisRecoverPol.attributes.errDisRecovIntvl   {{ apic.fabric_policies.err_disabled_recovery.interval | default(defaults.apic.fabric_policies.err_disabled_recovery.interval) }}

Verify MCP Loop Policy
    ${policy}=   Set Variable   imdata[0].edrErrDisRecoverPol.children[?edrEventP.attributes.event=='event-mcp-loop'] | [0]
    Should Be Equal JMESPath Json   ${r}    ${policy}.edrEventP.attributes.recover   {{ 'yes' if apic.fabric_policies.err_disabled_recovery.mcp_loop | default(defaults.apic.fabric_policies.err_disabled_recovery.mcp_loop) else 'no' }}

Verify EP Move Policy
    ${policy}=   Set Variable   imdata[0].edrErrDisRecoverPol.children[?edrEventP.attributes.event=='event-ep-move'] | [0]
    Should Be Equal JMESPath Json   ${r}    ${policy}.edrEventP.attributes.recover   {{ 'yes' if apic.fabric_policies.err_disabled_recovery.ep_move | default(defaults.apic.fabric_policies.err_disabled_recovery.ep_move) else 'no' }}

Verify BPDU Guard Policy
    ${policy}=   Set Variable   imdata[0].edrErrDisRecoverPol.children[?edrEventP.attributes.event=='event-bpduguard'] | [0]
    Should Be Equal JMESPath Json   ${r}    ${policy}.edrEventP.attributes.recover   {{ 'yes' if apic.fabric_policies.err_disabled_recovery.bpdu_guard | default(defaults.apic.fabric_policies.err_disabled_recovery.bpdu_guard) else 'no' }}
