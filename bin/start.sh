#!/bin/bash
set -e
: ${NETWORK_RANGE:?"ERROR: NETWORK_RANGE parameter is required Example: NETWORK_RANGE=192.168.1.0/24"}
: ${TS_API_CLIENT_ID:?"ERROR: TS_API_CLIENT_ID environment variable is required Set with: export TS_API_CLIENT_ID=your_client_id"}
: ${TS_API_CLIENT_SECRET:?"ERROR: TS_API_CLIENT_SECRET environment variable is required . Set with: export TS_API_CLIENT_SECRET=your_client_secret"}

# Parse command line arguments
NETWORK_RANGE=""
for arg in "$@"; do
  case $arg in
    NETWORK_RANGE=*)
      NETWORK_RANGE="${arg#*=}"
      shift
      ;;
    *)
      # Unknown option
      ;;
  esac
done

echo "Using network CIDR: $NETWORK_RANGE"
export NETWORK_RANGE

# Enable VNC service
curl -sL https://raw.githubusercontent.com/rsgarciae/raspi-tailhole/main/bin/enable_vnc.sh | bash

# Set static ip 
curl -sL https://raw.githubusercontent.com/rsgarciae/raspi-tailhole/main/bin/set_static_ip.sh | bash

# Enable ip forwarding 
curl -sL https://raw.githubusercontent.com/rsgarciae/raspi-tailhole/main/bin/enable_ip_forwarding.sh | bash

# Install additional dependencies
echo "Installing additional dependencies"
curl -sL https://raw.githubusercontent.com/rsgarciae/raspi-tailhole/main/bin/install_packages.sh | bash

# Download refresh_tailscale script
sudo mkdir -p /var/opt
echo "Download refresh tailscale script"
sudo curl -sL https://raw.githubusercontent.com/rsgarciae/raspi-tailhole/main/bin/refresh_tailscale.sh -o /var/opt/refresh_tailscale.sh && sudo chmod +x /var/opt/refresh_tailscale.sh
bash /var/opt/refresh_tailscale.sh "$NETWORK_RANGE"
