*** Settings ***
Documentation   Verify Spine Switch Policy Group
Suite Setup     Login APIC
Default Tags    apic   day1   config   access_policies
Resource        ../../apic_common.resource

*** Test Cases ***
{% for pg in apic.access_policies.spine_switch_policy_groups | default([]) %}
{% set policy_group_name = pg.name ~ defaults.apic.access_policies.spine_switch_policy_groups.name_suffix %}

Verify Spine Switch Policy Group {{ policy_group_name }}
    ${r}=   GET On Session   apic   /api/mo/uni/infra/funcprof/spaccnodepgrp-{{ policy_group_name }}.json   params=rsp-subtree=full
    Set Suite Variable   $r   ${r.json()}
    Should Be Equal JMESPath Json   ${r}    imdata[0].infraSpineAccNodePGrp.attributes.name   {{ policy_group_name }}
{% if pg.lldp_policy is defined %}
{% set lldp_policy_name = pg.lldp_policy ~ defaults.apic.access_policies.interface_policies.lldp_policies.name_suffix %}
    Should Be Equal JMESPath Json   ${r}    imdata[0].infraSpineAccNodePGrp.children[?infraRsSpinePGrpToLldpIfPol] | [0].infraRsSpinePGrpToLldpIfPol.attributes.tnLldpIfPolName   {{ lldp_policy_name }}
{% endif %}
{% if pg.cdp_policy is defined %}
{% set cdp_policy_name = pg.cdp_policy ~ defaults.apic.access_policies.interface_policies.cdp_policies.name_suffix %}
    Should Be Equal JMESPath Json   ${r}    imdata[0].infraSpineAccNodePGrp.children[?infraRsSpinePGrpToCdpIfPol] | [0].infraRsSpinePGrpToCdpIfPol.attributes.tnCdpIfPolName   {{ cdp_policy_name }}
{% endif %}
{% if pg.bfd_ipv4_policy is defined %}
{% set bfd_ipv4_policy = pg.bfd_ipv4_policy ~ defaults.apic.access_policies.switch_policies.bfd_ipv4_policies.name_suffix %}
    Should Be Equal JMESPath Json   ${r}    imdata[0].infraSpineAccNodePGrp.children[?infraRsSpineBfdIpv4InstPol] | [0].infraRsSpineBfdIpv4InstPol.attributes.tnBfdIpv4InstPolName   {{ bfd_ipv4_policy }}
{% endif %}
{% if pg.bfd_ipv6_policy is defined %}
{% set bfd_ipv6_policy = pg.bfd_ipv6_policy ~ defaults.apic.access_policies.switch_policies.bfd_ipv6_policies.name_suffix %}
    Should Be Equal JMESPath Json   ${r}    imdata[0].infraSpineAccNodePGrp.children[?infraRsSpineBfdIpv6InstPol] | [0].infraRsSpineBfdIpv6InstPol.attributes.tnBfdIpv6InstPolName   {{ bfd_ipv6_policy }}
{% endif %}

{% endfor %}
