#!/bin/bash
set -e

echo "###########################################"
echo "#             Installing Docker           #"
echo "###########################################"

# Get ARCH directly from the script output
ARCH=$(curl -sL https://raw.githubusercontent.com/rsgarciae/raspi-tailhole/main/bin/get_arch.sh | bash)

echo "Detected architecture: $ARCH"

# Install Docker dependencies
echo "Installing Docker dependencies"
sudo apt update
sudo apt install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    sudo

# Add Docker's official GPG key
echo "Adding Docker's GPG key..."
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Add Docker's official repository based on architecture
echo "Setting up Docker repository..."
if [[ "$ARCH" == "amd64" ]]; then
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
elif [[ "$ARCH" == "arm64" ]]; then
    echo "deb [arch=arm64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
elif [[ "$ARCH" == "armhf" ]]; then
    echo "deb [arch=armhf signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
fi

# Update package list
echo "Updating package list..."
sudo apt update

# Install Docker
echo "Installing Docker..."
sudo apt install -y docker-ce docker-ce-cli containerd.io

# Start Docker and enable it to run on startup
echo "Starting Docker..."
sudo systemctl enable docker
sudo systemctl start docker

# Check if the Docker group exists, if not create it
if ! grep -q "docker" /etc/group; then
    echo "Docker group does not exist. Creating Docker group..."
    sudo groupadd docker
else
    echo "Docker group already exists."
fi

# Add current user to the Docker group
echo "Adding user to the Docker group to run Docker without sudo..."
sudo usermod -aG docker $USER

# Use newgrp to apply the group change immediately in the current shell
echo "Switching to the docker group using newgrp..."
newgrp docker

docker --version
echo "Docker installation complete!"