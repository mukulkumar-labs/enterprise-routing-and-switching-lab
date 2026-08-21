# enterprise-routing-and-switching-lab
Simulated enterprise network (Cisco Packet Tracer) demonstrating OSPF routing, VLAN segmentation, and router-on-a-stick inter-VLAN routing across a Head Office–Branch Office topology. Includes full configs, phase-wise verification screenshots, and a documented troubleshooting log.
# Enterprise Routing & Switching Lab

A simulated enterprise network built in Cisco Packet Tracer, demonstrating OSPF dynamic routing, VLAN segmentation, and inter-VLAN routing across a Head Office–Branch Office topology. This project is Project 1 of a Network Security Engineer portfolio track, focused on core routing/switching and network segmentation skills.

## Objective

Simulate a small enterprise network with a Head Office and a Branch Office, connected via a routed WAN link, with local network segmentation at the branch using VLANs. The goal was to demonstrate hands-on configuration, verification, and troubleshooting of enterprise routing and switching fundamentals.

## Topology

![Topology Diagram](screenshots/phase1_topology/02_topology_diagram.png)

- **Head Office Router** (Cisco 2911) — simulates the head office edge router
- **Branch Router** (Cisco 2911) — simulates the branch office router, handles inter-VLAN routing
- **Switch0** (Cisco 2960-24TT) — Layer 2 access switch at the branch, hosts two VLANs
- **PC0, PC1** — end devices, placed in separate VLANs to demonstrate segmentation

## IP Addressing Plan (VLSM)

| Network | Purpose | CIDR |
|---|---|---|
| 192.168.1.0/30 | Branch Router ↔ Head Office Router (WAN link) | /30 |
| 192.168.10.0/24 | VLAN 10 — Staff | /24 |
| 192.168.20.0/24 | VLAN 20 — Guest | /24 |

| Device | Interface | IP Address |
|---|---|---|
| Branch Router | GigabitEthernet0/0 | 192.168.1.1 |
| Branch Router | GigabitEthernet0/1.10 (VLAN 10) | 192.168.10.1 |
| Branch Router | GigabitEthernet0/1.20 (VLAN 20) | 192.168.20.1 |
| Head Office Router | GigabitEthernet0/0 | 192.168.1.2 |
| PC0 | FastEthernet0 (VLAN 10) | 192.168.10.10 |
| PC1 | FastEthernet0 (VLAN 20) | 192.168.20.10 |

## What Was Implemented

### 1. Physical Topology & Cabling
Connected Head Office Router, Branch Router, Switch0, and two end devices. Verified all links reached an "up/up" state before proceeding.

### 2. IP Addressing
Configured static IP addressing on all router interfaces and end devices per the VLSM plan above, and verified reachability with `show ip interface brief` and point-to-point pings.

### 3. OSPF Dynamic Routing
Configured single-area OSPF (Area 0) between the Branch Router and Head Office Router. Verified neighbor adjacency reached `FULL` state and confirmed the Head Office Router learned the branch's VLAN subnet via OSPF (`show ip route ospf`).

### 4. VLAN Segmentation & Inter-VLAN Routing
Created two VLANs on Switch0 (VLAN 10 – Staff, VLAN 20 – Guest), assigned access ports, configured a trunk link to the Branch Router, and implemented **router-on-a-stick** using sub-interfaces (`Gi0/1.10`, `Gi0/1.20`) for inter-VLAN routing. Verified VLAN isolation at Layer 2 and successful routed communication between VLANs at Layer 3 (confirmed via TTL decrement on ping, proving the traffic crossed a router hop).

## Troubleshooting Log

Documenting issues encountered and resolved is arguably the most useful part of this project — it reflects real diagnostic work, not just following steps.

| Issue | Root Cause | Resolution |
|---|---|---|
| Link between Switch0 and PC1 showed down (dashed line) | Wrong cable type used (Copper Cross-Over instead of Straight-Through) for a switch-to-PC connection | Replaced with Copper Straight-Through cable; link came up immediately |
| `interface gigabitEthernet0/0/0` command rejected on router | Assumed interface naming from a different router model (ISR 8200 series); actual router used was a Cisco 2911, which uses `Gi0/0` / `Gi0/1` naming | Verified actual interface names via the router's physical view before issuing config commands |
| Sub-interface `fastEthernet0/1.10` rejected with "Invalid interface type and number" | Assumed the router used a FastEthernet interface toward the switch, based on the switch-side port label; the router-side interface was actually GigabitEthernet0/1 | Re-verified interface type directly on the router (not the switch) and reconfigured sub-interfaces as `gigabitEthernet0/1.10` / `.20` |

## Verification Evidence

Screenshots for each phase are in the [`screenshots/`](./screenshots). folder:

**[/screenshots/phase1_topology/](/screenshots/phase1_topology/).**
- [/screenshots/phase1_topology/01_packet_tracer_interface.png](/screenshots/phase1_topology/01_packet_tracer_interface.png) — initial Packet Tracer environment
- [/screenshots/phase1_topology/02_topology_diagram.png](/screenshots/phase1_topology/02_topology_diagram.png) — full topology with all links up

**[/screenshots/phase2_ip_addressing/](/screeenshots/phase2_ip_addressing/)**
- [/screenshots/phase2_ip_addressing/03_branch_router_config.png](/screenshots/phase2_ip_addressing/03_branch_router_config.png) — Branch Router interface IP config (CLI)
- [/screenshots/phase2_ip_addressing/04_head_office_router_conf.png](/screenshots/phase2_ip_addressing/04_head_office_router_conf.png) — Head Office Router interface IP config (CLI)
- [/screenshots/phase2_ip_addressing/05_pc0_conf.png](/screenshots/phase2_ip_addressing/05_pc0_conf.png) — PC0 static IP configuration
- [/screenshots/phase2_ip_addressing/06_ip_configuration_topology.png](/screenshots/phase2_ip_addressing/06_ip_configuration_topology.png) — topology annotated with all assigned IPs
- [/screenshots/phase2_ip_addressing/07_ip_interface_on_branch_router.png](/screenshots/phase2_ip_addressing/07_ip_interface_on_branch_router.png) — interface verification + successful WAN ping

**[/screenshots/phase3_ospf/](/screeenshots/phase3_ospf)**
- [/screenshots/phase3_ospf/08_ospf_config_on_branch_router.png](/screenshots/phase3_ospf/08_ospf_config_on_branch_router.png) — OSPF process config on Branch Router
- [/screenshots/phase3_ospf/09_ospf_config_on_head_office_router.png](/screenshots/phase3_ospf/09_ospf_config_on_head_office_router.png) — OSPF process config on Head Office Router
- [/screenshots/phase3_ospf/10_neighbor_state_on_branch_router.png](/screenshots/phase3_ospf/10_neighbor_state_on_branch_router.png) — neighbor adjacency reaching FULL state
- [/screenshots/phase3_ospf/11_ip_route_ospf_on_head_office_router.png](/screenshots/phase3_ospf/11_ip_route_ospf_on_head_office_router.png) — Head Office Router learning the branch's VLAN subnet via OSPF

**[/screenshots/phase4_vlan/](/screenshots/phase4_vlan)**
- [/screenshots/phase4_vlan/12_vlan_conf_on_switch.png](/screenshots/phase4_vlan/12_vlan_conf_on_switch.png) — VLAN creation, access ports, trunk config on Switch0
- [/screenshots/phase4_vlan/13_sub_interface_naming_error_on_branch_router` — the sub-interface naming error encountered (see Troubleshooting Log)
- [/screenshots/phase4_vlan/13_sub_interface_config_on_branch_router.png](/screenshots/phase4_vlan/13_sub_interface_config_on_branch_router.png) — corrected sub-interface config, verified up/up
- [/screenshots/phase4_vlan/14_pc1_in_vlan20_conf.png](/screenshots/phase4_vlan/14_pc1_in_vlan20_conf.png) — PC1 re-addressed into VLAN 20
- [/screenshots/phase4_vlan/15_pc0_to_pc1_ping.png]([/screenshots/phase4_vlan/15_pc0_to_pc1_ping.png) — successful inter-VLAN ping (TTL=127 confirms routed hop)

## Configs

Full running-config command sequences for each device are in [/configs](/configs).

## Tools Used

- Cisco Packet Tracer

## Skills Demonstrated

`Routing & Switching` `OSPF` `VLAN Segmentation` `Router-on-a-Stick` `VLSM Subnetting` `Network Troubleshooting` `Cisco IOS CLI`

## Next Steps

Planned follow-on project: BGP peering, VxLAN overlay, and VRF-based segmentation using GNS3 with Cisco IOSv/IOSvL2 images — extending this topology into a multi-site, multi-AS design.

---
*Part of a Network Security Engineer portfolio. See also: [VAPT Analyst portfolio projects] for offensive security work.*
