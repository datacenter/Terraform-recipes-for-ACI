## Usage
```
terraform init
terraform apply -y
```

## Configuration Overview

```
L3Out
    - OSPF Area: 0
    - OSPF Area Type: Regular

    + Node Profile
        + pod-1/node-101
            - router_id 1.1.1.1
        + pod-1/node-102
            - router_id 2.2.2.2

        + Interface Profile
            + pod-1/node-101-102/VPC1_IFPG
                - VLAN 2052
                - side A: 10.2.0.1/24
                - side B: 10.2.0.2/24

            + OSPF I/F Profile
                + OSPF Policy [bcast]
                    - network type: broadcast

    + External EPG 1
        + 172.16.1.0/24
            - External Subnets for the External EPG
        + 172.16.2.0/24
            - External Subnets for the External EPG
        + Contracts
            - ICMP (provided)
            - HTTP (consumed)

    + External EPG 2
        + 192.168.1.0/24
            - External Subnets for the External EPG
        + Contracts
            - ICMP (provided)
```
Note:
The following non-L3Out components are not created by this plan and need to be created separately.
* Access Policies (Interface profiles, Interface Policy Group and such)
* A L3Out Domain with an AEP and a VLAN pool
* Contracts

## Topology

```
  Router ID: 1.1.1.1               Router ID: 2.2.2.2
  +----------+                     +----------+
  | node-101 |                     | node-102 |
  +----------+                     +----------+
       | e1/2 (VPC1_IFPG)               | e1/2 (VPC1_IFPG)
       |   - 10.2.0.1/24                |   - 10.2.0.2/24
       |   - SVI                        |   - SVI
       |   - vlan-2052                  |   - vlan-2052
       |   - OSPF broadcast             |   - OSPF broadcast
       |   - mtu 1500                   |   - mtu 1500
       |                                |
       +---------------++---------------+
                       ||  <-- vPC
                       ||
                    (router)
                  172.16.1.0/24
                  172.16.2.0/24
                  192.168.1.0/24
```
