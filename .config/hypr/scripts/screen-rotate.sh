#!/bin/bash
# filepath: ~/.config/hypr/scripts/screen-rotate.sh

# Get your monitor name (run `hyprctl monitors` to verify)
MONITOR="eDP-1"

# Function to rotate screen without changing scale
rotate_screen() {
    case $1 in
        "normal")
            hyprctl keyword monitor "$MONITOR,preferred,auto,auto,transform,0"
            ;;
        "left-up")
            hyprctl keyword monitor "$MONITOR,preferred,auto,auto,transform,1"
            ;;
        "bottom-up")
            hyprctl keyword monitor "$MONITOR,preferred,auto,auto,transform,2"
            ;;
        "right-up")
            hyprctl keyword monitor "$MONITOR,preferred,auto,auto,transform,3"
            ;;
    esac
}

# Kill any existing instances
pkill -f "monitor-sensor"

# Monitor orientation changes
monitor-sensor 2>/dev/null | while read -r line; do
    echo "Sensor: $line"  # Debug output
    case "$line" in
        *"Accelerometer orientation changed: normal"*)
            rotate_screen "normal"
            ;;
        *"Accelerometer orientation changed: left-up"*)
            rotate_screen "left-up"
            ;;
        *"Accelerometer orientation changed: bottom-up"*)
            rotate_screen "bottom-up"
            ;;
        *"Accelerometer orientation changed: right-up"*)
            rotate_screen "right-up"
            ;;
    esac
done