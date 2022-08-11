#############################################################################
#  BGP on two border leaf switches with sub-interfaces                      #
#                                                                           #
# Note:                                                                     #
# The following non-L3out components are not created by this plan and need  #                                                                       #
# to be created separately.                                                 #
#   * Access Policies (Interface profiles, Interface Policy Group and such) #
#   * A L3Out Domain with an AEP and VLAN pool                              #
#   * Contracts                                                             #
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

# Create L3Out
resource "aci_l3_outside" "l3_outside" {
  tenant_dn                    = data.aci_tenant.tenant.id
  name                         = var.l3out_settings.name
  enforce_rtctrl               = var.l3out_settings.route_control
  relation_l3ext_rs_ectx       = data.aci_vrf.vrf.id
  relation_l3ext_rs_l3_dom_att = data.aci_l3_domain_profile.l3out_dom.id
}

# Create L3Out Node Profile
resource "aci_logical_node_profile" "logical_node_profile" {
  l3_outside_dn = aci_l3_outside.l3_outside.id
  name          = var.l3out_settings.name
}

# Create L3out Interface Profile
resource "aci_logical_interface_profile" "logical_interface_profile" {
  logical_node_profile_dn = aci_logical_node_profile.logical_node_profile.id
  name                    = "int_prof"
}

# Configure the L3out for BGP
resource "aci_l3out_bgp_external_policy" "l3out_bgp" {
  l3_outside_dn = aci_l3_outside.l3_outside.id
}

# Create L3out Nodes
resource "aci_logical_node_to_fabric_node" "l3out_nodes" {
  for_each                = var.nodes
  logical_node_profile_dn = aci_logical_node_profile.logical_node_profile.id
  tdn                     = "topology/pod-${each.value.pod_id}/node-${each.value.node_id}"
  rtr_id                  = each.value.router_id
  rtr_id_loop_back        = each.value.router_id_as_loopback
}

# Create L3Out subinterface configuration
resource "aci_l3out_path_attachment" "l3out_subints" {
  for_each                     = var.nodes
  logical_interface_profile_dn = aci_logical_interface_profile.logical_interface_profile.id
  target_dn                    = "topology/pod-${each.value.pod_id}/paths-${each.value.node_id}/pathep-[${each.value.if_path}]"
  if_inst_t                    = each.value.if_type
  addr                         = each.value.addr
  encap                        = each.value.encap
  mode                         = each.value.if_mode
  mtu                          = each.value.mtu
}

# Create L3out BGP peers configuration
resource "aci_bgp_peer_connectivity_profile" "l3out_bgp_peers" {
  for_each  = var.nodes
  parent_dn = aci_l3out_path_attachment.l3out_subints[each.key].id
  addr      = each.value.bgp_peers.peer_ip
  ttl       = each.value.bgp_peers.ttl
  as_number = each.value.bgp_peers.remote_asn
}

# Create L3out External EPG
resource "aci_external_network_instance_profile" "network_instance_profile" {
  l3_outside_dn       = aci_l3_outside.l3_outside.id
  name                = var.ext_epg1.name
  relation_fv_rs_prov = [data.aci_contract.icmp_contract.id]
}

# Create subnet under the L3Out External EPG
resource "aci_l3_ext_subnet" "ext_epg_subnet" {
  external_network_instance_profile_dn = aci_external_network_instance_profile.network_instance_profile.id
  ip                                   = var.ext_epg1.subnet
  scope                                = var.ext_epg1.subnet_scope
}