# VRF

Location in GUI:
`Application Management` » `Schemas`

{{ doc_gen }}

### Examples

Example 1: The YAML snippet below demonstrates how to enable "Site-aware Policy Enforcement Mode" in NDO for a stretched VRF, which is essential to support PBR vzAny Multi-Site deployments. This is enabled by setting the `site_aware_policy_enforcement_mode: true` flag, ensuring that policies within the stretched VRF are enforced with awareness of the site, allowing for proper PBR and vzAny functionality across multiple locations.

```yaml
ndo:
  schemas:
    - name: SCH_TN_10_NONP
      templates:
        - name: TMP_STRETCHED
          tenant: TN_STAGING
          vrfs:
            - name: VRF_STAGING
              vzany: true
              site_aware_policy_enforcement: true
```

On-premise VRF:

```yaml
ndo:
  schemas:
    - name: ABC
      templates:
        - name: TEMPLATE1
          vrfs:
            - name: VRF1
              data_plane_learning: true
              preferred_group: false
              l3_multicast: true
              vzany: true
              site_aware_policy_enforcement: true
              contracts:
                consumers:
                  - name: CONTRACT2
```

Azure VRF:

```yaml
ndo:
  schemas:
    - name: AZURE1
      templates:
        - name: TEMPLATE1
          vrfs:
            - name: VRF1
              sites:
                - name: AZURE-SITE1
                  regions:
                    - name: eastus
                      hub_network: true
                      hub_network_name: default
                      hub_network_tenant: infra
                      cidrs:
                        - ip: 172.31.0.0/24
```
