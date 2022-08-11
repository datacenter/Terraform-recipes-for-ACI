  #############################################################################
  # This Terraform plan creates a complete tenant on ACI using variables      #
  # which are defined in variables.tf                                         #
  #                                                                           #
  # This playbook assumes a shared L3out called internet is already in place. #
  # Tailor as you see fit.                                                    #
  #############################################################################

terraform {
  required_providers {
    aci = {
      source  = "CiscoDevNet/aci"
      version = "2.5.1"
    }
  }
}

provider "aci" {
  username = var.credentials.apic_username
  password = var.credentials.apic_password
  url      = var.credentials.apic_url
}

# Tenant
resource "aci_tenant" "tenant1" {
  name = var.tenant
}

# VRF
resource "aci_vrf" "vrf1" {
  tenant_dn = aci_tenant.tenant1.id
  name      = var.vrf
}

# Bridge Domains
resource "aci_bridge_domain" "bds" {
  for_each                 = var.bds
  name                     = each.key
  tenant_dn                = aci_tenant.tenant1.id
  relation_fv_rs_ctx       = aci_vrf.vrf1.id
  relation_fv_rs_bd_to_out = [for key, value in var.epgs : data.aci_l3_outside.shared_l3_out.id if value.external_access == true && value.bd == each.key]
}

# Bridge Domains Subnets
resource "aci_subnet" "subnets" {
  for_each  = { for key, value in var.epgs : key => value }
  parent_dn = aci_bridge_domain.bds[var.epgs[each.key].bd].id
  ip        = var.bds[var.epgs[each.key].bd].ip
  scope     = each.value.external_access ? ["public", "shared"] : ["private"]
}

# Application Profile
resource "aci_application_profile" "ap1" {
  tenant_dn = aci_tenant.tenant1.id
  name      = var.ap
}

# EPGs
resource "aci_application_epg" "epgs" {
  depends_on             = [aci_bridge_domain.bds]
  for_each               = var.epgs
  name                   = each.key
  description            = var.epgs[each.key].description
  application_profile_dn = "uni/tn-${aci_tenant.tenant1.name}/ap-${var.epgs[each.key].ap}"
  relation_fv_rs_bd      = "uni/tn-${aci_tenant.tenant1.name}/BD-${var.epgs[each.key].bd}"
}

# EPGs to Domain
resource "aci_epg_to_domain" "epgs_domain" {
  for_each = var.epgs
  application_epg_dn    = aci_application_epg.epgs[each.key].id
  tdn                   = "uni/${each.value.domain_type}-${each.value.domain}"
}

# Static path binding type Port-Channel or Interface
resource "aci_epg_to_static_path" "switchport" {
  depends_on         = [aci_application_epg.epgs]
  for_each           = { for key, value in var.static_paths : key => value if value.iftype != "vpc" }
  application_epg_dn = "uni/tn-${aci_tenant.tenant1.name}/ap-${var.ap}/epg-${var.static_paths[each.key].epg}"
  tdn                = "topology/pod-${var.static_paths[each.key].pod}/paths-${var.static_paths[each.key].leaf}/pathep-[${var.static_paths[each.key].if}]"
  mode               = each.value.ifmode
  encap              = "vlan-${var.static_paths[each.key].encap}"
}

# Static path binding type VPC
resource "aci_epg_to_static_path" "vpc" {
  depends_on         = [aci_application_epg.epgs]
  for_each           = { for key, value in var.static_paths : key => value if value.iftype == "vpc" }
  application_epg_dn = "uni/tn-${aci_tenant.tenant1.name}/ap-${var.ap}/epg-${var.static_paths[each.key].epg}"
  tdn                = "topology/pod-${var.static_paths[each.key].pod}/protpaths-${var.static_paths[each.key].leaf}/pathep-[${var.static_paths[each.key].if}]"
  mode               = each.value.ifmode
  encap              = "vlan-${var.static_paths[each.key].encap}"
}

# Filters
resource "aci_filter" "filters" {
  tenant_dn = aci_tenant.tenant1.id
  for_each  = var.filters
  name      = each.key
}

# Filter entries
resource "aci_filter_entry" "filter_entries" {
  depends_on  = [aci_filter.filters]
  for_each    = var.filters
  filter_dn   = "uni/tn-${aci_tenant.tenant1.name}/flt-${each.key}"
  name        = each.key
  d_from_port = each.value.destination_from_port
  d_to_port   = each.value.destination_to_port
  prot        = each.value.protocol
  ether_t     = each.value.ether_type
}

# Contracts
resource "aci_contract" "contracts" {
  for_each  = var.contracts
  tenant_dn = aci_tenant.tenant1.id
  name      = each.key
}

# Contract Subjects
resource "aci_contract_subject" "subjects" {
  depends_on                   = [aci_contract.contracts]
  for_each                     = var.contracts
  contract_dn                  = "uni/tn-${aci_tenant.tenant1.name}/brc-${each.key}"
  name                         = each.value.subject
  relation_vz_rs_subj_filt_att = [for f in each.value.filter : "uni/tn-${aci_tenant.tenant1.name}/flt-${f}"]
}

# Contract consumers
resource "aci_epg_to_contract" "con_providers" {
  depends_on         = [aci_application_epg.epgs]
  for_each           = { for key, value in var.contract_to_epgs : key => value if value.provider != "" }
  application_epg_dn = "uni/tn-${aci_tenant.tenant1.name}/ap-${var.ap}/epg-${var.contract_to_epgs[each.key].provider}"
  contract_dn        = "uni/tn-${aci_tenant.tenant1.name}/brc-${each.key}"
  contract_type      = "provider"
}

# Contract providers
resource "aci_epg_to_contract" "con_consumers" {
  depends_on         = [aci_application_epg.epgs]
  for_each           = { for key, value in var.contract_to_epgs : key => value if value.consumer != "" }
  application_epg_dn = "uni/tn-${aci_tenant.tenant1.name}/ap-${var.ap}/epg-${var.contract_to_epgs[each.key].consumer}"
  contract_dn        = "uni/tn-${aci_tenant.tenant1.name}/brc-${each.key}"
  contract_type      = "consumer"
}

# External network profile for the shared L3out
resource "aci_external_network_instance_profile" "network_instance_profile" {
  l3_outside_dn          = data.aci_l3_outside.shared_l3_out.id
  description            = "ExtEPG used by ${aci_tenant.tenant1.name}"
  name                   = aci_tenant.tenant1.name
  relation_fv_rs_cons_if = [for f in aci_contract.external_routing_contracts : "uni/tn-${data.aci_tenant.common_tenant.name}/cif-${f.name}"]
}

# External subnet for the shared L3out
resource "aci_l3_ext_subnet" "ext_epg_subnet" {
  external_network_instance_profile_dn = aci_external_network_instance_profile.network_instance_profile.id
  description                          = "L3 External subnet"
  ip                                   = "0.0.0.0/0"
  aggregate                            = "shared-rtctrl"
  scope                                = ["import-security", "shared-security", "import-rtctrl", "shared-rtctrl"]
}

# Contracts used with shared L3out
resource "aci_contract" "external_routing_contracts" {
  for_each  = { for key, value in var.epgs : key => value if value.external_access == true }
  tenant_dn = aci_tenant.tenant1.id
  name      = "${aci_tenant.tenant1.name}-${aci_application_epg.epgs[each.key].name}-to-common"
  scope     = "global"
}

# Contracts subjects used with shared L3out
resource "aci_contract_subject" "external_routing" {
  for_each                     = aci_contract.external_routing_contracts
  contract_dn                  = aci_contract.external_routing_contracts[each.key].id
  description                  = "external routing for ${each.key}"
  name                         = "subject1"
  rev_flt_ports                = "yes"
  relation_vz_rs_subj_filt_att = ["uni/tn-${aci_tenant.tenant1.name}/flt-tcp_src_any_to_dst_8080"]
}

# Contract providers used with shared L3out
resource "aci_epg_to_contract" "aci_epgs_to_common" {
  for_each           = { for key, value in var.epgs : key => value if value.external_access == true }
  application_epg_dn = "uni/tn-${aci_tenant.tenant1.name}/ap-${var.ap}/epg-${each.key}"
  contract_dn        = aci_contract.external_routing_contracts[each.key].id
  contract_type      = "provider"
}

# Contract export used with shared L3out
resource "aci_imported_contract" "imported_contracts" {
  for_each          = aci_contract.external_routing_contracts
  tenant_dn         = data.aci_tenant.common_tenant.id
  name              = "${aci_tenant.tenant1.name}-${each.key}-to-common"
  relation_vz_rs_if = "uni/tn-${aci_tenant.tenant1.name}/brc-${aci_tenant.tenant1.name}-${each.key}-to-common"
}

resource "aci_subnet" "epg_subnets" {
  depends_on = [aci_subnet.subnets]
  for_each  = { for key, value in var.epgs : key => value if value.external_access == true }
  parent_dn = aci_application_epg.epgs[each.key].id
  ip        = var.bds[var.epgs[each.key].bd].ip
  scope     = ["public", "shared"]
}

# # Leaking subnets to shared L3out VRF for when you use ESGs
# resource "aci_vrf_leak_epg_bd_subnet" "vrf_leak_epg_bd_subnet" {
#   for_each = { for key, value in var.epgs : key => value if value.external_access == true }
#   vrf_dn                    = aci_vrf.vrf1.id
#   ip                        = var.bds[var.epgs[each.key].bd].ip
#   allow_l3out_advertisement = true
#   leak_to {
#     vrf_dn                    = data.aci_vrf.common_vrf.id
#   }
# }