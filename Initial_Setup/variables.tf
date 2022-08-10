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

variable "apic_conn_pref" {
  default = {
    apic_conn_pref = "ooband"
  }
}

variable "system_alias_banner" {
  default = {
    alias         = "terraform-demo"
    apic_banner   = "Welcome to this Terraform-automated fabric"
    switch_banner = "You are logging into a switch that belongs to a Terraform-automated ACI fabric"
  }
}

variable "system_response_time" {
  default = {
    state             = "enabled"
    resp_threshold    = "85000"
    frequency         = "300"
    top_slow_requests = "5"
  }
}

variable "global_aes_encryption" {
  default = {
    passphrase                = "Cisco123456789ABCDEF"
    strong_encryption_enabled = "no"
  }
}

variable "control_plane_mtu" {
  default = {
    control_plane_mtu = "9000"
  }
}

variable "endpoint_controls" {
  default = {
    ep_loop_protection = {
      state  = "enabled"
      action = ["port-disable"]
    },
    rogue_ep_control = {
      state                 = "enabled"
      detection_interval    = "30"
      multiplication_factor = "6"
      hold_interval         = "1800"
    }
    ip_aging = {
      state = "enabled"
    }
  }
}

variable "fabric_wide" {
  default = {
    disable_remote_ep_learn     = "yes"
    enforce_subnet_check        = "yes"
    enforce_epg_vlan_validation = "yes"
    enforce_domain_validation   = "yes"
    enable_remote_leaf_direct   = "yes"
    opflex_client_auth          = "no"
    reallocate_gipo             = "yes"
  }
}

variable "port_tracking" {
  default = {
    state = "on"
    delay = "120"
    links = "0"
  }
}

variable "system_gipo" {
  default = {
    use_system_gipo = "enabled"
  }
}

####

variable "date_time" {
  default = {
    format   = "local"
    timezone = "p120_Europe-Amsterdam"
    offset   = "enabled"
  }
}

variable "coop_group_policy" {
  default = {
    mode = "strict"
  }
}

variable "load_balancer" {
  default = {
    dlb     = "off"
    dpp     = "on"
    lb_mode = "traditional"
    gtp     = "no"
  }
}

variable "ptp" {
  default = {
    state      = "enabled"
    resolution = "0"
  }
}

variable "pod_policies" {
  default = {
    date_time = {
      name         = "default"
      admin_state  = "enabled"
      server_state = "disabled"
      auth_state   = "disabled"
      ntp = {
        name        = "173.38.201.67"
        description = "NTP Pool"
        preferred   = "yes"
        min_poll    = "4"
        max_poll    = "6"
        mgmt_epg    = "oob-default"
      }
    }
    snmp = {
      name  = "default"
      state = "enabled"
      community = {
        name = "public"
      }
      client_group = {
        name     = "snmp_client-Terraform"
        mgmt_epg = "oob-default"
        client = {
          ip   = "10.61.124.13"
          name = "snmpManager"
        }
      }
    }
  }
}

variable "management_access" {
  default = {
    name = "default"
    telnet = {
      state = "disabled"
      port  = "23"
    }
    ssh = {
      state         = "enabled"
      password_auth = "enabled"
      port          = "22"
      ciphers       = ["aes128-ctr", "aes192-ctr", "aes256-ctr"]
      macs          = ["hmac-sha1", "hmac-sha2-256"]
    }
    ssh_web = {
      state = "disabled"
    }
    http = {
      state             = "disabled"
      port              = "80"
      redirect          = "disabled"
      allow_origins     = "http://127.0.0.0:8000"
      allow_credentials = "disabled"
      throttle          = "disabled"
    }
    https = {
      state             = "enabled"
      port              = "443"
      allow_origins     = "http://127.0.0.0:8000"
      allow_credentials = "disabled"
      ssl_protocols     = ["TLSv1.2"]
      dh_param          = "none"
      throttle          = "disabled"
      keyring           = "default"
    }
    ssl_ciphers = {
      "3DES"                    = { state = "disabled" }
      "aNULL"                   = { state = "disabled" }
      "DHE-RSA-AES128-SHA"      = { state = "disabled" }
      "DHE-RSA-AES256-SHA"      = { state = "disabled" }
      "DHE-RSA-CAMELLIA128-SHA" = { state = "disabled" }
      "DHE-RSA-CAMELLIA256-SHA" = { state = "disabled" }
      "DHE-RSA-SEED-SHA"        = { state = "disabled" }
      "DSS"                     = { state = "disabled" }
      "ECDSA"                   = { state = "disabled" }
      "EDH+aRSA"                = { state = "enabled" }
      "EECDH"                   = { state = "enabled" }
      "EECDH+aRSA+AESGCM"       = { state = "enabled" }
      "EECDH+aRSA+SHA256"       = { state = "enabled" }
      "EECDH+aRSA+SHA384"       = { state = "enabled" }
      "eNULL"                   = { state = "disabled" }
      "EXP"                     = { state = "disabled" }
      "EXPORT"                  = { state = "disabled" }
      "LOW"                     = { state = "disabled" }
      "MD5"                     = { state = "disabled" }
      "PSK"                     = { state = "disabled" }
      "RC4"                     = { state = "disabled" }
      "SRP"                     = { state = "disabled" }
    }
  }
}

variable "isis" {
  default = {
    mtu           = "1492"
    metric        = "32"
    lsp_fastflood = "enabled"
    lsp_init      = "50"
    lsp_max       = "8000"
    lsp_sec       = "50"
    spf_init      = "50"
    spf_max       = "8000"
    spf_sec       = "50"
  }
}

variable "global_dns_policy" {
  default = {
    dns = {
      name       = "default"
      management = "oob-default"
      domain = {
        name    = "cisco.com"
        default = "yes"
      }
      provider = {
        addr      = "10.61.124.15"
        preferred = "yes"
      }
    }
  }
}

variable "pod_policy_group" {
  default = {
    name              = "default"
    date_time         = "default"
    isis              = "default"
    coop              = "default"
    bgp_rr            = "default"
    management_access = "default"
    snmp              = "default"
    macsec            = "default"
  }
}

variable "pod_profile" {
  default = {
    name = "default"
    selector = {
      name             = "default"
      type             = "ALL"
      pod_policy_group = "default"
    }
  }
}