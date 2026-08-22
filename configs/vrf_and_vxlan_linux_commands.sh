#!/bin/bash
# ===================================================================
# VRF-Equivalent Isolation + VxLAN Overlay
# Run on the Kali Linux VM (requires sudo)
# Advanced Phase of the Enterprise Routing & Switching Lab
# ===================================================================

# -------------------------------------------------------------------
# PART 1: VRF-Equivalent Isolation (Linux Network Namespaces)
# -------------------------------------------------------------------
# Two namespaces simulate two "customers" sharing one host, each with
# a fully independent routing table - the same isolation model VRF
# provides on a router. Both are deliberately given the SAME IP
# address to prove there is no conflict between the two routing
# domains.

sudo ip netns add customer-a
sudo ip netns add customer-b

sudo ip link add veth-a type veth peer name veth-a-br
sudo ip link add veth-b type veth peer name veth-b-br

sudo ip link set veth-a netns customer-a
sudo ip link set veth-b netns customer-b

sudo ip netns exec customer-a ip addr add 10.10.10.1/24 dev veth-a
sudo ip netns exec customer-a ip link set veth-a up
sudo ip netns exec customer-a ip link set lo up

sudo ip netns exec customer-b ip addr add 10.10.10.1/24 dev veth-b
sudo ip netns exec customer-b ip link set veth-b up
sudo ip netns exec customer-b ip link set lo up

# The host-side end of each veth pair must also be brought up
# (missed on the first pass - link showed "linkdown" until fixed):
sudo ip link set veth-a-br up
sudo ip link set veth-b-br up

# --- Verification ---
sudo ip netns list
sudo ip netns exec customer-a ip route
sudo ip netns exec customer-b ip route
sudo ip netns exec customer-a ping -c 3 10.10.10.1


# -------------------------------------------------------------------
# PART 2: VxLAN Overlay
# -------------------------------------------------------------------
# Two new namespaces simulate two physical "sites". An underlay veth
# link gives them basic L3 reachability (172.16.0.0/30). A VXLAN
# interface (VNI 100, UDP/4789) is then built on top, creating an
# overlay network (192.168.100.0/24) that appears directly connected
# even though it is encapsulated across the underlay.

sudo ip netns add site-a
sudo ip netns add site-b

# --- Underlay link ---
sudo ip link add veth-underlay-a type veth peer name veth-underlay-b
sudo ip link set veth-underlay-a netns site-a
sudo ip link set veth-underlay-b netns site-b

sudo ip netns exec site-a ip addr add 172.16.0.1/30 dev veth-underlay-a
sudo ip netns exec site-a ip link set veth-underlay-a up
sudo ip netns exec site-a ip link set lo up

sudo ip netns exec site-b ip addr add 172.16.0.2/30 dev veth-underlay-b
sudo ip netns exec site-b ip link set veth-underlay-b up
sudo ip netns exec site-b ip link set lo up

# --- Verify underlay ---
sudo ip netns exec site-a ping -c 3 172.16.0.2

# --- VXLAN overlay interface (VNI 100) ---
sudo ip netns exec site-a ip link add vxlan100 type vxlan id 100 dstport 4789 \
    local 172.16.0.1 remote 172.16.0.2 dev veth-underlay-a
sudo ip netns exec site-a ip addr add 192.168.100.1/24 dev vxlan100
sudo ip netns exec site-a ip link set vxlan100 up

sudo ip netns exec site-b ip link add vxlan100 type vxlan id 100 dstport 4789 \
    local 172.16.0.2 remote 172.16.0.1 dev veth-underlay-b
sudo ip netns exec site-b ip addr add 192.168.100.2/24 dev vxlan100
sudo ip netns exec site-b ip link set vxlan100 up

# --- Verify VXLAN interface ---
sudo ip netns exec site-a ip -d link show vxlan100
sudo ip netns exec site-b ip -d link show vxlan100

# --- Overlay reachability test ---
sudo ip netns exec site-a ping -c 3 192.168.100.2

# --- Proof of encapsulation: capture the underlay while the overlay
# ping is running (run this in a separate terminal, then trigger
# the ping above) ---
sudo ip netns exec site-a tcpdump -i veth-underlay-a -n udp port 4789 -c 5

# Expected: each ICMP echo request/reply on the 192.168.100.0/24
# overlay appears wrapped inside a UDP/4789 VXLAN packet between
# the underlay IPs (172.16.0.1 <-> 172.16.0.2), tagged with vni 100.
