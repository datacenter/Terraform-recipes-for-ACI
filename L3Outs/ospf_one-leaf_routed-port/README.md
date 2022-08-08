## Usage
```
terraform init
terraform apply -y
```


## Configuration overview

```
L3Out
    - OSPF Area: 0
    - OSPF Area Type: Regular

    + Node Profile
        + pod-1/node-101
            - router_id 1.1.1.1

        + Interface Profile
            + pod-1/node-101/eth-1/12
                - 10.2.0.1/30

            + OSPF I/F Profile
                + OSPF Policy [p2p]
                    - network type: point-to-point

    + External EPG 1
        + 0.0.0.0/0
            - External Subnets for the External EPG
        + Contracts
            - ICMP (provided)
```
Note:
The following non-L3Out components are not created by this
playbook and need to be created separately.
* Access Policies (Interface profiles, Interface Policy Group and such)
* A L3Out Domain with an AEP and a VLAN pool
* Contracts


## Topology

```
  Router ID: 1.1.1.1
  +----------+
  | node-101 |
  +----------+
       | e1/12
       |   - 10.2.0.1/30
       |   - routed port
       |   - OSPF point-to-point
       |   - mtu 1500
       |
   (router)
  172.16.1.0/24
```
