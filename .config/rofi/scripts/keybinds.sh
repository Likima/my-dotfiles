#!/bin/bash

# Hyprland Keybinds Cheatsheet for Rofi
# Tokyo Night themed

keybinds="
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  APPLICATIONS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Super + Q             Terminal (Kitty)
Super + E             File Manager
Super + R             App Launcher (Rofi)
Super + Z             Zen Browser
Super + B             VS Code
Super + .             VS Code (current dir)
Super + D             Discord
Super + S             Steam

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  WINDOW MANAGEMENT
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Super + C             Close Window
Super + V             Toggle Floating
Super + P             Pseudo Tile
Super + J             Toggle Split
Super + M             Exit Hyprland

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  WINDOW FOCUS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Super + ←             Focus Left
Super + →             Focus Right
Super + ↑             Focus Up
Super + ↓             Focus Down

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  WORKSPACES
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Super + 1-0           Switch to Workspace 1-10
Super + Shift + 1-0   Move Window to Workspace
Super + Scroll        Cycle Workspaces
Super + E             Special Workspace
Super + Shift + E     Move to Special

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  MOUSE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Super + LMB           Move Window
Super + RMB           Resize Window

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  SCREENSHOTS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Print                 Screenshot Region (Save)
Super + Shift + S     Screenshot to Clipboard

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  MEDIA & HARDWARE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Volume Up/Down        Adjust Volume
Volume Mute           Toggle Mute
Brightness Up/Down    Adjust Brightness
Play/Pause            Media Play/Pause
Next/Previous         Media Track Control

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  SYSTEM
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Super + Alt + S       Shutdown
Super + Alt + R       Reboot
Super + /             This Cheatsheet
"

# Display in rofi
echo "$keybinds" | rofi -dmenu \
    -i \
    -p " Keybinds" \
    -mesg "Press Escape to close" \
    -theme ~/.config/rofi/keybinds.rasi
