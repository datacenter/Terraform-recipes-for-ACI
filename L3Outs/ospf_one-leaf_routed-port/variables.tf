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

# Existing VRF that for the new L3out
data "aci_vrf" "vrf" {
  tenant_dn = data.aci_tenant.tenant.id
  name      = "default"
}

# Existing L3 Domain for the new L3Out
data "aci_l3_domain_profile" "l3out_dom" {
  name = "L3out"
}

# Existing contract to be provided from the new L3Out External EPG
data "aci_contract" "contract" {
  tenant_dn  = data.aci_tenant.tenant.id
  name       = "ICMP"
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
variable "node" {
  default = {
    pod_id                = "1"
    node_id               = "101"
    router_id             = "1.1.1.1"
    router_id_as_loopback = "no"
  }
}
variable "interface" {
  default = {
    pod_id  = "1"
    node_id = "101"
    if_path = "eth1/12"
    if_type = "l3-port" # l3-port|sub-interface|ext-svi
    addr    = "10.2.0.1/30"
    mtu     = "1500"
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
    name         = "p2p"
    network_type = "p2p" #p2p|bcast
  }
}