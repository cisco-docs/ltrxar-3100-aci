# Smart Licensing

Location in GUI:
`System` » `Smart Licensing`


{{ doc_gen }}

### Examples

Example-1: This example demonstrates how to configure Smart Licensing using an HTTP/HTTPS Proxy to communicate with Cisco Smart Software Manager (CSSM). The apic registers using a CSSM registration token and reaches CSSM through the proxy. The registration_token enables the device to register, while proxy hostname_ip and proxy.port identify the proxy the APIC will use.

```yaml
apic:
  fabric_policies:
    smart_licensing:
      mode: proxy
      registration_token: ABCDEFG
      proxy:
        hostname_ip: 192.168.10.101
        port: 3128
```
