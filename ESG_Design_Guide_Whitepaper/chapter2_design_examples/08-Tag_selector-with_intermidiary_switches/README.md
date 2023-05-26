# Example 8: Tag selectors with intermediary switches

This is a terraform plan example for [Example 8: Tag selectors with intermediary switches](https://www.cisco.com/c/en/us/td/docs/dcn/whitepapers/cisco-aci-esg-design-guide.html#Example8Tagselectorswithintermediaryswitches)

> **Warning**
> Configuration of PVLAN in the intermediary switches are not covered in this plan as the intermediary switches can be any switches.

# Usage

1. Create `apic.auto.tfvars` and provide APIC IP and credentials in it. See `apic.auto.tfvars.example` for an example.

2. Run terraform.
```bash
terraform apply
```
