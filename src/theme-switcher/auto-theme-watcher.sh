#!/bin/bash

# Auto Theme Watcher - Monitors macOS appearance changes and switches themes automatically

THEME_SCRIPT="$HOME/.dotfiles/src/theme-switcher/switch-theme.sh"
CURRENT_THEME_FILE="$HOME/.config/theme-switcher/current-theme.sh"

# Function to get current macOS appearance
get_macos_theme() {
    if [[ "$(defaults read -g AppleInterfaceStyle 2>/dev/null)" == "Dark" ]]; then
        echo "dark"
    else
        echo "light"
    fi
}

# Function to get stored theme
get_stored_theme() {
    if [[ -f "$CURRENT_THEME_FILE" ]]; then
        source "$CURRENT_THEME_FILE"
        echo "$MACOS_THEME"
    else
        echo ""
    fi
}

echo "Starting auto theme watcher..."
echo "Monitoring macOS appearance changes..."
echo "Press Ctrl+C to stop"

# Initial theme check
CURRENT_MACOS_THEME=$(get_macos_theme)
STORED_THEME=$(get_stored_theme)

if [[ "$CURRENT_MACOS_THEME" != "$STORED_THEME" ]]; then
    echo "Initial theme sync: $CURRENT_MACOS_THEME"
    "$THEME_SCRIPT" "$CURRENT_MACOS_THEME"
fi

# Monitor for changes
PREVIOUS_THEME="$CURRENT_MACOS_THEME"

while true; do
    sleep 2
    
    CURRENT_MACOS_THEME=$(get_macos_theme)
    
    if [[ "$CURRENT_MACOS_THEME" != "$PREVIOUS_THEME" ]]; then
        echo "Theme change detected: $PREVIOUS_THEME -> $CURRENT_MACOS_THEME"
        "$THEME_SCRIPT" "$CURRENT_MACOS_THEME" "$CURRENT_MACOS_THEME"
        PREVIOUS_THEME="$CURRENT_MACOS_THEME"
    fi
done
