# Contract

Location in GUI:
`Application Management` » `Schemas`

{{ doc_gen }}

### Examples

Example-1: Here is an example of two contracts `database_access_contract` and `web_traffic_contract`,  defined under the `OnPrem` Tenant/Schema in `Site_A`.  The default scope is `context` which translates to VRF scope. The default setting for the type of contract is `bothway`, which translates to bi-directional traffic.

The filters `port_3306` and `port_1433` defined within the contracts are located in the `Common` schema under `SiteAB` template in this example, to enable reusability of these filters across both the fabrics and multiple tenants. The log `true` enables logging of the relevant events when the traffic matches the criteria defined by this filter. The filters are further explained in the filter section.

```yaml
ndo:
  schemas:
    - name: OnPrem
      templates:
        - name: Site_A
          contracts:
            - name: database_access_contract
              filters:
                - name: port_3306
                  schema: Common
                  template: Site_AB
                  log: true
                - name: port_1433
                  schema: Common
                  template: Site_AB
                  log: true

```

Example-2: This example illustrates how a service graph is used to specify the redirection of traffic matching a contract through Layer 4 to Layer 7 (L4-L7) service devices, such as firewalls.

The contract `FW_NAT` is defined under the `Azure` Tenant/Schema and uses a filter named `Filter_Any`, which is defined in the `Common` schema under `Site_AB` template.

The service graph `FW` is associated to this contract. It represents the path and sequence of service functions that traffic will traverse once the contract is matched. The Node Identifier `FW_1` represents the L4-L7 service device within the service graph.  These objects are further defined in the service graph section under NDO.

Under the provider section, the details specify the bridge domain `FW_BD` where the provider node (service device) resides. The sites subsection under the provider specifies the deployment location of the service device, including the site name `Site_A`, tenant `Azure`, device name `FW1`, logical interface `Internal`, and the redirect policy `PBR1`. The redirect policy defines how traffic is steered to the service device. These objects are defined on the APIC, which is further explained in the sections L4L7 Device, Service Graph Templates and Redirect Policy.

Similarly, the consumer section reflects the provider’s bridge domain, site, device, logical interface, and redirect policy, representing the traffic flow that is redirected into the same bridge domain where the provider resides. This enables the service graph to use the same physical or logical service node interfaces. This kind of configuration is often used for one-arm deployments, where the same device interface handles both provider and consumer traffic.

```yaml
ndo:
  schemas:
    - name: Azure
      templates:
        - name: Site_A
          contracts:
            - name: FW_NAT
              filters:
                - name: Filter_Any
                  schema: Common
                  template: Site_AB
                  log: true
              service_graph:
                name: FW
                nodes:
                  - name: FW_1
                    provider:
                      bridge_domain: FW_BD
                      sites:
                        - name: Site_A
                          tenant: Azure
                          device: FW1
                          logical_interface: Internal
                          redirect_policy: PBR1
                    consumer:
                      bridge_domain: FW_BD
                      sites:
                        - name: Site_A
                          tenant: Azure
                          device: FW1
                          logical_interface: Internal
                          redirect_policy: PBR1
```
