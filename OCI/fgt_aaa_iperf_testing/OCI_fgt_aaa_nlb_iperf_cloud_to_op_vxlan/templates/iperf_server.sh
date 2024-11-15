#!/bin/bash

# Install iperf3
apt-get update
apt-get install -y iperf3

# Disable Ubuntu OCI iptables default
iptables -F
netfilter-persistent save

# Execute iperf3 server
iperf3 -s &