# Example 2: A security zone per set of subnets/VLANs (EPG Selectors)

This is a terraform plan example for [Example 2: A security zone per set of subnets/VLANs (EPG Selectors)](https://www.cisco.com/c/en/us/td/docs/dcn/whitepapers/cisco-aci-esg-design-guide.html#Example2AsecurityzonepersetofsubnetsVLANsEPGSelectors)


# Usage

1. Create `apic.auto.tfvars` and provide APIC IP and credentials in it. See `apic.auto.tfvars.example` for an example.

2. Run terraform.
```bash
terraform apply
```

# See Also
* [APIC Security Configuration Guide - About EPG Selectors](https://www.cisco.com/c/en/us/td/docs/dcn/aci/apic/6x/security-configuration/cisco-apic-security-configuration-guide-60x/endpoint-security-groups-60x.html#Cisco_Concept.dita_dd517557-dd00-4f6d-8ad1-06d33bd54045)
* [APIC Security Configuration Guide - Creating an EPG Selector](https://www.cisco.com/c/en/us/td/docs/dcn/aci/apic/6x/security-configuration/cisco-apic-security-configuration-guide-60x/endpoint-security-groups-60x.html#Cisco_Task_in_List_GUI.dita_ecdc57cd-5d77-465e-914c-8d3d57d7f0d8)
* [APIC Security Configuration Guide - ESG Migration Strategy](https://www.cisco.com/c/en/us/td/docs/dcn/aci/apic/6x/security-configuration/cisco-apic-security-configuration-guide-60x/endpoint-security-groups-60x.html#Cisco_Concept.dita_e77dba3c-1ca7-4d70-989d-e33b7c19467f)
