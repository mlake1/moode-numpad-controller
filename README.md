# moOde Audio USB Numpad Controller

> ⚠️ **Early Development Notice**: This is a personal project and is in early development and has not been extensively tested. Please test thoroughly before relying on it for critical applications. Issues and feedback are welcome!

Utilises a standard number pad to control playback, volume, radio stations, and system functions with physical keys. My aim was to have music playing with a single key press and without the need for a phone or screen.

![moOde Controller](https://img.shields.io/badge/moOde-9.x-blue) ![Platform](https://img.shields.io/badge/platform-Raspberry%20Pi-red) ![License](https://img.shields.io/badge/license-GPL%20v3-green)


![Screenshot 2025-06-14 181729](https://github.com/user-attachments/assets/13e4de6a-72a8-46cb-8da8-68671670ec4c)

This shows all the features - stations and functions can all be updated with the config files
The HTML template file is inclued and can be updated as desired.

## 📊 Using This Project?
I'd love to hear from you! Please:
- ⭐ Star the repository if it's useful
- 🐛 Report issues you encounter  
- 💡 Suggest features you'd like
- 📸 Share photos of your setup
- 💬 Join the discussion in Issues

## Key Features

- **Radio Station Selection**: Direct access to 10 favorite radio stations (keys 0-9)
- **Playback Control**: Play/pause, stop, next/previous track
- **Volume Management**: Volume up/down, mute toggle
- **System Functions**: Queue management, status display, safe shutdown
- **Real-time Response**: Hardware key detection with minimal latency
- **Extensible Design**: Easy to add new functions and customise key mappings

## System Architecture

```
Physical Key Press → triggerhappy → Bash Wrapper → Python Controller → moOde REST API → Audio Action
```

## Hardware Requirements

### Raspberry Pi
- Only tested so far on Pi 4
- Raspberry Pi 3/4/5, 400/500, CM3/4/5, or Zero 2 W
- Running moOde Audio 9.x series

### USB Numpad
**✅ Recommended: Kensington Wired Numeric Keypad model: K79820WW **
- [Product Link](https://www.kensington.com/en-gb/p/products/control/keyboards/wired-numeric-keypad/)
- Detected as: "Homertech USB Keyboard" (USB ID: 276d:1160)
- Full Linux HID compliance, works perfectly with triggerhappy

**❌ Known Incompatible: Targus AKP10EU**
- Firmware defect found with non-standard USB-HID implementation
- Sends KEY_NUMLOCK events with every key press
- Incompatible with Linux input event systems

**🔍 Likely Compatible (Community Testing Needed)**
- Cherry Numpads KC 1000 SC, G84-4700, Stream series
- Need testing: Community reports welcome!

**Other Standard Brands**
 - Logitech, Microsoft, Dell, HP OEM numpads should work OK
 - Most mechanical keyboard brand numpads
 - Requirement: Must use standard USB HID implementation, if they follow the standards they should work perfectly, however it's generally not      possible to tell which controller they use prior to purchase

**To Test Follow These Steps:**
 - 1. Check USB detection
 '''bash
lsusb | grep -i keyboard
'''
- 2. Test key detection  
'''bash
sudo evtest
'''
 - 3. Look for standard KEY_KP codes
 - Should see: KEY_KP0, KEY_KP1, etc. (not custom codes)

**#Community Contributions: Please report your hardware compatibility results!**

## 🚀 Quick Start

### 1. Install Dependencies
```bash
sudo apt update
sudo apt install triggerhappy python3 curl
```

### 2. Clone Repository
```bash
git clone https://github.com/mlake1/moode-numpad-controller.git
cd moode-numpad-controller
```

### 3. Run Installation Script
```bash
sudo ./install.sh
```

### 4. Configure Your Radio Stations
Edit the station mappings in `moode_numpad_controller.py`:
```python
STATIONS = {
    '0': 'RADIO/Your Station 1.pls',
    '1': 'RADIO/Your Station 2.pls',
    # ... customise with your favorites
}
```

### 5. Start the Service
```bash
sudo systemctl restart triggerhappy
```

## 📁 File Structure

```
moode-numpad-controller/
├── README.md
├── install.sh
├── src/
│   ├── moode_numpad_controller.py
│   ├── numpad-wrapper.sh
│   └── numpad-moode.conf
└── docs/
    └── SETUP.md
```

## 🎹 Key Mappings - these can be updated as desired

### Radio Stations (Numpad 0-9)
| Key | Default Station |
|-----|----------------|
| 0 | Radio Swiss Jazz |
| 1 | BBC Radio 1 |
| 2 | BBC Radio 2 |
| 3 | BBC Radio 3 |
| 4 | BBC Radio 4 FM |
| 5 | Resonance Radio 104.4 FM |
| 6 | BBC Radio 6 Music |
| 7 | France Inter Paris |
| 8 | RTS - Couleur 3 |
| 9 | France Bleu Loire |

### Control Keys
| Key | Function |
|-----|----------|
| Enter | Play/Pause |
| . (Dot) | Stop |
| + (Plus) | Volume Up |
| - (Minus) | Volume Down |
| = (Equal) | Mute Toggle |

### Special Functions
| Key | Function |
|-----|----------|
| Tab | Clear Queue |
| / (Slash) | Show Status |
| * (Asterisk) | Local Music |
| Backspace | not working yet ~~Safe Shutdown~~ |
| Calculator | Clear Queue |

## 🛠️ Manual Installation

### 1. Create Wrapper Script
```bash
sudo nano /usr/local/bin/numpad-wrapper.sh
```
```bash
#!/bin/bash
/usr/bin/python3 /usr/local/bin/moode_numpad_controller.py "$1"
```
```bash
sudo chmod +x /usr/local/bin/numpad-wrapper.sh
```

### 2. Install Python Controller
```bash
sudo cp src/moode_numpad_controller.py /usr/local/bin/
sudo chmod +x /usr/local/bin/moode_numpad_controller.py
```

### 3. Configure Triggerhappy
```bash
sudo cp src/numpad-moode.conf /etc/triggerhappy/triggers.d/
sudo systemctl restart triggerhappy
```

### 4. Safe Shutdown
Safe shutdown functionality 
For this to work triggerhappy needs to run as moode default is running as nobody user which lacks sudo privileges

 /lib/systemd/system/triggerhappy.service
 change User=nobody to User=moode

 commands to run:
sudo nano /lib/systemd/system/triggerhappy.service
sudo systemctl daemon-reload
sudo systemctl restart triggerhappy

## 🔍 Setup Verification

### Test USB Numpad Detection
```bash
# Check USB device
lsusb | grep -i keyboard

# List input devices
ls /dev/input/event*
```

### Discover Key Codes
```bash
# Interactive key testing
sudo evtest

# Monitor triggerhappy logs
sudo journalctl -u triggerhappy -f
```

### Find Radio Stations
```bash
# Query moOde database
sqlite3 /var/local/www/db/moode-sqlite3.db "SELECT name FROM cfg_radio WHERE type='f';"

# Check radio directory
ls -la /var/lib/mpd/music/RADIO/
```

## Configuration

### Customise Radio Stations
1. Add stations to moOde favorites via web interface
2. Update `STATIONS` dictionary in `moode_numpad_controller.py`
3. Use exact station names including `.pls` extension

### Add New Functions
1. Create function in Python controller:
```python
def your_function():
    """Your custom function"""
    result = execute_command('your_moode_command')
    print("Function executed")
```

2. Add to command handler:
```python
elif command == "your_command":
    your_function()
```

3. Add key mapping to `numpad-moode.conf`:
```
KEY_YOURKEY 1 /usr/local/bin/numpad-wrapper.sh your_command
```

4. Restart triggerhappy:
```bash
sudo systemctl restart triggerhappy
```

## Troubleshooting

### Keys Not Responding
```bash
# Check triggerhappy status
sudo systemctl status triggerhappy

# Monitor key events
sudo evtest

# Check logs
sudo journalctl -u triggerhappy -f
```

### API Commands Failing
```bash
# Test API directly
curl "http://moode/command/?cmd=status"

# Check connectivity
ping moode

# Verify moOde web interface
http://moode
```

### Radio Stations Not Playing
- Verify exact station names match moOde favorites
- Check stations work in moOde web interface
- Ensure stations are properly added to favorites

## moOde API Reference

### Commands Used
| Command | Purpose |
|---------|---------|
| `pause` | Toggle play/pause |
| `stop` | Stop playback |
| `next` / `prev` | Skip tracks |
| `set_volume -up 5` | Volume control |
| `set_volume -mute` | Toggle mute |
| `play_item {station}` | Play radio station |
| `clear_queue` | Clear queue |
| `random` / `repeat` | Toggle modes |
| `status` | Get current status |

### API Format
```bash
curl -G "http://moode/command/" --data-urlencode "cmd=COMMAND"
```

## 📊 Performance

- **Response Time**: 100-500ms per command
- **System Load**: Minimal impact on moOde
- **Memory Usage**: <10MB RAM
- **Network**: Local HTTP requests only

## 🔒 Security Notes

- Designed for trusted local network use
- No authentication required for commands
- Physical access can shutdown system
- Scripts run with standard user privileges

## ⚠️ Project Status

**Current Version**: v1.0 (Early Development)

This project has been tested with:
- ✅ Raspberry Pi 4 running moOde Audio 9.3.x
- ✅ Kensington Wired Numeric Keypad (USB ID: 276d:1160)
- ✅ Basic playback and volume control functions
- ✅ Radio station selection (0-9 keys)

**Not yet tested**:
- Other Raspberry Pi models (3, 5, Zero 2W, etc.)
- Different USB numpad models
- Various moOde Audio versions
- Extended uptime/reliability testing

**Please report**:
- Hardware compatibility results
- Bug reports and issues
- Feature requests and improvements

## 🚧 Known Issues & Future Work

### Current Limitations
- **Safe Shutdown**: The Backspace key shutdown function is not working reliably due to permission/authentication issues with triggerhappy context
- **Volume API**: Some volume commands may need refinement for optimal response

### Planned Improvements
- [X] F̶i̶x̶ ̶s̶a̶f̶e̶ ̶s̶h̶u̶t̶d̶o̶w̶n̶ ̶f̶u̶n̶c̶t̶i̶o̶n̶a̶l̶i̶t̶y̶ ̶w̶i̶t̶h̶ ̶p̶r̶o̶p̶e̶r̶ ̶p̶r̶i̶v̶i̶l̶e̶g̶e̶ ̶e̶s̶c̶a̶l̶a̶t̶i̶o̶n- SOLVED
- [ ] Add configuration file for easier station management
- [ ] Implement station cycling feature
- [ ] Add display output for current status
- [ ] Create web interface for key mapping configuration
- [ ] Add support for playlist management

 ̶#̶#̶#̶ ̶S̶a̶f̶e̶ ̶S̶h̶u̶t̶d̶o̶w̶n̶ ̶D̶e̶v̶e̶l̶o̶p̶m̶e̶n̶t̶ ̶N̶o̶t̶e̶s̶  SOLVED
-̶T̶h̶e̶ ̶s̶h̶u̶t̶d̶o̶w̶n̶ ̶f̶u̶n̶c̶t̶i̶o̶n̶ ̶f̶a̶c̶e̶s̶ ̶c̶h̶a̶l̶l̶e̶n̶g̶e̶s̶ ̶d̶u̶e̶ ̶t̶o̶:̶
̶-̶ ̶t̶r̶i̶g̶g̶e̶r̶h̶a̶p̶p̶y̶ ̶r̶u̶n̶n̶i̶n̶g̶ ̶i̶n̶ ̶r̶e̶s̶t̶r̶i̶c̶t̶e̶d̶ ̶c̶o̶n̶t̶e̶x̶t̶
̶-̶ ̶s̶y̶s̶t̶e̶m̶d̶ ̶a̶u̶t̶h̶e̶n̶t̶i̶c̶a̶t̶i̶o̶n̶ ̶r̶e̶q̶u̶i̶r̶e̶m̶e̶n̶t̶s̶
̶-̶ ̶s̶e̶t̶u̶i̶d̶ ̶s̶c̶r̶i̶p̶t̶ ̶l̶i̶m̶i̶t̶a̶t̶i̶o̶n̶s̶ ̶w̶i̶t̶h̶ ̶m̶o̶d̶e̶r̶n̶ ̶L̶i̶n̶u̶x̶ ̶s̶e̶c̶u̶r̶i̶t̶y̶

 ̶*̶*̶P̶o̶t̶e̶n̶t̶i̶a̶l̶ ̶s̶o̶l̶u̶t̶i̶o̶n̶s̶ ̶b̶e̶i̶n̶g̶ ̶i̶n̶v̶e̶s̶t̶i̶g̶a̶t̶e̶d̶:̶*̶*̶
̶1̶.̶ ̶C̶u̶s̶t̶o̶m̶ ̶s̶y̶s̶t̶e̶m̶d̶ ̶s̶e̶r̶v̶i̶c̶e̶ ̶f̶o̶r̶ ̶s̶h̶u̶t̶d̶o̶w̶n̶
̶2̶.̶ ̶G̶P̶I̶O̶-̶b̶a̶s̶e̶d̶ ̶h̶a̶r̶d̶w̶a̶r̶e̶ ̶s̶h̶u̶t̶d̶o̶w̶n̶ ̶c̶i̶r̶c̶u̶i̶t̶
̶3̶.̶ ̶A̶l̶t̶e̶r̶n̶a̶t̶i̶v̶e̶ ̶p̶r̶i̶v̶i̶l̶e̶g̶e̶ ̶e̶s̶c̶a̶l̶a̶t̶i̶o̶n̶ ̶m̶e̶t̶h̶o̶d̶s̶
̶4̶.̶ ̶I̶n̶t̶e̶g̶r̶a̶t̶i̶o̶n̶ ̶w̶i̶t̶h̶ ̶m̶o̶O̶d̶e̶'̶s̶ ̶e̶x̶i̶s̶t̶i̶n̶g̶ ̶s̶h̶u̶t̶d̶o̶w̶n̶ ̶m̶e̶c̶h̶a̶n̶i̶s̶m̶s̶

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the GNU General Public License v3.0 - see the [LICENSE](LICENSE) file for details.

This license choice ensures that:
- Any improvements or modifications must be shared back to the community
- The project remains free and open source forever
- Commercial use is allowed but derivatives must also be GPL v3
- Patent protection is included
- Aligns with moOde Audio's licensing philosophy

## 🙏 Acknowledgments

- [moOde Audio](https://moodeaudio.org) - Fantastic Project!
- [triggerhappy](https://github.com/wertarbyte/triggerhappy) - Linux input event daemon
- Tibs

## Support

- **Issues**: [GitHub Issues](https://github.com/malake1/moode-numpad-controller/issues)
- **moOde Forum**: [moodeaudio.org/forum](https://moodeaudio.org/forum) - very supportive and supportive community
- **Documentation**: [Full Setup Guide](docs/SETUP.md)
