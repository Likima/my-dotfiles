#!/bin/bash
# SWWW Wallpaper Selector using Rofi - Tokyo Night Theme

WALLPAPER_DIR="$HOME/Pictures/Wallpapers"

# Get list of wallpapers
WALLPAPERS=$(find "$WALLPAPER_DIR" -type f \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" -o -name "*.webp" -o -name "*.gif" \) -printf "%f\n" | sort)

if [ -z "$WALLPAPERS" ]; then
    notify-send "Wallpaper Error" "No wallpapers found in $WALLPAPER_DIR" -u critical
    exit 1
fi

# Show rofi menu
SELECTED=$(echo "$WALLPAPERS" | rofi -dmenu -p "Wallpaper" -theme ~/.config/rofi/config.rasi)

if [ -n "$SELECTED" ]; then
    swww img "$WALLPAPER_DIR/$SELECTED" \
        --transition-type grow \
        --transition-pos center \
        --transition-duration 1.5 \
        --transition-fps 60 \
        --transition-bezier 0.65,0,0.35,1
    
    notify-send "Wallpaper Set" "$SELECTED" -i "$WALLPAPER_DIR/$SELECTED" -t 3000
fi