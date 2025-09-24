# Access FEX Interface Profile

FEX Interface Profiles can either be auto-generated (one per FEX) by providing a naming convention, or can be system-generated (one per FEX), or can be defined explicitly. In case of auto-generated profiles the following placeholders can be used when defining the naming convention:

* `\\g<id>`: gets replaced by the respective leaf node ID
* `\\g<name>`: gets replaced by the respective leaf hostname
* `\\g<fex>`: gets replaced by the respective FEX ID

Location in GUI:
`Fabric` » `Access Policies` » `Interfaces` » `Leaf Interfaces` » `Profiles`


{{ doc_gen }}

### Examples

Auto-generated profiles:

```yaml
apic:
  auto_generate_access_leaf_switch_interface_profiles: true
  access_policies:
    fex_profile_name: "LEAF\\g<id>-FEX\\g<fex>"
  interface_policies:
    nodes:
      - id: 101
        fexes:
          - id: 101
```

System-generated profiles:

```yaml
apic:
  new_interface_configuration: true
  interface_policies:
    nodes:
      - id: 101
        fexes:
          - id: 101
```

Example-1: This configuration explicitly creates a FEX interface profile named `LEAF101-FEX101`, with a selector `SEL1` that applies the `10G-SERVER` policy group to a port block `BLOCK1` starting at port `1`.

```yaml
apic:
  access_policies:
    fex_interface_profiles:
      - name: LEAF101-FEX101
        selectors:
          - name: SEL1
            policy_group: 10G-SERVER
            port_blocks:
              - name: BLOCK1
                description: Server ABC
                from_port: 1
```
Example-2: This is another example for a FEX Interface Profile, along with a clear description of each value. 
- fex_interface_profiles: List of FEX interface profiles to define explicitly.
- selectors: List of selectors for this profile.
- policy_group: The policy group to associate with this selector (e.g., `20G-APP-SERVERS`).
- port_blocks: List of port blocks under this selector.
- from_port and to_port: Starting port number in the block (e.g., `1`) and ending port number in the block (e.g., `8`).

```yaml
apic:
  access_policies:
    fex_interface_profiles:
      - name: LEAF102-FEX201
        selectors:
          - name: FEX201-SEL
            policy_group: 20G-APP-SERVERS
            port_blocks:
              - name: APP-BLOCK
                description: Application Servers Block
                from_port: 1
                to_port: 8
```
