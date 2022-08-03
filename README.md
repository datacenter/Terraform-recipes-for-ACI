# Terraform recipes for ACI
## _Simple yet powerful plans you can use_

This repo contains a series of Terraform plans you can use with [Cisco ACI](https://www.cisco.com/c/en/us/solutions/data-center-virtualization/application-centric-infrastructure/index.html).
The playbooks make use of [native ACI Terraform resources](https://registry.terraform.io/providers/CiscoDevNet/aci/latest/docs) as much as possible.
They are kept as simple as possible to make them easy to understand and reuse in your environment.
Example plans you can find here include:

- Complete configuration of interface, interface policies, VLAN pools, domains (WIP)
- Comprehensive multi-tier tenant configuration
- Configuration of common features such as NTP, DNS, BGP Route Reflector (WIP)
- etc. (WIP)

## _How to use this code_

Please check [here](https://learn.hashicorp.com/tutorials/terraform/install-cli) for installation instructions.
Inside each directory you'll find a `main.tf` that contains Terraform resources, and a variables.tf which can be modified to fit your needs.

## _Disclaimer and license_

All code found in this repo is provided as-is and subject to all terms and conditions of [the unlicense](https://unlicense.org/)