provider "vsphere" {
  vsphere_server       = var.vc_ip
  user                 = var.vc_username
  password             = var.vc_password
  allow_unverified_ssl = true
}

data "vsphere_datacenter" "this" {
  name = var.vc_datacenter
}

resource "vsphere_distributed_virtual_switch" "non_aci_vmm" {
  name          = "NonACIVMM"
  datacenter_id = data.vsphere_datacenter.this.id

  pvlan_mapping {
    primary_vlan_id   = 11
    secondary_vlan_id = 11
    pvlan_type        = "promiscuous"
  }
  pvlan_mapping {
    primary_vlan_id   = 11
    secondary_vlan_id = 10
    pvlan_type        = "isolated"
  }
  pvlan_mapping {
    primary_vlan_id   = 21
    secondary_vlan_id = 21
    pvlan_type        = "promiscuous"
  }
  pvlan_mapping {
    primary_vlan_id   = 21
    secondary_vlan_id = 20
    pvlan_type        = "isolated"
  }
  pvlan_mapping {
    primary_vlan_id   = 31
    secondary_vlan_id = 31
    pvlan_type        = "promiscuous"
  }
  pvlan_mapping {
    primary_vlan_id   = 31
    secondary_vlan_id = 30
    pvlan_type        = "isolated"
  }
}

resource "vsphere_distributed_port_group" "this" {
  for_each = toset(["10", "20", "30"])

  name                            = "VLAN${each.key}_${tonumber(each.key) + 1}"
  distributed_virtual_switch_uuid = vsphere_distributed_virtual_switch.non_aci_vmm.id

  port_private_secondary_vlan_id = each.key
}
