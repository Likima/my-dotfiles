#!/bin/bash
# SWWW Wallpaper Changer Script - Tokyo Night Theme
# Randomly selects and sets a wallpaper with smooth transitions

WALLPAPER_DIR="$HOME/Pictures/Wallpapers"

# Available transition types
TRANSITIONS=(
    "grow"
    "wave"
    "wipe"
    "center"
    "fade"
    "outer"
    "random"
)

# Get random transition
TRANSITION=${TRANSITIONS[$RANDOM % ${#TRANSITIONS[@]}]}

# Get random wallpaper
WALLPAPER=$(find "$WALLPAPER_DIR" -type f \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" -o -name "*.webp" \) | shuf -n 1)

if [ -z "$WALLPAPER" ]; then
    notify-send "Wallpaper Error" "No wallpapers found in $WALLPAPER_DIR" -u critical
    exit 1
fi

# Set wallpaper with transition
swww img "$WALLPAPER" \
    --transition-type "$TRANSITION" \
    --transition-pos center \
    --transition-duration 1.5 \
    --transition-fps 60 \
    --transition-bezier 0.65,0,0.35,1

# Send notification
FILENAME=$(basename "$WALLPAPER")
notify-send "Wallpaper Changed" "$FILENAME" -i "$WALLPAPER" -t 3000