#!/bin/bash
# filepath: ~/.config/waybar/scripts/weather.sh

# Replace with your city or use auto-detection
CITY="${CITY:-}"  # Empty for auto-detect

# Weather icons mapping
declare -A weather_icons=(
    ["Clear"]="󰖙"
    ["Sunny"]="󰖙"
    ["Partly cloudy"]="󰖕"
    ["Cloudy"]="󰖐"
    ["Overcast"]="󰖐"
    ["Mist"]="󰖑"
    ["Fog"]="󰖑"
    ["Light rain"]="󰖗"
    ["Rain"]="󰖗"
    ["Heavy rain"]="󰖖"
    ["Thunderstorm"]="󰖓"
    ["Snow"]="󰖘"
    ["Light snow"]="󰖘"
    ["Heavy snow"]="󰼶"
)

# Fetch weather data
weather_data=$(curl -s "wttr.in/${CITY}?format=j1" 2>/dev/null)

if [ -z "$weather_data" ] || [ "$weather_data" == "Unknown location" ]; then
    echo '{"text": "󰖐 N/A", "tooltip": "Weather data unavailable"}'
    exit 0
fi

# Parse weather info
condition=$(echo "$weather_data" | jq -r '.current_condition[0].weatherDesc[0].value')
temp_c=$(echo "$weather_data" | jq -r '.current_condition[0].temp_C')
feels_like=$(echo "$weather_data" | jq -r '.current_condition[0].FeelsLikeC')
humidity=$(echo "$weather_data" | jq -r '.current_condition[0].humidity')
wind=$(echo "$weather_data" | jq -r '.current_condition[0].windspeedKmph')
location=$(echo "$weather_data" | jq -r '.nearest_area[0].areaName[0].value')

# Get weather icon
icon="${weather_icons[$condition]:-󰖐}"

# Build tooltip with forecast
tooltip="$location\n$condition\n\n"
tooltip+="Temperature: ${temp_c}°C\n"
tooltip+="Feels like: ${feels_like}°C\n"
tooltip+="Humidity: ${humidity}%\n"
tooltip+="Wind: ${wind} km/h"

echo "{\"text\": \"$icon ${temp_c}°C\", \"tooltip\": \"$tooltip\"}"