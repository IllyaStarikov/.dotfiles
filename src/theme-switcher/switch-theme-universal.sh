#!/usr/bin/env bash
# Universal theme switcher for macOS and Linux
# Handles Alacritty, tmux, and terminal theme switching

set -euo pipefail

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Import helpers if available
if [[ -f "$SCRIPT_DIR/../setup/setup-helpers.sh" ]]; then
    source "$SCRIPT_DIR/../setup/setup-helpers.sh"
else
    # Fallback definitions
    info() { echo "ℹ️  $1"; }
    success() { echo "✅ $1"; }
    warning() { echo "⚠️  $1"; }
    error() { echo "❌ $1"; }
fi

# Configuration
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/theme-switcher"
CURRENT_THEME_FILE="$CONFIG_DIR/current-theme.sh"
ALACRITTY_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/alacritty"
TMUX_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/tmux"

# Default themes
LIGHT_THEME="${THEME_LIGHT:-tokyonight_day}"
DARK_THEME="${THEME_DARK:-tokyonight_moon}"

# Create directories
mkdir -p "$CONFIG_DIR" "$ALACRITTY_DIR" "$TMUX_DIR"

# Detect OS
detect_os() {
    case "$OSTYPE" in
        darwin*) echo "macos" ;;
        linux*) echo "linux" ;;
        *) echo "unknown" ;;
    esac
}

# Detect current theme mode on macOS
detect_macos_theme() {
    local appearance=$(defaults read -g AppleInterfaceStyle 2>/dev/null || echo "Light")
    if [[ "$appearance" == "Dark" ]]; then
        echo "dark"
    else
        echo "light"
    fi
}

# Detect current theme mode on Linux
detect_linux_theme() {
    # Try to source the Linux theme detector
    if [[ -f "$SCRIPT_DIR/switch-theme-linux.sh" ]]; then
        # Extract just the detection logic
        mode=$("$SCRIPT_DIR/switch-theme-linux.sh" detect 2>/dev/null || echo "dark")
        echo "$mode"
    else
        # Default to dark if we can't detect
        echo "dark"
    fi
}

# Detect current theme mode
detect_theme_mode() {
    local os=$(detect_os)
    case "$os" in
        macos)
            detect_macos_theme
            ;;
        linux)
            detect_linux_theme
            ;;
        *)
            echo "dark"
            ;;
    esac
}

# Get theme name based on mode
get_theme_name() {
    local mode="$1"
    if [[ "$mode" == "light" ]]; then
        echo "$LIGHT_THEME"
    else
        echo "$DARK_THEME"
    fi
}

# Apply theme to Alacritty
apply_alacritty_theme() {
    local theme="$1"
    local theme_file="$SCRIPT_DIR/themes/$theme/alacritty/theme.toml"
    
    if [[ -f "$theme_file" ]]; then
        cp "$theme_file" "$ALACRITTY_DIR/theme.toml"
        success "Updated Alacritty theme to $theme"
    else
        warning "Alacritty theme file not found: $theme_file"
    fi
}

# Apply theme to tmux
apply_tmux_theme() {
    local theme="$1"
    local tmux_theme_file="$SCRIPT_DIR/themes/$theme/tmux/theme.conf"
    
    if [[ -f "$tmux_theme_file" ]]; then
        cp "$tmux_theme_file" "$TMUX_DIR/theme.conf"
        
        # Reload tmux if running
        if command -v tmux &> /dev/null && tmux info &> /dev/null; then
            tmux source-file ~/.tmux.conf 2>/dev/null || true
            # Refresh all clients
            tmux list-clients -F '#{client_name}' 2>/dev/null | while read -r client; do
                tmux refresh-client -t "$client" 2>/dev/null || true
            done
        fi
        
        success "Updated tmux theme to $theme"
    else
        warning "tmux theme file not found: $tmux_theme_file"
    fi
}

# Write current theme configuration
write_theme_config() {
    local theme="$1"
    local mode="$2"
    
    cat > "$CURRENT_THEME_FILE" << EOF
#!/bin/bash
# Auto-generated theme configuration
export MACOS_THEME="$theme"
export MACOS_VARIANT="$mode"
export MACOS_BACKGROUND="$mode"
export THEME_MODE="$mode"
export CURRENT_THEME="$theme"

# For compatibility
export THEME_VARIANT="$mode"
EOF
    
    chmod +x "$CURRENT_THEME_FILE"
    success "Theme configuration written"
}

# Main function
main() {
    local theme_arg="${1:-auto}"
    local mode
    local theme
    
    case "$theme_arg" in
        auto)
            mode=$(detect_theme_mode)
            theme=$(get_theme_name "$mode")
            info "Auto-detected mode: $mode"
            ;;
        light)
            mode="light"
            theme="$LIGHT_THEME"
            info "Manually setting light mode"
            ;;
        dark)
            mode="dark"
            theme="$DARK_THEME"
            info "Manually setting dark mode"
            ;;
        *)
            # Check if it's a specific theme name
            if [[ -d "$SCRIPT_DIR/themes/$theme_arg" ]]; then
                theme="$theme_arg"
                # Try to determine if it's light or dark from the name
                if [[ "$theme" == *"light"* ]] || [[ "$theme" == *"day"* ]]; then
                    mode="light"
                else
                    mode="dark"
                fi
                info "Using specific theme: $theme"
            else
                error "Unknown theme or mode: $theme_arg"
                echo "Usage: $0 [auto|light|dark|theme-name]"
                exit 1
            fi
            ;;
    esac
    
    info "Applying theme: $theme"
    
    # Apply themes
    apply_alacritty_theme "$theme"
    apply_tmux_theme "$theme"
    
    # Write configuration
    write_theme_config "$theme" "$mode"
    
    success "Theme switching complete!"
    
    # OS-specific post-processing
    local os=$(detect_os)
    if [[ "$os" == "linux" ]]; then
        info "You may need to restart your applications for changes to take effect."
    fi
}

# Run main function
main "$@"