#!/bin/bash
# moOde Audio USB Numpad Controller - Wrapper Script
# Copyright (C) 2025 M Lake
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

echo "Installing moOde Numpad Controller..."

# Copy files to system locations
sudo cp src/numpad-wrapper.sh /usr/local/bin/
sudo cp src/moode_numpad_controller.py /usr/local/bin/
sudo cp src/numpad-moode.conf /etc/triggerhappy/triggers.d/

# Set permissions
sudo chmod +x /usr/local/bin/numpad-wrapper.sh
sudo chmod +x /usr/local/bin/moode_numpad_controller.py

# Detect the appropriate user for triggerhappy
echo "Detecting appropriate user for triggerhappy service..."

# Check if moode user exists and has sudo privileges
if id "moode" &>/dev/null && sudo -l -U moode 2>/dev/null | grep -q "NOPASSWD"; then
    TRIGGER_USER="moode"
    echo "Using 'moode' user (detected with sudo privileges)"
# Check if pi user exists and has sudo privileges  
elif id "pi" &>/dev/null && sudo -l -U pi 2>/dev/null | grep -q "NOPASSWD"; then
    TRIGGER_USER="pi"
    echo "Using 'pi' user (detected with sudo privileges)"
# Check what's in the sudoers file
elif [ -f /etc/sudoers.d/010_pi-nopasswd ]; then
    SUDOERS_USER=$(grep "NOPASSWD" /etc/sudoers.d/010_pi-nopasswd | head -1 | awk '{print $1}')
    if [ -n "$SUDOERS_USER" ] && id "$SUDOERS_USER" &>/dev/null; then
        TRIGGER_USER="$SUDOERS_USER"
        echo "Using '$SUDOERS_USER' user (found in sudoers file)"
    else
        TRIGGER_USER="moode"
        echo "Defaulting to 'moode' user (unable to detect privileged user)"
    fi
else
    TRIGGER_USER="moode"
    echo "Defaulting to 'moode' user (no sudoers file found)"
fi

# Configure triggerhappy to run as detected user
echo "Configuring triggerhappy service to run as '$TRIGGER_USER' user..."
sudo systemctl stop triggerhappy

# Create systemd override directory if it doesn't exist
sudo mkdir -p /etc/systemd/system/triggerhappy.service.d

# Create override configuration
sudo tee /etc/systemd/system/triggerhappy.service.d/override.conf > /dev/null << EOF
[Service]
User=$TRIGGER_USER
Group=$TRIGGER_USER
EOF

# Reload systemd and restart triggerhappy service
sudo systemctl daemon-reload
sudo systemctl start triggerhappy
sudo systemctl restart triggerhappy

echo "Installation complete!"
echo "Edit /usr/local/bin/moode_numpad_controller.py to configure your radio stations"
echo ""
echo "Changes made:"
echo "- Installed numpad controller files"
echo "- Configured triggerhappy to run as '$TRIGGER_USER' user for proper permissions"
echo "- Restarted triggerhappy service to apply changes"
