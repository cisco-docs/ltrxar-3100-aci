# Access Spine Interface Policy Group

Location in GUI:
`Fabric` » `Access Policies` » `Interfaces` » `Spine Interfaces` » `Policy Groups`


{{ doc_gen }}

### Examples

Example-1: This configuration defines a spine interface policy group named `IPN1`, it sets the interface speed to `10G`, enables CDP, and associates the group with the AAEP profile `AAEP1` for consistent policy application on spine switch interfaces.

```yaml
apic:
  access_policies:
    spine_interface_policy_groups:
      - name: IPN1
        link_level_policy: 10G
        cdp_policy: CDP-ENABLED
        aaep: AAEP1
```


Example-2: This configuration defines two Access Spine Interface Policy Groups. This group allows you to associate interface-level policies such as link level, CDP, LLDP, and attachable access entity profiles AAEP to spine interfaces.

The first group, named `IPN1`, assigns the following policies to spine interfaces:

- link_level_policy: `10G`: Sets the interface speed to 10 Gigabit.
- cdp_policy: `CDP-ENABLED`: Enables Cisco Discovery Protocol on the interface.
- aaep: `AAEP1`: Associates the interface with the Attachable Access Entity Profile named AAEP1.
- lldp_policy: `LLDP-ENABLED`: Enables Link Layer Discovery Protocol.
- description: Provides a human-readable description for the group.

The second group, `SPINE-INT-GRP-01`, is similar but uses a `25G` link level policy, disables CDP, and uses a different AAEP.

These groups standardize interface settings for spine switches, making it easier to apply consistent policies across multiple interfaces.

```yaml
apic:
  access_policies:
    spine_interface_policy_groups:
    - name: IPN1
      link_level_policy: "10G"
      cdp_policy: "CDP-ENABLED"
      aaep: "AAEP1"
      lldp_policy: "LLDP-ENABLED"
      description: "Spine interface group for IPN connectivity"

    - name: SPINE-INT-GRP-01
      link_level_policy: "25G"
      cdp_policy: "CDP-DISABLED"
      aaep: "AAEP-SPINE"
      lldp_policy: "LLDP-ENABLED"
      description: "Standard 25G spine interface group"
```
