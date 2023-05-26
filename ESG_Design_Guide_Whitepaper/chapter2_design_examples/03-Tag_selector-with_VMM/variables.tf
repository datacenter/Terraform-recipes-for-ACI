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
