# moOde Audio USB Numpad Controller - Detailed Setup Guide

This comprehensive guide covers everything needed to install, configure, and customise the moOde Audio USB Numpad Controller system.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Hardware Setup](#hardware-setup)
- [Software Installation](#software-installation)
- [Configuration](#configuration)
- [Testing & Verification](#testing--verification)
- [Customisation](#customisation)
- [Troubleshooting](#troubleshooting)

## Prerequisites

### System Requirements
- **Raspberry Pi**: 3, 4, 5, 400/500, CM3/4/5, or Zero 2 W
- **Operating System**: moOde Audio 9.x series (9.3.x recommended)
- **Network**: Local network access to moOde web interface
- **SSH Access**: Enabled on the Raspberry Pi

### Required Packages
```bash
sudo apt update
sudo apt install triggerhappy python3 curl sqlite3 evtest
```

### Verify moOde Installation
```bash
# Check moOde version
cat /var/www/footer.php | grep -i version

# Test moOde API access
curl -s "http://moode/command/?cmd=status" | head -5

# Verify web interface access
ping moode
```

## Hardware Setup

### USB Numpad Selection

#### ✅ Recommended Hardware
**Kensington Wired Numeric Keypad**
- **Product**: https://www.kensington.com/en-gb/p/products/control/keyboards/wired-numeric-keypad/
- **Model**: K72274US/K72274EU
- **USB ID**: 276d:1160 (Homertech USB Keyboard)
- **Compatibility**: Full Linux HID compliance
- **Price Range**: £15-£20

#### ❌ Known Incompatible Hardware
**Targus AKP10EU**
- **Issue**: Non-standard USB-HID implementation
- **Problem**: Sends KEY_NUMLOCK with every key press
- **Result**: Cannot be used with triggerhappy

#### 🔍 Hardware Verification

**Step 1: Check USB Detection**
```bash
# Plug in your USB numpad, then check:
lsusb | grep -i keyboard
# Expected output: Bus XXX Device XXX: ID 276d:1160 Homertech USB Keyboard

# Alternative check
dmesg | tail -10
# Should show USB device connection
```

**Step 2: Verify Input Device Creation**
```bash
# List input devices
ls -la /dev/input/
# Look for event devices (event0, event1, etc.)

# Check device details
cat /proc/bus/input/devices | grep -A 10 -B 5 -i keyboard
```

**Step 3: Test Key Detection**
```bash
# Interactive key testing
sudo evtest
# Select your keyboard device (usually "Homertech USB Keyboard")
# Press various keys and verify KEY_KPX codes appear
```

## Software Installation

### Method 1: Automated Installation

```bash
# Clone the repository
git clone https://github.com/mlake1/moode-numpad-controller.git
cd moode-numpad-controller

# Run installation script
sudo ./install.sh

# Verify installation
sudo systemctl status triggerhappy
```

### Method 2: Manual Installation

#### Step 1: Create Directory Structure
```bash
sudo mkdir -p /usr/local/bin
sudo mkdir -p /etc/triggerhappy/triggers.d
```

#### Step 2: Install Wrapper Script
```bash
sudo nano /usr/local/bin/numpad-wrapper.sh
```

```bash
#!/bin/bash
#
# moOde Audio USB Numpad Controller - Wrapper Script
# Copyright (C) 2025 M Lake
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

/usr/bin/python3 /usr/local/bin/moode_numpad_controller.py "$1"
```

```bash
sudo chmod +x /usr/local/bin/numpad-wrapper.sh
```

#### Step 3: Install Python Controller
```bash
sudo nano /usr/local/bin/moode_numpad_controller.py
```

**Copy the complete Python script** (see [Python Controller Code](#python-controller-code) section below)

```bash
sudo chmod +x /usr/local/bin/moode_numpad_controller.py
```

#### Step 4: Install Triggerhappy Configuration
```bash
sudo nano /etc/triggerhappy/triggers.d/numpad-moode.conf
```

**Copy the triggerhappy configuration** (see [Triggerhappy Configuration](#triggerhappy-configuration) section below)

#### Step 5: Enable Services
```bash
sudo systemctl enable triggerhappy
sudo systemctl restart triggerhappy
```

## Configuration

### Radio Station Setup

#### Step 1: Discover Available Stations

**Method A: Web Interface**
1. Open moOde web interface: `http://moode`
2. Navigate to **Browse** → **Radio**
3. View your favorite stations
4. Note the exact station names

**Method B: Database Query**
```bash
# Access moOde database
sqlite3 /var/local/www/db/moode-sqlite3.db

# List all favorite radio stations
.headers on
.mode column
SELECT name, station FROM cfg_radio WHERE type='f';

# Search for specific stations
SELECT name FROM cfg_radio WHERE name LIKE '%BBC%';

# Exit database
.quit
```

**Method C: File System**
```bash
# Check radio directory
ls -la /var/lib/mpd/music/RADIO/

# Find playlist files
find /var/lib/mpd/music/RADIO/ -name "*.pls" | sort
```

#### Step 2: Configure Station Mappings

Edit the Python controller:
```bash
sudo nano /usr/local/bin/moode_numpad_controller.py
```

Update the STATIONS dictionary:
```python
# Radio station mappings - must match moOde favorites exactly
STATIONS = {
    '0': 'RADIO/Your Favorite Station.pls',
    '1': 'RADIO/BBC Radio 1 (320K).pls',
    '2': 'RADIO/BBC Radio 2 (320K).pls',
    '3': 'RADIO/Classical KUSC.pls',
    '4': 'RADIO/Jazz FM London.pls',
    '5': 'RADIO/Your Station 5.pls',
    '6': 'RADIO/Your Station 6.pls',
    '7': 'RADIO/Your Station 7.pls',
    '8': 'RADIO/Your Station 8.pls',
    '9': 'RADIO/Your Station 9.pls'
}
```

**Important Notes:**
- Station names must match **exactly** (case-sensitive)
- Include the `.pls` file extension
- Stations must exist in moOde favorites
- Use the full path starting with `RADIO/`

#### Step 3: Restart Services
```bash
sudo systemctl restart triggerhappy
```

### Key Mapping Customisation

#### Discover Key Codes
```bash
# Interactive key discovery
sudo evtest
# Select your numpad device
# Press keys to see their KEY_XXX codes
```

#### Modify Key Mappings
```bash
sudo nano /etc/triggerhappy/triggers.d/numpad-moode.conf
```

**Configuration Format:**
```
KEY_NAME    1    /usr/local/bin/numpad-wrapper.sh    function_name
```

**Common Key Codes:**
- `KEY_KP0` to `KEY_KP9` - Numpad numbers
- `KEY_KPENTER` - Numpad Enter
- `KEY_KPPLUS`, `KEY_KPMINUS` - Plus/Minus
- `KEY_KPASTERISK`, `KEY_KPSLASH` - Asterisk/Slash
- `KEY_KPDOT` - Decimal point
- `KEY_TAB`, `KEY_BACKSPACE` - Tab/Backspace

## Testing & Verification

### Step 1: Test Individual Components

**Test API Connection:**
```bash
# Test moOde API directly
curl -s "http://moode/command/?cmd=status"

# Test with specific command
curl -s "http://moode/command/?cmd=pause"
```

**Test Python Controller:**
```bash
# Test individual functions
/usr/local/bin/moode_numpad_controller.py play_pause
/usr/local/bin/moode_numpad_controller.py volume_up
/usr/local/bin/moode_numpad_controller.py 1
```

**Test Wrapper Script:**
```bash
# Test wrapper
/usr/local/bin/numpad-wrapper.sh play_pause
/usr/local/bin/numpad-wrapper.sh status
```

### Step 2: Test Key Detection

**Monitor Triggerhappy:**
```bash
# Watch triggerhappy logs in real-time
sudo journalctl -u triggerhappy -f

# In another terminal, press numpad keys
# You should see trigger actions in the log
```

**Test Specific Keys:**
```bash
# Press each key and verify output:
# - Numpad 1 should show: "Playing station: [station name]"
# - Enter should show: "Play/pause"
# - Plus should show: "Volume increased"
```

### Step 3: Functional Testing

**Radio Station Testing:**
1. Press numpad keys 0-9
2. Verify correct stations play
3. Check station names in moOde web interface

**Playback Control Testing:**
1. Start playing a station
2. Test Enter (play/pause)
3. Test volume up/down (+/-)
4. Test mute (=)

**System Function Testing:**
1. Test Tab (clear queue)
2. Test / (show status)
3. Test * (local music - if configured)

## Customisation

### Adding New Functions

#### Step 1: Create Python Function
```python
def your_new_function():
    """Description of your function"""
    result = execute_command('your_moode_api_command')
    if result:
        print("Function completed successfully")
    else:
        print("Function failed")
```

#### Step 2: Add Command Handler
```python
# In the main section, add:
elif command == "your_command":
    your_new_function()
```

#### Step 3: Add Key Mapping
```bash
# Add to triggerhappy config:
KEY_YOURKEY 1 /usr/local/bin/numpad-wrapper.sh your_command
```

#### Step 4: Restart Service
```bash
sudo systemctl restart triggerhappy
```

### Advanced Customisation Examples

#### Volume Presets
```python
def set_volume_25():
    """Set volume to 25%"""
    result = execute_command('set_volume&vol=25')
    print("Volume set to 25%")

def set_volume_50():
    """Set volume to 50%"""
    result = execute_command('set_volume&vol=50')
    print("Volume set to 50%")
```

#### Playlist Management
```python
def load_playlist(name):
    """Load a specific playlist"""
    result = execute_command(f'load_playlist {name}')
    if result:
        print(f"Loaded playlist: {name}")
```

#### Multiple moOde Instances
```python
# Configure multiple moOde hosts
MOODE_HOSTS = {
    'kitchen': 'moode-kitchen.local',
    'living': 'moode-living.local'
}

def switch_host(location):
    global MOODE_HOST
    MOODE_HOST = MOODE_HOSTS.get(location, 'moode')
    print(f"Switched to {location} moOde")
```

## Troubleshooting

### Key Presses Not Working

**Symptoms:** Keys don't trigger any actions

**Diagnosis:**
```bash
# Check triggerhappy status
sudo systemctl status triggerhappy

# Check for errors
sudo journalctl -u triggerhappy --no-pager

# Test key detection
sudo evtest
```

**Solutions:**
1. **Restart triggerhappy:** `sudo systemctl restart triggerhappy`
2. **Check file permissions:** All scripts should be executable
3. **Verify device detection:** Use `lsusb` and `evtest`
4. **Check configuration syntax:** Review triggerhappy config file

### API Commands Failing

**Symptoms:** "Error executing command" or no response

**Diagnosis:**
```bash
# Test API directly
curl -v "http://moode/command/?cmd=status"

# Check network connectivity
ping moode

# Verify moOde is running
systemctl status mpd
```

**Solutions:**
1. **Update MOODE_HOST:** Change to IP address or 'localhost'
2. **Check moOde status:** Verify web interface works
3. **Network issues:** Check WiFi/Ethernet connection
4. **API changes:** Some commands may have changed in newer moOde versions

### Radio Stations Not Playing

**Symptoms:** Station commands execute but no audio

**Diagnosis:**
```bash
# Check station exists in moOde
sqlite3 /var/local/www/db/moode-sqlite3.db "SELECT name FROM cfg_radio WHERE name LIKE '%Your Station%';"

# Test station in web interface
# Navigate to Browse → Radio and try playing the station
```

**Solutions:**
1. **Exact name matching:** Station names must match exactly
2. **Add to favorites:** Stations must be in moOde favorites
3. **Check station availability:** Some internet stations go offline
4. **Update station URLs:** Streaming URLs may change

### Permission Issues

**Symptoms:** "Permission denied" errors

**Diagnosis:**
```bash
# Check file permissions
ls -la /usr/local/bin/numpad-*
ls -la /etc/triggerhappy/triggers.d/numpad-*

# Check user groups
groups $USER
```

**Solutions:**
```bash
# Fix script permissions
sudo chmod +x /usr/local/bin/numpad-wrapper.sh
sudo chmod +x /usr/local/bin/moode_numpad_controller.py

# Fix triggerhappy config permissions
sudo chown root:root /etc/triggerhappy/triggers.d/numpad-moode.conf
sudo chmod 644 /etc/triggerhappy/triggers.d/numpad-moode.conf
```

### Service Not Starting

**Symptoms:** triggerhappy fails to start

**Diagnosis:**
```bash
# Check service status
sudo systemctl status triggerhappy

# Check for syntax errors
sudo triggerhappy -d /dev/input/event* -c /etc/triggerhappy/triggers.d/ -v
```

**Solutions:**
1. **Fix configuration syntax:** Check for typos in config files
2. **Check device permissions:** Ensure /dev/input/event* are accessible
3. **Reinstall triggerhappy:** `sudo apt reinstall triggerhappy`

## Logging and Debug Mode

### Enable Debug Logging
```bash
# Stop triggerhappy
sudo systemctl stop triggerhappy

# Run in debug mode
sudo triggerhappy -d /dev/input/event* -f -v

# In another terminal, press keys to see debug output
```

### Log File Locations
- **triggerhappy logs:** `sudo journalctl -u triggerhappy`
- **moOde logs:** `/var/log/moode.log`
- **System logs:** `/var/log/syslog`

### Custom Debug Function
Add to your Python script:
```python
DEBUG = True  # Set to False for production

def debug_print(message):
    if DEBUG:
        print(f"DEBUG: {message}")

# Use in functions:
def play_station(num):
    debug_print(f"Attempting to play station {num}")
    # ... rest of function
```

## Performance Tips

### Optimisation
- **Reduce API timeout:** Modify curl timeout in execute_command()
- **Cache station info:** Store frequently used data
- **Minimise logging:** Disable debug output in production

### Resource Usage
- **CPU:** Minimal impact (<1% when idle)
- **Memory:** Python script uses ~5-10MB RAM
- **Network:** Local HTTP requests only

## Security Considerations

### Network Security
- System designed for trusted local networks only
- No authentication mechanism for commands
- Consider firewall rules for API access

### File Security
```bash
# Secure script permissions
sudo chown root:root /usr/local/bin/moode_numpad_controller.py
sudo chmod 755 /usr/local/bin/moode_numpad_controller.py

# Secure configuration
sudo chown root:root /etc/triggerhappy/triggers.d/numpad-moode.conf
sudo chmod 644 /etc/triggerhappy/triggers.d/numpad-moode.conf
```

## Support and Resources

### Official Documentation
- **moOde Audio:** https://moodeaudio.org
- **moOde Forum:** https://moodeaudio.org/forum
- **triggerhappy:** https://github.com/wertarbyte/triggerhappy

### Community Support
- **GitHub Issues:** Report bugs and request features
- **moOde Forum:** General audio and system questions
- **Raspberry Pi Forums:** Hardware compatibility questions

### Useful Commands Reference
```bash
# Service management
sudo systemctl status triggerhappy
sudo systemctl restart triggerhappy
sudo systemctl enable triggerhappy

# Key testing
sudo evtest
lsusb | grep -i keyboard
ls /dev/input/event*

# API testing
curl "http://moode/command/?cmd=status"
curl "http://moode/command/?cmd=pause"

# Log monitoring
sudo journalctl -u triggerhappy -f
sudo journalctl -u triggerhappy --no-pager

# Database queries
sqlite3 /var/local/www/db/moode-sqlite3.db "SELECT name FROM cfg_radio WHERE type='f';"
```

---

## Python Controller Code

```python
#!/usr/bin/env python3
"""
moOde Audio USB Numpad Controller
Copyright (C) 2025 M Lake

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.
"""

import sys
import subprocess
import json

MOODE_HOST = "moode"  # or use "localhost" or your hostname

# Radio station mappings - need to be a favourite and must match perfectly
STATIONS = {
    '0': 'RADIO/Radio Swiss Jazz.pls',
    '1': 'RADIO/BBC Radio 1 (320K).pls',
    '2': 'RADIO/BBC Radio 2 (320K).pls',
    '3': 'RADIO/BBC Radio 3 (320K).pls',
    '4': 'RADIO/BBC Radio 4 FM (320K).pls',
    '5': 'RADIO/Resonance Radio 104.4 FM.pls',
    '6': 'RADIO/BBC Radio 6 music (320K).pls',
    '7': 'RADIO/France Inter Paris (FIP).pls',
    '8': 'RADIO/RTS - Couleur 3.pls',
    '9': 'RADIO/France Bleu Loire.pls'
}

def execute_command(cmd):
    """Execute moOde REST API command using curl"""
    try:
        result = subprocess.run([
            'curl', '-G', '-s', '-S',
            '--data-urlencode', f'cmd={cmd}',
            f'http://{MOODE_HOST}/command/'
        ], capture_output=True, text=True)
        
        if result.stdout:
            response = json.loads(result.stdout)
            return response
        return None
    except Exception as e:
        print(f"Error executing command: {e}")
        return None

def play_station(num):
    """Play a radio station"""
    if num in STATIONS:
        station = STATIONS[num]
        result = execute_command(f'play_item {station}')
        if result and result.get('info') == 'OK':
            print(f"Playing station: {station}")
        else:
            print(f"Failed to play station: {station}")

def play_pause():
    """Toggle play/pause"""
    execute_command('pause')
    print("Play/pause")

def stop_playback():
    """Stop playback"""
    result = execute_command('stop')
    if result:
        print("Playback stopped")

def next_track():
    """Next track"""
    result = execute_command('next')
    if result:
        print("Next track")

def volume_up():
    """Volume up"""
    result = execute_command('set_volume -up 5')
    if result:
        print("Volume increased")
        print(f"Current volume: {result}")

def volume_down():
    """Volume down"""
    result = execute_command('set_volume -dn 5')
    if result:
        print("Volume decreased")
        print(f"Current volume: {result}")

def previous_track():
    """Previous track"""
    result = execute_command('prev')
    if result:
        print("Previous track")

def shutdown():
    """Shutdown the system safely"""
    print("Initiating shutdown...")
    try:
        subprocess.run(['/usr/local/bin/moode-shutdown'], check=False)
        print("Shutdown command sent")
    except Exception as e:
        print(f"Shutdown failed: {e}")

def show_status():
    """Show current status"""
    result = execute_command('status')
    if result:
        state = result.get('state', 'unknown')
        title = result.get('title', 'No title')
        artist = result.get('artist', 'No artist')
        print(f"Status: {state}")
        print(f"Playing: {artist} - {title}")

def local_music():
    """Switch to local music library"""
    # This would need to be customised based on your setup
    print("Switching to local music...")
    # You might want to play a specific playlist or folder here

def clear():
    """Clear queue and play current selection"""
    execute_command('clear_queue')
    print("Queue cleared")

def random_toggle():
    """Toggle random play mode"""
    result = execute_command('random')
    print("Random mode toggled")

def repeat_toggle():
    """Toggle repeat mode"""
    result = execute_command('repeat')
    print("Repeat mode toggled")

def mute():
    """Toggle mute"""
    result = execute_command('set_volume -mute')
    print("Mute toggled")

if __name__ == "__main__":
    if len(sys.argv) > 1:
        command = sys.argv[1]
        if command in STATIONS.keys():
            play_station(command)
        elif command == "play_pause":
            play_pause()
        elif command == "stop":
            stop_playback()
        elif command == "next":
            next_track()
        elif command == "prev":
            previous_track()
        elif command == "shutdown":
            shutdown()
        elif command == "status":
            show_status()
        elif command == "local":
            local_music()
        elif command == "clear":
            clear()
        elif command == "random":
            random_toggle()
        elif command == "repeat":
            repeat_toggle()
        elif command == "mute":
            mute()
        elif command == "volume_up":
            volume_up()
        elif command == "volume_down":
            volume_down()
        else:
            print(f"Unknown command: {command}")
```

## Triggerhappy Configuration

```bash
# moOde Numpad Controller Configuration
# Format: KEY<TAB>VALUE<TAB>COMMAND

# Radio station keys (0-9)
KEY_KP0 1 /usr/local/bin/numpad-wrapper.sh 0
KEY_KP1 1 /usr/local/bin/numpad-wrapper.sh 1
KEY_KP2 1 /usr/local/bin/numpad-wrapper.sh 2
KEY_KP3 1 /usr/local/bin/numpad-wrapper.sh 3
KEY_KP4 1 /usr/local/bin/numpad-wrapper.sh 4
KEY_KP5 1 /usr/local/bin/numpad-wrapper.sh 5
KEY_KP6 1 /usr/local/bin/numpad-wrapper.sh 6
KEY_KP7 1 /usr/local/bin/numpad-wrapper.sh 7
KEY_KP8 1 /usr/local/bin/numpad-wrapper.sh 8
KEY_KP9 1 /usr/local/bin/numpad-wrapper.sh 9

# Regular number keys
KEY_1 1 /usr/local/bin/numpad-wrapper.sh 1
KEY_2 1 /usr/local/bin/numpad-wrapper.sh 2
KEY_3 1 /usr/local/bin/numpad-wrapper.sh 3
KEY_4 1 /usr/local/bin/numpad-wrapper.sh 4
KEY_5 1 /usr/local/bin/numpad-wrapper.sh 5
KEY_6 1 /usr/local/bin/numpad-wrapper.sh 6
KEY_7 1 /usr/local/bin/numpad-wrapper.sh 7
KEY_8 1 /usr/local/bin/numpad-wrapper.sh 8
KEY_9 1 /usr/local/bin/numpad-wrapper.sh 9
KEY_0 1 /usr/local/bin/numpad-wrapper.sh 0

# Control keys
KEY_KPENTER 1 /usr/local/bin/numpad-wrapper.sh play_pause
KEY_KPDOT 1 /usr/local/bin/numpad-wrapper.sh stop
KEY_KPPLUS 1 /usr/local/bin/numpad-wrapper.sh volume_up
KEY_KPMINUS 1 /usr/local/bin/numpad-wrapper.sh volume_down

# Special function keys
KEY_TAB 1 /usr/local/bin/numpad-wrapper.sh clear
KEY_KPSLASH 1 /usr/local/bin/numpad-wrapper.sh status
KEY_KPASTERISK 1 /usr/local/bin/numpad-wrapper.sh local
KEY_BACKSPACE 1 /usr/local/bin/numpad-wrapper.sh shutdown
KEY_EQUAL 1 /usr/local/bin/numpad-wrapper.sh mute
KEY_CALC 1 /usr/local/bin/numpad-wrapper.sh clear
```
