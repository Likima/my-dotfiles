// filepath: install-packages.sh
#!/bin/bash

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() {
    echo -e "${BLUE}[*]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

# Check if yay is installed
if ! command -v yay &> /dev/null; then
    print_status "yay not found, installing..."
    sudo pacman -S --needed git base-devel
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    cd /tmp/yay
    makepkg -si --noconfirm
    cd -
    rm -rf /tmp/yay
    print_success "yay installed"
fi

# Core packages (from official repos)
OFFICIAL_PACKAGES=(
    # Hyprland & Wayland
    hyprland
    hyprpaper
    hyprlock
    hypridle
    xdg-desktop-portal-hyprland
    xdg-desktop-portal-gtk
    qt5-wayland
    qt6-wayland
    
    # Status bar
    waybar
    
    # Terminal
    kitty
    
    # Editor
    neovim
    
    # Notifications
    dunst
    libnotify
    
    # Audio
    pipewire
    pipewire-alsa
    pipewire-pulse
    pipewire-jack
    wireplumber
    pavucontrol
    easyeffects
    
    # File manager
    thunar
    thunar-archive-plugin
    thunar-volman
    gvfs
    gvfs-mtp
    
    # Image viewer
    imv
    
    # GTK theming
    gtk3
    gtk4
    
    # Fonts
    fontconfig
    ttf-jetbrains-mono-nerd
    ttf-font-awesome
    otf-font-awesome
    noto-fonts
    noto-fonts-emoji
    
    # Input
    ibus
    
    # Utilities
    polkit-gnome
    grim
    slurp
    wl-clipboard
    cliphist
    brightnessctl
    playerctl
    network-manager-applet
    bluez
    bluez-utils
    blueman
    unzip
    zip
    p7zip
    xdg-user-dirs
    jq
    socat
    
    # Development
    nodejs
    npm
    typescript
    go
    python
    python-pip
    
    # Browsers
    chromium
)

# AUR packages
AUR_PACKAGES=(
    # Launcher
    rofi-wayland
    
    # Wallpaper
    swww
    
    # AGS
    aylurs-gtk-shell
    
    # Apps
    google-chrome
    discord
    spotify-launcher
    visual-studio-code-bin
    whatsapp-for-linux
    
    # Webcam
    webcamoid
)

echo ""
echo "╔════════════════════════════════════════╗"
echo "║     Package Installation Script        ║"
echo "╚════════════════════════════════════════╝"
echo ""

# Update system first
print_status "Updating system..."
sudo pacman -Syu --noconfirm

# Install official packages
print_status "Installing official packages..."
sudo pacman -S --needed --noconfirm "${OFFICIAL_PACKAGES[@]}"
print_success "Official packages installed"

# Install AUR packages
print_status "Installing AUR packages..."
yay -S --needed --noconfirm "${AUR_PACKAGES[@]}"
print_success "AUR packages installed"

# Enable services
print_status "Enabling services..."

# PipeWire (user services)
systemctl --user enable --now pipewire.socket
systemctl --user enable --now pipewire-pulse.socket
systemctl --user enable --now wireplumber.service

# Bluetooth
sudo systemctl enable --now bluetooth.service

# Create user directories
print_status "Creating user directories..."
xdg-user-dirs-update

print_success "All packages installed and services enabled!"
echo ""
echo "You can now run ./install.sh to set up your dotfiles"
echo ""
