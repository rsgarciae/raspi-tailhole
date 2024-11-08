#!/bin/bash
set -e

echo "###########################################"
echo "#         Set static IP                   #"
echo "###########################################"

# Find the first active interface with an IP address (excluding 'lo')
ip_found=false
for iface in $(ls /sys/class/net/); do
  # Skip loopback interface
  if [ "$iface" != "lo" ]; then
    ip=$(ifconfig $iface | grep 'inet ' | awk '{print $2}')
    if [ -n "$ip" ]; then
      ip_found=true
      interface_found=$iface
      break
    fi
  fi
done

# If no interface is found with an IP, exit the script
if [ "$ip_found" = false ]; then
  echo "No valid IPv4 address found on any interface. Exiting."
  exit 1
fi

echo "Found IPv4 address on interface: $interface_found"

# Get the connection name associated with the found interface
connection_name=$(nmcli connection show | grep -i "$interface_found" | while read -r line; do
  echo "$line" | sed 's/^\([[:space:]]*\)\([A-Za-z0-9[:space:]]*\)[[:space:]]\{2,\}.*/\2/'
done)

# If connection name is not found, exit the script
if [ -z "$connection_name" ]; then
  echo "No valid connection found for interface $interface_found. Exiting."
  exit 1
fi

echo "Found valid connection name: $connection_name"

# Get the gateway IP for the found interface
gateway_ip=$(route -n | grep 'UG[ \t]' | grep -i "$interface_found" | awk '{print $2}' | tr -d '\n' | sed 's/[[:space:]]//g')

if [ -z "$gateway_ip" ]; then
  echo "Gateway address for $interface_found not found. Exiting."
  exit 1
fi

echo "Found gateway IP: $gateway_ip"

# Get the DNS IP for the found interface
dns_ip=$(cat /etc/resolv.conf | grep nameserver | awk '{print $2}' | grep -E '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$')

if [ -z "$dns_ip" ]; then
  echo "No valid DNS address found. Exiting."
  exit 1
fi

echo "Found DNS IP: $dns_ip"

# Step 5: Set the static IP, gateway, and DNS using nmcli
echo "Configuring static IP..."
sudo nmcli connection modify "$connection_name" ipv4.addresses "$ip"
if [ $? -ne 0 ]; then
  echo "Failed to set static IP. Exiting."
  exit 1
fi

sudo nmcli connection modify "$connection_name" ipv4.gateway "$gateway_ip"
if [ $? -ne 0 ]; then
  echo "Failed to set gateway IP. Exiting."
  exit 1
fi

sudo nmcli connection modify "$connection_name" ipv4.dns "$dns_ip"
if [ $? -ne 0 ]; then
  echo "Failed to set DNS IP. Exiting."
  exit 1
fi

sudo nmcli connection modify "$connection_name" ipv4.method manual
if [ $? -ne 0 ]; then
  echo "Failed to set IPv4 method to manual. Exiting."
  exit 1
fi

# Restart the connection to apply changes
sudo nmcli connection down "$connection_name" && sudo nmcli connection up "$connection_name"
if [ $? -ne 0 ]; then
  echo "Failed to restart the connection. Exiting."
  exit 1
fi

#Print the configuration used
echo ""
echo "Static IP configuration applied successfully:"
echo "--------------------------------------------"
echo "Static IP: $ip"
echo "Gateway IP: $gateway_ip"
echo "DNS IP: $dns_ip"
echo "--------------------------------------------"

echo "Static IP configuration completed successfully."

echo "###########################################"
echo "-------------------------------------------"