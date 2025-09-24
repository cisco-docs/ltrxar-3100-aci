# Bridge Domain

Location in GUI:
`Application Management` » `Schemas`

{{ doc_gen }}

### Examples

Example-1: This illustrates a configuration example for a Layer 2 bridge domain named `Layer2_BD` under `Azure` Schema/Tenant and `Site_A` fabric . The unicast_routing flag is set to `false`, indicating that subnets within this bridge domain are not propagated to the leaf switches, and no routing occurs within the fabric. The l2_unknown_unicast flag is configured to `flood`, ensuring that unknown unicast traffic is flooded within the bridge domain. The bridge domain is not stretched, as shown by the l2_stretch flag being set to `false`. 

The subnet configuration allows the fabric to manage IP addresses and ARP within the Layer 2 domain without providing routing or default gateway services. 

The VRF `Prod` in this example is defined in a stretched template `Site_AB` which is further detailed under the vrf section. 

```yaml
ndo:
  schemas:
    - name: Azure
      templates:
        - name: Site_A
          bridge_domains:
            - name: Layer2_BD
              l2_unknown_unicast: flood
              l2_stretch: false
              unicast_routing: false
              arp_flooding: true
              vrf:
                name: PROD
                schema: Azure
                template: Site_AB
              sites:
                - name: Site_A
                  subnets:
                    - ip: 1.1.1.1/24
                      scope: public
```

Example-2: This example illustrates a configuration for a Layer 3 bridge domain named `Layer3_BD` under `Azure` Schema/Tenant and `Site_A` fabric. The default setting for unicast routing is `true`, so it does not need to be explicitly specified in the YAML. The l2_unknown_unicast flag is set to `proxy` in this example, which is used to optimize traffic by sending unknown unicast frames to the spine for a proxy lookup in the COOP database. The bridge domain is not stretched, as indicated by the l2_stretch flag set to `false`.

The EP detection mode is configured as `garp`, enabling the fabric to detect an endpoint IP move from one MAC address to another when the new MAC is on the same interface and within the same EPG. This mode is often used with VMware ESXi hosts connected to ACI.

The VRF `Prod` in this example is defined in a stretched template named `Site_AB`, which is further detailed under the vrf section. To advertise routes externally, an L3Out named `Prod_L3out` is attached to the bridge domain. Details of the L3Out configuration can be found under the l3out section

```yaml
ndo:
  schemas:
    - name: Azure
      templates:
        - name: Site_A
          bridge_domains:
            - name: Layer3_BD
              l2_unknown_unicast: proxy
              l2_stretch: false
              arp_flooding: true
              ep_move_detection_mode: garp
              vrf:
                name: PROD
                schema: Azure
                template: Site_AB
              sites:
                - name: Site_A
                  subnets:
                    - ip: 2.2.2.2/24
                      scope: public
                  l3outs:
                    - Prod_L3OUT
```
