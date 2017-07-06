#!/bin/bash

set -x

brctl addbr br0

ip addr add 192.168.1.2/24 dev eth1
ip link set dev eth1 up
brctl addif br0 eth1

ip addr add 192.168.1.3/24 dev eth2
ip link set dev eth2 up
brctl addif br0 eth2

ip addr add 1.1.1.5/16 dev br0
ip link set dev br0 up

arp -s 1.1.1.10 04:F4:BC:2F:C8:C1
arp -s 1.1.2.10 04:F4:BC:2F:C8:C0

sysctl -w net.ipv4.ip_forward=1

sysctl -w net.ipv4.conf.all.rp_filter=0
sysctl -w net.ipv4.conf.eth1.rp_filter=0
sysctl -w net.ipv4.conf.eth2.rp_filter=0

