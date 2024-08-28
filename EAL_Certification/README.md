## Introduction
This Terraform plan accompanies the test setup used in 11.2.9: FDP_IFC.1, FDP_IFF.1 Information Flow Control, FMT_MSA.1 Secure Security Attributes, FMT_MSA.3 Static Attribute Initialization and FDP_RIP.2 Full Residual Information Protection.

## Configuration Overview
For configuration overview, refer to inventory information in the `*.nac.yaml` files in the `data` folder.

## Usage

1. Update TOE credentials in `terraform.tfvars`.
2. The initian tenant configuration is created by executing the following commands:
```
terraform init
terraform apply --auto-approve
```

3. When establishing communication between client and server, uncomment all commented sections in `/data/tn-eal-certification.nac.yaml`. This will create a contract between `client` and `server` networks, allowing communication to TCP port 5555.
4. Execute the following command:
```
terraform apply --auto-approve
```