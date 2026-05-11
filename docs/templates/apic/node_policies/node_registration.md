# Node Registration

Location in GUI:
`Fabric` » `Inventory` » `Fabric Membership`


{{ doc_gen }}

### Examples

Example-1: In the example below we create a node registration for a leaf and a spine switch. The spine switch uses the `set_role` option to define that it is a spine if hardware is a dual-role.

```yaml
apic:
  node_policies:
    nodes:
      - id: 101
        pod: 1
        role: leaf
        serial_number: ABC1234567
        name: LEAF101
      - id: 1001
        pod: 1
        role: spine
        set_role: true  # For dual-role switches
        serial_number: ABC1234569
        name: SPINE1001
```

Example-2: In the example below we create a node registration for a remote leaf switch.

```yaml
apic:
    nodes:

      - id: 3101
        pod: 1
        role: leaf
        type: remote-leaf-wan
        serial_number: ABC1234568
        name: RLEAF3101
```

Example-3: In the example below we create a node registration for a leaf that is supposed to work as a border gateway switch.
```yaml
apic:
    nodes:
      - id: 401
        pod: 1
        role: leaf
        type: border-gateway
        serial_number: TEP-1-401
        name: leaf-401
```
