# Introduction
These are terraform plans for each examples in [ESG Design Guide - ESG Design Examples](https://www.cisco.com/c/en/us/td/docs/dcn/whitepapers/cisco-aci-esg-design-guide.html#ESGDesignExamples).

The main goal of these examples are for readers of the design guide to see the actual configuration required for each example. Hence all ACI configuration related to ESG is stored in `config.yaml` in each example for readability.

This is taking a similar approach as [Nexus-as-code project](https://developer.cisco.com/docs/nexus-as-code/#!aci-introduction), but with a simple module focusing on tenant configuration via native [ACI terraform provider resources](https://registry.terraform.io/providers/CiscoDevNet/aci/latest/docs).

Each example consists of two main components:
* `config.yaml` - ACI tenant configuration
* `main.tf` - Terraform plan that reads `config.yaml` and deploys them via `modules.aci_tenant`.

```bash
├── 01-EPG_selector-security_zone_per_VRF
│   ├── apic.auto.tfvars.example
│   ├── config.yaml
│   ├── main.tf
│   ├── README.md
│   └── variables.tf
...
├── modules
│   └── aci_tenant
│       ├── main.tf
│       └── variables.tf
```

# Usage

1. (optional) Deploy `00-preparation` to configure interfaces, domains used across all examples.

2. Select an example to try such as `03-Tag_selector-with_VMM` and run terraform.

> **Note**
> All examples use the same interfaces, VLAN, etc. This means that you would need to `destroy` the plan that was deployed first prior to trying another example.
