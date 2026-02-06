#!/bin/bash
# Rofi wallpaper modi script with live preview

WALLPAPER_DIR="$HOME/Pictures/Wallpapers"
PREVIEW_FILE="/tmp/wallpaper-preview.jpg"

update_preview() {
    local img="$WALLPAPER_DIR/$1"
    if [ -f "$img" ]; then
        # Quick resize for preview
        convert "$img" -resize 440x400^ -gravity center -extent 440x400 "$PREVIEW_FILE" 2>/dev/null || cp "$img" "$PREVIEW_FILE"
        # Signal rofi to refresh (if possible)
        pkill -SIGUSR1 rofi 2>/dev/null
    fi
}

if [ -z "$@" ]; then
    # Initial call - list all wallpapers
    find "$WALLPAPER_DIR" -type f \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" -o -name "*.webp" -o -name "*.gif" \) -printf "%f\n" | sort
else
    # Selection made
    SELECTED="$@"
    update_preview "$SELECTED"
    
    # Return selection to apply
    coproc {
        swww img "$WALLPAPER_DIR/$SELECTED" \
            --transition-type grow \
            --transition-pos center \
            --transition-duration 1.5 \
            --transition-fps 60 \
            --transition-bezier 0.65,0,0.35,1
        notify-send "Wallpaper Set" "$SELECTED" -i "$WALLPAPER_DIR/$SELECTED" -t 3000
    }
fi
