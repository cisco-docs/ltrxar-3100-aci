class Rule:
    id = "308"
    description = "Verify length of VMM port-group name"
    severity = "HIGH"

    @classmethod
    def match(cls, inventory):
        results = []
        vmdom_epg = []
        temp = []

        try:
            tenants = inventory.get("apic", {}).get("tenants", [])
            for tenant in tenants:
                tn_name = tenant["name"]
                application_profiles = tenant.get("application_profiles", [])
                for app in application_profiles:
                    ap_name = app["name"]
                    endpoint_groups = app.get("endpoint_groups", [])
                    for epg in endpoint_groups:
                        epg_name = epg["name"]
                        vmware_vmm_domains = epg.get(
                            "vmware_vmm_domains",
                        )
                        if vmware_vmm_domains:
                            vmdom_epg.append(f"{tn_name}{ap_name}{epg_name}")
                            temp.append(f"{tn_name}|{ap_name}|{epg_name}")

            for k, m in zip(temp, vmdom_epg):
                if len(m) > 79:
                    results.append(
                        k
                        + " --- The length of Tenant+AP+EPG is too long: "
                        + str(len(m))
                        + " characters"
                    )

        except KeyError:
            pass
        return results
