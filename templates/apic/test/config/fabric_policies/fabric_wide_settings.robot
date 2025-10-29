*** Settings ***
Documentation   Verify Fabric Wide Settings
Suite Setup     Login APIC
Default Tags    apic   day0   config   fabric_policies
Resource        ../../apic_common.resource

*** Test Cases ***
Verify Fabric Wide Settings
    ${r}=   GET On Session   apic   /api/mo/uni/infra/settings.json
    Set Suite Variable   $r   ${r.json()}
    Should Be Equal Value Json String   ${r}    $..infraSetPol.attributes.domainValidation   {{ 'yes' if apic.fabric_policies.global_settings.domain_validation | default(defaults.apic.fabric_policies.global_settings.domain_validation) else 'no' }}
    Should Be Equal Value Json String   ${r}    $..infraSetPol.attributes.enforceSubnetCheck   {{ 'yes' if apic.fabric_policies.global_settings.enforce_subnet_check | default(defaults.apic.fabric_policies.global_settings.enforce_subnet_check) else 'no' }}
    Should Be Equal Value Json String   ${r}    $..infraSetPol.attributes.opflexpAuthenticateClients   {{ 'yes' if apic.fabric_policies.global_settings.opflex_authentication | default(defaults.apic.fabric_policies.global_settings.opflex_authentication) else 'no' }}
    Should Be Equal Value Json String   ${r}    $..infraSetPol.attributes.unicastXrEpLearnDisable   {{ 'yes' if apic.fabric_policies.global_settings.disable_remote_endpoint_learn | default(defaults.apic.fabric_policies.global_settings.disable_remote_endpoint_learn) else 'no' }}
    Should Be Equal Value Json String   ${r}    $..infraSetPol.attributes.validateOverlappingVlans   {{ 'yes' if apic.fabric_policies.global_settings.overlapping_vlan_validation | default(defaults.apic.fabric_policies.global_settings.overlapping_vlan_validation) else 'no' }}
    Should Be Equal Value Json String   ${r}    $..infraSetPol.attributes.enableRemoteLeafDirect   {{ 'yes' if apic.fabric_policies.global_settings.remote_leaf_direct | default(defaults.apic.fabric_policies.global_settings.remote_leaf_direct) else 'no' }}
    Should Be Equal Value Json String   ${r}    $..infraSetPol.attributes.reallocateGipo   {{ 'yes' if apic.fabric_policies.global_settings.reallocate_gipo | default(defaults.apic.fabric_policies.global_settings.reallocate_gipo) else 'no' }}
