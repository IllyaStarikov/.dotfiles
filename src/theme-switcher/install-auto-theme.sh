#!/bin/bash

# Install Auto Theme Switching

PLIST_FILE="$HOME/.dotfiles/src/theme-switcher/io.starikov.theme-watcher.plist"
LAUNCH_AGENTS_DIR="$HOME/Library/LaunchAgents"
TARGET_PLIST="$LAUNCH_AGENTS_DIR/io.starikov.theme-watcher.plist"

echo "Installing auto theme switching..."

# Create LaunchAgents directory if it doesn't exist
mkdir -p "$LAUNCH_AGENTS_DIR"

# Copy plist to LaunchAgents
cp "$PLIST_FILE" "$TARGET_PLIST"

# Load the launch agent
launchctl load "$TARGET_PLIST"

echo "Auto theme switching installed and started!"
echo "The watcher will now automatically switch themes when macOS appearance changes."
echo ""
echo "To check status: launchctl list | grep theme-watcher"
echo "To stop: launchctl unload ~/Library/LaunchAgents/io.starikov.theme-watcher.plist"
echo "To start: launchctl load ~/Library/LaunchAgents/io.starikov.theme-watcher.plist"
echo "Logs: ~/.config/theme-switcher/watcher.log"