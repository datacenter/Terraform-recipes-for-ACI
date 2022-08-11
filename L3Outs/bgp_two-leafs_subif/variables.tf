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
  name = "internet"
}

# Existing contract to be provided from the new L3Out External EPG
data "aci_contract" "icmp_contract" {
  tenant_dn = data.aci_tenant.tenant.id
  name      = "ICMP"
}


# Main L3out configuration parameters
variable "l3out_settings" {
  default = {
    name          = "BGP"
    route_control = ["export"]
    proto         = "bgp"
  }
}

# Nodes and interface parameters
variable "nodes" {
  default = {
    101 = {
      pod_id                = "1"
      node_id               = "101"
      router_id             = "1.1.1.1"
      router_id_as_loopback = "no"
      if_path               = "eth1/11"
      if_type               = "sub-interface" # l3-port|sub-interface|ext-svi
      if_mode               = "regular"       # regular(i.e. tagged)|untagged|native
      encap                 = "vlan-2051"
      addr                  = "10.1.0.1/30"
      mtu                   = "1500"
      bgp_peers = {
        peer_ip    = "10.1.0.2"
        remote_asn = "65003"
        ttl        = "1"
      }
    },
    102 = {
      pod_id                = "1"
      node_id               = "102"
      router_id             = "2.2.2.2"
      router_id_as_loopback = "no"
      if_path               = "eth1/11"
      if_type               = "sub-interface" # l3-port|sub-interface|ext-svi
      if_mode               = "regular"       # regular(i.e. tagged)|untagged|native
      encap                 = "vlan-2051"
      addr                  = "10.1.0.5/30"
      mtu                   = "1500"
      bgp_peers = {
        peer_ip    = "10.1.0.6"
        remote_asn = "65003"
        ttl        = "1"
      }
    }
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