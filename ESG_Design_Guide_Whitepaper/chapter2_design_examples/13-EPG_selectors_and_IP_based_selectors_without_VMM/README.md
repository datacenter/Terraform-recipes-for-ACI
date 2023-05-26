# Example 13: EPG Selectors and IP-based Selectors Without a VMM Domain

This is a terraform plan example for [Example 13: EPG Selectors and IP-based Selectors Without a VMM Domain](https://www.cisco.com/c/en/us/td/docs/dcn/whitepapers/cisco-aci-esg-design-guide.html#Example13EPGSelectorsandIPbasedSelectorsWithoutaVMMDomain)

# Usage

1. Create `apic.auto.tfvars` and provide APIC IP and credentials in it. See `apic.auto.tfvars.example` for an example.

2. Run terraform.
```bash
terraform apply
```

# See Also
* [APIC Security Configuration Guide - About EPG Selectors](https://www.cisco.com/c/en/us/td/docs/dcn/aci/apic/6x/security-configuration/cisco-apic-security-configuration-guide-60x/endpoint-security-groups-60x.html#Cisco_Concept.dita_dd517557-dd00-4f6d-8ad1-06d33bd54045)
* [APIC Security Configuration Guide - Creating an EPG Selector](https://www.cisco.com/c/en/us/td/docs/dcn/aci/apic/6x/security-configuration/cisco-apic-security-configuration-guide-60x/endpoint-security-groups-60x.html#Cisco_Task_in_List_GUI.dita_ecdc57cd-5d77-465e-914c-8d3d57d7f0d8)
* [APIC Security Configuration Guide - About Tag Selectors](https://www.cisco.com/c/en/us/td/docs/dcn/aci/apic/6x/security-configuration/cisco-apic-security-configuration-guide-60x/endpoint-security-groups-60x.html#Cisco_Concept.dita_4865832c-c812-4ca3-885e-640e2ebc7dcf)
* [APIC Security Configuration Guide - Creating a Tag Selector](https://www.cisco.com/c/en/us/td/docs/dcn/aci/apic/6x/security-configuration/cisco-apic-security-configuration-guide-60x/endpoint-security-groups-60x.html#Cisco_Task_in_List_GUI.dita_cd9a3336-4bb7-48d7-8220-d0beace26d0c)
* [APIC Security Configuration Guide - Creating an Endpoint IP Tag](https://www.cisco.com/c/en/us/td/docs/dcn/aci/apic/6x/security-configuration/cisco-apic-security-configuration-guide-60x/endpoint-security-groups-60x.html#Cisco_Task_in_List_GUI.dita_e7c73256-20a1-4047-8e81-0222b323ad5f)
* [APIC Security Configuration Guide - ESG Migration Strategy](https://www.cisco.com/c/en/us/td/docs/dcn/aci/apic/6x/security-configuration/cisco-apic-security-configuration-guide-60x/endpoint-security-groups-60x.html#Cisco_Concept.dita_e77dba3c-1ca7-4d70-989d-e33b7c19467f)
