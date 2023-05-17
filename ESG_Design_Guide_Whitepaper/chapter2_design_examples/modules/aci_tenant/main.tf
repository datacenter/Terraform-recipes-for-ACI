terraform {
  required_version = ">= 0.13.1"

  required_providers {
    aci = {
      source  = "CiscoDevNet/aci"
      version = ">= 2.1.0"
    }
  }
}

locals {
  aps = flatten([
    for tenant in var.config.tenants : [
      for ap in tenant.application_profiles : merge(
        {
          _key    = join("/", [tenant.name, ap.name]),
          _tenant = tenant.name
        },
        ap
    )]
  ])
  esgs = flatten([
    for tenant in var.config.tenants : [
      for ap in tenant.application_profiles : [
        for esg in ap.endpoint_security_groups : merge(
          {
            _key     = join("/", [tenant.name, ap.name, esg.name]),
            _ap_key  = join("/", [tenant.name, ap.name]),
            _vrf_key = join("/", [tenant.name, esg.vrf]),
          },
          esg
        )
      ]
    ]
  ])
  esg_epg_selectors = flatten([
    for tenant in var.config.tenants : [
      for ap in tenant.application_profiles : [
        for esg in ap.endpoint_security_groups : [
          for selector in esg.epg_selectors : merge(
            {
              _key     = join("/", [tenant.name, ap.name, esg.name, selector.application_profile, selector.endpoint_group]),
              _esg_key = join("/", [tenant.name, ap.name, esg.name]),
              _epg_key = join("/", [tenant.name, selector.application_profile, selector.endpoint_group]),
            },
            selector
          )
        ]
      ]
    ]
  ])
  esg_ip_subnet_selectors = flatten([
    for tenant in var.config.tenants : [
      for ap in tenant.application_profiles : [
        for esg in ap.endpoint_security_groups : [
          for selector in esg.ip_subnet_selectors : merge(
            {
              _key     = join("/", [tenant.name, ap.name, esg.name, selector.ip]),
              _esg_key = join("/", [tenant.name, ap.name, esg.name]),
            },
            selector
          )
        ]
      ]
    ]
  ])
  esg_tag_selectors = flatten([
    for tenant in var.config.tenants : [
      for ap in tenant.application_profiles : [
        for esg in ap.endpoint_security_groups : [
          for selector in esg.tag_selectors : merge(
            {
              _key     = join("/", [tenant.name, ap.name, esg.name, selector.match_key, selector.match_operator, selector.match_value]),
              _esg_key = join("/", [tenant.name, ap.name, esg.name]),
            },
            selector
          )
        ]
      ]
    ]
  ])
  esg_mac_endpoints = flatten([
    for tenant in var.config.tenants : [
      for mac in tenant.mac_endpoints : merge(
        {
          _key    = join("/", [tenant.name, mac.bridge_domain, mac.address]),
          _tenant = tenant.name
        },
        mac
      )
    ]
  ])
  esg_mac_policy_tags = flatten([
    for tenant in var.config.tenants : [
      for mac in tenant.mac_endpoints : [
        for tag in mac.policy_tags : merge(
          {
            _key    = join("/", [tenant.name, mac.bridge_domain, mac.address, tag.key, tag.value]),
            _ep_key = join("/", [tenant.name, mac.bridge_domain, mac.address])
          },
          tag
        )
      ]
    ]
  ])
  esg_ip_endpoints = flatten([
    for tenant in var.config.tenants : [
      for ip in tenant.ip_endpoints : merge(
        {
          _key    = join("/", [tenant.name, ip.vrf, ip.address]),
          _tenant = tenant.name
        },
        ip
      )
    ]
  ])
  esg_ip_policy_tags = flatten([
    for tenant in var.config.tenants : [
      for ip in tenant.ip_endpoints : [
        for tag in ip.policy_tags : merge(
          {
            _key    = join("/", [tenant.name, ip.vrf, ip.address, tag.key, tag.value]),
            _ep_key = join("/", [tenant.name, ip.vrf, ip.address])
          },
          tag
        )
      ]
    ]
  ])
  epgs = flatten([
    for tenant in var.config.tenants : [
      for ap in tenant.application_profiles : [
        for epg in ap.endpoint_groups : merge(
          {
            _key    = join("/", [tenant.name, ap.name, epg.name]),
            _ap_key = join("/", [tenant.name, ap.name]),
            _bd_key = join("/", [tenant.name, epg.bridge_domain]),
          },
          epg
        )
      ]
    ]
  ])
  epg_to_domains_vmm = flatten([
    for tenant in var.config.tenants : [
      for ap in tenant.application_profiles : [
        for epg in ap.endpoint_groups : [
          for dom in epg.vmware_vmm_domains : merge(
            {
              _key     = join("/", [tenant.name, ap.name, epg.name, dom.name]),
              _epg_key = join("/", [tenant.name, ap.name, epg.name]),
            },
            dom
          )
        ]
      ]
    ]
  ])
  epg_to_domains_phys = flatten([
    for tenant in var.config.tenants : [
      for ap in tenant.application_profiles : [
        for epg in ap.endpoint_groups : [
          for dom in epg.physical_domains : merge(
            {
              _key     = join("/", [tenant.name, ap.name, epg.name, dom.name]),
              _epg_key = join("/", [tenant.name, ap.name, epg.name]),
            },
            dom
          )
        ]
      ]
    ]
  ])
  vrfs = flatten([
    for tenant in var.config.tenants : [
      for vrf in tenant.vrfs : merge(
        {
          _key    = join("/", [tenant.name, vrf.name]),
          _tenant = tenant.name
        },
        vrf
    )]
  ])
  bds = flatten([
    for tenant in var.config.tenants : [
      for bd in tenant.bridge_domains : merge(
        {
          _key     = join("/", [tenant.name, bd.name]),
          _tenant  = tenant.name
          _vrf_key = join("/", [tenant.name, bd.vrf]),
        },
        bd
    )]
  ])
  bd_subnets = flatten([
    for tenant in var.config.tenants : [
      for bd in tenant.bridge_domains : [
        for subnet in bd.subnets : merge(
          {
            _key    = join("/", [tenant.name, bd.name, subnet.ip]),
            _bd_key = join("/", [tenant.name, bd.name]),
          },
          subnet
        )
      ]
    ]
  ])
}

##################################
# Tenant
##################################
resource "aci_tenant" "this" {
  for_each = toset([for tenant in var.config.tenants : tenant.name])

  name = each.value
}

##################################
# Application Profiles
##################################
resource "aci_application_profile" "this" {
  for_each = { for ap in local.aps : ap._key => ap }

  tenant_dn = aci_tenant.this[each.value._tenant].id
  name      = each.value.name
}

##################################
# Security 1 (ESG)
##################################
resource "aci_endpoint_security_group" "this" {
  for_each = { for esg in local.esgs : esg._key => esg }

  application_profile_dn = aci_application_profile.this[each.value._ap_key].id
  name                   = each.value.name
  relation_fv_rs_scope   = aci_vrf.this[each.value._vrf_key].id
  pc_enf_pref            = each.value.intra_esg_isolation ? "enforced" : "unenforced"
  relation_fv_rs_intra_epg = [
    for contract in try(each.value.contracts.intra_esgs, []) :
    "uni/tn-${contract.tenant}/brc-${contract.name}"
  ]
}

resource "aci_endpoint_security_group_epg_selector" "this" {
  for_each = { for selector in local.esg_epg_selectors : selector._key => selector }

  endpoint_security_group_dn = aci_endpoint_security_group.this[each.value._esg_key].id
  match_epg_dn               = aci_application_epg.esg_matched[each.value._epg_key].id
}

resource "aci_endpoint_security_group_selector" "this" {
  for_each = { for selector in local.esg_ip_subnet_selectors : selector._key => selector }

  endpoint_security_group_dn = aci_endpoint_security_group.this[each.value._esg_key].id
  description                = each.value.description
  match_expression           = "ip=='${each.value.ip}'"
}

resource "aci_endpoint_security_group_tag_selector" "this" {
  for_each = { for selector in local.esg_tag_selectors : selector._key => selector }

  endpoint_security_group_dn = aci_endpoint_security_group.this[each.value._esg_key].id
  match_key                  = each.value.match_key
  match_value                = each.value.match_value
  value_operator             = each.value.match_operator
}
##################################
# Security 2 (Policy Tag for ESG)
##################################
resource "aci_rest_managed" "fvEpMacTag" {
  for_each = { for mac in local.esg_mac_endpoints : mac._key => mac }

  dn         = "uni/tn-${aci_tenant.this[each.value._tenant].name}/eptags/epmactag-${each.value.address}-[${each.value.bridge_domain}]"
  class_name = "fvEpMacTag"
  content = {
    bdName = each.value.bridge_domain
    mac    = each.value.address
  }
}

resource "aci_tag" "mac" {
  for_each = { for tag in local.esg_mac_policy_tags : tag._key => tag }

  parent_dn = aci_rest_managed.fvEpMacTag[each.value._ep_key].id
  key       = each.value.key
  value     = each.value.value
}

resource "aci_rest_managed" "fvEpIpTag" {
  for_each = { for ip in local.esg_ip_endpoints : ip._key => ip }

  dn         = "uni/tn-${aci_tenant.this[each.value._tenant].name}/eptags/epiptag-${each.value.address}-[${each.value.vrf}]"
  class_name = "fvEpIpTag"
  content = {
    ctxName = each.value.vrf
    ip      = each.value.address
  }
}

resource "aci_tag" "ip" {
  for_each = { for tag in local.esg_ip_policy_tags : tag._key => tag }

  parent_dn = aci_rest_managed.fvEpIpTag[each.value._ep_key].id
  key       = each.value.key
  value     = each.value.value
}

##################################
# Network 1 (EPG i.e. VLAN)
##################################
resource "aci_application_epg" "esg_not_matched" {
  for_each = {
    for epg in local.epgs : epg._key => epg
    if !contains(local.esg_epg_selectors[*]._epg_key, epg._key)
  }

  application_profile_dn = aci_application_profile.this[each.value._ap_key].id
  name                   = each.value.name
  relation_fv_rs_bd      = aci_bridge_domain.this[each.value._bd_key].id
  pc_enf_pref            = each.value.intra_epg_isolation ? "enforced" : "unenforced"
  fwd_ctrl               = each.value.proxy_arp ? "proxy-arp" : "none"
}

# no security config when an EPG is matched to an ESG
resource "aci_application_epg" "esg_matched" {
  for_each = {
    for epg in local.epgs : epg._key => epg
    if contains(local.esg_epg_selectors[*]._epg_key, epg._key)
  }

  application_profile_dn = aci_application_profile.this[each.value._ap_key].id
  name                   = each.value.name
  relation_fv_rs_bd      = aci_bridge_domain.this[each.value._bd_key].id
  fwd_ctrl               = each.value.proxy_arp ? "proxy-arp" : "none"
}

resource "aci_epg_to_domain" "vmm" {
  for_each = { for dom in local.epg_to_domains_vmm : dom._key => dom }

  application_epg_dn = try(
    aci_application_epg.esg_not_matched[each.value._epg_key].id,
    aci_application_epg.esg_matched[each.value._epg_key].id
  )
  tdn             = "uni/vmmp-VMware/dom-${each.value.name}"
  allow_micro_seg = each.value.u_segmentation ? "true" : "false"
  res_imedcy      = each.value.resolution_immediacy
  instr_imedcy    = each.value.deployment_immediacy
}

resource "aci_epg_to_domain" "phys" {
  for_each = { for dom in local.epg_to_domains_phys : dom._key => dom }

  application_epg_dn = try(
    aci_application_epg.esg_not_matched[each.value._epg_key].id,
    aci_application_epg.esg_matched[each.value._epg_key].id
  )
  tdn = "uni/phys-${each.value.name}"
}

resource "aci_bulk_epg_to_static_path" "this" {
  for_each = { for epg in local.epgs : epg._key => epg if length(epg.static_ports) > 0 }

  application_epg_dn = try(
    aci_application_epg.esg_not_matched[each.value._key].id,
    aci_application_epg.esg_matched[each.value._key].id
  )

  dynamic "static_path" {
    for_each = { for port in each.value.static_ports : join("/", [port.node_id, port.port_id]) => port }
    content {
      interface_dn         = "topology/pod-${static_path.value.pod_id}/paths-${static_path.value.node_id}/pathep-[eth1/${static_path.value.port_id}]"
      encap                = "vlan-${static_path.value.vlan_id}"
      primary_encap        = try("vlan-${static_path.value.primary_vlan_id}", "unknown")
      deployment_immediacy = static_path.value.deployment_immediacy
    }
  }
}
##################################
# Network 2 (VRF & BD)
##################################
resource "aci_vrf" "this" {
  for_each = { for vrf in local.vrfs : vrf._key => vrf }

  tenant_dn = aci_tenant.this[each.value._tenant].id
  name      = each.value.name
}

resource "aci_bridge_domain" "this" {
  for_each = { for bd in local.bds : bd._key => bd }

  tenant_dn          = aci_tenant.this[each.value._tenant].id
  name               = each.value.name
  relation_fv_rs_ctx = aci_vrf.this[each.value._vrf_key].id
}

resource "aci_subnet" "this" {
  for_each = { for subnet in local.bd_subnets : subnet._key => subnet }

  parent_dn = aci_bridge_domain.this[each.value._bd_key].id
  ip        = each.value.ip
  scope     = each.value.scope
}
