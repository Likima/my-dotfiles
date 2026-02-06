#!/bin/bash
# SWWW Wallpaper Selector - Rofi with live preview

WALLPAPER_DIR="$HOME/Pictures/Wallpapers"
STATE_FILE="/tmp/wallpaper-selector-state"
FIFO="/tmp/wallpaper-selector-fifo"
PID_FILE="/tmp/wallpaper-preview-pid"

cleanup() {
    [ -f "$PID_FILE" ] && kill "$(cat "$PID_FILE")" 2>/dev/null
    hyprctl keyword windowrulev2 "unset,class:(imv-wallpaper-preview)" &>/dev/null
    rm -f "$STATE_FILE" "$FIFO" "$PID_FILE"
}
trap cleanup EXIT

# Build wallpaper list
mapfile -t WALLPAPERS < <(find "$WALLPAPER_DIR" -type f \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" -o -name "*.webp" -o -name "*.gif" \) -printf "%f\n" | sort)

if [ ${#WALLPAPERS[@]} -eq 0 ]; then
    notify-send "Wallpaper Error" "No wallpapers found in $WALLPAPER_DIR" -u critical
    exit 1
fi

# Get current wallpaper for default selection
CURRENT=$(swww query 2>/dev/null | grep -oP 'image: \K.*' | xargs basename 2>/dev/null)
[ -z "$CURRENT" ] && CURRENT="${WALLPAPERS[0]}"

# Monitor dimensions
eval "$(hyprctl monitors -j | jq -r '.[0] | "MON_W=\(.width) MON_H=\(.height)"')"

# Calculate positions for centered layout
ROFI_W=$((MON_W * 28 / 100))
ROFI_H=$((MON_H * 65 / 100))

PREVIEW_W=$((MON_W * 35 / 100))
PREVIEW_H=$((MON_H * 65 / 100))
GAP=$((MON_W * 2 / 100))

# Center point calculation
TOTAL_W=$((PREVIEW_W + GAP + ROFI_W))
START_X=$(((MON_W - TOTAL_W) / 2))

PREVIEW_X=$START_X
PREVIEW_Y=$(((MON_H - PREVIEW_H) / 2))

ROFI_X=$((START_X + PREVIEW_W + GAP))
ROFI_Y=$(((MON_H - ROFI_H) / 2))

# Window rules
hyprctl keyword windowrulev2 "float,class:(imv-wallpaper-preview)"
hyprctl keyword windowrulev2 "size $PREVIEW_W $PREVIEW_H,class:(imv-wallpaper-preview)"
hyprctl keyword windowrulev2 "move $PREVIEW_X $PREVIEW_Y,class:(imv-wallpaper-preview)"
hyprctl keyword windowrulev2 "noanim,class:(imv-wallpaper-preview)"

# Create FIFO for preview updates
rm -f "$FIFO"
mkfifo "$FIFO"

# Start preview window with imv reading from FIFO
(
    imv -c imv-wallpaper-preview -f -s shrink "$WALLPAPER_DIR/$CURRENT" < "$FIFO" &
    echo $! > "$PID_FILE"
) &

sleep 0.4

# Create preview update script
PREVIEW_SCRIPT="/tmp/wallpaper-preview.sh"
cat > "$PREVIEW_SCRIPT" << 'EOFPREVIEW'
#!/bin/bash
WALLPAPER_DIR="$HOME/Pictures/Wallpapers"
FIFO="/tmp/wallpaper-selector-fifo"
PID_FILE="/tmp/wallpaper-preview-pid"

if [ -n "$1" ] && [ -f "$WALLPAPER_DIR/$1" ]; then
    if [ -p "$FIFO" ]; then
        PID=$(cat "$PID_FILE" 2>/dev/null)
        if [ -n "$PID" ] && kill -0 "$PID" 2>/dev/null; then
            kill "$PID" 2>/dev/null
            sleep 0.05
        fi
        imv -c imv-wallpaper-preview -f -s shrink "$WALLPAPER_DIR/$1" < "$FIFO" &
        echo $! > "$PID_FILE"
    fi
fi
EOFPREVIEW
chmod +x "$PREVIEW_SCRIPT"

# Rofi with preview binding and selection-changed hook
SELECTED=$(printf "%s\n" "${WALLPAPERS[@]}" | rofi -dmenu \
    -i \
    -p " Wallpaper" \
    -theme-str "window { location: center; width: ${ROFI_W}px; height: ${ROFI_H}px; x-offset: $((ROFI_X - MON_W / 2))px; y-offset: 0px; }" \
    -theme-str "listview { lines: 15; scrollbar: true; }" \
    -select "$CURRENT" \
    -format 's' \
    -kb-accept-entry 'Return,KP_Enter' \
    -selection-changed "$PREVIEW_SCRIPT {0}" \
    -no-custom)

# Apply selected wallpaper
if [ -n "$SELECTED" ]; then
    WALLPAPER_PATH="$WALLPAPER_DIR/$SELECTED"
    
    if [ -f "$WALLPAPER_PATH" ]; then
        swww img "$WALLPAPER_PATH" \
            --transition-type grow \
            --transition-pos center \
            --transition-duration 1.5 \
            --transition-fps 60 \
            --transition-bezier 0.65,0,0.35,1

        notify-send "Wallpaper Set" "$SELECTED" -i "$WALLPAPER_PATH" -t 3000
    fi
fi

rm -f "$PREVIEW_SCRIPT"
