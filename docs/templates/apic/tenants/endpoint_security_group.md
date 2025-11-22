# Endpoint Security Group

Location in GUI:
`Tenants` » `XXX` » `Application Profiles` » `XXX` » `Endpoint Security Groups`


{{ doc_gen }}

### Examples

Example-1: The configuration below demonstrates how to configure an endpoint security group `PROD_Low_ESG` under the `PROD_AP` application profile in tenant `PROD`. The ESG ledverages ip_subnet_selectors to logically group Endpoints based on their IP subnets (`192.168.153.0/24`). The example would not be complete without highlighting the use of different provide/consume contracts (`PROD_EW_PBR_CT`) for this ESG, enabling precise control of communication.

```yaml
apic:
  tenants:
    - name: PROD
      application_profiles:
        - name: PROD_AP
          endpoint_security_groups: # ESGs
            - name: PROD_Low_ESG
              vrf: PROD
              contracts:
                consumers:
                  - PROD_EW_PBR_CT
                providers:
                  - PROD_EW_PBR_CT
              ip_subnet_selectors:
                - value: 192.168.153.0/24
                  description: IP Subnet Selector for the PROD_Low_BD subnet
```

Simple example:

```yaml
apic:
  tenants:
    - name: ABC
      application_profiles:
        - name: AP1
          endpoint_security_groups:
            - name: ESG1
              vrf: VRF1
              contracts:
                consumers:
                  - CON1
                providers:
                  - CON2
              ip_subnet_selectors:
                - value: 10.1.1.0/24
                  description: IP Subnet Selector 1
```

Full example:

```yaml
apic:
  tenants:
    - name: ABC
      application_profiles:
        - name: AP1
          endpoint_security_groups:
            - name: ESG1
              description: ESG1 description
              vrf: VRF1
              shutdown: true
              intra_esg_isolation: true
              preferred_group: true
              contracts:
                consumers:
                  - CON3
                providers:
                  - CON3
                imported_consumers:
                  - IMPORTED-CON1
                intra_esgs:
                  - CON3
                masters:
                  - application_profile: AP1
                    endpoint_security_group: ESG2
              tag_selectors:
                - key: KEY1
                  operator: contains
                  value: VALUE1
                  description: TAG Selector 1
              epg_selectors:
                - application_profile: AP1
                  endpoint_group: EPG1
                  description: EPG Selector 1
              ip_subnet_selectors:
                - value: 10.1.1.0/24
                  description: IP Subnet Selector 1
```
