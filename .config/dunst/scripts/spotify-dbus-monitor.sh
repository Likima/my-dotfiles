#!/bin/bash
# Monitor Spotify for track changes and send custom notifications

CACHE_DIR="$HOME/.cache/dunst"
mkdir -p "$CACHE_DIR"

get_album_art() {
    local url="$1"
    local art_file="$CACHE_DIR/spotify_art.png"
    
    if [[ -z "$url" ]]; then
        echo ""
        return
    fi
    
    # Convert Spotify URL if needed
    if [[ "$url" == *"open.spotify.com"* ]]; then
        url="${url/open.spotify.com/i.scdn.co}"
    fi
    
    if curl -s "$url" -o "$art_file" 2>/dev/null; then
        echo "$art_file"
    else
        echo ""
    fi
}

last_track=""

while true; do
    # Check if Spotify is running
    if ! playerctl -p spotify status &>/dev/null; then
        sleep 2
        continue
    fi
    
    # Get current track info
    status=$(playerctl -p spotify status 2>/dev/null)
    
    # Only notify if playing
    if [[ "$status" != "Playing" ]]; then
        sleep 1
        continue
    fi
    
    artist=$(playerctl -p spotify metadata artist 2>/dev/null)
    title=$(playerctl -p spotify metadata title 2>/dev/null)
    album=$(playerctl -p spotify metadata album 2>/dev/null)
    art_url=$(playerctl -p spotify metadata mpris:artUrl 2>/dev/null)
    
    current_track="${artist}-${title}"
    
    # Only notify if track changed
    if [[ "$current_track" != "$last_track" && -n "$title" ]]; then
        last_track="$current_track"
        
        # Download album art
        icon_arg=""
        if [[ -n "$art_url" ]]; then
            art_file=$(get_album_art "$art_url")
            if [[ -n "$art_file" && -f "$art_file" ]]; then
                icon_arg="-i $art_file"
            fi
        fi
        
        # Send notification
        dunstify -a "Spotify" \
            -u normal \
            -h string:x-dunst-stack-tag:spotify \
            $icon_arg \
            "$title" \
            "by <b>$artist</b>\non <i>$album</i>"
    fi
    
    sleep 1
done