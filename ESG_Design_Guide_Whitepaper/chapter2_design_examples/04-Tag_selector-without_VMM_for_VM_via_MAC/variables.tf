variable "apic_username" {
  type = string
}

variable "apic_password" {
  type      = string
  sensitive = true
}

variable "apic_url" {
  type = string
}

variable "vc_ip" {
  type = string
}

variable "vc_username" {
  type = string
}

variable "vc_password" {
  type      = string
  sensitive = true
}

variable "vc_datacenter" {
  type = string
}
