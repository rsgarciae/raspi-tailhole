#!/bin/bash
set -e

echo "###########################################"
echo "#        Installing additional packages   #"
echo "###########################################"

sudo apt update
sudo apt install -y \
    at \
    sudo

# Install go
echo "Installing go"
curl -sL https://raw.githubusercontent.com/rsgarciae/raspi-tailhole/main/bin/install_go.sh | bash

# Install docker
echo "Installing docker"
curl -sL https://raw.githubusercontent.com/rsgarciae/raspi-tailhole/main/bin/install_docker.sh | bash
