#!/bin/bash
# Theme switcher for macOS appearance synchronization
# Handles Alacritty, tmux, and Starship theme switching

set -euo pipefail

# Show usage/help
show_usage() {
    cat << EOF
Usage: $(basename "$0") [THEME|OPTION]

Theme Switcher - Synchronize terminal themes with macOS appearance

OPTIONS:
    -h, --help, help    Show this help message
    -l, --list          List all available themes

THEMES:
    auto, default       Auto-detect based on macOS appearance (default)
    light              Use default light theme (tokyonight_day)
    dark               Use default dark theme (tokyonight_storm)
    
    Shortcuts:
    day                tokyonight_day (light)
    night              tokyonight_night (dark)
    moon               tokyonight_moon (dark)
    storm              tokyonight_storm (dark) [default dark]
    
    Full theme names:
    tokyonight_day, tokyonight_night, tokyonight_moon, tokyonight_storm
    github_light, github_dark, github_dark_*

EXAMPLES:
    $(basename "$0")           # Auto-detect based on macOS appearance
    $(basename "$0") dark      # Use default dark theme (storm)
    $(basename "$0") moon      # Use TokyoNight Moon theme
    $(basename "$0") --list    # List all available themes

EOF
}

# List available themes
list_themes() {
    local theme_dir="$(dirname "$0")/themes"
    echo "Available themes:"
    echo ""
    echo "TokyoNight themes:"
    for theme in "$theme_dir"/tokyonight_*; do
        if [[ -d "$theme" ]]; then
            local name=$(basename "$theme")
            local variant="dark"
            [[ "$name" =~ day ]] && variant="light"
            echo "  $name ($variant)"
        fi
    done
    echo ""
    echo "GitHub themes:"
    for theme in "$theme_dir"/github_*; do
        if [[ -d "$theme" ]]; then
            local name=$(basename "$theme")
            local variant="dark"
            [[ "$name" =~ light ]] && variant="light"
            echo "  $name ($variant)"
        fi
    done
    echo ""
    echo "Use any theme name with: $(basename "$0") THEME_NAME"
}

# Check for help or list options
case "${1:-}" in
    -h|--help|help)
        show_usage
        exit 0
        ;;
    -l|--list)
        list_themes
        exit 0
        ;;
esac

# Configuration
THEME="${1:-auto}"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/theme-switcher"
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/theme-switcher"
ALACRITTY_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/alacritty"
TMUX_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/tmux"
STARSHIP_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"

# Default themes
LIGHT_THEME="${THEME_LIGHT:-tokyonight_day}"
DARK_THEME="${THEME_DARK:-tokyonight_storm}"

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
        # Handle short theme names
        moon)
            THEME="tokyonight_moon"
            VARIANT="dark"
            ;;
        night)
            THEME="tokyonight_night"
            VARIANT="dark"
            ;;
        storm)
            THEME="tokyonight_storm"
            VARIANT="dark"
            ;;
        day)
            THEME="tokyonight_day"
            VARIANT="light"
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
            echo "Already using theme: $THEME (reapplying)"
            # Continue to reapply the theme instead of exiting
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

# Atomic file update helper
atomic_update() {
    local source="$1"
    local dest="$2"
    local mode="${3:-644}"
    
    if [[ ! -f "$source" ]]; then
        log "Source file not found: $source" "WARN"
        return 1
    fi
    
    local temp_file="${dest}.tmp.$$"
    
    # Copy to temp file
    cp "$source" "$temp_file" || {
        rm -f "$temp_file"
        return 1
    }
    
    # Set permissions on temp file
    chmod "$mode" "$temp_file"
    
    # Atomic replacement
    mv -f "$temp_file" "$dest" || {
        rm -f "$temp_file"
        return 1
    }
    
    # Clean up any leftover temp files
    rm -f "${dest}.tmp."* 2>/dev/null || true
    
    return 0
}

# Update other application themes
update_app_themes() {
    local theme_dir="$(dirname "$0")/themes/$THEME"
    local success=0
    
    # Update Alacritty
    if [[ -f "$theme_dir/alacritty/theme.toml" ]]; then
        update_alacritty_theme "$theme_dir/alacritty/theme.toml" "$ALACRITTY_DIR/theme.toml" || success=1
    elif [[ -f "$theme_dir/alacritty.toml" ]]; then
        update_alacritty_theme "$theme_dir/alacritty.toml" "$ALACRITTY_DIR/theme.toml" || success=1
    fi
    
    # Update tmux
    if [[ -f "$theme_dir/tmux.conf" ]]; then
        if atomic_update "$theme_dir/tmux.conf" "$TMUX_DIR/theme.conf"; then
            log "Updated tmux theme"
        else
            log "Failed to update tmux theme" "ERROR"
            success=1
        fi
    fi
    
    # Update Starship
    if [[ -f "$theme_dir/starship.toml" ]]; then
        if atomic_update "$theme_dir/starship.toml" "$STARSHIP_DIR/starship.toml"; then
            log "Updated Starship theme"
        else
            log "Failed to update Starship theme" "ERROR"
            success=1
        fi
    fi
    
    return $success
}

# Reload tmux configuration
reload_tmux() {
    if command -v tmux &>/dev/null && tmux info &>/dev/null; then
        tmux source-file ~/.tmux.conf 2>/dev/null || true
        tmux refresh-client -S 2>/dev/null || true
        log "Reloaded tmux configuration"
    fi
}

# Backup current configuration
backup_config() {
    local backup_dir="$CACHE_DIR/backup.$$"
    mkdir -p "$backup_dir"
    
    # Backup current files
    [[ -f "$CONFIG_DIR/current-theme.sh" ]] && cp "$CONFIG_DIR/current-theme.sh" "$backup_dir/"
    [[ -f "$ALACRITTY_DIR/theme.toml" ]] && cp "$ALACRITTY_DIR/theme.toml" "$backup_dir/"
    [[ -f "$TMUX_DIR/theme.conf" ]] && cp "$TMUX_DIR/theme.conf" "$backup_dir/"
    [[ -f "$STARSHIP_DIR/starship.toml" ]] && cp "$STARSHIP_DIR/starship.toml" "$backup_dir/"
    
    echo "$backup_dir"
}

# Restore configuration on failure
restore_config() {
    local backup_dir="$1"
    
    if [[ -d "$backup_dir" ]]; then
        [[ -f "$backup_dir/current-theme.sh" ]] && cp "$backup_dir/current-theme.sh" "$CONFIG_DIR/"
        [[ -f "$backup_dir/theme.toml" ]] && cp "$backup_dir/theme.toml" "$ALACRITTY_DIR/"
        [[ -f "$backup_dir/theme.conf" ]] && cp "$backup_dir/theme.conf" "$TMUX_DIR/"
        [[ -f "$backup_dir/starship.toml" ]] && cp "$backup_dir/starship.toml" "$STARSHIP_DIR/"
        
        rm -rf "$backup_dir"
        log "Restored previous configuration"
    fi
}

# Validate theme exists
validate_theme() {
    local theme_dir="$(dirname "$0")/themes/$THEME"
    if [[ ! -d "$theme_dir" ]]; then
        echo "Error: Theme '$THEME' not found" >&2
        echo "Use '$(basename "$0") --list' to see available themes" >&2
        exit 1
    fi
}

# Main execution
main() {
    determine_theme
    validate_theme
    log "Switching to theme: $THEME ($VARIANT)"
    
    acquire_lock
    check_current_theme
    
    # Create backup before making changes
    local backup_dir=$(backup_config)
    
    # Attempt theme switch
    if save_theme_state && update_app_themes; then
        reload_tmux
        release_lock
        
        # Clean up backup on success
        rm -rf "$backup_dir"
        
        log "Theme switch completed successfully"
        echo "✅ Theme switched to $THEME ($VARIANT mode)"
    else
        # Restore on failure
        restore_config "$backup_dir"
        release_lock
        
        log "Theme switch failed, configuration restored" "ERROR"
        echo "❌ Theme switch failed, previous configuration restored" >&2
        exit 1
    fi
}

main