#!/bin/bash

set -e

: ${NETWORK_RANGE:?"ERROR: NETWORK_RANGE parameter is required Example: NETWORK_RANGE=192.168.1.0/24"}
: ${TS_API_CLIENT_ID:?"ERROR: TS_API_CLIENT_ID environment variable is required Set with: export TS_API_CLIENT_ID=your_client_id"}
: ${TS_API_CLIENT_SECRET:?"ERROR: TS_API_CLIENT_SECRET environment variable is required . Set with: export TS_API_CLIENT_SECRET=your_client_secret"}


# Check if network range is provided as argument
if [ -n "$1" ]; then
    NETWORK_RANGE="$1"
else
    echo "ERROR: Network range not provided"
    echo "Usage: $0 <network_range>"
    exit 1
fi

echo "Using network range: $NETWORK_RANGE"
# Generate a new Tailscale auth key
TS_AUTHKEY=$(go run tailscale.com/cmd/get-authkey@latest -reusable -ephemeral -preauth -tags tag:exitnode)

# Stop and remove the existing container if it exists
if docker ps -a --format '{{.Names}}' | grep 'tailscale'; then
    echo "Stopping and removing existing Tailscale container..."
    docker stop tailscale || true
    docker rm tailscale || true
fi

# Start a new Tailscale container with the new key
echo "Starting new Tailscale container with fresh auth key..."
docker run -d \
    --name=tailscale \
    -v "/var/lib:/var/lib" \
    -v "/dev/net/tun:/dev/net/tun" \
    --network=host \
    --cap-add=NET_ADMIN \
    --cap-add=NET_RAW \
    --env TS_AUTHKEY="$TS_AUTHKEY" \
    --env TS_EXTRA_ARGS="--advertise-exit-node"  \
    --env TS_ROUTES="$NETWORK_RANGE" \
    --restart unless-stopped \
    tailscale/tailscale:v1.74.1

echo "Tailscale container refreshed successfully."
echo "/var/opt/refresh_tailscale.sh \"$NETWORK_RANGE\"" | at now + 90 days