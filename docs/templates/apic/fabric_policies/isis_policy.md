# Fabric ISIS Redistribute Metric

Location in GUI:
`System` » `System Settings` » `ISIS Policy`


{{ doc_gen }}

### Examples

Example-1: This data model sets the ISIS Redistribute Metric to `59`, which determines the metric value assigned to ISIS routes redistributed by spine nodes from other routing protocols (such as OSPF) into ISIS within the fabric. This metric influences route preference for redistributed ISIS routes in Multi-Pod, Multi-Site, and Remote Leaf deployments. Best practice recommends setting this value to 62 or lower because when a spine node reboots or joins the fabric, it enters an "overload mode" during which it advertises redistributed routes with a higher metric to avoid being preferred until it stabilizes.

Modifying the ISIS Redistribution Metric is a non-disruptive operation.

```yaml
apic:
  fabric_policies:
    fabric_isis_redistribute_metric: 59
```
