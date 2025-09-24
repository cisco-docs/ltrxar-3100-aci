# Application Profile

Location in GUI:
`Application Management` » `Schemas`

{{ doc_gen }}

### Examples

Example-1: The example below shows how an application profile named `Prod` is created under the schema/tenant `Azure` and the template Site_A. Note: The endpoint groups that belong to the application profile are explained in the endpoint group section.

```yaml
ndo:
  schemas:
    - name: Azure
      templates:
        - name: Site_A
          tenant: Azure
          application_profiles:
            - name: Prod
```

Example-2: Extending the previous example, a similar structure is followed to create and define application profiles across multiple templates and sites within the `Azure` schema. In this example, two application profiles, `Prod` and `Dev`, are deployed in two templates, `Site_A` and `Site_B`, respectively. Additionally, an application profile named `Shared` is defined in the stretched template `Site_AB`, which is used to define objects that need to be stretched across both sites.

```yaml
ndo:
  schemas:
    - name: Azure
      templates:
        - name: Site_A
          tenant: Azure
          application_profiles:
            - name: Prod
        - name: Site_B
          tenant: Azure
          application_profiles:
            - name: Dev
        - name: Site_AB
          tenant: Azure
          application_profiles:
            - name: Shared
```
