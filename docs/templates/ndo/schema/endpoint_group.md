# Endpoint Group

Location in GUI:
`Application Management` » `Schemas`

{{ doc_gen }}

### Examples

Example-1: Here is an example of an Endpoint Group(EPG) named `Database_VMM` under the `OnPrem` Tenant/Schema and the `PROD_VMM` application profile. Two contracts, `database_access_contract` and `web_traffic_contract` are provided and consumed to facilitate communication with other EPGs. The contracts are defined in the `Site_A` template. Further details on the contracts are explained in the contract section.

The subnets are defined with the scope set to `private`, and the no_default_gateway flag is set to `true`, indicating that the gateway is managed either at the Bridge Domain level or externally.

This EPG is used to host endpoints from the VMM domain with `dynamic` VLAN allocation and `immediate` deployment policy.

```yaml
ndo:
  schemas:
    - name: OnPrem
      templates:
        - name: Site_A
          application_profiles:
            - name: PROD_VMM
              endpoint_groups:
                - name: Database_VMM
                  preferred_group: false
                  bridge_domain:
                    name: Database_BD
                    schema: OnPrem
                    template: Site_A
                  contracts:
                    providers:
                      - name: database_access_contract
                        template: TEMPLATE1
                    consumers:
                      - name: web_traffic_contract
                        template: TEMPLATE1
                  subnets:
                    - ip: 2.2.2.2/24
                      scope: private
                      no_default_gateway: true
                  sites:
                    - name: Site_A
                      vmware_vmm_domains:
                        - name: ANS-VMM1
                          deployment_immediacy: immediate
                          resolution_immediacy: immediate
                          vlan_mode: dynamic
```

Example-2: The example below demonstrates configuring a EndPoint Group(EPG) named `Web` under the application profile `Prod` and schema `Azure`.  Two contracts, `web_traffic_contract` and `database_access_contract` are provided and consumed to facilitate communication with other EPGs. The contracts are defined in the `Site_A` template.

The phyical domain `Prod_PHY` is attached to the EPG to enable VLAN encapsulation `1001` to be pushed to the leaf switches and the physical endpoints attached to ACI.

The static bindings are defined under the EPG as shown below. In this example, there are two bindings: one with a VPC using Leafs `101` and `102` of Pod-1 with an Interface Polixy Group(IPG) named `VPC_IPG` defined under the channel and an encapsulation VLAN of `1001`; and the other as as an individual port `1` on leaf `103` with deployment immediacy set to `immediate`, indicating the policy is programmed into hardware as soon as it is downloaded to the leaf switches rather than waiting for the first packet to hit this policy.

```yaml
ndo:
  schemas:
    - name: Azure
      templates:
        - name: Site_A
          application_profiles:
            - name: Prod
              endpoint_groups:
                - name: Web
                  bridge_domain:
                    name: Web_BD
                  contracts:
                    providers:
                      - name: web_traffic_contract
                        template: Site_A
                    consumers:
                      - name: database_access_contract
                        template: Site_A
                  sites:
                    - name: Site_A
                      physical_domains:
                        - name: Prod_PHY
                          deployment_immediacy: immediate
                          resolution_immediacy: immediate
                      static_ports:
                        - vlan: 1001
                          pod: 1
                          type: vpc
                          node_1: 101
                          node_2: 102
                          channel: VPC_IPG
                        - vlan: 1001
                          pod: 1
                          node: 103
                          port: 1
                          deployment_immediacy: immediate
```
