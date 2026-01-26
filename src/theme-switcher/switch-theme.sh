#!/usr/bin/env zsh
# ════════════════════════════════════════════════════════════════════════════════
# switch-theme.sh - Dynamic theme switcher for terminal applications
# ════════════════════════════════════════════════════════════════════════════════
#
# DESCRIPTION:
#   Synchronizes terminal application themes with macOS appearance settings.
#   Changes Alacritty, tmux, Starship, and Neovim themes atomically to prevent
#   visual inconsistencies during switching.
#   Based on Google Shell Style Guide: https://google.github.io/styleguide/shellguide.html
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

# Get the absolute directory of the script
# This needs to work in multiple contexts: direct execution, sourced, symlinked, etc.
DEBUG=${DEBUG:-0}
if [[ -n "${BASH_SOURCE[0]:-}" ]]; then
  # Running in bash compatibility mode
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  [[ $DEBUG -eq 1 ]] && echo "DEBUG: Using BASH_SOURCE, SCRIPT_DIR=$SCRIPT_DIR" >&2
elif [[ -n "${(%):-%x}" ]] && [[ "${(%):-%x}" != "-zsh" ]]; then
  # Zsh with %x prompt expansion (works when sourced)
  SCRIPT_DIR="$(cd "$(dirname "${(%):-%x}")" && pwd)"
  [[ $DEBUG -eq 1 ]] && echo "DEBUG: Using zsh %x, SCRIPT_DIR=$SCRIPT_DIR" >&2
elif [[ -n "${0}" ]] && [[ "${0}" != "-zsh" ]] && [[ "${0}" != "zsh" ]]; then
  # Standard $0 approach (works for direct execution)
  SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
  [[ $DEBUG -eq 1 ]] && echo "DEBUG: Using \$0, SCRIPT_DIR=$SCRIPT_DIR" >&2
else
  # Ultimate fallback: assume we're in ~/.dotfiles structure
  SCRIPT_DIR="$HOME/.dotfiles/src/theme-switcher"
  [[ $DEBUG -eq 1 ]] && echo "DEBUG: Using fallback, SCRIPT_DIR=$SCRIPT_DIR" >&2
fi

# Display usage information and available options
# Provides comprehensive help for theme selection
show_usage() {
  cat <<EOF
Usage: $(basename "$0") [THEME|OPTION]

Theme Switcher - Synchronize terminal themes with macOS appearance

OPTIONS:
    -h, --help, help    Show this help message
    -l, --list          List all available themes
    --local THEME       Change terminal + tmux for THIS session (no global config)
    --local --tmux THEME    Just tmux for this session
    --local --terminal THEME  Just terminal colors for this pane
    --local --shell THEME   Just shell exports
    -t, --terminal THEME  Alias for --local --terminal
    -s, --shell THEME   Alias for --local --shell
    --tmux THEME        Alias for --local --tmux

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

    # Shell-local theming (env vars only):
    source <($(basename "$0") --shell day)   # Light theme env vars
    source <($(basename "$0") --shell moon)  # Dark theme env vars

    # Per-terminal theming (changes THIS terminal's colors):
    $(basename "$0") --terminal day   # Light colors in this terminal
    $(basename "$0") --terminal moon  # Dark colors in this terminal

EOF
}

# Enumerate all available theme variants
# Scans theme directories to provide current options
list_themes() {
  local theme_switcher_dir="$SCRIPT_DIR/themes"
  local wezterm_themes_dir="$HOME/.dotfiles/src/wezterm/themes"
  local themes=()

  echo "Available themes:"
  echo ""

  # Scan theme-switcher themes
  local switcher_themes=(${theme_switcher_dir}/*(N-/))
  for theme_path in $switcher_themes; do
    themes+=("$(basename "$theme_path")")
  done

  # Scan WezTerm themes
  local wezterm_themes=(${wezterm_themes_dir}/*.lua(N.))
  for theme_file in $wezterm_themes; do
    themes+=("$(basename "$theme_file" .lua)")
  done

  # Unique sorted list
  if (( ${#themes[@]} > 0 )); then
    local unique_themes=($(printf "%s\n" "${themes[@]}" | sort -u))
    for theme in "${unique_themes[@]}"; do
      local variant="dark"
      [[ "$theme" =~ (day|light) ]] && variant="light"
      echo "  $theme ($variant)"
    done
  else
    echo "  No themes found."
  fi
  echo ""
  echo "Use any theme name with: switch-theme.sh THEME_NAME"
}

# Print shell export commands for local theming
# Used with: source <(switch-theme.sh --shell THEME)
print_shell_exports() {
  local starship_config="$SCRIPT_DIR/themes/$THEME/starship.toml"
  cat <<EOF
export MACOS_THEME="$THEME"
export MACOS_VARIANT="$VARIANT"
export BAT_THEME="tokyonight_${VARIANT}"
export STARSHIP_CONFIG="$starship_config"
EOF
}

# Send OSC escape sequences to change THIS terminal's colors
# Only affects the current terminal instance, not all terminals
# Handles tmux passthrough automatically when inside tmux
set_terminal_colors() {
  local colors_file="$SCRIPT_DIR/themes/$THEME/colors.sh"

  if [[ ! -f "$colors_file" ]]; then
    echo "Error: Colors file not found: $colors_file" >&2
    return 1
  fi

  # Determine output target: prefer stdout if it's a TTY, else try /dev/tty
  local tty_target=""
  if [[ -t 1 ]]; then
    tty_target="/dev/stdout"
  elif { echo -n "" > /dev/tty; } 2>/dev/null; then
    tty_target="/dev/tty"
  else
    echo "Error: No TTY available for OSC sequences" >&2
    return 1
  fi

  # Source the colors
  source "$colors_file"

  # Helper: convert #RRGGBB to rgb:RR/GG/BB format for OSC sequences
  _hex_to_osc_rgb() {
    local hex="${1#\#}"
    local r="${hex:0:2}" g="${hex:2:2}" b="${hex:4:2}"
    echo "rgb:$r/$g/$b"
  }

  # Helper: send OSC sequence with tmux passthrough if needed
  # Uses doubled escapes for tmux passthrough as per WezTerm/terminal docs
  _osc() {
    local code="$1" value="$2"
    if [[ -n "${TMUX:-}" ]]; then
      # tmux passthrough: \033P tmux; \033\033]code;value\007 \033\\
      # All inner escapes must be doubled for tmux to pass through correctly
      printf '\033Ptmux;\033\033]%s;%s\007\033\\' "$code" "$value" > "$tty_target"
    else
      printf '\033]%s;%s\007' "$code" "$value" > "$tty_target"
    fi
  }

  # OSC 10: Set foreground color
  _osc "10" "$(_hex_to_osc_rgb "$FOREGROUND")"

  # OSC 11: Set background color
  _osc "11" "$(_hex_to_osc_rgb "$BACKGROUND")"

  # OSC 12: Set cursor color (use foreground if not specified)
  _osc "12" "$(_hex_to_osc_rgb "${CURSOR:-$FOREGROUND}")"

  # OSC 4: Set palette colors 0-15
  local i color
  for i in {0..15}; do
    eval "color=\$COLOR_$i"
    if [[ -n "$color" ]]; then
      _osc "4;$i" "$(_hex_to_osc_rgb "$color")"
    fi
  done
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

# Default themes (defined early for auto-detection)
LIGHT_THEME="${THEME_LIGHT:-tokyonight_day}"
DARK_THEME="${THEME_DARK:-tokyonight_storm}"

# Auto-detect theme from macOS system appearance preferences
# Respects user's system-wide dark/light mode setting for consistency
if [[ -z "$THEME" ]]; then
  # Query macOS appearance setting via defaults command
  # AppleInterfaceStyle returns "Dark" in dark mode, undefined in light mode
  if defaults read -g AppleInterfaceStyle 2>/dev/null | grep -q "Dark"; then
    THEME="$DARK_THEME"
  else
    THEME="$LIGHT_THEME"
  fi
  echo "Auto-detected theme: $THEME"
fi

# Configuration directories
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/theme-switcher"
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/theme-switcher"
ALACRITTY_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/alacritty"
TMUX_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/tmux"
STARSHIP_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"
WEZTERM_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/wezterm"
KITTY_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/kitty"

# Lock and log configuration
LOCK_FILE="$CACHE_DIR/theme-switch.lock"
LOCK_ACQUIRED=0
LOG_FILE="$CACHE_DIR/theme-switch.log"
MAX_LOG_SIZE=1048576 # 1MB

# Create required directories with appropriate permissions
# Cache directory needs restricted access for lock files and logs
mkdir -p "$CONFIG_DIR" "$CACHE_DIR" "$ALACRITTY_DIR" "$TMUX_DIR" "$WEZTERM_DIR" "$KITTY_DIR"
chmod 700 "$CACHE_DIR"

# Log messages with timestamps for debugging theme switches
# Provides audit trail for troubleshooting theme issues
log() {
  local level="${2:-INFO}"
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$level] $1" >>"$LOG_FILE"

  # Prevent log files from growing indefinitely
  # Rotates when exceeding size limit to maintain performance
  if [[ -f "$LOG_FILE" ]]; then
    local log_size
    if [[ "$(uname)" == "Darwin" ]]; then
      log_size=$(stat -f%z "$LOG_FILE" 2>/dev/null || echo 0)
    else
      log_size=$(stat -c%s "$LOG_FILE" 2>/dev/null || echo 0)
    fi

    if [[ $log_size -gt $MAX_LOG_SIZE ]]; then
      mv "$LOG_FILE" "$LOG_FILE.old"
      touch "$LOG_FILE"
      chmod 600 "$LOG_FILE"
    fi
  fi
}

# Acquire exclusive lock to prevent concurrent theme switches
# Prevents race conditions that could corrupt theme configurations
acquire_lock() {
  local timeout=100  # 10 seconds in 0.1 second increments
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
    echo "Error: Another theme switch is in progress. If stuck, remove: $LOCK_FILE" >&2
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

# Map user input to canonical theme names
# Handles both short names (day, night) and full names (tokyonight_day)
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
    # Map convenient short names to full theme identifiers
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
      # Auto-detect variant from theme name patterns
      # Light themes typically contain 'day' or 'light' in name
      if [[ "$THEME" =~ (day|light)$ ]]; then
        VARIANT="light"
      else
        VARIANT="dark"
      fi
      ;;
  esac
}

# Avoid unnecessary operations if theme already active
# Still allows reapplication to fix potential inconsistencies
check_current_theme() {
  if [[ -f "$CONFIG_DIR/current-theme.sh" ]]; then
    source "$CONFIG_DIR/current-theme.sh"
    if [[ "${MACOS_THEME:-}" == "$THEME" ]]; then
      echo "Already using theme: $THEME (reapplying to ensure consistency)"
      # Continue processing to fix any potential configuration drift
    fi
  fi
}

# Save theme state atomically to prevent corruption
# Other processes can safely read current theme during switches
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

# Update Alacritty configuration with atomic file replacement
# Prevents terminal corruption during theme application
update_alacritty_theme() {
  local theme_source="$1"
  local theme_dest="$2"

  if [[ ! -f "$theme_source" ]]; then
    log "Theme file not found: $theme_source" "WARN"
    return 1
  fi

  local temp_file="${theme_dest}.tmp.$$"
  cp "$theme_source" "$temp_file"

  # Atomic move ensures configuration consistency
  # Prevents partial writes that could break terminal rendering
  mv -f "$temp_file" "$theme_dest"
  chmod 644 "$theme_dest"

  # Clean up any leftover temp files (zsh-safe glob)
  setopt localoptions nullglob
  rm -f "${theme_dest}".tmp.* 2>/dev/null || true

  log "Updated Alacritty theme"
  return 0
}

# Update WezTerm theme globally using a hybrid approach:
# 1. Update current-theme file (new windows read this at creation time)
# 2. OSC sequences to current pane (fixes focused window - bypasses bug #5451)
# 3. User-var triggers OSC injection to ALL panes via Lua handler
# See: https://github.com/wezterm/wezterm/issues/5451
update_wezterm_theme() {
  local colors_file="$SCRIPT_DIR/themes/$THEME/colors.sh"

  # Helper: convert #RRGGBB to rgb:RR/GG/BB format for OSC sequences
  _hex_to_osc_rgb() {
    local hex="${1#\#}"
    local r="${hex:0:2}" g="${hex:2:2}" b="${hex:4:2}"
    echo "rgb:$r/$g/$b"
  }

  # Helper: send escape sequence (handles tmux passthrough)
  # Uses printf '%b' to interpret \033 as actual ESC bytes
  _send_seq() {
    local seq="$1"
    local target="$2"
    if [[ -n "${TMUX:-}" ]]; then
      # tmux passthrough: double all escape characters
      # First interpret \033 sequences, then double them for tmux
      local doubled
      doubled=$(printf '%b' "$seq" | sed 's/\x1b/\x1b\x1b/g')
      printf '\033Ptmux;%s\033\\' "$doubled" > "$target"
    else
      printf '%b' "$seq" > "$target"
    fi
  }

  # STEP 1: Update current-theme file (new windows read this at creation time)
  local theme_name_file="$HOME/.config/wezterm/current-theme"
  mkdir -p "$(dirname "$theme_name_file")"
  echo "$THEME" > "$theme_name_file"
  log "Updated WezTerm current-theme file"

  # Determine TTY target
  local tty_target=""
  if [[ -t 1 ]]; then
    tty_target="/dev/stdout"
  elif { echo -n "" > /dev/tty; } 2>/dev/null; then
    tty_target="/dev/tty"
  fi

  # STEP 2: Send OSC color sequences to CURRENT pane (fixes focused window)
  if [[ -f "$colors_file" ]] && [[ -n "$tty_target" ]]; then
    source "$colors_file"

    local osc_sequence=""
    [[ -n "${FOREGROUND:-}" ]] && osc_sequence+="\033]10;$(_hex_to_osc_rgb "$FOREGROUND")\007"
    [[ -n "${BACKGROUND:-}" ]] && osc_sequence+="\033]11;$(_hex_to_osc_rgb "$BACKGROUND")\007"
    osc_sequence+="\033]12;$(_hex_to_osc_rgb "${CURSOR:-$FOREGROUND}")\007"

    local i color
    for i in {0..15}; do
      eval "color=\${COLOR_$i:-}"
      [[ -n "$color" ]] && osc_sequence+="\033]4;$i;$(_hex_to_osc_rgb "$color")\007"
    done

    _send_seq "$osc_sequence" "$tty_target"
    log "Applied OSC colors to current pane"
  fi

  # STEP 3: Send user-var to trigger reload_configuration() (loads NEW config for new windows)
  if [[ -n "$tty_target" ]]; then
    local encoded_theme
    encoded_theme=$(printf '%s' "$THEME" | base64)
    local uservar_seq
    uservar_seq=$(printf '\033]1337;SetUserVar=%s=%s\007' "theme" "$encoded_theme")
    _send_seq "$uservar_seq" "$tty_target"
    log "Sent user-var to trigger config reload"
  fi

  return 0
}

# Utility for safe configuration file updates
# Ensures atomicity and proper permissions for all theme files
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

  # Clean up any leftover temp files (zsh-safe glob)
  setopt localoptions nullglob
  rm -f "${dest}".tmp.* 2>/dev/null || true

  return 0
}

# Update other application themes
update_app_themes() {
  local theme_dir="$SCRIPT_DIR/themes/$THEME"
  local success=0

  [[ $DEBUG -eq 1 ]] && echo "DEBUG: Looking for theme files in: $theme_dir" >&2

  # Update Alacritty
  if [[ -f "$theme_dir/alacritty.toml" ]]; then
    update_alacritty_theme "$theme_dir/alacritty.toml" "$ALACRITTY_DIR/theme.toml" || success=1
  fi

  # Update WezTerm (generates complete ~/.wezterm.lua with colors inlined)
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
      [[ $DEBUG -eq 1 ]] && echo "DEBUG: No tmux server found" >&2
      return 0
    fi

    [[ $DEBUG -eq 1 ]] && echo "DEBUG: Reloading tmux configuration" >&2

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

    # Explicitly source theme.conf directly (tmux if-shell runs async, so we can't rely on it)
    if [[ -f "$TMUX_DIR/theme.conf" ]]; then
      tmux source-file "$TMUX_DIR/theme.conf" 2>/dev/null || true
      log "Sourced theme.conf directly"
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

  # Backup current files (preserving structure for easy restore)
  [[ -f "$CONFIG_DIR/current-theme.sh" ]] && cp "$CONFIG_DIR/current-theme.sh" "$backup_dir/"
  [[ -f "$ALACRITTY_DIR/theme.toml" ]] && cp "$ALACRITTY_DIR/theme.toml" "$backup_dir/"
  [[ -f "$WEZTERM_DIR/theme.lua" ]] && cp "$WEZTERM_DIR/theme.lua" "$backup_dir/"
  [[ -f "$KITTY_DIR/theme.conf" ]] && cp "$KITTY_DIR/theme.conf" "$backup_dir/kitty-theme.conf"
  [[ -f "$TMUX_DIR/theme.conf" ]] && cp "$TMUX_DIR/theme.conf" "$backup_dir/"
  [[ -f "$STARSHIP_DIR/starship.toml" ]] && cp "$STARSHIP_DIR/starship.toml" "$backup_dir/"

  echo "$backup_dir"
}

# Restore configuration on failure
restore_config() {
  local backup_dir="$1"

  if [[ -d "$backup_dir" ]]; then
    # Restore all backed up files to their original locations
    [[ -f "$backup_dir/current-theme.sh" ]] && cp "$backup_dir/current-theme.sh" "$CONFIG_DIR/"
    [[ -f "$backup_dir/theme.toml" ]] && cp "$backup_dir/theme.toml" "$ALACRITTY_DIR/"
    [[ -f "$backup_dir/theme.lua" ]] && cp "$backup_dir/theme.lua" "$WEZTERM_DIR/"
    [[ -f "$backup_dir/kitty-theme.conf" ]] && cp "$backup_dir/kitty-theme.conf" "$KITTY_DIR/theme.conf"
    [[ -f "$backup_dir/theme.conf" ]] && cp "$backup_dir/theme.conf" "$TMUX_DIR/"
    [[ -f "$backup_dir/starship.toml" ]] && cp "$backup_dir/starship.toml" "$STARSHIP_DIR/"

    # Archive the backup after restore (keeping for debugging)
    local archive_dir="$HOME/.dotfiles-theme-backups/$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$archive_dir"
    mv "$backup_dir" "$archive_dir/restored-backup" 2>/dev/null || true
    log "Restored previous configuration (backup archived to $archive_dir)"
  fi
}

# Validate theme exists
validate_theme() {
  local theme_switcher_dir="$SCRIPT_DIR/themes"
  local theme_dir="$theme_switcher_dir/$THEME"
  local wezterm_themes_dir="$HOME/.dotfiles/src/wezterm/themes"
  local wezterm_theme_file="$wezterm_themes_dir/$THEME.lua"

  [[ $DEBUG -eq 1 ]] && echo "DEBUG: Validating theme '$THEME'" >&2
  [[ $DEBUG -eq 1 ]] && echo "DEBUG: Checking directory: $theme_dir" >&2
  [[ $DEBUG -eq 1 ]] && echo "DEBUG: Checking WezTerm file: $wezterm_theme_file" >&2

  if [[ ! -d "$theme_dir" && ! -f "$wezterm_theme_file" ]]; then
    echo "Error: Theme '$THEME' not found" >&2
    echo "Checked for directory: $theme_dir" >&2
    echo "Checked for WezTerm theme: $wezterm_theme_file" >&2
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

    # Clean up backup on success (no need to keep it)
    rm -rf "$backup_dir" 2>/dev/null || true

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

# Handle --shell flag for shell-local theming
# Must be after function definitions but before main()
if [[ "${1:-}" == "-s" || "${1:-}" == "--shell" ]]; then
  shift
  THEME="${1:-}"
  if [[ -z "$THEME" ]]; then
    echo "Error: --shell requires a theme name" >&2
    echo "Usage: source <($(basename "$0") --shell THEME)" >&2
    exit 1
  fi
  determine_theme
  validate_theme
  print_shell_exports
  exit 0
fi

# Handle --local flag for per-session theming (no global config changes)
# Changes terminal colors + tmux for THIS session only
if [[ "${1:-}" == "--local" ]]; then
  shift

  # Check for sub-flags: --local --tmux, --local --terminal, --local --shell
  _local_component=""
  if [[ "${1:-}" == "--tmux" || "${1:-}" == "--terminal" || "${1:-}" == "--shell" ]]; then
    _local_component="${1#--}"
    shift
  fi

  THEME="${1:-}"
  if [[ -z "$THEME" ]]; then
    echo "Error: --local requires a theme name" >&2
    echo "Usage: $(basename "$0") --local [--tmux|--terminal|--shell] THEME" >&2
    exit 1
  fi
  determine_theme
  validate_theme

  # Helper: apply tmux theme to current session only (not global)
  _apply_tmux_session_theme() {
    local theme_file="$SCRIPT_DIR/themes/$THEME/tmux.conf"
    if [[ ! -f "$theme_file" ]]; then
      return 1
    fi
    # Strip -g flag to make settings session-local instead of global
    # Also strip setw -g to set -w (window option for current session)
    sed -e 's/^set -g /set /g' -e 's/^setw -g /setw /g' "$theme_file" | \
      while IFS= read -r line; do
        # Skip comments and empty lines
        [[ "$line" =~ ^#.*$ || -z "$line" ]] && continue
        eval "tmux $line" 2>/dev/null || true
      done
    tmux refresh-client -S 2>/dev/null || true
  }

  case "$_local_component" in
    tmux)
      # Just tmux for this session
      _apply_tmux_session_theme
      ;;
    terminal)
      # Just terminal colors
      set_terminal_colors
      ;;
    shell)
      # Just shell exports
      print_shell_exports
      ;;
    *)
      # Everything: terminal + tmux (session-local)
      set_terminal_colors
      if [[ -n "${TMUX:-}" ]]; then
        _apply_tmux_session_theme
      fi
      ;;
  esac
  exit 0
fi

# Handle --tmux flag (reload tmux theme only, session-wide)
if [[ "${1:-}" == "--tmux" ]]; then
  shift
  THEME="${1:-}"
  if [[ -z "$THEME" ]]; then
    echo "Error: --tmux requires a theme name" >&2
    echo "Usage: $(basename "$0") --tmux THEME" >&2
    exit 1
  fi
  determine_theme
  validate_theme
  if [[ -f "$SCRIPT_DIR/themes/$THEME/tmux.conf" ]]; then
    tmux source-file "$SCRIPT_DIR/themes/$THEME/tmux.conf" || {
      echo "Error: Failed to reload tmux theme" >&2
      exit 1
    }
    tmux refresh-client -S 2>/dev/null || true
    echo "Reloaded tmux theme: $THEME"
  else
    echo "Error: tmux.conf not found for theme $THEME" >&2
    exit 1
  fi
  exit 0
fi

# Handle --terminal flag for per-terminal theming via OSC sequences
# Same as --local, kept for compatibility
if [[ "${1:-}" == "-t" || "${1:-}" == "--terminal" ]]; then
  shift
  THEME="${1:-}"
  if [[ -z "$THEME" ]]; then
    echo "Error: --terminal requires a theme name" >&2
    echo "Usage: $(basename "$0") --terminal THEME" >&2
    exit 1
  fi
  determine_theme
  validate_theme
  set_terminal_colors
  exit 0
fi

main
