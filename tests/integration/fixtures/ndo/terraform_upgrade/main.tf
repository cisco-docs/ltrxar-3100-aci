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
  #source = "github.com/netascode/terraform-mso-nac-ndo.git?ref=main"
  source  = "netascode/nac-ndo/mso"
  version = "1.0.1"

  yaml_directories = ["../standard", "../standard_44"]

  manage_system            = true
  manage_sites             = true
  manage_site_connectivity = true
  manage_tenants           = true
  manage_schemas           = true
  deploy_templates         = true

  write_default_values_file = "defaults.yaml"
}
