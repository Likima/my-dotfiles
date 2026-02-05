#!/bin/bash

# Theme Switcher - Rofi menu with palette previews
# Bound to $mainMod SHIFT, T in keybinds.conf

THEME_DIR="$(cd "$(dirname "$0")" && pwd)"
THEMES_DIR="$THEME_DIR/themes"
PALETTE_DIR="/tmp/theme-palettes"

# Get current theme
CURRENT=$(cat "$THEME_DIR/current" 2>/dev/null || echo "none")

# Generate palette swatch images if magick is available
HAS_MAGICK=false
if command -v magick &>/dev/null; then
    HAS_MAGICK=true
    mkdir -p "$PALETTE_DIR"
    for theme_file in "$THEMES_DIR"/*.conf; do
        theme_name=$(basename "$theme_file" .conf)
        palette="$PALETTE_DIR/$theme_name.png"

        # Skip if palette is cached and theme hasn't changed
        [ -f "$palette" ] && [ ! "$theme_file" -nt "$palette" ] && continue

        # Source theme in subshell and generate 3x3 color grid
        (
            source "$theme_file"
            magick montage \
                \( -size 50x50 xc:"$BG" \) \
                \( -size 50x50 xc:"$BG_SURFACE" \) \
                \( -size 50x50 xc:"$FG" \) \
                \( -size 50x50 xc:"$ACCENT" \) \
                \( -size 50x50 xc:"$GREEN" \) \
                \( -size 50x50 xc:"$RED" \) \
                \( -size 50x50 xc:"$YELLOW" \) \
                \( -size 50x50 xc:"$MAGENTA" \) \
                \( -size 50x50 xc:"$CYAN" \) \
                -tile 3x3 -geometry 50x50+2+2 -background none \
                "$palette" 2>/dev/null
        )
    done
fi

# Build rofi entry list with palette icons
entries=""
for theme_file in "$THEMES_DIR"/*.conf; do
    theme_name=$(basename "$theme_file" .conf)
    if $HAS_MAGICK; then
        palette="$PALETTE_DIR/$theme_name.png"
        entries+="${theme_name}\0icon\x1f${palette}\n"
    else
        entries+="${theme_name}\n"
    fi
done

# Build rofi arguments
rofi_args=(-dmenu -p " Theme" -mesg "Current: $CURRENT")
if $HAS_MAGICK; then
    rofi_args+=(
        -theme-str 'window { width: 700px; }'
        -theme-str 'listview { lines: 5; }'
        -theme-str 'element-icon { size: 150px; border-radius: 8px; }'
        -theme-str 'element-text { vertical-align: 0.5; }'
    )
else
    rofi_args+=(
        -theme-str 'window { width: 300px; }'
        -theme-str 'listview { lines: 5; }'
    )
fi

# Show rofi menu
SELECTED=$(echo -en "$entries" | rofi "${rofi_args[@]}")

# Apply selected theme
if [[ -n "$SELECTED" ]]; then
    "$THEME_DIR/apply.sh" "$SELECTED"
fi
