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

# Configure triggerhappy to run as moode user instead of nobody
echo "Configuring triggerhappy service to run as moode user..."
sudo systemctl stop triggerhappy

# Create systemd override directory if it doesn't exist
sudo mkdir -p /etc/systemd/system/triggerhappy.service.d

# Create override configuration
sudo tee /etc/systemd/system/triggerhappy.service.d/override.conf > /dev/null << EOF
[Service]
User=moode
Group=moode
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
echo "- Configured triggerhappy to run as 'moode' user for proper permissions"
echo "- Restart triggerhappy service to apply changes"
