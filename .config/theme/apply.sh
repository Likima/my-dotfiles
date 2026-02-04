#!/bin/bash

# Theme Apply Script
# Usage: apply.sh <theme-name>
# Processes template files with theme colors and reloads services

THEME_DIR="$(cd "$(dirname "$0")" && pwd)"
TEMPLATES_DIR="$THEME_DIR/templates"
THEMES_DIR="$THEME_DIR/themes"
CONFIG_DIR="$HOME/.config"

# --- Argument handling ---

if [[ -z "$1" ]]; then
    echo "Usage: apply.sh <theme-name>"
    echo "Available themes:"
    ls "$THEMES_DIR/" | sed 's/\.conf$//'
    exit 1
fi

THEME_NAME="$1"
THEME_FILE="$THEMES_DIR/${THEME_NAME}.conf"

if [[ ! -f "$THEME_FILE" ]]; then
    echo "Error: Theme '$THEME_NAME' not found at $THEME_FILE"
    exit 1
fi

# --- Source theme ---

source "$THEME_FILE"

# --- Format conversion functions ---

# Strip '#' from hex color: #rrggbb -> rrggbb
nohash() {
    echo "${1#\#}"
}

# Convert hex to decimal RGB: #rrggbb -> R, G, B
hex_to_dec() {
    local hex="${1#\#}"
    local r=$((16#${hex:0:2}))
    local g=$((16#${hex:2:2}))
    local b=$((16#${hex:4:2}))
    echo "$r, $g, $b"
}

# --- Build sed expression ---

# All template variables and their hex values
declare -A VARS=(
    [BG]="$BG"
    [BG_DARK]="$BG_DARK"
    [BG_HIGHLIGHT]="$BG_HIGHLIGHT"
    [BG_SURFACE]="$BG_SURFACE"
    [BG_SELECTED]="$BG_SELECTED"
    [FG]="$FG"
    [FG_DARK]="$FG_DARK"
    [BLUE]="$BLUE"
    [CYAN]="$CYAN"
    [GREEN]="$GREEN"
    [MAGENTA]="$MAGENTA"
    [RED]="$RED"
    [YELLOW]="$YELLOW"
    [ORANGE]="$ORANGE"
    [ACCENT]="$ACCENT"
    [BORDER_ACTIVE]="$BORDER_ACTIVE"
    [BORDER_INACTIVE]="$BORDER_INACTIVE"
    [SELECTION_BG]="$SELECTION_BG"
    [SELECTION_FG]="$SELECTION_FG"
    [URL_COLOR]="$URL_COLOR"
    [CURSOR]="$CURSOR"
    [CURSOR_TEXT]="$CURSOR_TEXT"
    [TAB_ACTIVE_BG]="$TAB_ACTIVE_BG"
    [TAB_ACTIVE_FG]="$TAB_ACTIVE_FG"
    [TAB_INACTIVE_BG]="$TAB_INACTIVE_BG"
    [TAB_INACTIVE_FG]="$TAB_INACTIVE_FG"
    [KITTY_BORDER_ACTIVE]="$KITTY_BORDER_ACTIVE"
    [KITTY_BORDER_INACTIVE]="$KITTY_BORDER_INACTIVE"
    [COLOR0]="$COLOR0"
    [COLOR1]="$COLOR1"
    [COLOR2]="$COLOR2"
    [COLOR3]="$COLOR3"
    [COLOR4]="$COLOR4"
    [COLOR5]="$COLOR5"
    [COLOR6]="$COLOR6"
    [COLOR7]="$COLOR7"
    [COLOR8]="$COLOR8"
    [COLOR9]="$COLOR9"
    [COLOR10]="$COLOR10"
    [COLOR11]="$COLOR11"
    [COLOR12]="$COLOR12"
    [COLOR13]="$COLOR13"
    [COLOR14]="$COLOR14"
    [COLOR15]="$COLOR15"
    [COLOR16]="$COLOR16"
    [COLOR17]="$COLOR17"
    [WALLPAPER]="$WALLPAPER"
)

# Build the sed command with all replacements
build_sed() {
    local sed_args=""

    for var in "${!VARS[@]}"; do
        local val="${VARS[$var]}"
        # Standard @VAR@ -> #rrggbb (or plain string for WALLPAPER)
        sed_args+="s|@${var}@|${val}|g;"

        # Only generate format variants for hex color values
        if [[ "$val" == \#* ]]; then
            # @_NOHASH_VAR@ -> rrggbb (for Hyprland rgba)
            sed_args+="s|@_NOHASH_${var}@|$(nohash "$val")|g;"

            # @_DEC_VAR@ -> R, G, B (for hyprlock decimal)
            sed_args+="s|@_DEC_${var}@|$(hex_to_dec "$val")|g;"
        fi
    done

    echo "$sed_args"
}

SED_EXPR=$(build_sed)

# --- Process templates ---

apply_template() {
    local template="$1"
    local output="$2"

    if [[ ! -f "$template" ]]; then
        echo "Warning: Template not found: $template"
        return 1
    fi

    # Ensure output directory exists
    mkdir -p "$(dirname "$output")"

    sed "$SED_EXPR" "$template" > "$output"
    echo "  Applied: $(basename "$template") -> $output"
}

echo "Applying theme: $THEME_NAME"
echo "---"

# Template -> Output mappings
apply_template "$TEMPLATES_DIR/ags-style.scss"           "$CONFIG_DIR/ags/style.scss"
apply_template "$TEMPLATES_DIR/waybar-style.css"         "$CONFIG_DIR/waybar/style.css"
apply_template "$TEMPLATES_DIR/waybar-config.jsonc"      "$CONFIG_DIR/waybar/config.jsonc"
apply_template "$TEMPLATES_DIR/waybar-spotify-popup.sh"  "$CONFIG_DIR/waybar/scripts/spotify_popup.sh"
apply_template "$TEMPLATES_DIR/dunstrc"                  "$CONFIG_DIR/dunst/dunstrc"
apply_template "$TEMPLATES_DIR/rofi-config.rasi"         "$CONFIG_DIR/rofi/config.rasi"
apply_template "$TEMPLATES_DIR/rofi-keybinds.rasi"       "$CONFIG_DIR/rofi/keybinds.rasi"
apply_template "$TEMPLATES_DIR/rofi.conf"                "$CONFIG_DIR/rofi/rofi.conf"
apply_template "$TEMPLATES_DIR/kitty-theme.conf"         "$CONFIG_DIR/kitty/current-theme.conf"
apply_template "$TEMPLATES_DIR/gtk.css"                  "$CONFIG_DIR/gtk-3.0/gtk.css"
apply_template "$TEMPLATES_DIR/hypr-theme.conf"          "$CONFIG_DIR/hypr/theme.conf"
apply_template "$TEMPLATES_DIR/hyprlock.conf"            "$CONFIG_DIR/hypr/hyprlock.conf"

# Preserve executable permission on scripts
chmod +x "$CONFIG_DIR/waybar/scripts/spotify_popup.sh" 2>/dev/null

# --- Save current theme ---

echo "$THEME_NAME" > "$THEME_DIR/current"

# --- Reload services ---

echo "---"
echo "Reloading services..."

# Hyprland
if command -v hyprctl &>/dev/null && [[ -n "$HYPRLAND_INSTANCE_SIGNATURE" ]]; then
    hyprctl reload &>/dev/null && echo "  Hyprland reloaded"
fi

# Kitty (live reload via SIGUSR1)
if pgrep -x kitty &>/dev/null; then
    killall -SIGUSR1 kitty 2>/dev/null && echo "  Kitty reloaded"
fi

# Waybar
if pgrep -x waybar &>/dev/null; then
    killall waybar 2>/dev/null
    sleep 0.3
    waybar &>/dev/null &
    disown
    echo "  Waybar restarted"
fi

# Dunst
if pgrep -x dunst &>/dev/null; then
    killall dunst 2>/dev/null
    sleep 0.2
    dunst &>/dev/null &
    disown
    echo "  Dunst restarted"
fi

# AGS
if command -v ags &>/dev/null; then
    ags quit 2>/dev/null
    sleep 0.3
    ags run &>/dev/null &
    disown
    echo "  AGS restarted"
fi

echo "---"
echo "Theme '$THEME_NAME' applied successfully!"
