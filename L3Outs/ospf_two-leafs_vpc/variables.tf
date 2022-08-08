# APIC credentials and URL
variable "credentials" {
  type = map(string)
  default = {
    apic_username = "admin"
    apic_password = "password"
    apic_url      = "https://apic-url"
  }
  sensitive = true
}

# Existing tenant for the new L3out
data "aci_tenant" "tenant" {
  name = "common"
}

# Existing VRF for the new L3out
data "aci_vrf" "vrf" {
  tenant_dn = data.aci_tenant.tenant.id
  name      = "default"
}

# Existing L3 Domain for the new L3Out
data "aci_l3_domain_profile" "l3out_dom" {
  name = "l3out"
}

# Existing contract to be provided from the new L3Out External EPG
data "aci_contract" "icmp_contract" {
  tenant_dn = data.aci_tenant.tenant.id
  name      = "ICMP"
}

# Existing VPC to be used for the new L3Out
data "aci_leaf_access_bundle_policy_group" "vpc" {
  name = "your_vpc"
}

# Main L3out configuration parameters
variable "l3out_settings" {
  default = {
    name           = "OSPF"
    route_control  = ["export"]
    proto          = "ospf"
    ospf_area_id   = "0"
    ospf_area_type = "regular" # regular|nssa|stub
    ospf_area_cost = "1"
  }
}

# Node and interface parameters
variable "node_a" {
  default = {
    pod_id                = "1"
    node_id               = "101"
    router_id             = "1.1.1.1"
    router_id_as_loopback = "no"
  }
}
variable "node_b" {
  default = {
    pod_id                = "1"
    node_id               = "102"
    router_id             = "2.2.2.2"
    router_id_as_loopback = "no"
  }
}
variable "interface" {
  default = {
    pod_id  = "1"
    node_id = "101-102"
    if_type = "ext-svi" # l3-port|sub-interface|ext-svi
    if_mode = "regular" # regular(i.e. tagged)|untagged|native
    if_path = "VPC_to_external_N9K"
    side_a  = "10.2.0.1/24"
    side_b  = "10.2.0.2/24"
    mtu     = "1500"
    encap   = "vlan-2052"
  }
}
# External EPGs and contracts
variable "ext_epg1" {
  default = {
    name          = "EPG1"
    subnet        = "0.0.0.0/0"
    subnet_scope  = ["import-security"]
    contract_name = "ICMP"
    contract_type = "provider"
  }
}

variable "ospf_int_policies" {
  default = {
    name         = "bcast"
    network_type = "bcast" #p2p|bcast
  }
}