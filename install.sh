#!/bin/bash

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.config"

source "$DOTFILES_DIR/scripts/utils.sh"

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

# Dotfiles to symlink to ~/
HOME_DOTFILES=(
    ".bashrc"
    ".bash_profile"
    ".gitconfig"
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

    # Symlink home-directory dotfiles
    print_status "Symlinking home dotfiles..."
    for file in "${HOME_DOTFILES[@]}"; do
        if [ -f "$DOTFILES_DIR/$file" ]; then
            create_symlink "$DOTFILES_DIR/$file" "$HOME/$file"
        else
            print_warning "File not found: $file (skipping)"
        fi
    done

    # Create .config directory if it doesn't exist
    mkdir -p "$CONFIG_DIR"
    print_status "Ensured $CONFIG_DIR exists"

    # Symlink config directories
    print_status "Symlinking configuration directories..."
    for dir in "${CONFIG_DIRS[@]}"; do
        if [ -d "$DOTFILES_DIR/.config/$dir" ]; then
            create_symlink "$DOTFILES_DIR/.config/$dir" "$CONFIG_DIR/$dir"
        else
            print_warning "Directory not found: .config/$dir (skipping)"
        fi
    done

    # Symlink config files
    print_status "Symlinking configuration files..."
    for file in "${CONFIG_FILES[@]}"; do
        if [ -f "$DOTFILES_DIR/.config/$file" ]; then
            create_symlink "$DOTFILES_DIR/.config/$file" "$CONFIG_DIR/$file"
        else
            print_warning "File not found: .config/$file (skipping)"
        fi
    done

    # Handle usr-scripts
    if [ -d "$DOTFILES_DIR/.config/usr-scripts" ]; then
        print_status "Linking user scripts..."
        mkdir -p "$HOME/.local/bin"
        for script in "$DOTFILES_DIR/.config/usr-scripts"/*; do
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
