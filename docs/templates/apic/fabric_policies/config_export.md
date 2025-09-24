# Config Exports

Location in GUI:
`Admin` » `Import/Export` » `Export Policies` » `Configuration`


{{ doc_gen }}

### Examples

Example-1: this example demonstrates the configuration of a config export policy `ACI_EXPORT`. It will export the ACI backup format as `json` to the server associated to the remote location policy listed under the remote_location attribute of `BKP_SRV`. The backup is configured with a scheduler named `MIDNIGHT`, which can be set to run on a nightly basis. Since the snapshot attribute is set to `true`, a snapshot of the configuration will be stored on the APIC in addition to the server export. Note that the snapshot attribute, which exports the config backup locally on the APIC, is missing. It is off by default, and since it is mutually exclusive with the definition of a remote location, it is left to its default.

```yaml
apic:
  fabric_policies:
    config_exports:
      - name: ACI_EXPORT
        description: Export ACI JSON configuration to remote server
        format: json
        remote_location: BKP_SRV
        scheduler: MIDNIGHT
```
