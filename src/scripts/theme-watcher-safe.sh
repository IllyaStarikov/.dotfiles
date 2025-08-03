#!/bin/bash
# Safe theme watcher that prevents terminal crashes
# Monitors macOS appearance changes and switches themes accordingly

set -euo pipefail

# Configuration
THEME_SWITCHER="$HOME/.dotfiles/src/theme-switcher/switch-theme.sh"
LOG_FILE="/tmp/theme-watcher.log"
LAST_APPEARANCE=""
MIN_SWITCH_INTERVAL=2  # Minimum seconds between theme switches

# Function to log messages
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# Function to get current macOS appearance
get_appearance() {
    if defaults read -g AppleInterfaceStyle 2>/dev/null | grep -q "Dark"; then
        echo "dark"
    else
        echo "light"
    fi
}

# Function to safely switch theme
switch_theme_safe() {
    local appearance="$1"
    
    # Add a small delay to let the system settle
    sleep 0.5
    
    # Switch theme
    if [[ "$appearance" == "dark" ]]; then
        "$THEME_SWITCHER" dark 2>&1 | tee -a "$LOG_FILE"
    else
        "$THEME_SWITCHER" light 2>&1 | tee -a "$LOG_FILE"
    fi
    
    # Send notification (optional)
    if command -v osascript &>/dev/null; then
        osascript -e "display notification \"Switched to $appearance mode\" with title \"Theme Watcher\""
    fi
}

# Main monitoring loop
main() {
    log "Theme watcher started"
    echo "🎨 Theme watcher started. Monitoring macOS appearance changes..."
    echo "📝 Logs: $LOG_FILE"
    echo "🛑 Press Ctrl+C to stop"
    
    # Get initial appearance
    LAST_APPEARANCE=$(get_appearance)
    log "Initial appearance: $LAST_APPEARANCE"
    
    # Track last switch time
    last_switch_time=0
    
    while true; do
        current_appearance=$(get_appearance)
        current_time=$(date +%s)
        
        if [[ "$current_appearance" != "$LAST_APPEARANCE" ]]; then
            # Check if enough time has passed since last switch
            time_since_last=$((current_time - last_switch_time))
            
            if [[ $time_since_last -ge $MIN_SWITCH_INTERVAL ]]; then
                log "Appearance changed: $LAST_APPEARANCE -> $current_appearance"
                switch_theme_safe "$current_appearance"
                LAST_APPEARANCE="$current_appearance"
                last_switch_time=$current_time
            else
                log "Appearance change detected but too soon (${time_since_last}s < ${MIN_SWITCH_INTERVAL}s)"
            fi
        fi
        
        # Check every 2 seconds
        sleep 2
    done
}

# Cleanup on exit
cleanup() {
    log "Theme watcher stopped"
    echo "✋ Theme watcher stopped"
}

trap cleanup EXIT

# Start monitoring
main