#!/bin/bash
# SWWW Wallpaper Initialization Script

# Start swww daemon if not running
if ! pgrep -x "swww-daemon" > /dev/null; then
    swww-daemon &
    sleep 1
fi

# Read wallpaper from current theme
THEME_DIR="$HOME/.config/theme"
CURRENT_THEME=$(cat "$THEME_DIR/current" 2>/dev/null)
THEME_WALLPAPER=""
if [[ -n "$CURRENT_THEME" && -f "$THEME_DIR/themes/${CURRENT_THEME}.conf" ]]; then
    THEME_WALLPAPER=$(grep '^WALLPAPER=' "$THEME_DIR/themes/${CURRENT_THEME}.conf" | cut -d'"' -f2)
fi

# Use theme wallpaper, argument override, or fallback
if [[ -n "$1" ]]; then
    WALLPAPER="$1"
elif [[ -n "$THEME_WALLPAPER" && -f "$HOME/Pictures/Wallpapers/$THEME_WALLPAPER" ]]; then
    WALLPAPER="$HOME/Pictures/Wallpapers/$THEME_WALLPAPER"
else
    WALLPAPER="$HOME/Pictures/Wallpapers/a_mountain_with_trees_and_moon.jpg"
fi

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