#!/bin/bash

# Spotify popup widget for Waybar
# Shows album art and playback controls

CACHE_DIR="$HOME/.cache/waybar-spotify"
mkdir -p "$CACHE_DIR"

get_cover_art() {
    artUrl=$(playerctl -p spotify metadata mpris:artUrl 2>/dev/null)
    if [[ -n "$artUrl" ]]; then
        # Handle different Spotify URL formats
        # Format 1: https://open.spotify.com/image/...
        # Format 2: https://i.scdn.co/image/...
        if [[ "$artUrl" == *"open.spotify.com"* ]]; then
            artUrl="${artUrl/open.spotify.com/i.scdn.co}"
        fi

        coverPath="$CACHE_DIR/cover.png"
        # Use -L to follow redirects
        curl -sL "$artUrl" -o "$coverPath" 2>/dev/null

        # Verify the file was downloaded correctly
        if [[ -s "$coverPath" ]]; then
            echo "$coverPath"
        else
            echo ""
        fi
    fi
}

show_popup() {
    # Get current track info
    title=$(playerctl -p spotify metadata title 2>/dev/null || echo "Not Playing")
    artist=$(playerctl -p spotify metadata artist 2>/dev/null || echo "Unknown Artist")
    album=$(playerctl -p spotify metadata album 2>/dev/null || echo "Unknown Album")
    status=$(playerctl -p spotify status 2>/dev/null || echo "Stopped")

    # Get cover art
    coverPath=$(get_cover_art)

    # Create GTK popup using yad or zenity alternative
    # Using rofi for a cleaner look that matches your theme

    if [[ "$status" == "Playing" ]]; then
        play_icon="󰏤 Pause"
    else
        play_icon="󰐊 Play"
    fi

    choice=$(echo -e "󰒮 Previous\n$play_icon\n󰒭 Next\n󰓎 Shuffle\n󰑖 Repeat" | rofi -dmenu -p "󰓇 $title - $artist" -kb-cancel "Escape" -click-to-exit -theme-str '
        window {
            width: 300px;
            background-color: @BG@;
            border-color: @ACCENT@;
            border: 2px;
            border-radius: 12px;
        }
        listview {
            lines: 5;
            scrollbar: false;
        }
        element {
            padding: 8px 12px;
        }
        element selected {
            background-color: @BG_SELECTED@;
            text-color: @BG@;
        }
        inputbar {
            padding: 8px 12px;
            background-color: @BG_HIGHLIGHT@;
            text-color: @ACCENT@;
        }
    ')

    case "$choice" in
        *"Previous"*) playerctl -p spotify previous ;;
        *"Play"*|*"Pause"*) playerctl -p spotify play-pause ;;
        *"Next"*) playerctl -p spotify next ;;
        *"Shuffle"*) playerctl -p spotify shuffle toggle ;;
        *"Repeat"*) playerctl -p spotify loop track ;;
    esac
}

show_popup
