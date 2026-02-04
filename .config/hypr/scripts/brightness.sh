#!/bin/bash
# Brightness control script with dunst notifications

get_brightness() {
    brightnessctl -m | awk -F, '{print substr($4, 0, length($4)-1)}'
}

send_notification() {
    local brightness=$(get_brightness)
    local icon
    
    if [[ $brightness -lt 33 ]]; then
        icon="display-brightness-low"
    elif [[ $brightness -lt 66 ]]; then
        icon="display-brightness-medium"
    else
        icon="display-brightness-high"
    fi
    
    dunstify -a "brightness" \
        -u low \
        -i "$icon" \
        -h string:x-dunst-stack-tag:brightness \
        -h int:value:"$brightness" \
        "Brightness: ${brightness}%"
}

case "$1" in
    up)
        brightnessctl -e4 -n2 set 5%+
        send_notification
        ;;
    down)
        brightnessctl -e4 -n2 set 5%-
        send_notification
        ;;
    *)
        echo "Usage: $0 {up|down}"
        exit 1
        ;;
esac
