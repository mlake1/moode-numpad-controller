#!/bin/bash
#
# moOde Audio USB Numpad Controller - Wrapper Script
# Copyright (C) 2025 M Lake
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.
#
# Purpose: Bridge script between triggerhappy and Python controller
# Usage: Called by triggerhappy with command parameter
# Example: /usr/local/bin/numpad-wrapper.sh play_pause

/usr/bin/python3 /usr/local/bin/moode_numpad_controller.py "$1"
