# Example 4: Tag selectors without VMM integration for VM endpoints using the MAC address

This is a terraform plan example for [Example 4: Tag selectors without VMM integration for VM endpoints using the MAC address](https://www.cisco.com/c/en/us/td/docs/dcn/whitepapers/cisco-aci-esg-design-guide.html#Example4TagselectorswithoutVMMintegrationforVMendpointsusingtheMACaddress)

In addition to the ACI ESG configuration in `main.tf`, this example has `vmware_dvs.tf` to show the PVLAN (Private VLAN) requirement on a VMware vDS without ACI VMM integration.

> **Note**
> The configuration in `vmware_dvs.tf` is bare minimum to show only the PVLAN. Attach an ESXi host and uplinks to the vDS as well.


# Usage

1. Create `apic.auto.tfvars` and provide APIC IP, credentials and vCenter IP, credentials and datacenter for vDS in it. See `apic.auto.tfvars.example` for an example.

2. Run terraform.
```bash
terraform apply
```

# See Also
* [APIC Security Configuration Guide - About Tag Selectors](https://www.cisco.com/c/en/us/td/docs/dcn/aci/apic/6x/security-configuration/cisco-apic-security-configuration-guide-60x/endpoint-security-groups-60x.html#Cisco_Concept.dita_4865832c-c812-4ca3-885e-640e2ebc7dcf)
* [APIC Security Configuration Guide - Creating a Tag Selector](https://www.cisco.com/c/en/us/td/docs/dcn/aci/apic/6x/security-configuration/cisco-apic-security-configuration-guide-60x/endpoint-security-groups-60x.html#Cisco_Task_in_List_GUI.dita_cd9a3336-4bb7-48d7-8220-d0beace26d0c)
* [APIC Security Configuration Guide - Creating an Endpoint MAC Tag](https://www.cisco.com/c/en/us/td/docs/dcn/aci/apic/6x/security-configuration/cisco-apic-security-configuration-guide-60x/endpoint-security-groups-60x.html#Cisco_Task_in_List_GUI.dita_c5653743-428d-41e5-a2a9-a79208051106)
