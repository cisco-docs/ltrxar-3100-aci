# Device Selection Policy

Location in GUI:
`Tenants` » `XXX` » `Services` » `L4-L7` » `Device Selection Policies`


{{ doc_gen }}

### Examples

Example-1: This example demonstrates a one-armed Policy-Based Redirect (PBR) Service Graph that redirects all traffic originating from EPG-1 (the `PBR_SF_CT` contract consumer) to a PBR destination (e.g., a Firewall Cluster connected via the `PBR_SG_L3OUT` L3Out) for inspection before forwarding it to the final destination (e.g., vzAny, the `PBR_SF_CT` contract provider). It is one-armed because it is using the same consumer and provider logical interface (`Cluster_IF`) on the Firewall Cluster.

The data model can be applied as is; however, if referenced elements such as EPGs, L3Out, etc., are not configured, the deployment will not function correctly. This example relies on elements from the following modules:

- apic.tenants.contracts
- apic.tenants.services.service_graph_templates
- apic.tenants.services.l4l7_devices
- apic.tenants.services.redirect_policies

``` yaml
---
apic:
  tenants:
    - name: PBR_ServGraph
        device_selection_policies:
          - contract: PBR_SF_CT
            service_graph_template: PBR_SG_template
            node_name: FW_Cluster
            device_name: FW_Cluster
            consumer:
              redirect_policy:
                name: L4L7_PBR
              logical_interface: Cluster_IF
              external_endpoint_group:
                l3out: PBR_SG_L3OUT
                name: PBR_SG_eEPG
                redistribute:
                  bgp: true
                  ospf: true
            provider:
              redirect_policy:
                name: 'L4L7_PBR'
              logical_interface: Cluster_IF
              external_endpoint_group:
                l3out: PBR_SG_L3OUT
                name: 'PBR_SG_eEPG'
                redistribute:
                  bgp: true
                  ospf: true
```

Example-2: The configuration below links the contract named `PROD_EW_PBR_CT` and service_graph_template named `PROD_EW_FW_SG` to a network device. It details how traffic, both consumer and provider, is redirected via Policy-Based Redirect (PBR) using the `PROD_EW_FW_PBRPol` and `OneArm` logical interface within the `SVC_BD` bridge domain.

```yaml
apic:
  tenants:
    - name: PROD
      services:
        device_selection_policies:
        - contract: PROD_EW_PBR_CT
          service_graph_template: PROD_EW_FW_SG
          node_name: N1
          device_name: PROD_EW_FW
          consumer:
            redirect_policy:
              name: PROD_EW_FW_PBRPol
            logical_interface: OneArm
            bridge_domain:
              name: SVC_BD
          provider:
            redirect_policy:
              name: PROD_EW_FW_PBRPol
            logical_interface: OneArm
            bridge_domain:
              name: SVC_BD


Simple example:

```yaml
apic:
  tenants:
    - name: ABC
      services:
        device_selection_policies:
          - contract: CON1
            service_graph_template: TEMPLATE1
            consumer:
              redirect_policy:
                name: PBR1
              logical_interface: INT1
              bridge_domain:
                name: BD1
            provider:
              redirect_policy:
                name: PBR1
              logical_interface: INT1
              bridge_domain:
                name: BD1
```

Copy service:

```yaml
apic:
  tenants:
    - name: ABC
      services:
        device_selection_policies:
          - contract: CON2
            service_graph_template: TEMPLATE2
            copy_service:
              logical_interface: INT1
```

Full example:

```yaml
apic:
  tenants:
    - name: ABC
      services:
        device_selection_policies:
          - contract: CON1
            service_graph_template: TEMPLATE1
            consumer:
              l3_destination: true
              permit_logging: false
              redirect_policy:
                name: PBR1
              logical_interface: INT1
              bridge_domain:
                name: BD1
              service_epg_policy: SERVICE_EPG1
              custom_qos_policy: QOS_POLICY
            provider:
              redirect_policy:
                name: PBR1
              logical_interface: INT1
              bridge_domain:
                name: BD1
              service_epg_policy: SERVICE_EPG2
              custom_qos_policy: QOS_POLICY
```
