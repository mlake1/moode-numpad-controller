#!/bin/bash

# moOde Audio USB Numpad Controller - Wrapper Script
# Copyright (C) 2025 M Lake
#
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

# Restart triggerhappy service
sudo systemctl restart triggerhappy

echo "Installation complete!"
echo "Edit /usr/local/bin/moode_numpad_controller.py to configure your radio stations"
