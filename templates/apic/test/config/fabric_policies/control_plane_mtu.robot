*** Settings ***
Documentation   Verify ACI Control Plane MTU Policy
Suite Setup     Login APIC
Default Tags    apic   day0   config   fabric_policies
Resource        ../../apic_common.resource

*** Test Cases ***
Verify ACI Control Plane MTU Policy
    ${r}=   GET On Session   apic   /api/mo/uni/infra/CPMtu.json
    Set Suite Variable   $r   ${r.json()}

    # This assertion will always run (and correctly uses a default)
    Should Be Equal JMESPath Json   ${r}    imdata[0].infraCPMtuPol.attributes.CPMtu  {{ apic.fabric_policies.control_plane_mtu.mtu | default(defaults.apic.fabric_policies.control_plane_mtu.mtu) }}

    {% if apic.fabric_policies.control_plane_mtu.apic_mtu_apply is defined %}
    Should Be Equal JMESPath Json   ${r}    imdata[0].infraCPMtuPol.attributes.APICMtuApply  {{ 'yes' if apic.fabric_policies.control_plane_mtu.apic_mtu_apply else 'no' }}
    {% endif %}
