## Usage
```
terraform init
terraform apply
```

## Configuration overview


```
L3Out
    + Node Profile
        + pod-1/node-101
            - router_id 1.1.1.1
        + pod-1/node-102
            - router_id 2.2.2.2

        + Interface Profile
            + pod-1/node-101/eth-1/11
                - sub-interface (VLAN 2051)
                - 10.1.0.1/30
                + BGP Peer
                    - 10.1.0.2
                    - remote AS 65003

            + pod-1/node-102/eth-1/11
                - sub-interface (VLAN 2051)
                - 10.1.0.5/30
                + BGP Peer
                    - 10.1.0.6
                    - remote AS 65003

    + External EPG 1
        + 0.0.0.0/0
            - External Subnets for the External EPG
        + Contracts
            - ICMP (provided)
```


## Topology

```
  AS XXXXX                         AS XXXXX
  Router ID: 1.1.1.1               Router ID: 2.2.2.2
  +----------+                     +----------+
  | node-101 |                     | node-102 |
  +----------+                     +----------+
       | e1/11.x                        | e1/11.x
       |   - 10.1.0.1/30                |   - 10.1.0.5/30
       |   - sub-interface              |   - sub-interface
       |   - vlan-2051                  |   - vlan-2051
       |   - mtu 1500                   |   - mtu 1500
       |                                |
       +--------------+   +-------------+
                      |   |
             10.1.0.2 |   | 10.1.0.6
                     (router)
                     AS 65003
                   172.16.1.0/24
                   172.16.2.0/24
                   192.168.1.0/24
```

Note: ACI BGP AS number (XXXXX) is what you configured in MP-BGP, which is not the scope of this plan.