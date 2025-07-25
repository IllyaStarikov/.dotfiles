#!/bin/bash
set -eo pipefail  # Exit on error, pipe failures (removed -u for array handling)

show_help() {
    # Default theme mapping
    local DEFAULT_LIGHT_THEME="iceberg_light"
    local DEFAULT_DARK_THEME="dracula"
    
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
    echo "  theme iceberg_light  # Switch to Iceberg light theme"
    echo "  theme iceberg_dark   # Switch to Iceberg dark theme"
    echo "  theme dracula        # Switch to Dracula theme"
    echo ""
    echo "AVAILABLE THEMES:"
    
    # List available themes from directory structure
    local themes_dir="$HOME/.dotfiles/src/theme-switcher/themes"
    if [ -d "$themes_dir" ]; then
        # Get unique theme families, handling GitHub themes specially
        local theme_families=()
        local github_themes=()
        
        for theme_dir in "$themes_dir"/*; do
            if [ -d "$theme_dir" ]; then
                local theme_name=$(basename "$theme_dir")
                
                # Special handling for GitHub themes
                if [[ "$theme_name" == github_* ]]; then
                    github_themes+=("$theme_name")
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
        
        # Sort GitHub themes
        IFS=$'\n' github_themes=($(sort <<<"${github_themes[*]}"))
        unset IFS
        
        # Display regular theme families
        for family in "${theme_families[@]}"; do
            echo ""
            echo "${family} theme:"
            
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
        done
        
        # Display GitHub themes as one family
        if [ ${#github_themes[@]} -gt 0 ]; then
            echo ""
            echo "github family (all standalone themes):"
            
            for theme in "${github_themes[@]}"; do
                local mode="Light mode"
                if [[ "$theme" == *dark* ]]; then
                    mode="Dark mode"
                fi
                printf "  theme %-25s # $mode\n" "$theme"
            done
        fi
    fi
    
    echo ""
    echo "DEFAULT THEMES:"
    echo "  • theme / theme default → Automatically selects:"
    echo "    - Light mode: $DEFAULT_LIGHT_THEME"
    echo "    - Dark mode: $DEFAULT_DARK_THEME"
    echo ""
    echo "THEME NAMING CONVENTION:"
    echo "  • Light themes end with _light (e.g., iceberg_light)"
    echo "  • Dark themes end with _dark (e.g., iceberg_dark)"
    echo "  • Standalone themes have no suffix (e.g., dracula)"
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
    
    # Special handling for GitHub themes - they are standalone themes, not base_variant
    if [[ "$input_theme" == github_* ]]; then
        BASE_THEME="$input_theme"
        VARIANT="light"  # Default variant for GitHub themes
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
# Currently: light = iceberg_light, dark = dracula
DEFAULT_LIGHT_THEME="iceberg_light"
DEFAULT_DARK_THEME="dracula"

# Determine theme and variant
if [ -z "$1" ]; then
    # Auto-detect based on system appearance
    APPEARANCE=$(defaults read -g AppleInterfaceStyle 2>/dev/null)
    if [[ "$APPEARANCE" == "Dark" ]]; then
        BASE_THEME="$DEFAULT_DARK_THEME"
        VARIANT="dark"
    else
        BASE_THEME="$DEFAULT_LIGHT_THEME"
        VARIANT="light"
    fi
elif [[ "$1" == "default" ]]; then
    # Handle 'default' specially - use system appearance
    APPEARANCE=$(defaults read -g AppleInterfaceStyle 2>/dev/null)
    if [[ "$APPEARANCE" == "Dark" ]]; then
        BASE_THEME="$DEFAULT_DARK_THEME"
        VARIANT="dark"
    else
        BASE_THEME="$DEFAULT_LIGHT_THEME"
        VARIANT="light"
    fi
else
    parse_theme_name "$1"
fi

# Determine background for Vim
BACKGROUND="light"
if [[ "$VARIANT" == "dark" ]]; then
    BACKGROUND="dark"
elif [[ "$BASE_THEME" == github_dark* ]]; then
    # GitHub dark themes should have dark background
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
THEME_DIR="$HOME/.dotfiles/src/theme-switcher/themes/$FULL_THEME_NAME"

if [[ ! -d "$THEME_DIR" ]]; then
    echo "❌ Error: Theme '$FULL_THEME_NAME' not found at $THEME_DIR"
    echo "Available themes:"
    ls -1 "$HOME/.dotfiles/src/theme-switcher/themes/" | head -5
    exit 1
fi

# Alacritty
ALACRITTY_CONFIG_DIR="$HOME/.config/alacritty"
mkdir -p "$ALACRITTY_CONFIG_DIR"
if [ -f "$THEME_DIR/alacritty.toml" ]; then
    cp "$THEME_DIR/alacritty.toml" "$ALACRITTY_CONFIG_DIR/theme.toml"
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
    cp "$THEME_DIR/vim.vim" "$VIM_THEME_DIR/iceberg.vim"
    # Update .vimrc to use the new theme
    sed -i '' "s/colorscheme .*/colorscheme iceberg/g" "$HOME/.dotfiles/src/vimrc"
fi

# Reload tmux
if tmux info &> /dev/null; then
    tmux source-file "$TMUX_CONFIG_DIR/theme.conf"
    tmux refresh-client -S
    if [[ "$THEME_RESET" == true ]]; then
        tmux display-message "Theme reset to $FULL_THEME_NAME"
    else
        tmux display-message "Theme switched to $FULL_THEME_NAME"
    fi
fi

# Display appropriate message
if [[ "$THEME_RESET" == true ]]; then
    echo "Theme reset to $FULL_THEME_NAME mode (already active)"
else
    echo "Theme switched to $FULL_THEME_NAME mode"
fi