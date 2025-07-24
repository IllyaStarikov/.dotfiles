#!/bin/bash

show_help() {
    echo "Theme Switcher - dotfiles theme management"
    echo "========================================="
    echo ""
    echo "USAGE:"
    echo "  theme [THEME_NAME]"
    echo "  theme --help | help"
    echo ""
    echo "EXAMPLES:"
    echo "  theme                # Auto-detect based on macOS appearance"
    echo "  theme write          # Switch to write theme (light mode)"
    echo "  theme write_dark     # Switch to write theme (dark mode)"
    echo "  theme write_light    # Same as 'theme write' (alias)"
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
                    # Regular theme families
                    local family_name="${theme_name%_dark}"
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
            echo "${family} family:"
            
            # Check if base theme exists (light mode)
            if [ -d "$themes_dir/$family" ]; then
                printf "  theme %-25s # Light mode\n" "$family"
                printf "  theme %-25s # Light mode (alias)\n" "${family}_light"
            fi
            
            # Check if dark variant exists
            if [ -d "$themes_dir/${family}_dark" ]; then
                printf "  theme %-25s # Dark mode\n" "${family}_dark"
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
    echo "THEME NAMING CONVENTION:"
    echo "  • Base theme name = light mode (e.g., write, tron, default)"
    echo "  • Dark variant = base + _dark suffix (e.g., write_dark, tron_dark)"
    echo "  • Light alias = base + _light works same as base (e.g., write_light = write)"
    echo ""
    echo "AUTOMATIC DETECTION:"
    echo "  When no theme is specified, automatically uses 'default' or 'default_dark'"
    echo "  based on macOS system appearance (Light/Dark mode)."
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
    
    # Handle aliases: write_light -> write, default_light -> default
    if [[ "$input_theme" == *"_light" ]]; then
        input_theme="${input_theme%_light}"
    fi
    
    # Check if theme ends with _dark
    if [[ "$input_theme" == *"_dark" ]]; then
        BASE_THEME="${input_theme%_dark}"
        VARIANT="dark"
    else
        BASE_THEME="$input_theme"
        VARIANT="light"
    fi
}

# Determine theme and variant
if [ -z "$1" ]; then
    # Auto-detect based on system appearance
    APPEARANCE=$(defaults read -g AppleInterfaceStyle 2>/dev/null)
    if [[ "$APPEARANCE" == "Dark" ]]; then
        BASE_THEME="default"
        VARIANT="dark"
    else
        BASE_THEME="default"
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
if [[ "$BASE_THEME" == github_* ]]; then
    # GitHub themes are standalone - use the full name as-is
    FULL_THEME_NAME="$BASE_THEME"
elif [[ "$VARIANT" == "dark" ]]; then
    FULL_THEME_NAME="${BASE_THEME}_dark"
else
    FULL_THEME_NAME="$BASE_THEME"
fi

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

if [ ! -d "$THEME_DIR" ]; then
    echo "Theme '$FULL_THEME_NAME' not found."
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