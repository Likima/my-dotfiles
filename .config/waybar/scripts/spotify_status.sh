#!/bin/bash

# Enhanced Spotify status for Waybar

get_status() {
    status=$(playerctl -p spotify status 2>/dev/null)
    
    if [[ -z "$status" ]]; then
        echo '{"text": "", "tooltip": "Spotify not running", "class": "stopped", "alt": "stopped"}'
        exit 0
    fi
    
    title=$(playerctl -p spotify metadata title 2>/dev/null | cut -c1-30)
    artist=$(playerctl -p spotify metadata artist 2>/dev/null | cut -c1-20)
    album=$(playerctl -p spotify metadata album 2>/dev/null)
    
    if [[ "$status" == "Playing" ]]; then
        icon="󰓇"
        class="Playing"
    elif [[ "$status" == "Paused" ]]; then
        icon="󰏤"
        class="Paused"
    else
        icon="󰓛"
        class="stopped"
    fi
    
    if [[ -n "$title" ]]; then
        text="$artist - $title"
    else
        text="Spotify"
    fi
    
    echo "{\"text\": \"$text\", \"tooltip\": \"$album\\n$artist - $title\", \"class\": \"$class\", \"alt\": \"$class\"}"
}

get_status