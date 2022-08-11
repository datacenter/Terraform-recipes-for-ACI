#############################################################################
# This Terraform plan creates all policies required for interface           #
# configuration on ACI using variables which are defined in variables.tf    #
#                                                                           #
# Tailor as you see fit.                                                    #
#############################################################################

terraform {
  required_providers {
    aci = {
      source  = "CiscoDevNet/aci"
      version = "2.5.2"
    }
  }
}

provider "aci" {
  username = var.credentials.apic_username
  password = var.credentials.apic_password
  url      = var.credentials.apic_url
}

# Leaf profiles
resource "aci_leaf_profile" "l_profs" {
  for_each                     = var.leafs
  name                         = each.value.name
  relation_infra_rs_acc_port_p = ["${aci_leaf_interface_profile.li_profs[each.key].id}"]
  leaf_selector {
    name                    = each.value.name
    switch_association_type = "range"
    node_block {
      name  = each.value.name
      from_ = each.key
      to_   = each.key
    }
  }
}

# Leaf interface profile
resource "aci_leaf_interface_profile" "li_profs" {
  for_each    = var.leafs
  name        = each.value.name
  description = "interface profile associated with ${each.value.name}"
}

# Link level policies
resource "aci_fabric_if_pol" "llpols" {
  for_each      = var.intpols
  name          = each.key
  description   = each.value.desc
  auto_neg      = each.value.autoneg
  fec_mode      = each.value.fec
  link_debounce = each.value.linkdebounce
  speed         = each.value.speed
}

# LLDP policies
resource "aci_lldp_interface_policy" "lldp_pols" {
  for_each    = var.lldp
  description = each.value.desc
  name        = each.key
  admin_rx_st = each.value.receive
  admin_tx_st = each.value.transmit
}

# CDP policies
resource "aci_cdp_interface_policy" "cdp_pols" {
  for_each    = var.cdp
  description = each.value.desc
  name        = each.key
  admin_st    = each.value.admin_state
}

# MCP policies
resource "aci_miscabling_protocol_interface_policy" "mcp_pols" {
  for_each    = var.mcp
  description = each.value.desc
  name        = each.key
  admin_st    = each.value.admin_state
}

# LACP policies
resource "aci_lacp_policy" "lacp_pols" {
  for_each  = var.lacp
  name      = each.key
  max_links = each.value.max_links
  min_links = each.value.min_links
  mode      = each.value.mode
}

# VLAN pools
resource "aci_vlan_pool" "vlan_pools" {
  for_each    = var.vlan_pools
  name        = each.key
  description = each.value.desc
  alloc_mode  = each.value.allocation
}

# VLAN pool ranges
resource "aci_ranges" "vlan_pool_range1" {
  for_each     = var.vlan_pools
  vlan_pool_dn = aci_vlan_pool.vlan_pools[each.key].id
  from         = "vlan-${var.vlan_pools[each.key].range1.start}"
  to           = "vlan-${var.vlan_pools[each.key].range1.end}"
  alloc_mode   = var.vlan_pools[each.key].range1.allocation
}

# Physical Domains
resource "aci_physical_domain" "phys_doms" {
  for_each = { for key, value in var.domains : key => value if value.type == "phys" }
  name     = each.key
}

# L3 Domains
resource "aci_l3_domain_profile" "l3_doms" {
  for_each = { for key, value in var.domains : key => value if value.type == "l3dom" }
  name     = each.key
}

# VMM Domains
resource "aci_vmm_domain" "vmmv_doms" {
  for_each            = { for key, value in var.domains : key => value if value.type == "vmware" }
  provider_profile_dn = "uni/vmmp-VMware"
  name                = each.key
}

# Variable domain DNs
variable "domain_prefix" {
  default = {
    vmware = "uni/vmmp-VMware/dom"
    l3dom  = "uni/l3dom"
    phys   = "uni/phys"
  }
}

# Attachable Entity Profile
resource "aci_attachable_access_entity_profile" "aaeps" {
  for_each    = var.aaeps
  name        = each.key
  description = each.value.desc
  relation_infra_rs_dom_p = [for f in each.value.domain : "${var.domain_prefix[var.domains["${f}"].type]}-${f}"]
}

# Leaf Access Port Policy Groups
resource "aci_leaf_access_port_policy_group" "leaf_appgs" {
  for_each                      = var.leafs_appg
  name                          = each.key
  relation_infra_rs_lldp_if_pol = aci_lldp_interface_policy.lldp_pols[each.value.lldp].id
  relation_infra_rs_att_ent_p   = aci_attachable_access_entity_profile.aaeps[each.value.aaep].id
  description                   = each.value.desc
}

resource "aci_access_port_selector" "leaf_apss" {
  for_each                  = {for key, value in var.interfaces: key => value if value.iftype == "switch_port" }
  leaf_interface_profile_dn = aci_leaf_interface_profile.li_profs[each.value.leaf].id
  name                      = each.key
  access_port_selector_type = "range"
  relation_infra_rs_acc_base_grp = aci_leaf_access_port_policy_group.leaf_appgs[each.value.polgrp].id
}

resource "aci_access_port_block" "leaf_apbs" {
  for_each                = {for key, value in var.interfaces: key => value if value.iftype == "switch_port" }
  access_port_selector_dn = aci_access_port_selector.leaf_apss[each.key].id
  name                    = each.key
  from_card               = each.value.lfblk
  to_card                 = each.value.lfblk
  from_port               = each.value.from
  to_port                 = each.value.end
}

# VPC Access Port Policy Groups
resource "aci_leaf_access_bundle_policy_group" "leaf_vppgs" {
  for_each                      = var.leafs_vppg
  name                          = each.key
  relation_infra_rs_lacp_pol    = aci_lacp_policy.lacp_pols[each.value.channel_mode].id
  relation_infra_rs_lldp_if_pol = aci_lldp_interface_policy.lldp_pols[each.value.lldp].id
  relation_infra_rs_att_ent_p   = aci_attachable_access_entity_profile.aaeps[each.value.aaep].id
  lag_t                         = "node"
}

resource "aci_access_port_selector" "leaf_vpss" {
  for_each                  = {for key, value in var.interfaces: key => value if value.iftype == "vpc" }
  leaf_interface_profile_dn = aci_leaf_interface_profile.li_profs[each.value.leaf].id
  name                      = each.key
  access_port_selector_type = "range"
  relation_infra_rs_acc_base_grp = aci_leaf_access_bundle_policy_group.leaf_vppgs[each.value.polgrp].id
}

resource "aci_access_port_block" "leaf_vpbs" {
  for_each                = {for key, value in var.interfaces: key => value if value.iftype == "vpc" }
  access_port_selector_dn = aci_access_port_selector.leaf_vpss[each.key].id
  name                    = each.key
  from_card               = each.value.lfblk
  to_card                 = each.value.lfblk
  from_port               = each.value.from
  to_port                 = each.value.end
}