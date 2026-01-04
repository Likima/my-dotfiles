// filepath: install.sh
#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.config"

print_status() {
    echo -e "${BLUE}[*]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

# Directories to symlink to ~/.config/
CONFIG_DIRS=(
    "ags"
    "dunst"
    "easyeffects"
    "fontconfig"
    "gtk-3.0"
    "gtk-4.0"
    "hypr"
    "ibus"
    "imv"
    "kitty"
    "nvim"
    "pipewire"
    "rofi"
    "swww"
    "waybar"
    "wireplumber"
    "Thunar"
    "xfce4"
)

# Files to symlink to ~/.config/
CONFIG_FILES=(
    "mimeapps.list"
    "pavucontrol.ini"
)

backup_existing() {
    local target="$1"
    if [ -e "$target" ] || [ -L "$target" ]; then
        local backup="${target}.backup.$(date +%Y%m%d_%H%M%S)"
        print_warning "Backing up existing $target to $backup"
        mv "$target" "$backup"
    fi
}

create_symlink() {
    local source="$1"
    local target="$2"
    
    if [ -L "$target" ] && [ "$(readlink "$target")" = "$source" ]; then
        print_success "Already linked: $target"
        return
    fi
    
    backup_existing "$target"
    ln -sf "$source" "$target"
    print_success "Linked: $target -> $source"
}

main() {
    echo ""
    echo "╔════════════════════════════════════════╗"
    echo "║     Dotfiles Installation Script       ║"
    echo "╚════════════════════════════════════════╝"
    echo ""
    
    # Create .config directory if it doesn't exist
    mkdir -p "$CONFIG_DIR"
    print_status "Ensured $CONFIG_DIR exists"
    
    # Symlink config directories
    print_status "Symlinking configuration directories..."
    for dir in "${CONFIG_DIRS[@]}"; do
        if [ -d "$DOTFILES_DIR/$dir" ]; then
            create_symlink "$DOTFILES_DIR/$dir" "$CONFIG_DIR/$dir"
        else
            print_warning "Directory not found: $dir (skipping)"
        fi
    done
    
    # Symlink config files
    print_status "Symlinking configuration files..."
    for file in "${CONFIG_FILES[@]}"; do
        if [ -f "$DOTFILES_DIR/$file" ]; then
            create_symlink "$DOTFILES_DIR/$file" "$CONFIG_DIR/$file"
        else
            print_warning "File not found: $file (skipping)"
        fi
    done
    
    # Handle Tokyo Night GTK Theme
    if [ -d "$DOTFILES_DIR/Tokyo-Night-GTK-Theme" ]; then
        print_status "Installing Tokyo Night GTK Theme..."
        mkdir -p "$HOME/.themes"
        create_symlink "$DOTFILES_DIR/Tokyo-Night-GTK-Theme" "$HOME/.themes/Tokyo-Night"
    fi
    
    # Handle usr-scripts
    if [ -d "$DOTFILES_DIR/usr-scripts" ]; then
        print_status "Linking user scripts..."
        mkdir -p "$HOME/.local/bin"
        for script in "$DOTFILES_DIR/usr-scripts"/*; do
            if [ -f "$script" ]; then
                script_name=$(basename "$script")
                create_symlink "$script" "$HOME/.local/bin/$script_name"
                chmod +x "$script"
            fi
        done
        print_warning "Make sure ~/.local/bin is in your PATH"
    fi
    
    # AGS setup
    if [ -d "$CONFIG_DIR/ags" ] && [ -f "$CONFIG_DIR/ags/package.json" ]; then
        print_status "Setting up AGS..."
        if command -v npm &> /dev/null; then
            cd "$CONFIG_DIR/ags"
            npm install
            print_success "AGS dependencies installed"
            cd "$DOTFILES_DIR"
        else
            print_warning "npm not found, skipping AGS setup. Run 'npm install' in ~/.config/ags manually"
        fi
    fi
    
    # Create common directories
    print_status "Creating common directories..."
    mkdir -p "$HOME/Pictures/Wallpapers"
    mkdir -p "$HOME/Pictures/Screenshots"
    mkdir -p "$HOME/.local/share"
    
    echo ""
    print_success "Installation complete!"
    echo ""
    echo "Next steps:"
    echo "  1. Log out and select Hyprland from your display manager"
    echo "  2. Or run 'Hyprland' from a TTY"
    echo ""
    echo "If you haven't installed packages yet, run:"
    echo "  ./install-packages.sh"
    echo ""
}

main "$@"
