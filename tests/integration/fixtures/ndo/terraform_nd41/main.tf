terraform {
  required_providers {
    mso = {
      source = "CiscoDevNet/mso"
    }
  }
}

provider "mso" {
  platform = "nd"
}

module "ndo" {
  source = "github.com/netascode/terraform-mso-nac-ndo.git?ref=main"

  yaml_directories = ["../standard", "../standard_nd41"]

  manage_system            = true
  manage_sites             = true
  manage_site_connectivity = true
  manage_tenants           = true
  manage_schemas           = true
  manage_tenant_templates  = true
  deploy_templates         = true

  write_default_values_file = "defaults.yaml"
}
