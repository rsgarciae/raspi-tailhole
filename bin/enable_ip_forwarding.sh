#!/bin/bash
set -e

echo "###########################################"
echo "#        Enable Ip Forwarding             #"
echo "###########################################"

# Check if /etc/sysctl.d directory exists
if [ -d "/etc/sysctl.d" ]; then
    # Enable IP forwarding using /etc/sysctl.d/99-tailscale.conf
    echo "Enabling IP forwarding with /etc/sysctl.d/99-tailscale.conf..."
    echo 'net.ipv4.ip_forward = 1' | sudo tee -a /etc/sysctl.d/99-tailscale.conf
    echo 'net.ipv6.conf.all.forwarding = 1' | sudo tee -a /etc/sysctl.d/99-tailscale.conf
    sudo sysctl -p /etc/sysctl.d/99-tailscale.conf
else
    # Enable IP forwarding using /etc/sysctl.conf
    echo "Enabling IP forwarding with /etc/sysctl.conf..."
    echo 'net.ipv4.ip_forward = 1' | sudo tee -a /etc/sysctl.conf
    echo 'net.ipv6.conf.all.forwarding = 1' | sudo tee -a /etc/sysctl.conf
    sudo sysctl -p /etc/sysctl.conf
fi

echo "###########################################"
echo "-------------------------------------------"