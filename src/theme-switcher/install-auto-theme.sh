#!/bin/bash

# Install Auto Theme Switching

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"
PLIST_TEMPLATE="$DOTFILES_DIR/src/theme-switcher/io.starikov.theme-watcher.plist.template"
LAUNCH_AGENTS_DIR="$HOME/Library/LaunchAgents"
TARGET_PLIST="$LAUNCH_AGENTS_DIR/io.starikov.theme-watcher.plist"

echo "Installing auto theme switching..."

# Create LaunchAgents directory if it doesn't exist
mkdir -p "$LAUNCH_AGENTS_DIR"

# Generate plist from template
sed -e "s|{{DOTFILES_DIR}}|$DOTFILES_DIR|g" \
    -e "s|{{HOME}}|$HOME|g" \
    "$PLIST_TEMPLATE" > "$TARGET_PLIST"

# Load the launch agent
launchctl load "$TARGET_PLIST"

echo "Auto theme switching installed and started!"
echo "The watcher will now automatically switch themes when macOS appearance changes."
echo ""
echo "To check status: launchctl list | grep theme-watcher"
echo "To stop: launchctl unload ~/Library/LaunchAgents/io.starikov.theme-watcher.plist"
echo "To start: launchctl load ~/Library/LaunchAgents/io.starikov.theme-watcher.plist"
echo "Logs: ~/.config/theme-switcher/watcher.log"