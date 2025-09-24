# Maintenance Groups

Location in GUI:
`Admin` » `Firmware` » `Nodes`


{{ doc_gen }}

### Examples

Example 1: The YAML snippet below demonstrates the use of the `target_version` field within an update group which would allow users to specify exactly which software version a group of devices should upgrade to. This is important for performing phased updates, testing new software on a small set of devices first, and ensuring specific groups run compatible software versions. The `target_version` field is a `string`.

```yaml
apic:
  node_policies:
    update_groups:
      - name: UPG_POD1_SP_1
        scheduler: scheduler1
        target_version: n9000-16.0(1j)
    nodes:
      - id: 101
        update_group: UPG_POD1_SP_1
```
