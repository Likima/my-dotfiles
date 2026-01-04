#!/bin/bash
# filepath: /home/brandon/.config/waybar/scripts/spotify_wave.sh

status=$(playerctl --player=spotify status 2>/dev/null)
if [ "$status" = "Playing" ]; then
    notify-send -t 2000 -h string:x-canonical-private-synchronous:spotify "Spotify" "🎵 ▂▄▆█▆▄▂"
else
    notify-send -t 2000 -h string:x-canonical-private-synchronous:spotify "Spotify" "Paused"
fi