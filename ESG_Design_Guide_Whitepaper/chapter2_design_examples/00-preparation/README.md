# Preparation for Other Examples
This handles non-ESG specific configuration that is common to all examples such as interface profiles, VLAN pool, VMM domain, physical domain etc.

> **Note**
> An exception is "Enable Tag Collection" in a VMM domain, which is required for ESG to use VM tags or VM names with tag selectors.

# Usage

1. Create `apic.auto.tfvars` and provide APIC IP, credentials and VC IP, DC, credentials in it. See `apic.auto.tfvars.example` for an example.

2. Run terraform.
```bash
terraform apply
```
