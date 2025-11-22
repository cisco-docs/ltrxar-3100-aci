# GUI and CLI Banner

Location in GUI:
`System` » `System Settings` » `System Alias and Banners`


{{ doc_gen }}

### Examples

Example-1: The following data model configures various banners related to legal usage; `apic_gui_banner_message` displays a custom informational or legal banner on the APIC GUI login page. The `switch_cli_banner` and `apic_cli_banner` are shown when connecting to the fabric switches and controllers respectively using SSH or Telnet (if available). Please note that a new line is represented by `\n`.
Finally, the `apic_gui_alias` helps identify which APIC controller you are currently viewing in a multi-APIC cluster environment.

```yaml
apic:
  fabric_policies:
    banners:
      apic_gui_alias: San Francisco DC
      switch_cli_banner: "*************************************************\n*   WARNING: Unauthorized access is prohibited! *\n*   This system is for authorized users only.   *\n*   All activities are monitored and recorded.  *\n*************************************************"
      apic_gui_banner_message: "By logging in, you agree to the terms and conditions of use. Unauthorized access is prohibited."
      apic_cli_banner: "*************************************************\n*   WARNING: Unauthorized access is prohibited! *\n*   This system is for authorized users only.   *\n*   All activities are monitored and recorded.  *\n*************************************************"
```
