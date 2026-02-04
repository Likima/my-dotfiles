#!/bin/bash
# Volume control script with dunst notifications

get_volume() {
    wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print int($2 * 100)}'
}

get_mute() {
    wpctl get-volume @DEFAULT_AUDIO_SINK@ | grep -q MUTED && echo "yes" || echo "no"
}

send_notification() {
    local volume=$(get_volume)
    local muted=$(get_mute)
    local icon
    local text
    
    if [[ "$muted" == "yes" ]]; then
        icon="audio-volume-muted"
        text="Muted"
        volume=0
    elif [[ $volume -eq 0 ]]; then
        icon="audio-volume-muted"
        text="Volume: ${volume}%"
    elif [[ $volume -lt 33 ]]; then
        icon="audio-volume-low"
        text="Volume: ${volume}%"
    elif [[ $volume -lt 66 ]]; then
        icon="audio-volume-medium"
        text="Volume: ${volume}%"
    else
        icon="audio-volume-high"
        text="Volume: ${volume}%"
    fi
    
    dunstify -a "volume" \
        -u low \
        -i "$icon" \
        -h string:x-dunst-stack-tag:volume \
        -h int:value:"$volume" \
        "$text"
}

case "$1" in
    up)
        wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+
        send_notification
        ;;
    down)
        wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
        send_notification
        ;;
    mute)
        wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
        send_notification
        ;;
    mic-mute)
        wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle
        # Mic notification
        if wpctl get-volume @DEFAULT_AUDIO_SOURCE@ | grep -q MUTED; then
            dunstify -a "volume" -u low -i "microphone-sensitivity-muted" \
                -h string:x-dunst-stack-tag:mic "Microphone Muted"
        else
            dunstify -a "volume" -u low -i "microphone-sensitivity-high" \
                -h string:x-dunst-stack-tag:mic "Microphone Unmuted"
        fi
        ;;
    *)
        echo "Usage: $0 {up|down|mute|mic-mute}"
        exit 1
        ;;
esac
