#!/bin/bash

# Theme Switcher - Rofi menu for selecting themes
# Bound to $mainMod SHIFT, T in keybinds.conf

THEME_DIR="$(cd "$(dirname "$0")" && pwd)"
THEMES_DIR="$THEME_DIR/themes"

# Get available themes
THEMES=$(ls "$THEMES_DIR/" | sed 's/\.conf$//' | sort)

# Get current theme
CURRENT=$(cat "$THEME_DIR/current" 2>/dev/null || echo "none")

# Show rofi menu
SELECTED=$(echo "$THEMES" | rofi -dmenu \
    -p "Theme" \
    -mesg "Current: $CURRENT" \
    -theme-str 'window { width: 300px; }' \
    -theme-str 'listview { lines: 5; }')

# Apply selected theme
if [[ -n "$SELECTED" ]]; then
    "$THEME_DIR/apply.sh" "$SELECTED"
fi
