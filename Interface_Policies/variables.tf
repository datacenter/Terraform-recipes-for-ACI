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

# Leafs
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

# Interfaces
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

# Leaf Access Port Policy Groups
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

# Leaf VPC Port Policy Groups
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


# Link level policies
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

# LLDP policies
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

# CDP policies
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

# MCP policies
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

# LACP policies
variable "lacp" {
  default = {
    lacp_active = {
      min_links = "1"
      max_links = "16"
      mode      = "active"
    }
  }
}

# VLAN Pools
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

# Domains
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

# Attachable Entity Profiles (AAEPs)
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