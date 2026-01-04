#!/bin/bash
# filepath: ~/.config/waybar/scripts/updates.sh

# Check for updates (Arch + AUR)
arch_updates=$(checkupdates 2>/dev/null | wc -l)
aur_updates=$(yay -Qua 2>/dev/null | wc -l)

total=$((arch_updates + aur_updates))

if [ $total -eq 0 ]; then
    echo '{"text": "0", "tooltip": "System is up to date", "class": "updated"}'
else
    tooltip="Arch: $arch_updates updates\nAUR: $aur_updates updates"
    echo "{\"text\": \"$total\", \"tooltip\": \"$tooltip\", \"class\": \"pending\"}"
fi