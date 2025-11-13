*** Settings ***
Documentation   Verify QOS Class
Suite Setup     Login APIC
Default Tags    apic   day0   config   access_policies
Resource        ../../apic_common.resource

*** Test Cases ***
Verify QoS COS presevation status
    ${r}=   GET On Session   apic   /api/mo/uni/infra/qosinst-default.json   params=rsp-subtree=full
    Set Suite Variable   $r   ${r.json()}
    Should Be Equal JMESPath Json   ${r}    imdata[0].qosInstPol.attributes.ctrl   {{ 'dot1p-preserve' if apic.access_policies.qos.preserve_cos | default(defaults.apic.access_policies.qos.preserve_cos) }}

{% for level in range(1, 7) %}
{% set query = "qos_classes[?level==`" ~ level ~ "`]" %}
{% set default_qos_class = (defaults.apic.access_policies.qos | community.general.json_query(query))[0] %}
{% if apic.access_policies.qos is defined %}
{% set qos_class = ((apic.access_policies.qos | community.general.json_query(query)) | default([]))[0] %}
{% endif %}

Verify QoS Class Level {{ level }}
    ${level}=  Set Variable   imdata[0].qosInstPol.children[?qosClass.attributes.prio=='level{{ level }}'] | [0].qosClass
    Should Be Equal JMESPath Json   ${r}    ${level}.attributes.admin   {{ 'enabled' if qos_class.admin_state | default(default_qos_class.admin_state) else 'disabled' }}
    Should Be Equal JMESPath Json   ${r}    ${level}.attributes.mtu   {{ qos_class.mtu | default(default_qos_class.mtu) }}
    Should Be Equal JMESPath Json   ${r}    ${level}.children[?qosSched] | [0].qosSched.attributes.meth   {{ 'wrr' if qos_class.scheduling | default(default_qos_class.scheduling) == "wrr" else ('sp' if qos_class.scheduling | default(default_qos_class.scheduling) == "strict-priority" else '') }}
    Should Be Equal JMESPath Json   ${r}    ${level}.children[?qosSched] | [0].qosSched.attributes.bw   {{ qos_class.bandwidth_percent | default(default_qos_class.bandwidth_percent) }}
    Should Be Equal JMESPath Json   ${r}    ${level}.children[?qosBuffer] | [0].qosBuffer.attributes.min   {{ qos_class.minimum_buffer | default(default_qos_class.minimum_buffer) }}
    Should Be Equal JMESPath Json   ${r}    ${level}.children[?qosPfcPol] | [0].qosPfcPol.attributes.adminSt   {{ 'yes' if qos_class.pfc_state | default(default_qos_class.pfc_state) else 'no' }}
    Should Be Equal JMESPath Json   ${r}    ${level}.children[?qosPfcPol] | [0].qosPfcPol.attributes.noDropCos   {{ qos_class.no_drop_cos | default(default_qos_class.no_drop_cos) }}
    Should Be Equal JMESPath Json   ${r}    ${level}.children[?qosCong] | [0].qosCong.attributes.algo   {{ qos_class.congestion_algorithm | default(default_qos_class.congestion_algorithm) }}
    Should Be Equal JMESPath Json   ${r}    ${level}.children[?qosCong] | [0].qosCong.attributes.ecn   {{ 'enabled' if qos_class.ecn | default(default_qos_class.ecn) else 'disabled' }}
    Should Be Equal JMESPath Json   ${r}    ${level}.children[?qosCong] | [0].qosCong.attributes.forwardNonEcn   {{ 'enabled' if qos_class.forward_non_ecn | default(default_qos_class.forward_non_ecn) else 'disabled' }}
    Should Be Equal JMESPath Json   ${r}    ${level}.children[?qosCong] | [0].qosCong.attributes.wredMaxThreshold   {{ qos_class.wred_max_threshold | default(default_qos_class.wred_max_threshold) }}
    Should Be Equal JMESPath Json   ${r}    ${level}.children[?qosCong] | [0].qosCong.attributes.wredMinThreshold   {{ qos_class.wred_min_threshold | default(default_qos_class.wred_min_threshold) }}
    Should Be Equal JMESPath Json   ${r}    ${level}.children[?qosCong] | [0].qosCong.attributes.wredProbability   {{ qos_class.wred_probability | default(default_qos_class.wred_probability) }}
    Should Be Equal JMESPath Json   ${r}    ${level}.children[?qosCong] | [0].qosCong.attributes.wredWeight   {{ qos_class.weight | default(default_qos_class.weight) }}
{% endfor %}
