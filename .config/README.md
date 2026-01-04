// filepath: README.md
# Dotfiles

Personal dotfiles for Arch Linux with Hyprland desktop environment.

## Overview

This repository contains configuration files for:

- **Window Manager**: Hyprland
- **Status Bar**: Waybar, AGS (Aylur's GTK Shell)
- **Terminal**: Kitty
- **Shell**: Fish/Bash (check your preference)
- **Editor**: Neovim
- **Application Launcher**: Rofi
- **Notifications**: Dunst
- **Audio**: PipeWire, PulseAudio (pavucontrol), EasyEffects
- **File Manager**: Thunar
- **Image Viewer**: imv
- **Wallpaper**: swww
- **Theme**: Tokyo Night GTK Theme
- **Browser**: Google Chrome, Chromium
- **Other**: Discord, Spotify, WhatsApp Desktop

## Quick Install

### 1. Install all packages

```bash
# Run this command to install all required packages
yay -S --needed \
    hyprland hyprpaper hyprlock hypridle xdg-desktop-portal-hyprland \
    waybar \
    kitty \
    neovim \
    rofi-wayland \
    dunst libnotify \
    pipewire pipewire-alsa pipewire-pulse pipewire-jack wireplumber \
    pavucontrol easyeffects \
    thunar thunar-archive-plugin thunar-volman gvfs \
    imv \
    swww \
    gtk3 gtk4 \
    fontconfig \
    ibus \
    aylurs-gtk-shell \
    google-chrome chromium \
    discord \
    spotify-launcher \
    nodejs npm typescript \
    ttf-jetbrains-mono-nerd ttf-font-awesome otf-font-awesome \
    polkit-gnome \
    grim slurp wl-clipboard \
    brightnessctl \
    network-manager-applet \
    bluez bluez-utils blueman \
    unzip zip p7zip \
    xdg-user-dirs \
    qt5-wayland qt6-wayland
```

### 2. Run the install script

```bash
chmod +x install.sh
./install.sh
```

## Manual Installation

### Clone and Setup

```bash
# Clone this repository
git clone <your-repo-url> ~/dotfiles
cd ~/dotfiles

# Run the install script
./install.sh
```

### Directory Structure

After installation, configs will be symlinked to `~/.config/`:

```
~/.config/
├── ags/           # AGS shell widgets
├── dunst/         # Notification daemon
├── fontconfig/    # Font configuration
├── gtk-3.0/       # GTK3 theme settings
├── gtk-4.0/       # GTK4 theme settings
├── hypr/          # Hyprland WM config
├── imv/           # Image viewer
├── kitty/         # Terminal emulator
├── nvim/          # Neovim editor
├── pipewire/      # Audio server
├── rofi/          # Application launcher
├── swww/          # Wallpaper daemon
├── waybar/        # Status bar
├── wireplumber/   # PipeWire session manager
└── ...
```

## Post-Installation

### Enable Services

```bash
# Enable PipeWire
systemctl --user enable --now pipewire pipewire-pulse wireplumber

# Enable Bluetooth (if needed)
sudo systemctl enable --now bluetooth
```

### Set Default Applications

The `mimeapps.list` file will be copied to `~/.config/` to set default applications.

### AGS Setup

```bash
cd ~/.config/ags
npm install
```

## Keybindings

Check `hypr/hyprland.conf` for keybindings. Common ones:

- `SUPER + Return` - Open terminal
- `SUPER + D` - Open Rofi launcher
- `SUPER + Q` - Close window
- `SUPER + 1-9` - Switch workspaces

## Customization

- **Wallpaper**: Place wallpapers in `~/Pictures/Wallpapers/` and use swww
- **Theme**: Tokyo Night GTK theme included
- **Fonts**: JetBrains Mono Nerd Font recommended

## Troubleshooting

### Waybar not showing
```bash
killall waybar && waybar &
```

### Audio issues
```bash
systemctl --user restart pipewire pipewire-pulse wireplumber
```

### Hyprland crashes
Check logs: `cat ~/.local/share/hyprland/hyprland.log`
