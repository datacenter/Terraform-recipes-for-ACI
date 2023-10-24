#############################################################################
# This example Terraform plan maps IPs to their respective                  #  
# Application Profiles and Endpoint Security Groups based on the            #
# provided tag.                                                             #            
#                                                                           #
# Assumptions:                                                              #           
# - vzAny contract already in place and provided by the target VRF.         #
# - No overlapping IP addresses                                             #  
# - One tenant, single VRF                                                  #  
#                                                                           #
# Tailor as you see fit.                                                    #
#############################################################################

# Provider block
terraform {
  required_providers {
    aci = {
      source = "CiscoDevNet/aci"
    }
  }
}

provider "aci" {
  username = var.credentials.apic_username
  password = var.credentials.apic_password
  url      = var.credentials.apic_url
}

# Reading provided tenant, endpoints, vrf and permit-any contract
data "aci_tenant" "tenant" {
  name = var.tenant
}
data "aci_client_end_point" "check" {
  for_each = var.ips
  ip       = each.key
}
data "aci_vrf" "vrf" {
  tenant_dn = data.aci_tenant.tenant.id
  name      = var.vrf
}
data "aci_contract" "permit-any" {
  tenant_dn = data.aci_tenant.tenant.id
  name      = var.permit-any-contract
}

# Create Application Profile for each application tag
resource "aci_application_profile" "aps" {
  for_each  = toset(var.app_profiles)
  tenant_dn = data.aci_tenant.tenant.id
  name      = each.key
}

# Create an Endpoint Security Group (ESG) for each application profile
resource "aci_endpoint_security_group" "esgs" {
  for_each               = aci_application_profile.aps
  application_profile_dn = each.value.id
  name                   = var.esg
  relation_fv_rs_scope   = data.aci_vrf.vrf.id
  relation_fv_rs_prov {
    target_dn = data.aci_contract.permit-any.id
  }
}

# Create an Endpoint MAC policy for MAC address[0] associated with provided var.ips
resource "aci_rest_managed" "fvEpMacTags" {
  for_each   = data.aci_client_end_point.check
  dn         = "uni/tn-${var.tenant}/eptags/epmactag-${each.value.fvcep_objects[0].mac}-[*]"
  class_name = "fvEpMacTag"
  content = {
    annotation = "orchestrator:terraform"
    mac        = each.value.fvcep_objects[0].mac
    ctxName    = var.vrf
    status     = "created, modified"
  }
  child {
    class_name = "tagTag"
    rn         = "tagKey-ApplicationName"
    content = {
      key   = "ApplicationName"
      value = var.ips[each.key].app
    }
  }
} 

# Create an Endpoint Security Group Tag Selector for each provided application tag
resource "aci_endpoint_security_group_tag_selector" "tags" {
  depends_on                 = [aci_endpoint_security_group.esgs]
  for_each                   = aci_application_profile.aps
  endpoint_security_group_dn = "${each.value.id}/esg-${var.esg}"
  match_key                  = "ApplicationName"
  match_value                = each.value.name
  value_operator             = "equals"
}