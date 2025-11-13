*** Settings ***
Documentation   Verify IP Aging
Suite Setup     Login APIC
Default Tags    apic   day0   config   fabric_policies
Resource        ../../apic_common.resource

*** Test Cases ***
Verify IP Aging
    ${r}=   GET On Session   apic   /api/mo/uni/infra/ipAgingP-default.json
    Set Suite Variable   $r   ${r.json()}
    Should Be Equal JMESPath Json   ${r}    imdata[0].epIpAgingP.attributes.adminSt   {{ 'enabled' if apic.fabric_policies.ip_aging | default(defaults.apic.fabric_policies.ip_aging) else 'disabled' }}
