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

# Name of tenant that contains your applications
variable "tenant" {
  default = "demo-non-vmm"
}

# Name of VRF containing IP addresses associated with your applications
variable "vrf" {
  default = "vrf-01"
}

# Name for each ESG
variable "esg" {
  default = "all-services"
}

# Name of EXISTING contract to provide any-any communication through vzAny
variable "permit-any-contract" {
  default = "permit-to-all-applications"
}

# Name for each application profile
variable "app_profiles" {
  default = ["secure13", "secure14"]
}

# Map of each IP address and their associated application tag.
variable "ips" {
  default = {
    "10.0.13.101" = {
      app = "secure13"
    },
    "10.0.14.100" = {
      app = "secure14"
    }
  }
}