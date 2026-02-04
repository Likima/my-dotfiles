#!/bin/bash

# Event-driven Spotify status for Waybar (uses playerctl -F instead of polling)

playerctl -p spotify metadata --format '{"text": "{{ artist }} - {{ title }}", "tooltip": "{{ album }}\n{{ artist }} - {{ title }}", "class": "{{ status }}", "alt": "{{ status }}"}' -F 2>/dev/null || echo '{"text": "", "tooltip": "Spotify not running", "class": "stopped", "alt": "stopped"}'
