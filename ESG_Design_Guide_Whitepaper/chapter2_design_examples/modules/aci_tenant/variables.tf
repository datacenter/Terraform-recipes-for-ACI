variable "config" {
  type = object({
    tenants = list(object({
      name = string

      application_profiles = optional(list(object({
        name = string

        endpoint_groups = optional(list(object({
          name                = string
          bridge_domain       = string
          intra_epg_isolation = optional(bool, false)
          proxy_arp           = optional(bool, false)
          vmware_vmm_domains = optional(list(object({
            name                 = string
            u_segmentation       = optional(bool, false)
            deployment_immediacy = optional(string, "immediate")
            resolution_immediacy = optional(string, "immediate")
          })), [])
          physical_domains = optional(list(object({
            name                 = string
            deployment_immediacy = optional(string, "immediate")
            resolution_immediacy = optional(string, "immediate")
          })), [])
          static_ports = optional(list(object({
            pod_id               = number
            node_id              = number
            port_id              = number
            vlan_id              = number
            primary_vlan_id      = optional(number)
            deployment_immediacy = optional(string, "immediate")
          })), [])
        })), [])

        endpoint_security_groups = optional(list(object({
          name                = string
          vrf                 = string
          intra_esg_isolation = optional(bool, false)
          epg_selectors = optional(list(object({
            application_profile = string
            endpoint_group      = string
          })), [])
          tag_selectors = optional(list(object({
            match_key      = string
            match_value    = string
            match_operator = string
          })), [])
          ip_subnet_selectors = optional(list(object({
            description = optional(string)
            ip          = string
          })), [])
          contracts = optional(object({
            intra_esgs = optional(list(object({
              tenant = string
              name   = string
            })), [])
          }))
        })), [])

      })), [])

      vrfs = optional(list(object({
        name = string
      })), [])

      bridge_domains = optional(list(object({
        name = string
        vrf  = string
        subnets = optional(list(object({
          ip    = string
          scope = optional(list(string), ["private"])
        })), [])
      })), [])

      mac_endpoints = optional(list(object({
        bridge_domain = string
        address       = string
        policy_tags = optional(list(object({
          key   = string
          value = string
        })), [])
      })), [])

      ip_endpoints = optional(list(object({
        vrf     = string
        address = string
        policy_tags = optional(list(object({
          key   = string
          value = string
        })), [])
      })), [])

    }))
  })
}
