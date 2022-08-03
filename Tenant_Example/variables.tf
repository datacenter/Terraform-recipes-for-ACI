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

# Tenant that contains the shared L3out
data "aci_tenant" "common_tenant" {
  name = "common"
}

# VRF that contains the shared L3out
data "aci_vrf" "common_vrf" {
  tenant_dn = data.aci_tenant.common_tenant.id
  name      = "default"
}

# Name of the shared L3out
data "aci_l3_outside" "shared_l3_out" {
  tenant_dn = data.aci_tenant.common_tenant.id
  name      = "internet"
}

# Tenant
variable "tenant" {
  default = "demo"
}

# VRF
variable "vrf" {
  default = "demo.vrf1"
}

# Bridge domains and subnets (add a local for each BD as locals are used to iterate with a for_each loop in main.tf)
variable "bds" {
  default = {
    "192.168.100.0_24" = {
      ip = "192.168.100.1/24"
    },
    "192.168.101.0_24" = {
      ip = "192.168.101.1/24"
    },
    "192.168.102.0_24" = {
      ip = "192.168.102.1/24"
    }
  }
}
locals {
  bd_mapping = {
    "192.168.100.0_24" = var.bds["192.168.100.0_24"]
    "192.168.101.0_24" = var.bds["192.168.101.0_24"]
    "192.168.102.0_24" = var.bds["192.168.102.0_24"]
  }
}

# Application Profile
variable "ap" {
  default = "vlans"
}

# Endpoint Groups (add a local for each EPG as locals are used to iterate with a for_each loop in main.tf)
# Modifying the value of external_access will automatically advertise the BD subnet via the shared L3out
variable "epgs" {
  default = {
    vlan100 = {
      description     = "epg for 192.168.100.0_24"
      ap              = "vlans"
      bd              = "192.168.100.0_24"
      domain          = "phys"
      domain_type     = "phys"
      external_access = true
    },
    vlan101 = {
      description     = "epg for 192.168.101.0_24"
      ap              = "vlans"
      bd              = "192.168.101.0_24"
      domain          = "phys"
      domain_type     = "phys"
      external_access = false
    },
    vlan102 = {
      description     = "epg for 192.168.102.0_24"
      ap              = "vlans"
      bd              = "192.168.102.0_24"
      domain          = "phys"
      domain_type     = "phys"
      external_access = false
    }
  }
}
locals {
  epg_mapping = {
    vlan100 = var.epgs.vlan100
    vlan101 = var.epgs.vlan101
    vlan102 = var.epgs.vlan102
  }
}

# Filters (add a local for each filter as locals are used to iterate with a for_each loop in main.tf)
variable "filters" {
  default = {
    tcp_src_any_to_dst_3306 = {
      destination_from_port = "3306"
      destination_to_port   = "3306"
      protocol              = "tcp"
      ether_type            = "ipv4"
    },
    tcp_src_any_to_dst_8080 = {
      destination_from_port = "8080"
      destination_to_port   = "8080"
      protocol              = "tcp"
      ether_type            = "ipv4"
    },
    tcp_src_any_to_dst_6379 = {
      destination_from_port = "6379"
      destination_to_port   = "6379"
      protocol              = "tcp"
      ether_type            = "ipv4"
    },
    icmp_src_any_to_dst_0 = {
      destination_from_port = "0"
      destination_to_port   = "0"
      protocol              = "icmp"
      ether_type            = "ipv4"
    }
  }
}
locals {
  filter_mapping = {
    tcp_src_any_to_dst_3306 = var.filters.tcp_src_any_to_dst_3306
    tcp_src_any_to_dst_8080 = var.filters.tcp_src_any_to_dst_8080
    tcp_src_any_to_dst_6379 = var.filters.tcp_src_any_to_dst_6379
    icmp_src_any_to_dst_0   = var.filters.icmp_src_any_to_dst_0
  }
}

# Contracts (add a local for each item as locals are used to iterate with a for_each loop in main.tf)
variable "contracts" {
  default = {
    web_app = {
      subject = "subject1"
      filter  = ["tcp_src_any_to_dst_8080", "icmp_src_any_to_dst_0"]
    },
    cache = {
      subject = "subject1"
      filter  = ["tcp_src_any_to_dst_6379", "icmp_src_any_to_dst_0"]
    },
    sql = {
      subject = "subject1"
      filter  = ["tcp_src_any_to_dst_3306", "icmp_src_any_to_dst_0"]
    }
  }
}
locals {
  contract_mapping = {
    web_app = var.contracts.web_app
    cache   = var.contracts.cache
    sql     = var.contracts.sql
  }
}

# Contract relations to EPGs (add a local for each item as locals are used to iterate with a for_each loop in main.tf)
variable "contract_to_epgs" {
  default = {
    web_app = {
      consumer = ""
      provider = "vlan100"
    },
    sql = {
      consumer = "vlan100"
      provider = "vlan101"
    }
    cache = {
      consumer = "vlan101"
      provider = "vlan102"
    }
  }
}
locals {
  contract_to_epg_mapping = {
    web_app = var.contract_to_epgs.web_app
    sql     = var.contract_to_epgs.sql
    cache   = var.contract_to_epgs.cache
  }
}

# Static Path bindings (add a local for each Static Path binding as locals are used to iterate with a for_each loop in main.tf)
variable "static_paths" {
  default = {
    vlan100_to_leaf_101_1_12 = {
      epg    = "vlan100"
      encap  = "100"
      iftype = "switchport"
      ifmode = "regular"
      pod    = "1"
      leaf   = "101"
      if     = "1/12"
    },
    vlan101_to_leafs_101_102_test_vpc = {
      epg    = "vlan101"
      encap  = "101"
      iftype = "vpc"
      ifmode = "regular"
      pod    = "1"
      leaf   = "101-102"
      if     = "test_vpc"
    }
  }
}
locals {
  static_path_mapping = {
    vlan100_to_leaf_101_1_12          = var.static_paths.vlan100_to_leaf_101_1_12
    vlan101_to_leafs_101_102_test_vpc = var.static_paths.vlan101_to_leafs_101_102_test_vpc
  }
}