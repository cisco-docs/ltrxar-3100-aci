*** Settings ***
Documentation   Verify Config Export Operational State
Suite Setup     Login APIC
Default Tags    apic   day0   operational   fabric_policies   non-critical
Resource        ../../apic_common.resource

*** Test Cases ***
{% for policy in apic.fabric_policies.config_exports | default([]) %}
{% set policy_name = policy.name ~ defaults.apic.fabric_policies.config_exports.name_suffix %}

Verify Config Export {{ policy_name }} Job Status
    ${r}=   GET On Session   apic   /api/mo/uni/backupst/jobs-[uni/fabric/configexp-{{ policy_name }}].json   params=rsp-subtree=full
    Set Suite Variable   $r   ${r.json()}
    ${jobs}=   Get Value From Json   ${r}   $..configJobCont.children
    IF   @{jobs}
        FOR   ${job}   IN   @{jobs[0]}
            ${state}=   Get Value From Json   ${job}   $..configJob.attributes.operSt
            ${job_name}=   Get Value From Json   ${job}   $..configJob.attributes.name
            Run Keyword If   "${state}[0]" != "success"   Run Keyword And Continue On Failure
            ...   Fail  "Export Policy {{ policy_name }}: Job ${job_name} not successful"
        END
    END

{% endfor %}
