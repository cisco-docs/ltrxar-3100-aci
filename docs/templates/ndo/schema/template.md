# Template
Templates are used to define and deploy configurations across ACI fabrics. These templates can be of two types: `multi_site` or `autonomous`, each serving different deployment scenarios. The deploy_order attribute, relevant for Terraform, influences the sequence in which templates are deployed, with lower numbers indicating higher priority.

Location in GUI:
`Manage` » `Tenant Templates[Application]` » `Schema`

{{ doc_gen }}

### Examples

Example-1: Single Site Template

This configuration defines a multi-site schema template named `site1_app_template` within the `example_schema`. It is associated with the `tnt` tenant and is deployed to the `fabric_site1` site. The deploy_order attribute is set to `1`, indicating its deployment priority relative to other templates.

```yaml
---
ndo:
  schemas:
    - name: example_schema
      templates:
        - name: site1_app_template
          type: multi_site
          tenant: tnt
          deploy_order: 1
          sites:
            - fabric_site1
```

Example-2: Stretched Site Template

This configuration defines a multi-site schema template named stretched_app_template under the `example_schema`. It belongs to the `tnt` tenant and is designed to span across multiple sites: `fabric_site1` and `fabric_site2`. The deploy_order is set to `2`, indicating a lower deployment priority compared to templates with a deploy_order of 1.

```yaml
---
ndo:
  schemas:
    - name: example_schema
      templates:
        - name: stretched_app_template
          type: multi_site
          tenant: tnt
          deploy_order: 2
          sites:
            - fabric_site1
            - fabric_site2
```

Example-3: Automonous Site Template

This configuration defines an autonomous schema template named `site3_app_template` within the `example_schema`. It is associated with the `tnt` tenant and is deployed to the `fabric_site3` site. This template is type `autonomous`, meaning it allows for provisioning objects (like EPGs, BDs, VRFs) to a site that is part of an independently operated ACI fabric i.e without intersite infra.

```yaml
---
ndo:
  schemas:
    - name: example_schema
      templates:
        - name: site3_app_template
          type: autonomous
          tenant: tnt
          sites:
            - fabric_site3
```
