#!/bin/bash
# Theme switcher for macOS appearance synchronization
# Handles Alacritty, tmux, and Starship theme switching

set -euo pipefail

# Configuration
THEME="${1:-auto}"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/theme-switcher"
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/theme-switcher"
ALACRITTY_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/alacritty"
TMUX_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/tmux"
STARSHIP_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"

# Default themes
LIGHT_THEME="${THEME_LIGHT:-tokyonight_day}"
DARK_THEME="${THEME_DARK:-tokyonight_moon}"

# Lock and log configuration
LOCK_FILE="$CACHE_DIR/theme-switch.lock"
LOCK_ACQUIRED=0
LOG_FILE="$CACHE_DIR/theme-switch.log"
MAX_LOG_SIZE=1048576  # 1MB

# Ensure secure directories exist
mkdir -p "$CONFIG_DIR" "$CACHE_DIR" "$ALACRITTY_DIR" "$TMUX_DIR"
chmod 700 "$CACHE_DIR"

# Function to log messages
log() {
    local level="${2:-INFO}"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$level] $1" >> "$LOG_FILE"
    
    # Rotate log if too large
    if [[ -f "$LOG_FILE" ]] && [[ $(stat -f%z "$LOG_FILE" 2>/dev/null || stat -c%s "$LOG_FILE" 2>/dev/null) -gt $MAX_LOG_SIZE ]]; then
        mv "$LOG_FILE" "$LOG_FILE.old"
        touch "$LOG_FILE"
        chmod 600 "$LOG_FILE"
    fi
}

# Function to acquire lock
acquire_lock() {
    local timeout=10
    local elapsed=0
    
    while [[ -f "$LOCK_FILE" ]] && [[ $elapsed -lt $timeout ]]; do
        local lock_pid=$(cat "$LOCK_FILE" 2>/dev/null || echo "")
        if [[ -n "$lock_pid" ]] && ! kill -0 "$lock_pid" 2>/dev/null; then
            rm -f "$LOCK_FILE"
            break
        fi
        sleep 0.1
        elapsed=$((elapsed + 1))
    done
    
    if [[ -f "$LOCK_FILE" ]]; then
        echo "Error: Another theme switch is in progress" >&2
        exit 1
    fi
    
    echo $$ > "$LOCK_FILE"
    LOCK_ACQUIRED=1
}

# Function to release lock
release_lock() {
    if [[ $LOCK_ACQUIRED -eq 1 ]]; then
        rm -f "$LOCK_FILE"
        LOCK_ACQUIRED=0
    fi
}

# Cleanup on exit
trap release_lock EXIT

# Determine theme based on input
determine_theme() {
    case "$THEME" in
        auto|default)
            if [[ "$(defaults read -g AppleInterfaceStyle 2>/dev/null)" == "Dark" ]]; then
                THEME="$DARK_THEME"
                VARIANT="dark"
            else
                THEME="$LIGHT_THEME"
                VARIANT="light"
            fi
            ;;
        light)
            THEME="$LIGHT_THEME"
            VARIANT="light"
            ;;
        dark)
            THEME="$DARK_THEME"
            VARIANT="dark"
            ;;
        *)
            # Detect variant from theme name
            if [[ "$THEME" =~ (day|light)$ ]]; then
                VARIANT="light"
            else
                VARIANT="dark"
            fi
            ;;
    esac
}

# Check if already using the requested theme
check_current_theme() {
    if [[ -f "$CONFIG_DIR/current-theme.sh" ]]; then
        source "$CONFIG_DIR/current-theme.sh"
        if [[ "${MACOS_THEME:-}" == "$THEME" ]]; then
            echo "Already using theme: $THEME"
            exit 0
        fi
    fi
}

# Save current theme atomically
save_theme_state() {
    local theme_file_tmp="$CONFIG_DIR/current-theme.sh.tmp.$$"
    cat > "$theme_file_tmp" << EOF
export MACOS_THEME="$THEME"
export MACOS_VARIANT="$VARIANT"
export MACOS_BACKGROUND="$VARIANT"
EOF
    mv -f "$theme_file_tmp" "$CONFIG_DIR/current-theme.sh"
    chmod 600 "$CONFIG_DIR/current-theme.sh"
}

# Update Alacritty theme safely
update_alacritty_theme() {
    local theme_source="$1"
    local theme_dest="$2"
    
    if [[ ! -f "$theme_source" ]]; then
        log "Theme file not found: $theme_source" "WARN"
        return 1
    fi
    
    local temp_file="${theme_dest}.tmp.$$"
    cp "$theme_source" "$temp_file"
    
    # Atomic replacement
    mv -f "$temp_file" "$theme_dest"
    chmod 644 "$theme_dest"
    
    # Clean up any leftover temp files
    rm -f "${theme_dest}.tmp."* 2>/dev/null || true
    
    log "Updated Alacritty theme"
    return 0
}

# Update other application themes
update_app_themes() {
    local theme_dir="$(dirname "$0")/themes/$THEME"
    
    # Update Alacritty
    if [[ -f "$theme_dir/alacritty/theme.toml" ]]; then
        update_alacritty_theme "$theme_dir/alacritty/theme.toml" "$ALACRITTY_DIR/theme.toml"
    elif [[ -f "$theme_dir/alacritty.toml" ]]; then
        update_alacritty_theme "$theme_dir/alacritty.toml" "$ALACRITTY_DIR/theme.toml"
    fi
    
    # Update tmux
    if [[ -f "$theme_dir/tmux.conf" ]]; then
        cp "$theme_dir/tmux.conf" "$TMUX_DIR/theme.conf"
        chmod 644 "$TMUX_DIR/theme.conf"
        log "Updated tmux theme"
    fi
    
    # Update Starship
    if [[ -f "$theme_dir/starship.toml" ]]; then
        cp "$theme_dir/starship.toml" "$STARSHIP_DIR/starship.toml"
        chmod 644 "$STARSHIP_DIR/starship.toml"
        log "Updated Starship theme"
    fi
}

# Reload tmux configuration
reload_tmux() {
    if command -v tmux &>/dev/null && tmux info &>/dev/null; then
        tmux source-file ~/.tmux.conf 2>/dev/null || true
        tmux refresh-client -S 2>/dev/null || true
        log "Reloaded tmux configuration"
    fi
}

# Main execution
main() {
    determine_theme
    log "Switching to theme: $THEME ($VARIANT)"
    
    acquire_lock
    check_current_theme
    save_theme_state
    update_app_themes
    reload_tmux
    release_lock
    
    log "Theme switch completed successfully"
    echo "✅ Theme switched to $THEME ($VARIANT mode)"
}

main