#!/bin/bash
# SWWW Wallpaper Selector - fzf list with live imv preview
# Navigate to preview | Enter: apply | Escape: cancel

WALLPAPER_DIR="$HOME/Pictures/Wallpapers"
RESULT_FILE="/tmp/wallpaper-result"
LIST_FILE="/tmp/wallpaper-list"
PID_FILE="/tmp/wallpaper-imv-pid"
PREVIEW_SCRIPT="/tmp/wallpaper-preview.sh"

cleanup() {
    local pid
    pid=$(cat "$PID_FILE" 2>/dev/null)
    [ -n "$pid" ] && kill "$pid" 2>/dev/null
    hyprctl keyword windowrulev2 "unset,class:(imv)" &>/dev/null
    hyprctl keyword windowrulev2 "unset,class:(wallpaper-selector)" &>/dev/null
    rm -f "$RESULT_FILE" "$LIST_FILE" "$PID_FILE" "$PREVIEW_SCRIPT"
}
trap cleanup EXIT

# Build wallpaper list
find "$WALLPAPER_DIR" -type f \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" -o -name "*.webp" -o -name "*.gif" \) -printf "%f\n" | sort > "$LIST_FILE"

if [ ! -s "$LIST_FILE" ]; then
    notify-send "Wallpaper Error" "No wallpapers found in $WALLPAPER_DIR" -u critical
    exit 1
fi

# Monitor dimensions
eval "$(hyprctl monitors -j | jq -r '.[0] | "MON_W=\(.width) MON_H=\(.height)"')"

# Layout: imv left 48%, gap 2%, fzf right 48%
IMV_W=$((MON_W * 48 / 100))
IMV_H=$((MON_H * 80 / 100))
IMV_X=$((MON_W * 2 / 100))
IMV_Y=$(((MON_H - IMV_H) / 2))

TERM_W=$((MON_W * 48 / 100))
TERM_H=$IMV_H
TERM_X=$((MON_W * 50 / 100))
TERM_Y=$IMV_Y

# Window rules for positioning
hyprctl keyword windowrulev2 "float,class:(imv)"
hyprctl keyword windowrulev2 "size $IMV_W $IMV_H,class:(imv)"
hyprctl keyword windowrulev2 "move $IMV_X $IMV_Y,class:(imv)"
hyprctl keyword windowrulev2 "float,class:(wallpaper-selector)"
hyprctl keyword windowrulev2 "size $TERM_W $TERM_H,class:(wallpaper-selector)"
hyprctl keyword windowrulev2 "move $TERM_X $TERM_Y,class:(wallpaper-selector)"

# Preview helper: kills old imv, starts new one, saves PID
cat > "$PREVIEW_SCRIPT" << EOF
#!/bin/bash
OLD_PID=\$(cat "$PID_FILE" 2>/dev/null)
[ -n "\$OLD_PID" ] && kill "\$OLD_PID" 2>/dev/null
imv "$WALLPAPER_DIR/\$1" &
echo \$! > "$PID_FILE"
EOF
chmod +x "$PREVIEW_SCRIPT"

# Start imv with first wallpaper
FIRST=$(head -1 "$LIST_FILE")
imv "$WALLPAPER_DIR/$FIRST" &
echo $! > "$PID_FILE"
sleep 0.5

# Run fzf in kitty
rm -f "$RESULT_FILE"
kitty --class wallpaper-selector \
    -o font_size=14 \
    -o window_padding_width=16 \
    -e bash -c "
        fzf --layout=reverse \
            --prompt=' Wallpaper > ' \
            --header='Enter: apply | Escape: cancel' \
            --bind 'focus:execute-silent($PREVIEW_SCRIPT {})' \
            < '$LIST_FILE' > '$RESULT_FILE'
    "

# Apply selected wallpaper
if [ -f "$RESULT_FILE" ] && [ -s "$RESULT_FILE" ]; then
    SELECTED=$(cat "$RESULT_FILE")
    swww img "$WALLPAPER_DIR/$SELECTED" \
        --transition-type grow \
        --transition-pos center \
        --transition-duration 1.5 \
        --transition-fps 60 \
        --transition-bezier 0.65,0,0.35,1

    notify-send "Wallpaper Set" "$SELECTED" -i "$WALLPAPER_DIR/$SELECTED" -t 3000
fi
