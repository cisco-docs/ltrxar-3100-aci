*** Settings ***
Documentation   System Global GIPo
Suite Setup     Login APIC
Default Tags    apic   day0   config   fabric_policies
Resource        ../../apic_common.resource

*** Test Cases ***
Verify System Global GIPo
    ${r}=   GET On Session   apic   /api/mo/uni/infra/systemgipopol.json
    Set Suite Variable   $r   ${r.json()}
    Should Be Equal JMESPath Json   ${r}    imdata[0].fmcastSystemGIPoPol.attributes.useConfiguredSystemGIPo   {{ 'enabled' if apic.fabric_policies.use_infra_gipo | default(defaults.apic.fabric_policies.use_infra_gipo) else 'disabled' }}
