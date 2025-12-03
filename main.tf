terraform {
  required_providers {
    aci = {
      source = "CiscoDevNet/aci"
    }
  }

  backend "http" {
  }
}

provider "aci" {
}

module "aci" {
  source  = "netascode/nac-aci/aci"
  version = "1.1.0"

  yaml_directories = ["data"]

  manage_access_policies    = false
  manage_fabric_policies    = false
  manage_pod_policies       = false
  manage_node_policies      = true
  manage_interface_policies = true
  manage_tenants            = true

  write_default_values_file = "defaults.yaml"

}
