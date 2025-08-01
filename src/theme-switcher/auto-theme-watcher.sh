#!/bin/bash
# Auto theme watcher for macOS appearance changes
# Monitors system appearance and triggers theme switches

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
THEME_SCRIPT="$SCRIPT_DIR/switch-theme.sh"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/theme-switcher"
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/theme-switcher"
PID_FILE="$CACHE_DIR/theme-watcher.pid"
LOG_FILE="$CACHE_DIR/theme-watcher.log"
MAX_LOG_SIZE=1048576  # 1MB

# Timing configuration
CHECK_INTERVAL="${THEME_CHECK_INTERVAL:-3}"
DEBOUNCE_SECONDS="${THEME_DEBOUNCE:-5}"
MAX_FAILURES="${THEME_MAX_FAILURES:-3}"

# Ensure directories exist with proper permissions
mkdir -p "$CONFIG_DIR" "$CACHE_DIR"
chmod 700 "$CACHE_DIR"

# Function to log messages
log() {
    local level="${2:-INFO}"
    local message="[$(date '+%Y-%m-%d %H:%M:%S')] [$level] $1"
    
    # Output to both stdout and log file
    echo "$message"
    echo "$message" >> "$LOG_FILE"
    
    # Rotate log if too large
    if [[ -f "$LOG_FILE" ]] && [[ $(stat -f%z "$LOG_FILE" 2>/dev/null || stat -c%s "$LOG_FILE" 2>/dev/null) -gt $MAX_LOG_SIZE ]]; then
        mv "$LOG_FILE" "$LOG_FILE.old"
        touch "$LOG_FILE"
        chmod 600 "$LOG_FILE"
    fi
}

# Check if another instance is running
check_single_instance() {
    if [[ -f "$PID_FILE" ]]; then
        local old_pid=$(cat "$PID_FILE" 2>/dev/null || echo "")
        if [[ -n "$old_pid" ]] && kill -0 "$old_pid" 2>/dev/null; then
            log "Another theme watcher is already running (PID: $old_pid)" "ERROR"
            exit 1
        else
            rm -f "$PID_FILE"
        fi
    fi
    
    # Write our PID
    echo $$ > "$PID_FILE"
    chmod 600 "$PID_FILE"
}

# Cleanup on exit
cleanup() {
    log "Theme watcher shutting down"
    rm -f "$PID_FILE"
    exit 0
}

# Set up signal handlers
trap cleanup EXIT INT TERM

# Get current macOS appearance
get_macos_theme() {
    if [[ "$(defaults read -g AppleInterfaceStyle 2>/dev/null)" == "Dark" ]]; then
        echo "dark"
    else
        echo "light"
    fi
}

# Get stored theme variant
get_stored_variant() {
    if [[ -f "$CONFIG_DIR/current-theme.sh" ]]; then
        (source "$CONFIG_DIR/current-theme.sh" 2>/dev/null && echo "${MACOS_VARIANT:-}") || echo ""
    else
        echo ""
    fi
}

# Main monitoring loop
monitor_theme_changes() {
    local previous_theme=$(get_macos_theme)
    local consecutive_failures=0
    local last_switch_time=0
    
    log "Started monitoring (PID: $$, interval: ${CHECK_INTERVAL}s, debounce: ${DEBOUNCE_SECONDS}s)"
    
    # Initial sync if needed
    local stored_variant=$(get_stored_variant)
    if [[ "$previous_theme" != "$stored_variant" ]] && [[ -n "$stored_variant" ]]; then
        log "Initial sync: $stored_variant -> $previous_theme"
        "$THEME_SCRIPT" "$previous_theme" || true
    fi
    
    while true; do
        sleep "$CHECK_INTERVAL"
        
        # Verify we're still the active instance
        if [[ ! -f "$PID_FILE" ]] || [[ "$(cat "$PID_FILE" 2>/dev/null)" != "$$" ]]; then
            log "PID mismatch, exiting" "WARN"
            exit 1
        fi
        
        # Check current theme
        local current_theme=$(get_macos_theme)
        
        if [[ "$current_theme" != "$previous_theme" ]]; then
            local current_time=$(date +%s)
            local time_since_last=$((current_time - last_switch_time))
            
            # Check debounce
            if [[ $time_since_last -lt $DEBOUNCE_SECONDS ]]; then
                log "Theme change detected but within debounce period (${time_since_last}s < ${DEBOUNCE_SECONDS}s)"
                continue
            fi
            
            log "Theme change detected: $previous_theme -> $current_theme"
            
            # Execute theme switch
            if "$THEME_SCRIPT" "$current_theme"; then
                previous_theme="$current_theme"
                last_switch_time=$current_time
                consecutive_failures=0
                log "Theme switch successful"
            else
                ((consecutive_failures++))
                log "Theme switch failed (attempt $consecutive_failures/$MAX_FAILURES)" "ERROR"
                
                if [[ $consecutive_failures -ge $MAX_FAILURES ]]; then
                    log "Too many consecutive failures, exiting" "ERROR"
                    exit 1
                fi
            fi
        fi
    done
}

# Main execution
main() {
    # Verify theme script exists and is executable
    if [[ ! -x "$THEME_SCRIPT" ]]; then
        if [[ -f "$THEME_SCRIPT" ]]; then
            chmod +x "$THEME_SCRIPT"
        else
            log "Theme script not found: $THEME_SCRIPT" "ERROR"
            exit 1
        fi
    fi
    
    check_single_instance
    monitor_theme_changes
}

# Show usage if requested
if [[ "${1:-}" == "--help" ]] || [[ "${1:-}" == "-h" ]]; then
    cat << EOF
Usage: $(basename "$0") [OPTIONS]

Monitor macOS appearance changes and automatically switch themes.

Options:
  -h, --help    Show this help message

Environment variables:
  THEME_CHECK_INTERVAL    Check interval in seconds (default: 3)
  THEME_DEBOUNCE         Debounce period in seconds (default: 5)
  THEME_MAX_FAILURES     Max consecutive failures before exit (default: 3)
  XDG_CONFIG_HOME        Config directory (default: ~/.config)
  XDG_CACHE_HOME         Cache directory (default: ~/.cache)

Example:
  # Run with custom interval
  THEME_CHECK_INTERVAL=5 $(basename "$0")

Press Ctrl+C to stop monitoring.
EOF
    exit 0
fi

main