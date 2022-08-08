# APIC credentials and URL
variable "credentials" {
  type = map(string)
  default = {
    apic_username = "admin"
    apic_password = "C!sco12345"
    apic_url      = "https://10.61.124.105"
  }
  sensitive = true
}

# Leafs  (add a local for each leaf as locals are used to iterate with a for_each loop in main.tf)
variable "leafs" {
  default = {
    "101" = {
      name = "leaf-101"
    },
    "102" = {
      name = "leaf-102"
    }
  }
}
locals {
  leafs_mapping = {
    "101" = var.leafs["101"]
    "102" = var.leafs["102"]
  }
}

# Interfaces (add a local for each interface as locals are used to iterate with a for_each loop in main.tf) and make sure to set the correct interface type (.iftype)
variable "interfaces" {
  default = {
    "leaf_101_eth_1_12" = {
      leaf   = "101"
      iftype = "switch_port"
      lfblk  = "1"
      from   = "12"
      end    = "12"
      polgrp = "K8s_master_001"
    },
    "leaf_101_eth_1_13" = {
      leaf   = "101"
      iftype = "switch_port"
      lfblk  = "1"
      from   = "13"
      end    = "13"
      polgrp = "bare_metal_001"
    },
    "leaf_101_eth_1_24" = {
      leaf   = "101"
      iftype = "vpc"
      lfblk  = "1"
      from   = "24"
      end    = "24"
      polgrp = "VPC_to_external_N9K"
    },
    "leaf_102_eth_1_12" = {
      leaf   = "102"
      iftype = "switch_port"
      lfblk  = "1"
      from   = "12"
      end    = "12"
      polgrp = "vmm_server_001"
    },
    "leaf_102_eth_1_13" = {
      leaf   = "102"
      iftype = "switch_port"
      lfblk  = "1"
      from   = "13"
      end    = "13"
      polgrp = "vmm_server_002"
    },
    "leaf_102_eth_1_24" = {
      leaf   = "102"
      iftype = "vpc"
      lfblk  = "1"
      from   = "24"
      end    = "24"
      polgrp = "VPC_to_external_N9K"
    }
  }
}
locals {
  interfaces_mapping = {
    "leaf_101_eth_1_12" = var.interfaces["leaf_101_eth_1_12"]
    "leaf_101_eth_1_13" = var.interfaces["leaf_101_eth_1_13"]
    "leaf_101_eth_1_24" = var.interfaces["leaf_101_eth_1_24"]
    "leaf_102_eth_1_12" = var.interfaces["leaf_102_eth_1_12"]
    "leaf_102_eth_1_13" = var.interfaces["leaf_102_eth_1_13"]
    "leaf_102_eth_1_24" = var.interfaces["leaf_102_eth_1_24"]
  }
}

# Leaf Access Port Policy Groups (add a local for each Policy Group as locals are used to iterate with a for_each loop in main.tf)
variable "leafs_appg" {
  default = {
    K8s_master_001 = {
      lldp = "lldp_enabled"
      aaep = "kubernetes_aaep"
      desc = "K8s master node 001"
    },
    bare_metal_001 = {
      lldp = "lldp_enabled"
      aaep = "bare_metal_aaep"
      desc = "Bare metal server 001"
    },
    vmm_server_001 = {
      lldp = "lldp_enabled"
      aaep = "vmm_one_aaep"
      desc = "VMM server 001"
    },
    vmm_server_002 = {
      lldp = "lldp_enabled"
      aaep = "vmm_two_aaep"
      desc = "VMM server 002"
    }
  }
}
locals {
  leafs_appg_mapping = {
    K8s_master_001 = var.leafs_appg["K8s_master_001"]
    bare_metal_001 = var.leafs_appg["bare_metal_001"]
    vmm_server_001 = var.leafs_appg["vmm_server_001"]
    vmm_server_002 = var.leafs_appg["vmm_server_002"]
  }
}

# Leaf VPC Port Policy Groups (add a local for each VPC Policy Group as locals are used to iterate with a for_each loop in main.tf)
variable "leafs_vppg" {
  default = {
    VPC_to_external_N9K = {
      lldp         = "lldp_enabled"
      channel_mode = "lacp_active"
      aaep         = "external_n9k_aaep"
      desc         = "External N9K VPC to legacy env"
    }
  }
}
locals {
  leafs_vppg_mapping = {
    VPC_to_external_N9K = var.leafs_vppg["VPC_to_external_N9K"]
  }
}

# Link level policies (add a local for each Link Level Policy as locals are used to iterate with a for_each loop in main.tf)
variable "intpols" {
  default = {
    link-100M = {
      desc         = "100Mbps"
      speed        = "100M"
      linkdebounce = "100"
      fec          = "inherit"
      autoneg      = "on"
    },
    link-1G = {
      desc         = "1Gbps"
      speed        = "1G"
      linkdebounce = "100"
      fec          = "inherit"
      autoneg      = "on"
    },
    link-10G = {
      desc         = "10Gbps"
      speed        = "10G"
      linkdebounce = "100"
      fec          = "inherit"
      autoneg      = "on"
    },
    link-25G = {
      desc         = "25Gbps - use with short-length passive cables"
      speed        = "25G"
      linkdebounce = "100"
      fec          = "inherit"
      autoneg      = "on"
    },
    link-25G-FEC-CL74-FC = {
      desc         = "25Gbps - use with 3-meter passive cable and 1 to 10-meter active cables"
      speed        = "25G"
      linkdebounce = "100"
      fec          = "cl74-fc-fec"
      autoneg      = "on"
    },
    link-25G-FEC-CL91-RC = {
      desc         = "25Gbps - use with 5-meter passive cable and 100-meter SPF-25G-SR or SPF-25G-LR"
      speed        = "25G"
      linkdebounce = "100"
      fec          = "cl91-rs-fec"
      autoneg      = "on"
    },
    link-40G = {
      desc         = "40Gbps"
      speed        = "40G"
      linkdebounce = "100"
      fec          = "inherit"
      autoneg      = "on"
    },
    link-100G = {
      desc         = "100Gbps"
      speed        = "100G"
      linkdebounce = "100"
      fec          = "inherit"
      autoneg      = "on"
    }
  }
}
locals {
  intpols_mapping = {
    link-100M            = var.intpols["link-100M"]
    link-1G              = var.intpols["link-1G"]
    link-10G             = var.intpols["link-10G"]
    link-25G             = var.intpols["link-25G"]
    link-25G-FEC-CL74-F  = var.intpols["link-25G-FEC-CL74-FC"]
    link-25G-FEC-CL91-RC = var.intpols["link-25G-FEC-CL91-RC"]
    link-40G             = var.intpols["link-40G"]
    link-100G            = var.intpols["link-100G"]
  }
}

# LLDP policies (add a local for each LLDP policy as locals are used to iterate with a for_each loop in main.tf)
variable "lldp" {
  default = {
    lldp_enabled = {
      desc     = "lldp TX and RX on"
      receive  = "enabled"
      transmit = "enabled"
    },
    lldp_disabled = {
      desc     = "lldp TX and RX off"
      receive  = "disabled"
      transmit = "disabled"
    }
  }
}
locals {
  lldp_mapping = {
    lldp_enabled  = var.lldp["lldp_enabled"]
    lldp_disabled = var.lldp["lldp_disabled"]
  }
}

# CDP policies (add a local for each CDP Policy as locals are used to iterate with a for_each loop in main.tf)
variable "cdp" {
  default = {
    cdp_enabled = {
      desc        = "cdp enabled"
      admin_state = "enabled"
    },
    cdp_disabled = {
      desc        = "cdp disabled"
      admin_state = "disabled"
    }
  }
}
locals {
  cdp_mapping = {
    cdp_enabled  = var.cdp["cdp_enabled"]
    cdp_disabled = var.cdp["cdp_disabled"]
  }
}

# MCP policies (add a local for each MCP Policy as locals are used to iterate with a for_each loop in main.tf)
variable "mcp" {
  default = {
    mcp_enabled = {
      desc        = "mcp enabled"
      admin_state = "enabled"
    },
    mcp_disabled = {
      desc        = "mcp disabled"
      admin_state = "disabled"
    }
  }
}
locals {
  mcp_mapping = {
    mcp_enabled  = var.mcp["mcp_enabled"]
    mcp_disabled = var.mcp["mcp_disabled"]
  }
}

# LACP policies (add a local for each LACP Policy as locals are used to iterate with a for_each loop in main.tf)
variable "lacp" {
  default = {
    lacp_active = {
      min_links = "1"
      max_links = "16"
      mode      = "active"
    }
  }
}
locals {
  lacp_mapping = {
    lacp_active = var.lacp["lacp_active"]
  }
}

# VLAN Pools (add a local for each VLAN Pool as locals are used to iterate with a for_each loop in main.tf)
variable "vlan_pools" {
  default = {
    bare_metal_pool = {
      desc       = "pool for bare-metal servers"
      allocation = "static"
      range1 = {
        start      = "100"
        end        = "109"
        allocation = "static"
      }
    },
    kubernetes_pool = {
      desc       = "pool for K8s nodes"
      allocation = "static"
      range1 = {
        start      = "120"
        end        = "139"
        allocation = "static"
      }
    },
    vmm_pool_one = {
      desc       = "pool one for hypervisors"
      allocation = "dynamic"
      range1 = {
        start      = "140"
        end        = "159"
        allocation = "dynamic"
      }
    },
    vmm_pool_two = {
      desc       = "pool two for hypervisors"
      allocation = "dynamic"
      range1 = {
        start      = "160"
        end        = "179"
        allocation = "dynamic"
      },
    }
    external_n9k_pool = {
      desc       = "external N9K pool"
      allocation = "dynamic"
      range1 = {
        start      = "180"
        end        = "199"
        allocation = "static"
      },
      range2 = {
        start      = "3000"
        end        = "3100"
        allocation = "static"
      }
    },
    internet_pool = {
      desc       = "internet_pool"
      allocation = "dynamic"
      range1 = {
        start      = "555"
        end        = "555"
        allocation = "static"
      }
    }
  }
}
locals {
  vlan_pools_mapping = {
    bare_metal_pool   = var.vlan_pools["bare_metal_pool"]
    kubernetes_pool   = var.vlan_pools["kubernetes_pool"]
    vmm_pool_one      = var.vlan_pools["vmm_pool_one"]
    vmm_pool_two      = var.vlan_pools["vmm_pool_two"]
    external_n9k_pool = var.vlan_pools["external_n9k_pool"]
    internet_pool     = var.vlan_pools["internet_pool"]
  }
}

# Domains (add a local for each Domain as locals are used to iterate with a for_each loop in main.tf)
variable "domains" {
  default = {
    bare_metal_domain = {
      type = "phys"
    },
    kubernetes_domain = {
      type = "phys"
    },
    external_n9k_domain = {
      type = "phys"
    },
    internet_domain = {
      type = "l3dom"
    },
    vmm_domain_one = {
      type = "vmware"
    },
    vmm_domain_two = {
      type = "vmware"
    }
  }
}
locals {
  domains_mapping = {
    bare_metal_domain   = var.domains["bare_metal_domain"]
    kubernetes_domain   = var.domains["kubernetes_domain"]
    external_n9k_domain = var.domains["external_n9k_domain"]
    internet_domain     = var.domains["internet_domain"]
    vmm_domain_one      = var.domains["vmm_domain_one"]
    vmm_domain_two      = var.domains["vmm_domain_two"]
  }
}

# Attachable Entity Profiles (AAEPs) (add a local for each AAEP as locals are used to iterate with a for_each loop in main.tf)
variable "aaeps" {
  default = {
    bare_metal_aaep = {
      domain = ["bare_metal_domain"]
      desc   = "non K8s bare-metal servers"
    },
    kubernetes_aaep = {
      domain = ["kubernetes_domain"]
      desc   = "K8s bare-metal servers"
    },
    external_n9k_aaep = {
      domain = ["external_n9k_domain"]
      desc   = "external N9k routers"
    },
    internet_aaep = {
      domain = ["internet_domain"]
      desc   = "external internet access"
    },
    vmm_one_aaep = {
      domain = ["vmm_domain_one"]
      desc   = "VMM domain one"
    },
    vmm_two_aaep = {
      domain = ["vmm_domain_two"]
      desc   = "VMM domain two"
    }
  }
}
locals {
  aaeps_mapping = {
    bare_metal_aaep   = var.aaeps["bare_metal_aaep"]
    kubernetes_aaep   = var.aaeps["kubernetes_aaep"]
    external_n9k_aaep = var.aaeps["external_n9k_aaep"]
    internet_aaep     = var.aaeps["internet_aaep"]
    vmm_one_aaep      = var.aaeps["vmm_one_aaep"]
    vmm_two_aaep      = var.aaeps["vmm_two_aaep"]
  }
}
