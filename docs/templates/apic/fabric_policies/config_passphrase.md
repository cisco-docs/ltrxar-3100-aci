# Config Passphrase

Location in GUI:
`System` » `System Settings` » `Global AES Passphrase Encryption Settings`


{{ doc_gen }}

### Examples

Example-1: This data model defines an encryption passphrase, `Cisco123!Cisco123!`, which is used to secure configuration backups by encrypting all sensitive properties, such as passwords, using AES-256 encryption. When enabled, this feature ensures that passwords and other secure data are included in configuration exports and can only be successfully imported back into the fabric if the correct passphrase is provided.

As a best practice, it is not recommended to store or define passwords or passphrases in plain text. Instead, sensitive data should be passed using environment variables to enhance security.

```yaml
apic:
  fabric_policies:
    config_passphrase: Cisco123!Cisco123!
```
