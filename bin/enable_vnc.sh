#!/bin/bash
set -e

echo "###########################################"
echo "#             Enable VNC                  #"
echo "###########################################"

# Check if the VNC service is active
if [[ $(sudo systemctl is-active vncserver-x11-serviced.service) != "active" ]]; then
    echo "VNC is not active. Enabling and starting VNC..."

    # Enable VNC non-interactively
    sudo raspi-config nonint do_vnc 0

    # Start the VNC service
    sudo systemctl start vncserver-x11-serviced.service

    echo "VNC has been enabled and started."
else
    echo "VNC is already active. Continuing..."
fi

echo "###########################################"
echo "-------------------------------------------"
