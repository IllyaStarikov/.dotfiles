#!/bin/bash
set -eo pipefail  # Exit on error, pipe failures (removed -u for array handling)

# Script directory for relative paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

show_help() {
    # Default theme mapping
    local DEFAULT_LIGHT_THEME="tokyonight_day"
    local DEFAULT_DARK_THEME="tokyonight_moon"
    
    echo "Theme Switcher - dotfiles theme management"
    echo "========================================="
    echo ""
    echo "USAGE:"
    echo "  theme [THEME_NAME]"
    echo "  theme --help | help"
    echo ""
    echo "EXAMPLES:"
    echo "  theme                # Auto-detect based on macOS appearance"
    echo "  theme default        # Same as auto-detect"
    echo "  theme tokyonight_day # Switch to Tokyo Night Day (light)"
    echo "  theme tokyonight_moon # Switch to Tokyo Night Moon (dark)"
    echo ""
    echo "AVAILABLE THEMES:"
    
    # List available themes from directory structure
    local themes_dir="$HOME/.dotfiles/src/theme-switcher/themes"
    if [ -d "$themes_dir" ]; then
        # Get unique theme families
        local theme_families=()
        
        for theme_dir in "$themes_dir"/*; do
            if [ -d "$theme_dir" ]; then
                local theme_name=$(basename "$theme_dir")
                
                # Special handling for Tokyo Night themes
                if [[ "$theme_name" == tokyonight_* ]]; then
                    # Tokyo Night has its own variant system, treat each as standalone
                    if [[ ! " ${theme_families[@]} " =~ " tokyonight " ]]; then
                        theme_families+=("tokyonight")
                    fi
                else
                    # Extract theme family from name
                    local family_name="${theme_name%_light}"
                    family_name="${family_name%_dark}"
                    
                    # Add to families if not already present
                    if [[ ! " ${theme_families[@]} " =~ " ${family_name} " ]]; then
                        theme_families+=("$family_name")
                    fi
                fi
            fi
        done
        
        # Sort theme families
        IFS=$'\n' theme_families=($(sort <<<"${theme_families[*]}"))
        unset IFS
        
        # Display regular theme families
        for family in "${theme_families[@]}"; do
            echo ""
            echo "${family} theme:"
            
            # Special handling for Tokyo Night themes
            if [ "$family" = "tokyonight" ]; then
                # List all Tokyo Night variants
                for variant_dir in "$themes_dir"/tokyonight_*; do
                    if [ -d "$variant_dir" ]; then
                        local variant_name=$(basename "$variant_dir")
                        local variant_type="${variant_name#tokyonight_}"
                        local description="Tokyo Night variant"
                        
                        case "$variant_type" in
                            "day")   description="Light mode (default light)" ;;
                            "moon")  description="Dark mode (default dark)" ;;
                            "storm") description="Dark mode (storm variant)" ;;
                            "night") description="Dark mode (night variant)" ;;
                        esac
                        
                        printf "  theme %-25s # %s\n" "$variant_name" "$description"
                    fi
                done
            else
                # Check for light/dark variants with new naming
                if [ -d "$themes_dir/${family}_light" ]; then
                    printf "  theme %-25s # Light mode\n" "${family}_light"
                fi
                
                if [ -d "$themes_dir/${family}_dark" ]; then
                    printf "  theme %-25s # Dark mode\n" "${family}_dark"
                fi
                
                # Check if standalone theme exists
                if [ -d "$themes_dir/$family" ] && [ ! -d "$themes_dir/${family}_light" ] && [ ! -d "$themes_dir/${family}_dark" ]; then
                    printf "  theme %-25s\n" "$family"
                fi
            fi
        done
    fi
    
    echo ""
    echo "DEFAULT THEMES:"
    echo "  • theme / theme default → Automatically selects:"
    echo "    - Light mode: $DEFAULT_LIGHT_THEME"
    echo "    - Dark mode: $DEFAULT_DARK_THEME"
    echo ""
    echo "THEME NAMING CONVENTION:"
    echo "  • Light themes end with _light or _day"
    echo "  • Dark themes end with _dark, _moon, _night, _storm"
    echo ""
    echo "AUTOMATIC DETECTION:"
    echo "  When no theme is specified or 'default' is used, automatically selects:"
    echo "  • Light mode: $DEFAULT_LIGHT_THEME"
    echo "  • Dark mode: $DEFAULT_DARK_THEME"
    echo "  based on macOS system appearance."
    echo ""
}

# Check for help command
if [[ "$1" == "--help" || "$1" == "help" ]]; then
    show_help
    exit 0
fi

# Parse theme name to extract base theme and variant
parse_theme_name() {
    local input_theme="$1"
    
    # Special handling for Tokyo Night themes - they define their own variants
    if [[ "$input_theme" == tokyonight_* ]]; then
        BASE_THEME="$input_theme"
        # Determine variant based on the specific Tokyo Night theme
        case "$input_theme" in
            tokyonight_day)
                VARIANT="light"
                ;;
            tokyonight_moon|tokyonight_storm|tokyonight_night)
                VARIANT="dark"
                ;;
            *)
                VARIANT="dark"  # Default to dark for unknown variants
                ;;
        esac
        return
    fi
    
    # Handle new naming convention with actual theme names
    if [[ "$input_theme" == *"_light" ]]; then
        BASE_THEME="$input_theme"
        VARIANT="light"
    elif [[ "$input_theme" == *"_dark" ]]; then
        BASE_THEME="$input_theme"
        VARIANT="dark"
    else
        # Single theme name - treat as light variant
        BASE_THEME="$input_theme"
        VARIANT="light"
    fi
}

# Default theme mapping
# Currently: light = tokyonight_day, dark = tokyonight_moon
DEFAULT_LIGHT_THEME="tokyonight_day"
DEFAULT_DARK_THEME="tokyonight_moon"

# Determine theme and variant
if [ -z "$1" ]; then
    # Auto-detect based on system appearance
    APPEARANCE=$(defaults read -g AppleInterfaceStyle 2>/dev/null || echo "")
    if [[ "$APPEARANCE" == "Dark" ]]; then
        BASE_THEME="$DEFAULT_DARK_THEME"
        VARIANT="dark"
    else
        BASE_THEME="$DEFAULT_LIGHT_THEME"
        VARIANT="light"
    fi
elif [[ "$1" == "default" ]]; then
    # Handle 'default' specially - use system appearance
    APPEARANCE=$(defaults read -g AppleInterfaceStyle 2>/dev/null || echo "")
    if [[ "$APPEARANCE" == "Dark" ]]; then
        BASE_THEME="$DEFAULT_DARK_THEME"
        VARIANT="dark"
    else
        BASE_THEME="$DEFAULT_LIGHT_THEME"
        VARIANT="light"
    fi
else
    # Handle simple "light" or "dark" arguments (from auto-theme-watcher)
    if [[ "$1" == "light" ]]; then
        BASE_THEME="$DEFAULT_LIGHT_THEME"
        VARIANT="light"
    elif [[ "$1" == "dark" ]]; then
        BASE_THEME="$DEFAULT_DARK_THEME"
        VARIANT="dark"
    else
        parse_theme_name "$1"
    fi
fi

# Determine background for Vim
BACKGROUND="light"
if [[ "$VARIANT" == "dark" ]]; then
    BACKGROUND="dark"
fi

# Construct full theme name for directory lookup
FULL_THEME_NAME="$BASE_THEME"

# Create config directory if it doesn't exist
CONFIG_DIR="$HOME/.config/theme-switcher"
mkdir -p "$CONFIG_DIR"

# Check if theme is already active
CURRENT_THEME=""
THEME_RESET=false
if [ -f "$CONFIG_DIR/current-theme.sh" ]; then
    source "$CONFIG_DIR/current-theme.sh"
    CURRENT_THEME="$MACOS_THEME"
    if [[ "$CURRENT_THEME" == "$BASE_THEME" ]]; then
        THEME_RESET=true
    fi
fi

# Write current theme to file
cat > "$CONFIG_DIR/current-theme.sh" << EOF
export MACOS_THEME="$BASE_THEME"
export MACOS_VARIANT="$VARIANT"
export MACOS_BACKGROUND="$BACKGROUND"
EOF

# Theme directory
THEME_DIR="$SCRIPT_DIR/themes/$FULL_THEME_NAME"

if [[ ! -d "$THEME_DIR" ]]; then
    echo "❌ Error: Theme '$FULL_THEME_NAME' not found at $THEME_DIR"
    echo "Available themes:"
    ls -1 "$SCRIPT_DIR/themes/" 2>/dev/null | head -10 || echo "No themes found"
    exit 1
fi

# Alacritty
ALACRITTY_CONFIG_DIR="$HOME/.config/alacritty"
mkdir -p "$ALACRITTY_CONFIG_DIR"
if [ -f "$THEME_DIR/alacritty.toml" ]; then
    cp "$THEME_DIR/alacritty.toml" "$ALACRITTY_CONFIG_DIR/theme.toml"
elif [ -f "$THEME_DIR/alacritty/theme.toml" ]; then
    cp "$THEME_DIR/alacritty/theme.toml" "$ALACRITTY_CONFIG_DIR/theme.toml"
fi

# Tmux
TMUX_CONFIG_DIR="$HOME/.config/tmux"
mkdir -p "$TMUX_CONFIG_DIR"
if [ -f "$THEME_DIR/tmux.conf" ]; then
    cp "$THEME_DIR/tmux.conf" "$TMUX_CONFIG_DIR/theme.conf"
fi

# Vim
VIM_THEME_DIR="$HOME/.vim/colors"
mkdir -p "$VIM_THEME_DIR"
if [ -f "$THEME_DIR/vim.vim" ]; then
    cp "$THEME_DIR/vim.vim" "$VIM_THEME_DIR/theme.vim"
fi

# Reload tmux
if tmux info &> /dev/null; then
    # First ensure main tmux.conf is loaded
    if [[ -f "$HOME/.tmux.conf" ]]; then
        tmux source-file "$HOME/.tmux.conf" 2>/dev/null || true
    fi
    # Then load theme-specific config
    if [[ -f "$TMUX_CONFIG_DIR/theme.conf" ]]; then
        tmux source-file "$TMUX_CONFIG_DIR/theme.conf" 2>/dev/null || true
    fi
    tmux refresh-client -S
    if [[ "$THEME_RESET" == true ]]; then
        tmux display-message "Theme reset to $FULL_THEME_NAME"
    else
        tmux display-message "Theme switched to $FULL_THEME_NAME"
    fi
fi

# Display appropriate message
if [[ "$THEME_RESET" == true ]]; then
    echo "✅ Theme reset to $FULL_THEME_NAME mode (already active)"
else
    echo "✅ Theme switched to $FULL_THEME_NAME mode"
fi

# Notify user about Neovim
echo ""
echo "ℹ️  Note: Neovim will detect the theme automatically on next start"
echo "         Current sessions may need :source $MYVIMRC to update"