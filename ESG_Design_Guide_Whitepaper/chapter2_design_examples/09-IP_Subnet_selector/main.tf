terraform {
  required_version = ">= 0.13.1"

  required_providers {
    aci = {
      source  = "CiscoDevNet/aci"
      version = ">= 2.1.0"
    }
    vsphere = {
      source  = "hashicorp/vsphere"
      version = ">= 2.3.1"
    }
  }
}

provider "aci" {
  username = var.apic_username
  password = var.apic_password
  url      = var.apic_url
  insecure = true
}

module "tenants" {
  source = "../modules/aci_tenant"

  config = yamldecode(file("${path.root}/config.yaml"))
}
