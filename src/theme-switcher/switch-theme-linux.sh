#!/usr/bin/env bash

# Linux theme switcher
# Detects desktop environment and current theme preference

set -euo pipefail

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.config/theme-switcher"
CURRENT_THEME_FILE="$CONFIG_DIR/current-theme.sh"

# Create config directory if it doesn't exist
mkdir -p "$CONFIG_DIR"

# Detect desktop environment
detect_desktop_environment() {
    if [[ -n "${XDG_CURRENT_DESKTOP:-}" ]]; then
        echo "$XDG_CURRENT_DESKTOP"
    elif [[ -n "${DESKTOP_SESSION:-}" ]]; then
        echo "$DESKTOP_SESSION"
    elif [[ -n "${GNOME_DESKTOP_SESSION_ID:-}" ]]; then
        echo "GNOME"
    elif [[ -n "${KDE_FULL_SESSION:-}" ]]; then
        echo "KDE"
    elif command -v xfce4-session &> /dev/null; then
        echo "XFCE"
    else
        echo "UNKNOWN"
    fi
}

# Detect current theme mode
detect_theme_mode() {
    local de=$(detect_desktop_environment | tr '[:upper:]' '[:lower:]')
    local mode="dark" # Default
    
    case "$de" in
        *gnome*|*ubuntu*)
            # GNOME/Ubuntu
            if command -v gsettings &> /dev/null; then
                local theme=$(gsettings get org.gnome.desktop.interface gtk-theme 2>/dev/null || echo "")
                local color_scheme=$(gsettings get org.gnome.desktop.interface color-scheme 2>/dev/null || echo "")
                
                if [[ "$color_scheme" == *"prefer-light"* ]] || [[ "$theme" == *"light"* ]] || [[ "$theme" == *"Light"* ]]; then
                    mode="light"
                fi
            fi
            ;;
            
        *kde*|*plasma*)
            # KDE Plasma
            if command -v kreadconfig5 &> /dev/null; then
                local theme=$(kreadconfig5 --file kdeglobals --group General --key ColorScheme 2>/dev/null || echo "")
                if [[ "$theme" == *"Light"* ]] || [[ "$theme" == *"light"* ]]; then
                    mode="light"
                fi
            fi
            ;;
            
        *xfce*)
            # XFCE
            if command -v xfconf-query &> /dev/null; then
                local theme=$(xfconf-query -c xsettings -p /Net/ThemeName 2>/dev/null || echo "")
                if [[ "$theme" == *"Light"* ]] || [[ "$theme" == *"light"* ]]; then
                    mode="light"
                fi
            fi
            ;;
            
        *)
            # Check time-based theme (6 AM to 6 PM = light)
            local hour=$(date +%H)
            if [[ $hour -ge 6 ]] && [[ $hour -lt 18 ]]; then
                mode="light"
            fi
            ;;
    esac
    
    echo "$mode"
}

# Get theme name based on mode
get_theme_name() {
    local mode="$1"
    if [[ "$mode" == "light" ]]; then
        echo "tokyonight_day"
    else
        echo "tokyonight_moon"
    fi
}

# Apply theme to Alacritty
apply_alacritty_theme() {
    local theme="$1"
    local alacritty_config="$HOME/.config/alacritty/alacritty.toml"
    local theme_file="$SCRIPT_DIR/themes/$theme/alacritty/theme.toml"
    
    if [[ -f "$theme_file" ]]; then
        # Update or create the theme import in alacritty.toml
        mkdir -p "$HOME/.config/alacritty"
        cp "$theme_file" "$HOME/.config/alacritty/theme.toml"
        echo "Updated Alacritty theme to $theme"
    else
        echo "Warning: Alacritty theme file not found: $theme_file"
    fi
}

# Apply theme to tmux
apply_tmux_theme() {
    local theme="$1"
    local tmux_theme_file="$SCRIPT_DIR/themes/$theme/tmux/theme.conf"
    local tmux_config_dir="$HOME/.config/tmux"
    
    if [[ -f "$tmux_theme_file" ]]; then
        mkdir -p "$tmux_config_dir"
        cp "$tmux_theme_file" "$tmux_config_dir/theme.conf"
        
        # Reload tmux if running
        if command -v tmux &> /dev/null && tmux info &> /dev/null; then
            tmux source-file ~/.tmux.conf 2>/dev/null || true
        fi
        
        echo "Updated tmux theme to $theme"
    else
        echo "Warning: tmux theme file not found: $tmux_theme_file"
    fi
}

# Write current theme configuration
write_theme_config() {
    local theme="$1"
    local mode="$2"
    
    cat > "$CURRENT_THEME_FILE" << EOF
# Auto-generated theme configuration
export MACOS_THEME="$theme"
export MACOS_VARIANT="$mode"
export MACOS_BACKGROUND="$mode"
export THEME_MODE="$mode"
export CURRENT_THEME="$theme"
EOF
    
    # Make it sourceable
    chmod +x "$CURRENT_THEME_FILE"
}

# Main function
main() {
    # Detect current mode
    local mode=$(detect_theme_mode)
    local theme=$(get_theme_name "$mode")
    
    echo "Desktop Environment: $(detect_desktop_environment)"
    echo "Detected mode: $mode"
    echo "Applying theme: $theme"
    
    # Apply themes
    apply_alacritty_theme "$theme"
    apply_tmux_theme "$theme"
    
    # Write configuration
    write_theme_config "$theme" "$mode"
    
    echo "Theme switching complete!"
    echo "You may need to restart your applications for changes to take effect."
}

# Allow manual override
if [[ $# -gt 0 ]]; then
    case "$1" in
        light)
            mode="light"
            theme="tokyonight_day"
            ;;
        dark)
            mode="dark"
            theme="tokyonight_moon"
            ;;
        *)
            echo "Usage: $0 [light|dark]"
            exit 1
            ;;
    esac
    
    echo "Manually setting theme to: $theme"
    apply_alacritty_theme "$theme"
    apply_tmux_theme "$theme"
    write_theme_config "$theme" "$mode"
else
    main
fi