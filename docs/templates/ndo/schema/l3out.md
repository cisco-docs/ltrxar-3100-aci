# L3out

An L3out (Layer 3 Outside) in Netascode represents a routed connection from the ACI fabric to an external Layer 3 network. It is defined within an application template and specifies how the ACI fabric connects to external routers or networks, often including details about routing protocols, external EPGs, and associated VRFs.

Location in GUI:
`Manage` » `Tenant Templates[Application]` » `Schema (within a template's configuration)`

{{ doc_gen }}

### Examples

Example-1: Site Local L3out

This configuration defines an L3out named `site1_l3out` within the `site1_app_template`, which is part of `example_schema`. This L3out is associated with a VRF named `site1_vrf` that is also defined locally within the same `example_schema` and `site1_app_template`. This setup represents a typical single-site external routing connection where both the L3out and its associated VRF are confined to a specific application template and schema.

```yaml
ndo:
  schemas:
    - name: example_schema
      templates:
        - name: site1_app_template
          l3outs:
            - name: site1_l3out
              vrf:
                name: site1_vrf
                schema: example_schema
                template: site1_app_template
```

Example-2: Strectched L3out

This configuration defines an L3out named `stretched_l3out` within the `stretched_app_template`, which is part of `example_schema`. This L3out is associated with a VRF named `stretched_vrf`, also defined within the same `example_schema` and `stretched_app_template`. This setup indicates an L3out that is designed to be stretched across multiple sites, typically used in a multi-site domain where the application template and its components, including the L3out and VRF, span across different ACI fabrics.

```yaml
ndo:
  schemas:
    - name: example_schema
      templates:
        - name: stretched_app_template
          l3outs:
            - name: stretched_l3out
              vrf:
                name: stretched_vrf
                schema: example_schema
                template: stretched_app_template
```

Example-3: Site Local L3out with Strectched VRF Association

This configuration defines an L3out named `site1_l3out` within the `site1_app_template`, which is part of `example_schema`. However, this L3out is associated with a VRF named `stretched_vrf` which is defined in a different context: the `example_schema` and `stretched_app_template`. This demonstrates the flexibility of Netascode, allowing a local L3out to connect to a VRF that is part of a stretched configuration, enabling cross-schema and cross-template associations for external connectivity.

```yaml
ndo:
  schemas:
    - name: example_schema
      templates:
        - name: site1_app_template
          l3outs:
            - name: site1_l3out
              vrf:
                name: stretched_vrf
                schema: example_schema
                template: stretched_app_template
```

Example-4: Site Local L3out with Strectched VRF Association from differnet Schema

While all of the previous examples are all using the same schema this example using a different schema where the VRF is defined. This configuration defines an L3out named `site1_l3out` within the `site1_app_template`, which belongs to the `example_schema`. A key aspect of this configuration is that the L3out references a VRF named `stretched1_vrf` that is explicitly defined within a completely different schema, `example1_schema`, and its `stretched1_app_template`. 

```yaml
ndo:
  schemas:
    - name: example_schema
      templates:
        - name: site1_app_template
          l3outs:
            - name: site1_l3out
              vrf:
                name: stretched1_vrf
                schema: example1_schema
                template: stretched1_app_template
```
