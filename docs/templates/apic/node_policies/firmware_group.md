# Firmware Groups

Location in GUI:
`Admin` » `Firmware` » `Nodes`


{{ doc_gen }}

### Examples

Example-1: this example demonstrates a basic update group `MG1`, where node `101` is associated to the relevant group. 

```yaml
apic:
  node_policies:
    update_groups:
      - name: MG1
    nodes:
      - id: 101
        update_group: MG1
```

Example-2: this example demonstrates a typical ACI deployment setup, with the `ODD_NODES` group for odd nodes, and the `EVEN_NODES` group for even nodes. Assuming all devices connected to ACI are dual-homed for redundancy, this enables the ACI fabric to upgrade with minimal to no service interruption. The upgrade groups also define the target_version attribute to specify the firwmare image of `n6-0.9(e)`, meaning APIC release 6.0(9e). 

```yaml
apic:
  node_policies:
    update_groups:
      - name: ODD_NODES
        target_version: n6-0.9(e)
      - name: EVEN_NODES
        target_version: n6-0.9(e)
    nodes:
      - id: 201
        role: leaf
        update_group: ODD_NODES
      - id: 202
        role: leaf
        update_group: EVEN_NODES
```
