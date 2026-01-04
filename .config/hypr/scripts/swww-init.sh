#!/bin/bash
# SWWW Wallpaper Initialization Script

# Start swww daemon if not running
if ! pgrep -x "swww-daemon" > /dev/null; then
    swww-daemon &
    sleep 1
fi

# Set default wallpaper with transition
WALLPAPER="${1:-$HOME/Pictures/Wallpapers/sunset.jpg}"

# Check if file is a GIF - use simple transition to avoid stalling
if [[ "$WALLPAPER" == *.gif ]]; then
    swww img "$WALLPAPER" \
        --transition-type simple \
        --transition-duration 0.5
else
    swww img "$WALLPAPER" \
        --transition-type grow \
        --transition-pos center \
        --transition-duration 1 \
        --transition-fps 60
fi