# Set Rule

Location in GUI:
`Tenants` » `XXX` » `Policies` » `Protocol` » `Set Rules`


{{ doc_gen }}

### Examples

Example 1: The YAML snippet below demonstrates the `set_as_paths` functionality, designed to append multiple Autonomous Systems (ASs) to the `AS_PATH` of a BGP prefix. This is a key feature for BGP AS Path manipulation. The `set_as_paths` alongside the `asns` are defined as `list`.

```yaml
apic:
  tenants:
    - name: TN_01
      policies:
        set_rules:
          - name: SET_STG_STG_L_65002:10002
            community: regular:as2-nn2:65002:10002
            set_as_paths:
              - criteria: prepend
                asns:
                  - number: 65098
                    order: 1
                  - number: 65098
                    order: 2
                  - number: 65098
                    order: 3
              - criteria: prepend-last-as
                count: 8
```

Example 2: The YAML snippet below demonstrates the `set_as_path` functionality designed to address dynamic EPG classification. The `external_endpoint_group` is used to specify the external EPG to which the traffic would be classified.

```yaml
apic:
  tenants:
    - name: TN_01
      policies:
        set_rules:
          - name: set-extEPG
            external_endpoint_group:
              name: default_extepg
              l3out: default
              tenant: common
```