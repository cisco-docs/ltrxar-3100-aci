# Service Graph Template

Location in GUI:
`Tenants` » `XXX` » `Services` » `L4-L7` » `Service Graph Templates`


{{ doc_gen }}

### Examples

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

Simple example:

```yaml
apic:
  tenants:
    - name: ABC
      services:
        service_graph_templates:
          - name: TEMPLATE1
            redirect: true
            device:
              name: DEV1
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
