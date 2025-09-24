# Schema

A schema is a logical "container" of policies that provides a logical grouping for various application templates that define the network configurations for a specific application to be deployed to one or more sites. Association of policies for a tenant are always done at the application template level and not at the schema level.

Location in GUI:
`Manage` » `Tenant Templates[Application]`

{{ doc_gen }}

### Examples

Example-1: Schema

This configuration defines a schema named `site1-schema`. This example provides the top-level structure for defining a schema that will contain one or more application templates.

```yaml
---
ndo:
  schemas:
    - name: site1-schema
```
