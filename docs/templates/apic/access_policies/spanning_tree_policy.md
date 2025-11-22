# Spanning Tree Interface Policy

Location in GUI:
`Fabric` » `Access Policies` » `Policies` » `Interface` » `Spanning Tree Interface`


{{ doc_gen }}

### Examples

Example-1: this STP policy named `BPDU_FILTER` is configured to enable the BPDU filter feature, given that the bdpu_filter attribute is set to `true`. BPDU Filter will silently drop any BPDUs received from the associated interfaces without any further actions. While it is not disruptive, it essentially equates to disabling STP on the interface and should be used with care to ensure no loops occur.

```yaml
apic:
  access_policies:
    interface_policies:
      spanning_tree_policies:
        - name: BPDU-FILTER
          bpdu_filter: true
```
Example-2: this STP policy named `BPDU_GUARD` is configured to enable the BPDU guard feature, given that the bpdu_guard attribute is set to `true`. BPDU Guard will error-disable any interfaces from which BPDUs are received for a set time. While it may introduce downtime for the duraiton of the error-disablement, it can ensure the overall stability of the network by guaranteeing that no rogue BPDUs or switches affect the stability of the STP topology.

```yaml
apic:
  access_policies:
    interface_policies:
      spanning_tree_policies:
        - name: BPDU-FILTER
          bpdu_guard: true
```
