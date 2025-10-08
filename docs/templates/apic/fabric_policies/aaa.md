# AAA Settings

Location in GUI:
`Admin` » `AAA` » `Authentication` » `AAA`


{{ doc_gen }}

### Examples

Example 1: In this example we set the default authentication method for GUI and console to radius with the `login_domain` created using both of our configured radius servers.

```yaml
apic:
  fabric_policies:
    aaa:
      default_realm: radius
      default_login_domain: yourDomainRadius
      console_realm: radius
      console_login_domain: yourDomainRadius
```

Example 2: In this example we set the default authentication method for GUI and console to tacacs with the `login_domain` created using both of our configured tacacs servers.

```yaml
apic:
  fabric_policies:
    aaa:
      default_realm: tacacs
      default_login_domain: yourDomainTacacs
      console_realm: tacacs
      console_login_domain: yourDomainTacacs
```

Example 3: In this example we set the default authentication method for GUI and console to `local`, where the local realm represents locally created users.

```yaml
apic:
  fabric_policies:
    aaa:
      default_realm: local
      default_login_domain: local
      console_realm: local
      console_login_domain: local
```

Example 4: In this example below we have created a security domain called `secDomain1` where restricted RBAC has been enabled. Also in the management_settings we enable strong password check for local passwords, where they need to be of minimum length `8` and maximum length of `64` and needs to consist of lower case and uppercase characters.

```yaml
apic:
  fabric_policies:
    aaa:
      security_domains:
        - name: secDomain1
          restricted_rbac_domain: true
      management_settings:
        password_strength_check: true
        password_strength_profile:
          password_mininum_length: 8
          password_maximum_length: 64
          password_strength_test_type: custom
          password_class_flags:
            - lowercase
            - uppercase
```

Example 5: In this example we defined the maximum lifetime of an authentication token to `24` hours using the web_token_max_validity setting. Where web_token_timeout defines a token will be marked invalid if not used after `600` seconds, where the web_session_idle_timeout defines to demand reauthentication after `1200` seconds for idle sessions on the web GUI.

```yaml
apic:
  fabric_policies:
    aaa:
      management_settings:
        web_token_timeout: 600
        web_token_max_validity: 24
        web_session_idle_timeout: 1200
```
