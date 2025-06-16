#!/usr/bin/env python3
"""
moOde Audio USB Numpad Controller
Copyright (C) 2025 [M Lake]

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

# Radio station mappings - need to be a favourite and station names must match perfectly
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
    """Increase volume"""
    result = execute_command('set_volume -up 5')
        print("Volume increased")


def volume_down():
    result = execute_command('set_volume -dn 5')
        print("Volume decreased")

def previous_track():
    """Previous track"""
    result = execute_command('prev')
    if result:
        print("Previous track")

def shutdown():
    """Shutdown the system safely"""
    print("Initiating shutdown...")
    try:
        subprocess.call(['/var/local/www/commandw/restart.sh', 'poweroff'])
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
    # This would need to be customized based on your setup
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
