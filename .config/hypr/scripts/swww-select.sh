#!/bin/bash
# SWWW Wallpaper Selector with thumbnail previews

WALLPAPER_DIR="$HOME/Pictures/Wallpapers"
THUMB_DIR="/tmp/wallpaper-thumbs"
THUMB_SIZE="300x200"

# Get list of wallpapers
WALLPAPERS=$(find "$WALLPAPER_DIR" -type f \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" -o -name "*.webp" -o -name "*.gif" \) -printf "%f\n" | sort)

if [ -z "$WALLPAPERS" ]; then
    notify-send "Wallpaper Error" "No wallpapers found in $WALLPAPER_DIR" -u critical
    exit 1
fi

# Generate thumbnails if magick is available
HAS_MAGICK=false
if command -v magick &>/dev/null; then
    HAS_MAGICK=true
    mkdir -p "$THUMB_DIR"
    while IFS= read -r name; do
        src="$WALLPAPER_DIR/$name"
        thumb="$THUMB_DIR/${name%.*}.png"
        if [ ! -f "$thumb" ] || [ "$src" -nt "$thumb" ]; then
            magick "$src" -thumbnail "${THUMB_SIZE}^" -gravity center -extent "$THUMB_SIZE" "$thumb" 2>/dev/null
        fi
    done <<< "$WALLPAPERS"
fi

# Build rofi entry list
entries=""
while IFS= read -r name; do
    if $HAS_MAGICK; then
        thumb="$THUMB_DIR/${name%.*}.png"
        entries+="${name}\0icon\x1f${thumb}\n"
    else
        entries+="${name}\n"
    fi
done <<< "$WALLPAPERS"

# Build rofi arguments
rofi_args=(-dmenu -p " Wallpaper" -theme ~/.config/rofi/config.rasi)
if $HAS_MAGICK; then
    rofi_args+=(
        -theme-str 'window { width: 900px; }'
        -theme-str 'listview { lines: 4; }'
        -theme-str 'element-icon { size: 150px; border-radius: 8px; }'
        -theme-str 'element-text { vertical-align: 0.5; }'
    )
fi

# Show rofi menu
SELECTED=$(echo -en "$entries" | rofi "${rofi_args[@]}")

if [ -n "$SELECTED" ]; then
    swww img "$WALLPAPER_DIR/$SELECTED" \
        --transition-type grow \
        --transition-pos center \
        --transition-duration 1.5 \
        --transition-fps 60 \
        --transition-bezier 0.65,0,0.35,1

    notify-send "Wallpaper Set" "$SELECTED" -i "$WALLPAPER_DIR/$SELECTED" -t 3000
fi
