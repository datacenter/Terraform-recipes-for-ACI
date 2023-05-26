# Example 6: Tag selectors for bare metal endpoints using the MAC address

This is a terraform plan example for [Example 6: Tag selectors for bare metal endpoints using the MAC address](https://www.cisco.com/c/en/us/td/docs/dcn/whitepapers/cisco-aci-esg-design-guide.html#Example6TagselectorsforbaremetalendpointsusingtheMACaddress)

# Usage

1. Create `apic.auto.tfvars` and provide APIC IP and credentials in it. See `apic.auto.tfvars.example` for an example.

2. Run terraform.
```bash
terraform apply
```

# See Also
* [APIC Security Configuration Guide - About Tag Selectors](https://www.cisco.com/c/en/us/td/docs/dcn/aci/apic/6x/security-configuration/cisco-apic-security-configuration-guide-60x/endpoint-security-groups-60x.html#Cisco_Concept.dita_4865832c-c812-4ca3-885e-640e2ebc7dcf)
* [APIC Security Configuration Guide - Creating a Tag Selector](https://www.cisco.com/c/en/us/td/docs/dcn/aci/apic/6x/security-configuration/cisco-apic-security-configuration-guide-60x/endpoint-security-groups-60x.html#Cisco_Task_in_List_GUI.dita_cd9a3336-4bb7-48d7-8220-d0beace26d0c)
* [APIC Security Configuration Guide - Creating an Endpoint MAC Tag](https://www.cisco.com/c/en/us/td/docs/dcn/aci/apic/6x/security-configuration/cisco-apic-security-configuration-guide-60x/endpoint-security-groups-60x.html#Cisco_Task_in_List_GUI.dita_c5653743-428d-41e5-a2a9-a79208051106)
