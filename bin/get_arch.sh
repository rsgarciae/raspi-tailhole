#!/bin/bash
set -e
# Function to detect the architecture
get_architecture() {
    ARCHITECTURE=$(uname -m)

    if [[ "$ARCHITECTURE" == "x86_64" ]]; then
        ARCH="amd64"
    elif [[ "$ARCHITECTURE" == "aarch64" ]]; then
        ARCH="arm64"
    elif [[ "$ARCHITECTURE" == "armv7l" || "$ARCHITECTURE" == "armv6l" ]]; then
        ARCH="armhf"
    else
        echo "Unsupported architecture: $ARCHITECTURE"
        exit 1
    fi
    echo "$ARCH"
}

# Detect the architecture of the system
ARCH=$(get_architecture)