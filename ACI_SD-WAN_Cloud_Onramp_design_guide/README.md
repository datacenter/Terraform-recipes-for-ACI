## Introduction
This Terraform plan accompanies the Cisco ACI to SD-WAN Cloud OnRamp design guide. A link to this document is available here: [WIP](https://cisco.com).
All code required to build the ACI configuration is available in this repository.
This Terraform plan makes use of the open-source Nexus-as-Code Terraform module for ACI. For more information visit: [DevNet Nexus-as-Code](https://developer.cisco.com/docs/nexus-as-code/)

## Configuration Overview
For configuration overview, refer to inventory information in the `*.nac.yaml` files in the `data` folder.

## Usage
```
terraform init
terraform apply
```

Note:
This Terraform plan assumes that node 101 and 102 are registered as ACI leaf switches. The plan makes use of the traditional access policy configuration to ensure backwards compatibility. Should you want to make use of the new interface configuration wizard, modify `data/access-policies.nac.yaml` accordingly. An example has been commented.

Disclaimer: This Terraform plan provisions 250+ resources. Please refer to the scaling and state information at [Nexus-as-Code Scaling](https://developer.cisco.com/docs/nexus-as-code/scaling/) and [Terraform State](https://developer.hashicorp.com/terraform/language/state).