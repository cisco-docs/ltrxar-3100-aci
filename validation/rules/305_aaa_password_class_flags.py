class Rule:
    id = "305"
    description = "Verify AAA Security Settings - Password Class Flags"
    severity = "HIGH"

    @classmethod
    def match(cls, inventory):
        results = []
        try:
            password_class_flags = (
                inventory.get("apic", {})
                .get("fabric_policies", {})
                .get("aaa", {})
                .get("management_settings", {})
                .get("password_strength_profile", {})["password_class_flags"]
            )
            # We don't use .get("password_class_flags", []) above, because if
            # this key exists, then a valid value *must* be specified. To
            # assign a default value of an empty list would be incorrect,
            # because this is not a valid value for the attribute.

            # However, if the user has included it in the YAML and failed to
            # assign a value, then we need to catch the None and enable the
            # validation checks to fail...
            if password_class_flags is None:
                password_class_flags = []

            # insert the list to the set
            list_set = set(password_class_flags)
            # convert the set to the list
            unique_list = list(list_set)

            if len(unique_list) < 3 or len(unique_list) > 4:
                results.append(
                    "apic.fabric_policies.aaa.management_settings.password_class_flags - "
                    + str(password_class_flags)
                    + " is not a combination of at least three out of four options: digits,lowercase,specialchars,uppercase."
                )
        except KeyError:
            pass
        return results
