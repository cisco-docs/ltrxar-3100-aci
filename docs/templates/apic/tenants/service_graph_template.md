# Service Graph Template

Location in GUI:
`Tenants` » `XXX` » `Services` » `L4-L7` » `Service Graph Templates`


{{ doc_gen }}

### Examples

A new approach has been introduced to support multi-node Service Graph (SG) definitions. Please consider the following important points:
	-	All devices or nodes referenced in the examples must be defined within the Data Models using the `apic.tenants.services.l4l7_devices` module.
	-	The two approaches (old and new) are mutually exclusive and cannot be used together within the same SG template.
	-	Every device defined under `apic.tenants.services.service_graph_templates.devices` must also be listed in `apic.tenants.services.service_graph_templates.connections`.
	-	The `node_name` attribute for each element in `apic.tenants.services.service_graph_templates.devices` must be unique. If `node_name` is not explicitly defined, the `name` value will be used instead.
	-	It is mandatory to define the nodes `EPG-Consumer` as `consumer_node` and `EPG-Provider` as `provider_node` (each defined only once). These nodes specify the direction of traffic flow, ensuring proper configuration and traffic direction within the service graph template.
	-	The default value for the `Connection > Adjacency type` attribute has been aligned to `L2` in the new approach, whereas the old approach used `L3`.

New approach minimal example:

```
  EPG    ────────── FW ──────────   EPG
Consumer                          Provider
```

This example demonstrates the creation of a Service Graph Template that includes only the essential attributes.

```yaml
apic:
  tenants:
    - name: SGT-NewApproach
      services:
        service_graph_templates:
          - name: PBR_SG_Minimal
            devices:
              - name: FW   # Since no `node_name` is defined, `node_name` = `name`
            connections:
              - consumer_node: EPG-Consumer
                provider_node: FW
              - consumer_node: FW
                provider_node: EPG-Provider
```

New approach reusing device:

```
  EPG    ──────── Node-1 ───────── Node-1 ──────   EPG
Consumer           (N1)             (N2)         Provider
```

A Service Graph Template can reuse a device definition as soon different `node_name` values are used. The same tweak can be applied for Copy nodes.

```yaml
apic:
  tenants:
    - name: SGT-NewApproach
      services:
        service_graph_templates:
          - name: PBR_SG_Device_Reuse
            devices:
              - name: Node-1
                node_name: N1
              - name: Node-1
                node_name: N2
            connections:
              - consumer_node: EPG-Consumer
                provider_node: N1
              - consumer_node: N1
                provider_node: N2
              - consumer_node: N2
                provider_node: EPG-Provider
```

New approach full example:

```
  EPG    ────┬───── Node-1 ────┬───── Node-2 ──────   EPG
Consumer     │      (N1)       │      (N2)          Provider
             │                 │
            Copy              Copy
          Device-1          Device-2
            (C1)
```

This example is intended to showcase all new available options rather than illustrate a specific use case or best practices.

```yaml
apic:
  tenants:
    - name: ABC
      services:
        service_graph_templates:
          - name: PBR_SG_Full
            devices:
              - name: Node-1
                node_name: N1
                tenant: ABC
              - name: CopyDevice-1
                node_name: C1
              - name: CopyDevice-2
                template_type: FW_TRANS
              - name: Node-2
                node_name: N2
            connections:
              - consumer_node: EPG-Consumer
                provider_node: Node-1
                copy_node: CopyDevice-1
              - consumer_node: Node-1
                provider_node: Node-2
                copy_node: CopyDevice-2
                adjacency_type: L2
                unicast_route: false
              - consumer_node: Node-2
                provider_node: EPG-Provider
                copy_node: CopyDevice-1
                direct_connect: true
```


> The following examples are retained solely for reference and backward compatibility. We recommend discontinuing their use, as they will be deprecated in due course.

Example 1: This example creates a Service Graph template that offers a high-level, reusable framework for defining and deploying service chains for L3 devices (also known as Routed mode). The service graph will be a Layer 3 graph towards as the type is defined as `FW_ROUTED` allowing traffic redirect (`redirect: true`). Also, it is not sharing encapsulation across all connectors for the function node (`share_encapsulation: false`).

A Device Selection Policy can be used to specify the particular instantiation details generated when the template is applied to a contract.

The data model can be applied as is; however, if the referenced L4-L7 Device is not included (listed as FW), the deployment will not function correctly. The FW device referenced in this example is located in the following module:

- apic.tenants.services.l4l7_devices

```yaml
apic:
  tenants:
    - name: PBR_ServGraph
      services:
        service_graph_templates:
          - name: PBR_SG_template
            description: This is a PBR SG template
            template_type: FW_ROUTED
            redirect: true
            share_encapsulation: false
            device:
              name: FW
              node_name: FW_Cluster
```

Example 2: This minimal example creates a Service Graph template with default values, except for the `adjacency_type` parameter, which is set to L2. This parameter is configurable only for non-Copy devices; Copy devices receive mirrored (one-way) traffic, and no return path is required or expected, as Copy devices do not route traffic back into the fabric.

```yaml
apic:
  tenants:
    - name: ABC
      services:
        service_graph_templates:
          - name: TEMPLATE1
            device:
              name: DEV1
              adjacency_type: L2
```

Full example:

```yaml
apic:
  tenants:
    - name: ABC
      services:
        service_graph_templates:
          - name: TEMPLATE1
            alias: TEMPLATE1-ALIAS
            description: My Desc
            template_type: FW_ROUTED
            redirect: true
            share_encapsulation: false
            device:
              tenant: ABC
              name: DEV1
            consumer:
              direct_connect: false
            provider:
              direct_connect: true
```
