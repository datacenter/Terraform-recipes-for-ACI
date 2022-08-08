#############################################################################
#  OSPF on two border leaf switches with a vPC and SVI                      #
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

# Configure the L3out for OSPF
resource "aci_l3out_ospf_external_policy" "l3out_ospf" {
  l3_outside_dn = aci_l3_outside.l3_outside.id
  area_cost     = var.l3out_settings.ospf_area_cost
  area_id       = var.l3out_settings.ospf_area_id
  area_type     = var.l3out_settings.ospf_area_type
}

resource "aci_logical_node_to_fabric_node" "node_a" {
  logical_node_profile_dn = aci_logical_node_profile.logical_node_profile.id
  tdn                     = "topology/pod-${var.node_a.pod_id}/node-${var.node_a.node_id}"
  rtr_id                  = var.node_a.router_id
  rtr_id_loop_back        = var.node_a.router_id_as_loopback
}

resource "aci_logical_node_to_fabric_node" "node_b" {
  logical_node_profile_dn = aci_logical_node_profile.logical_node_profile.id
  tdn                     = "topology/pod-${var.node_b.pod_id}/node-${var.node_b.node_id}"
  rtr_id                  = var.node_b.router_id
  rtr_id_loop_back        = var.node_b.router_id_as_loopback
}

# Create L3Out Logical Interface Profile
resource "aci_l3out_ospf_interface_profile" "logical_interface" {
  logical_interface_profile_dn = aci_logical_interface_profile.logical_interface_profile.id
  auth_key                     = "1"
  relation_ospf_rs_if_pol      = aci_ospf_interface_policy.bcast.id
}

resource "aci_l3out_path_attachment" "l3out_path_attach" {
  logical_interface_profile_dn = aci_logical_interface_profile.logical_interface_profile.id
  target_dn                    = "topology/pod-${var.interface.pod_id}/protpaths-${var.interface.node_id}/pathep-[${var.interface.if_path}]"
  if_inst_t                    = var.interface.if_type
  encap                        = var.interface.encap
  mtu                          = var.interface.mtu
}

resource "aci_l3out_vpc_member" "l3_path_attach_a" {
  leaf_port_dn = aci_l3out_path_attachment.l3out_path_attach.id
  side         = "A"
  addr         = var.interface.side_a
}

resource "aci_l3out_vpc_member" "l3_path_attach_b" {
  leaf_port_dn = aci_l3out_path_attachment.l3out_path_attach.id
  side         = "B"
  addr         = var.interface.side_b
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

# Create the OSPF interface policy for P2P
resource "aci_ospf_interface_policy" "bcast" {
  tenant_dn = data.aci_tenant.tenant.id
  name      = var.ospf_int_policies.name
  nw_t      = var.ospf_int_policies.network_type
}