#!/usr/bin/env zsh
# ════════════════════════════════════════════════════════════════════════════════
# switch-theme.sh - Dynamic theme switcher for terminal applications
# ════════════════════════════════════════════════════════════════════════════════
#
# DESCRIPTION:
#   Synchronizes terminal application themes with macOS appearance settings.
#   Changes Alacritty, tmux, Starship, and Neovim themes atomically to prevent
#   visual inconsistencies during switching.
#
# USAGE:
#   switch-theme.sh [THEME|auto]
#
#   switch-theme.sh         # Auto-detect from macOS appearance
#   switch-theme.sh day     # TokyoNight Day (light)
#   switch-theme.sh night   # TokyoNight Night (dark)
#   switch-theme.sh moon    # TokyoNight Moon (dark)
#   switch-theme.sh storm   # TokyoNight Storm (dark)
#
# THEMES:
#   light/day   - TokyoNight Day (light theme)
#   dark/storm  - TokyoNight Storm (default dark)
#   night       - TokyoNight Night (bluish dark)
#   moon        - TokyoNight Moon (darker variant)
#
# FEATURES:
#   - Atomic switching (all apps change together)
#   - macOS appearance detection
#   - tmux session preservation
#   - Crash-proof with proper locking
#   - Configuration generation in ~/.config/
#
# FILES MODIFIED:
#   ~/.config/alacritty/theme.toml     - Alacritty colors
#   ~/.config/wezterm/theme.lua        - WezTerm colors
#   ~/.config/kitty/theme.conf         - Kitty colors
#   ~/.config/tmux/theme.conf          - tmux status bar
#   ~/.config/starship/theme.toml      - Starship prompt
#   ~/.config/theme-switcher/current-theme.sh - Shell environment
#
# EXAMPLES:
#   switch-theme.sh              # Auto-detect based on macOS
#   switch-theme.sh light        # Force light theme
#   switch-theme.sh moon         # Use moon variant
#   theme day                    # Using shell alias
# ════════════════════════════════════════════════════════════════════════════════

set -euo pipefail

# Show usage/help
show_usage() {
  cat <<EOF
Usage: $(basename "$0") [THEME|OPTION]

Theme Switcher - Synchronize terminal themes with macOS appearance

OPTIONS:
    -h, --help, help    Show this help message
    -l, --list          List all available themes

THEMES:
    light              Use default light theme (tokyonight_day)
    dark               Use default dark theme (tokyonight_storm)
    
    Shortcuts:
    day                tokyonight_day (light)
    night              tokyonight_night (dark)
    moon               tokyonight_moon (dark)
    storm              tokyonight_storm (dark) [default dark]
    
    Full theme names:
    tokyonight_day, tokyonight_night, tokyonight_moon, tokyonight_storm

EXAMPLES:
    $(basename "$0") dark      # Use default dark theme (storm)
    $(basename "$0") moon      # Use TokyoNight Moon theme
    $(basename "$0") day       # Use TokyoNight Day theme (light)
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
  echo "Use any theme name with: $(basename "$0") THEME_NAME"
}

# Check for help or list options
case "${1:-}" in
  -h | --help | help)
    show_usage
    exit 0
    ;;
  -l | --list)
    list_themes
    exit 0
    ;;
esac

# Configuration
THEME="${1:-}"
if [[ -z "$THEME" ]]; then
  echo "Error: No theme specified"
  echo "Usage: $(basename "$0") [THEME|OPTION]"
  echo "Try '$(basename "$0") --help' for more information"
  exit 1
fi
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/theme-switcher"
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/theme-switcher"
ALACRITTY_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/alacritty"
TMUX_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/tmux"
STARSHIP_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"
WEZTERM_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/wezterm"
KITTY_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/kitty"

# Default themes
LIGHT_THEME="${THEME_LIGHT:-tokyonight_day}"
DARK_THEME="${THEME_DARK:-tokyonight_storm}"

# Lock and log configuration
LOCK_FILE="$CACHE_DIR/theme-switch.lock"
LOCK_ACQUIRED=0
LOG_FILE="$CACHE_DIR/theme-switch.log"
MAX_LOG_SIZE=1048576 # 1MB

# Ensure secure directories exist
mkdir -p "$CONFIG_DIR" "$CACHE_DIR" "$ALACRITTY_DIR" "$TMUX_DIR" "$WEZTERM_DIR"
chmod 700 "$CACHE_DIR"

# Function to log messages
log() {
  local level="${2:-INFO}"
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$level] $1" >>"$LOG_FILE"

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

  echo $$ >"$LOCK_FILE"
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
  cat >"$theme_file_tmp" <<EOF
# Current theme configuration
export MACOS_THEME="$THEME"
export MACOS_VARIANT="$VARIANT"
EOF
  mv -f "$theme_file_tmp" "$CONFIG_DIR/current-theme.sh"
  chmod 644 "$CONFIG_DIR/current-theme.sh"
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

# Update WezTerm theme
update_wezterm_theme() {
  local wezterm_theme_file="$WEZTERM_DIR/theme.lua"
  local temp_file="${wezterm_theme_file}.tmp.$$"
  local home="\$HOME"

  # Create the WezTerm theme configuration
  cat >"$temp_file" <<EOF
-- Auto-generated WezTerm theme configuration
-- Theme: $THEME
-- Generated: $(date)

-- Load the theme module from dotfiles
local home = os.getenv("HOME")
package.path = package.path .. ";" .. home .. "/.dotfiles/src/wezterm/themes/?.lua"
local theme = require('${THEME}')

-- Return the theme for use in wezterm.lua
return theme
EOF

  # Atomic replacement
  mv -f "$temp_file" "$wezterm_theme_file"
  chmod 644 "$wezterm_theme_file"

  # Clean up any leftover temp files
  rm -f "${wezterm_theme_file}.tmp."* 2>/dev/null || true

  log "Updated WezTerm theme"
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
  if [[ -f "$theme_dir/alacritty.toml" ]]; then
    update_alacritty_theme "$theme_dir/alacritty.toml" "$ALACRITTY_DIR/theme.toml" || success=1
  fi

  # Update WezTerm
  update_wezterm_theme || success=1

  # Update Kitty
  if [[ -f "$theme_dir/kitty.conf" ]]; then
    if atomic_update "$theme_dir/kitty.conf" "$KITTY_DIR/theme.conf"; then
      log "Updated Kitty theme"
      # Reload Kitty configuration if it's running
      if pgrep -x "kitty" >/dev/null; then
        # Find Kitty socket and reload config
        local kitty_socket=$(ls /tmp/kitty-* 2>/dev/null | head -1)
        if [[ -n "$kitty_socket" ]]; then
          kitty @ --to unix:"$kitty_socket" load-config 2>/dev/null || true
        else
          # Fallback: try without socket specification
          kitty @ load-config 2>/dev/null || true
        fi
      fi
    else
      log "Failed to update Kitty theme" "ERROR"
      success=1
    fi
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

# Reload tmux configuration for ALL sessions
reload_tmux() {
  if command -v tmux &>/dev/null; then
    # Check if tmux server is running
    if ! tmux info &>/dev/null; then
      log "No tmux server running"
      return 0
    fi

    # Source the config file first
    if [[ -n "${TMUX:-}" ]]; then
      # We're inside tmux - reload directly
      tmux source-file ~/.tmux.conf 2>/dev/null || true
      log "Reloaded tmux configuration from inside tmux"
    else
      # We're outside tmux - send command to server
      tmux source-file ~/.tmux.conf 2>/dev/null || true
      log "Reloaded tmux configuration from outside tmux"
    fi

    # Get list of all tmux sessions and refresh each client
    local tmux_sessions=$(tmux list-sessions -F '#S' 2>/dev/null || true)
    if [[ -n "$tmux_sessions" ]]; then
      while IFS= read -r session; do
        # Refresh all clients attached to this session
        local clients=$(tmux list-clients -t "$session" -F '#{client_name}' 2>/dev/null || true)
        if [[ -n "$clients" ]]; then
          while IFS= read -r client; do
            tmux refresh-client -t "$client" -S 2>/dev/null || true
          done <<<"$clients"
        fi
      done <<<"$tmux_sessions"
      log "Refreshed all tmux clients"
    fi
  fi
}

# Backup current configuration
backup_config() {
  local backup_dir="$CACHE_DIR/backup.$$"
  mkdir -p "$backup_dir"

  # Backup current files
  [[ -f "$CONFIG_DIR/current-theme.sh" ]] && cp "$CONFIG_DIR/current-theme.sh" "$backup_dir/"
  [[ -f "$ALACRITTY_DIR/theme.toml" ]] && cp "$ALACRITTY_DIR/theme.toml" "$backup_dir/"
  [[ -f "$WEZTERM_DIR/theme.lua" ]] && cp "$WEZTERM_DIR/theme.lua" "$backup_dir/"
  [[ -f "$KITTY_DIR/theme.conf" ]] && cp "$KITTY_DIR/theme.conf" "$backup_dir/"
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
    [[ -f "$backup_dir/theme.lua" ]] && cp "$backup_dir/theme.lua" "$WEZTERM_DIR/"
    # Restore Kitty theme - note the file name in backup dir needs checking
    if [[ -f "$backup_dir/theme.conf" ]]; then
      # Check if it's Kitty or tmux theme based on content or separate files
      [[ -f "$KITTY_DIR/theme.conf" ]] && cp "$backup_dir/theme.conf" "$KITTY_DIR/"
    fi
    [[ -f "$backup_dir/theme.conf" ]] && cp "$backup_dir/theme.conf" "$TMUX_DIR/"
    [[ -f "$backup_dir/starship.toml" ]] && cp "$backup_dir/starship.toml" "$STARSHIP_DIR/"

    # Archive the backup instead of deleting
    local archive_dir="$HOME/.dotfiles-theme-backups/$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$archive_dir"
    mv "$backup_dir" "$archive_dir/restored-backup" 2>/dev/null || true
    log "Restored previous configuration (backup archived to $archive_dir)"
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

    # Archive backup on success instead of deleting
    local archive_dir="$HOME/.dotfiles-theme-backups/$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$archive_dir"
    mv "$backup_dir" "$archive_dir/success-backup" 2>/dev/null || true

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
