terraform {
  required_version = ">= 0.13.1"

  required_providers {
    aci = {
      source  = "CiscoDevNet/aci"
      version = ">= 2.1.0"
    }
  }
}

provider "aci" {
  username = var.apic_username
  password = var.apic_password
  url      = var.apic_url
  insecure = true
}

locals {
  tmpl = {
    vc_ip         = var.vc_ip
    vc_datacenter = var.vc_datacenter
    vc_username   = var.vc_username
    vc_password   = var.vc_password
  }

  config = yamldecode(templatefile("${path.root}/config.yaml", local.tmpl))
}

##################################
# VMM Domain
##################################
locals {
  vmm_vcenters = flatten([
    for dom in local.config.vmware_vmm_domains : [
      for vc in dom.vcenters : merge(
        {
          key      = join("/", [dom.name, vc.name]),
          dom_key  = dom.name,
          cred_key = join("/", [dom.name, vc.credential_policy])
        },
        vc
      )
    ]
  ])
  vmm_vc_creds = flatten([
    for dom in local.config.vmware_vmm_domains : [
      for cred in dom.credential_policies : merge(
        {
          key     = join("/", [dom.name, cred.name]),
          dom_key = dom.name
        },
        cred
      )
    ]
  ])
}

resource "aci_vmm_domain" "this" {
  for_each = { for dom in local.config.vmware_vmm_domains : dom.name => dom }

  provider_profile_dn       = "uni/vmmp-VMware"
  name                      = each.key
  relation_infra_rs_vlan_ns = aci_vlan_pool.this[each.value.vlan_pool].id

  # Required for ESG tag selectors with VM tags and/or VM names
  access_mode = each.value.access_mode
  enable_tag  = each.value.tag_collection ? "yes" : "no"
}

resource "aci_vmm_controller" "this" {
  for_each = { for vc in local.vmm_vcenters : vc.key => vc }

  vmm_domain_dn       = aci_vmm_domain.this[each.value.dom_key].id
  name                = each.value.name
  host_or_ip          = each.value.hostname_ip
  root_cont_name      = each.value.datacenter
  relation_vmm_rs_acc = aci_vmm_credential.this[each.value.cred_key].id
}

resource "aci_vmm_credential" "this" {
  for_each = { for cred in local.vmm_vc_creds : cred.key => cred }

  vmm_domain_dn = aci_vmm_domain.this[each.value.dom_key].id
  name          = each.value.name
  usr           = each.value.username
  pwd           = each.value.password
}

##################################
# Physical Domain
##################################
resource "aci_physical_domain" "this" {
  for_each = { for dom in local.config.physical_domains : dom.name => dom.vlan_pool }

  name                      = each.key
  relation_infra_rs_vlan_ns = aci_vlan_pool.this[each.value].id
}

##################################
# VLAN Pool
##################################
locals {
  vlan_ranges = flatten([
    for pool in local.config.vlan_pools : [
      for range in pool.ranges : merge(
        {
          key      = join("/", [pool.name, range.from, range.to]),
          pool_key = pool.name
        },
        range
      )
    ]
  ])
}

resource "aci_vlan_pool" "this" {
  for_each = { for pool in local.config.vlan_pools : pool.name => pool }

  name       = each.key
  alloc_mode = each.value.allocation
}

resource "aci_ranges" "this" {
  for_each = { for range in local.vlan_ranges : range.key => range }

  vlan_pool_dn = aci_vlan_pool.this[each.value.pool_key].id
  from         = "vlan-${each.value.from}"
  to           = "vlan-${each.value.to}"
  alloc_mode   = each.value.allocation
  role         = "external"
}

##################################
# AAEP
##################################
resource "aci_attachable_access_entity_profile" "this" {
  for_each = { for aaep in local.config.aaeps : aaep.name => aaep }

  name = each.key
  relation_infra_rs_dom_p = concat(
    [for dom in each.value.physical_domains : aci_physical_domain.this[dom].id],
    [for dom in each.value.vmm_domains : aci_vmm_domain.this[dom].id]
  )
}

##################################
# Interface Policy Group
##################################
resource "aci_leaf_access_port_policy_group" "this" {
  for_each = { for ifpg in local.config.interface_policy_groups : ifpg.name => ifpg }

  name                        = each.value.name
  relation_infra_rs_att_ent_p = aci_attachable_access_entity_profile.this[each.value.aaep].id
}

##################################
# Interface and Switch Profiles
##################################
locals {
  port_selectors = flatten([
    for p in local.config.interface_profiles : [
      for sel in p.interfaces : merge(
        {
          key         = join("_", [p.name, sel.port])
          profile_key = p.name
        },
        sel
      )
    ]
  ])
}
resource "aci_leaf_profile" "this" {
  for_each = { for p in local.config.interface_profiles : p.name => p }

  name                         = each.key
  relation_infra_rs_acc_port_p = [aci_leaf_interface_profile.this[each.key].id]
  leaf_selector {
    name                    = each.key
    switch_association_type = "range"
    node_block {
      name  = each.key
      from_ = each.value.node_id
      to_   = each.value.node_id
    }
  }
}

resource "aci_leaf_interface_profile" "this" {
  for_each = toset([for p in local.config.interface_profiles : p.name])

  name = each.value
}

resource "aci_access_port_selector" "this" {
  for_each = { for sel in local.port_selectors : sel.key => sel }

  leaf_interface_profile_dn      = aci_leaf_interface_profile.this[each.value.profile_key].id
  name                           = "PORT_${each.value.port}"
  access_port_selector_type      = "range"
  relation_infra_rs_acc_base_grp = aci_leaf_access_port_policy_group.this[each.value.policy_group].id
}

resource "aci_access_port_block" "this" {
  for_each = { for sel in local.port_selectors : sel.key => sel }

  access_port_selector_dn = aci_access_port_selector.this[each.key].id
  name                    = each.key
  from_card               = 1
  to_card                 = 1
  from_port               = each.value.port
  to_port                 = each.value.port
}
