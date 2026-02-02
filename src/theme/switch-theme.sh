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
#   ~/.config/theme/current-theme.sh - Shell environment
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
VERBOSE=${VERBOSE:-0}

# Print message when verbose mode is enabled
# Used for user-friendly progress output (different from DEBUG which is for development)
verbose() {
  [[ $VERBOSE -eq 1 ]] && echo "  → $1"
  return 0
}
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
  SCRIPT_DIR="$HOME/.dotfiles/src/theme"
  [[ $DEBUG -eq 1 ]] && echo "DEBUG: Using fallback, SCRIPT_DIR=$SCRIPT_DIR" >&2
fi

# JSON theme configuration file
THEMES_JSON="${SCRIPT_DIR}/../../config/themes.json"
THEMES_CACHE=""

# Initialize THEME variable (will be set by args, picker, or auto-detect)
THEME=""

# Load and cache theme configuration JSON
# Returns cached value if already loaded, otherwise reads from file
get_themes_json() {
  if [[ -z "$THEMES_CACHE" ]]; then
    if [[ -f "$THEMES_JSON" ]]; then
      THEMES_CACHE=$(cat "$THEMES_JSON")
    fi
  fi
  echo "$THEMES_CACHE"
}

# Check if jq is available for JSON parsing
has_jq() {
  command -v jq &>/dev/null
}

# Convert theme name (family_variant) to directory path (family/variant)
# Example: catppuccin_mocha -> catppuccin/mocha
get_theme_path() {
  local theme_name="$1"
  local family="${theme_name%%_*}"
  local variant="${theme_name#*_}"
  echo "$SCRIPT_DIR/$family/$variant"
}

# Map theme to valid bat syntax theme
# bat --list-themes shows available themes
get_bat_theme() {
  local theme_name="$1"
  local variant="$2"
  local family="${theme_name%%_*}"

  case "$family" in
    catppuccin) echo "Catppuccin ${variant^}" ;; # Capitalize variant
    dracula) echo "Dracula" ;;
    github) [[ "$variant" == "light" ]] && echo "GitHub" || echo "Visual Studio Dark+" ;;
    gruvbox) [[ "$variant" == "light" ]] && echo "gruvbox-light" || echo "gruvbox-dark" ;;
    monokai) echo "Monokai Extended" ;;
    nord) echo "Nord" ;;
    onedarkpro|atomone) echo "OneHalfDark" ;;
    *) [[ "$variant" == "light" ]] && echo "OneHalfLight" || echo "OneHalfDark" ;;
  esac
}

# Map theme to valid delta syntax theme (same as bat)
get_delta_theme() {
  get_bat_theme "$1" "$2"
}

# Get fzf color scheme based on variant
get_fzf_color() {
  local variant="$1"
  [[ "$variant" == "light" ]] && echo "light" || echo "dark"
}

# Display usage information and available options
# Provides comprehensive help for theme selection
# Dynamically generates theme list from JSON configuration
show_usage() {
  local default_light default_dark
  if has_jq && [[ -f "$THEMES_JSON" ]]; then
    default_light=$(jq -r '.defaults.light' "$THEMES_JSON" 2>/dev/null || echo "tokyonight_day")
    default_dark=$(jq -r '.defaults.dark' "$THEMES_JSON" 2>/dev/null || echo "tokyonight_storm")
  else
    default_light="tokyonight_day"
    default_dark="tokyonight_storm"
  fi

  cat <<EOF
Usage: $(basename "$0") [FAMILY VARIANT|THEME|OPTION]

Theme Switcher - Synchronize terminal themes with macOS appearance

OPTIONS:
    (no args)           Interactive picker with live color preview
    -p, --pick          Force interactive picker
    --auto              Auto-detect from macOS appearance (skip picker)
    -h, --help, help    Show this help message
    -l, --list [FAMILY] List all themes, or variants in a family
    --local THEME       Change terminal + tmux for THIS session (no global config)
    --local --tmux THEME    Just tmux for this session
    --local --terminal THEME  Just terminal colors for this pane
    --local --shell THEME   Just shell exports
    -t, --terminal THEME  Alias for --local --terminal
    -s, --shell THEME   Alias for --local --shell
    --tmux THEME        Alias for --local --tmux

QUICK DEFAULTS:
    light              Use default light theme ($default_light)
    dark               Use default dark theme ($default_dark)

SYNTAX:
    Two-word:          $(basename "$0") github dark
    Full name:         $(basename "$0") github_dark
    Shortcut:          $(basename "$0") storm

THEME FAMILIES:
$(generate_family_list)

SHORTCUTS:
$(generate_alias_list)

EXAMPLES:
    $(basename "$0") dark              # Use default dark theme
    $(basename "$0") catppuccin mocha  # Two-word syntax
    $(basename "$0") github_dark       # Full name syntax
    $(basename "$0") --list github     # List GitHub variants
    $(basename "$0") --terminal storm  # Per-terminal theming

EOF
}

# Generate formatted list of theme families from JSON
generate_family_list() {
  if has_jq && [[ -f "$THEMES_JSON" ]]; then
    jq -r '
      .families | to_entries[] |
      "    \(.key): \(.value.variants | keys | join(", "))"
    ' "$THEMES_JSON" 2>/dev/null | head -20
  else
    echo "    tokyonight: day, night, moon, storm"
  fi
}

# Generate formatted list of aliases from JSON
generate_alias_list() {
  if has_jq && [[ -f "$THEMES_JSON" ]]; then
    jq -r '
      .aliases | to_entries[] |
      select(.value != "defaults.light" and .value != "defaults.dark") |
      "    \(.key) -> \(.value)"
    ' "$THEMES_JSON" 2>/dev/null | head -15
  else
    echo "    day -> tokyonight_day"
    echo "    night -> tokyonight_night"
    echo "    moon -> tokyonight_moon"
    echo "    storm -> tokyonight_storm"
  fi
}

# Enumerate all available theme variants
# Supports optional family filter: list_themes [family]
# Reads from JSON configuration for accurate listing
list_themes() {
  local filter="${1:-}"

  if has_jq && [[ -f "$THEMES_JSON" ]]; then
    if [[ -n "$filter" ]]; then
      # List variants in a specific family
      local family_exists
      family_exists=$(jq -r ".families.\"$filter\" // empty" "$THEMES_JSON")
      if [[ -z "$family_exists" ]]; then
        echo "Error: Unknown family '$filter'" >&2
        echo "Use '$(basename "$0") --list' to see all families" >&2
        return 1
      fi

      local family_name
      family_name=$(jq -r ".families.\"$filter\".name // \"$filter\"" "$THEMES_JSON")
      echo "$family_name variants:"
      echo ""
      jq -r "
        .families.\"$filter\".variants | to_entries[] |
        \"  ${filter}_\(.key) (\(.value.mode))\"
      " "$THEMES_JSON"
    else
      # List all families and variants
      echo "Available themes:"
      echo ""

      jq -r '
        .families | to_entries | sort_by(.key)[] |
        "  \(.value.name) (\(.key)):",
        (.value.variants | to_entries | sort_by(.key)[] | "    - \(.key) [\(.value.mode)]"),
        ""
      ' "$THEMES_JSON"

      echo "Shortcuts:"
      jq -r '.aliases | to_entries[] | "  \(.key) -> \(.value)"' "$THEMES_JSON"
    fi
  else
    # Fallback: scan theme directories
    echo "Available themes:"
    echo ""

    local theme_dirs
    setopt localoptions nullglob
    theme_dirs=(${SCRIPT_DIR}/*_*(N-/))
    for theme_path in $theme_dirs; do
      local theme_name=$(basename "$theme_path")
      local variant="dark"
      [[ "$theme_name" =~ (day|light|latte) ]] && variant="light"
      echo "  $theme_name ($variant)"
    done
  fi
  echo ""
  echo "Usage: $(basename "$0") FAMILY VARIANT  or  $(basename "$0") THEME_NAME"
}

# Interactive theme picker with live color preview
# Uses fzf for selection and OSC sequences for live terminal color preview
interactive_picker() {
  if ! command -v fzf &>/dev/null; then
    echo "Error: fzf is required for interactive picker" >&2
    echo "Install with: brew install fzf" >&2
    return 1
  fi

  if ! has_jq || [[ ! -f "$THEMES_JSON" ]]; then
    echo "Error: themes.json required for interactive picker" >&2
    return 1
  fi

  # Setup cache directory for restore script
  local cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/theme"
  local config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/theme"
  mkdir -p "$cache_dir"

  # Generate theme list with tab-separated columns: full_name, family, variant, mode
  local theme_list
  theme_list=$(jq -r '
    .families | to_entries | sort_by(.key)[] |
    .key as $family | .value.name as $name |
    .value.variants | to_entries | sort_by(.key)[] |
    "\($family)_\(.key)\t\($name)\t\(.key)\t\(.value.mode)"
  ' "$THEMES_JSON")

  # Preview script that shows color palette
  local preview_cmd
  preview_cmd='
    theme=$(echo {} | cut -f1)
    family=$(echo {} | cut -f2)
    variant=$(echo {} | cut -f3)
    mode=$(echo {} | cut -f4)

    # Parse theme name into family/variant path
    family_key=$(echo $theme | cut -d"_" -f1)
    variant_key=$(echo $theme | cut -d"_" -f2-)
    theme_path="'"$SCRIPT_DIR"'/${family_key}/${variant_key}"
    colors_file="$theme_path/colors.sh"

    echo -e "\033[1m$family - $variant\033[0m ($mode)"
    echo ""

    if [[ -f "$colors_file" ]]; then
      source "$colors_file" 2>/dev/null

      # Show color palette with Unicode blocks
      if [[ -n "${BACKGROUND:-}" ]] && [[ -n "${FOREGROUND:-}" ]]; then
        echo -e "Background: \033[48;2;$(printf "%d;%d;%d" 0x${BACKGROUND:1:2} 0x${BACKGROUND:3:2} 0x${BACKGROUND:5:2})m    \033[0m $BACKGROUND"
        echo -e "Foreground: \033[38;2;$(printf "%d;%d;%d" 0x${FOREGROUND:1:2} 0x${FOREGROUND:3:2} 0x${FOREGROUND:5:2})m████\033[0m $FOREGROUND"
        echo ""
        echo "Normal colors:"
        for i in 0 1 2 3 4 5 6 7; do
          eval "c=\${COLOR_$i:-}"
          if [[ -n "$c" ]]; then
            printf "\033[48;2;$(printf "%d;%d;%d" 0x${c:1:2} 0x${c:3:2} 0x${c:5:2})m  \033[0m"
          fi
        done
        echo ""
        echo "Bright colors:"
        for i in 8 9 10 11 12 13 14 15; do
          eval "c=\${COLOR_$i:-}"
          if [[ -n "$c" ]]; then
            printf "\033[48;2;$(printf "%d;%d;%d" 0x${c:1:2} 0x${c:3:2} 0x${c:5:2})m  \033[0m"
          fi
        done
        echo ""
      else
        echo "(Could not load colors)"
      fi
    else
      echo "(colors.sh not found)"
    fi
  '

  # Live preview: apply colors to terminal AND tmux as user browses
  local execute_cmd
  execute_cmd='
    theme=$(echo {} | cut -f1)
    family_key=$(echo $theme | cut -d"_" -f1)
    variant_key=$(echo $theme | cut -d"_" -f2-)
    theme_dir="'"$SCRIPT_DIR"'/${family_key}/${variant_key}"
    colors_file="$theme_dir/colors.sh"
    tmux_file="$theme_dir/tmux.conf"

    if [[ -f "$colors_file" ]]; then
      source "$colors_file" 2>/dev/null || exit 0

      # Apply colors via OSC sequences (with error handling)
      [[ -z "${FOREGROUND:-}" ]] && exit 0
      [[ -z "${BACKGROUND:-}" ]] && exit 0

      hex_to_rgb() {
        local hex="${1#\#}"
        echo "rgb:${hex:0:2}/${hex:2:2}/${hex:4:2}"
      }

      # Set foreground, background, cursor
      printf "\033]10;$(hex_to_rgb "$FOREGROUND")\007"
      printf "\033]11;$(hex_to_rgb "$BACKGROUND")\007"
      printf "\033]12;$(hex_to_rgb "$FOREGROUND")\007"

      # Set palette colors
      for i in 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15; do
        eval "c=\${COLOR_$i:-}"
        if [[ -n "$c" ]]; then
          printf "\033]4;$i;$(hex_to_rgb "$c")\007"
        fi
      done
    fi

    # Also apply tmux theme for live preview using source-file (more reliable)
    if [[ -n "${TMUX:-}" ]] && [[ -f "$tmux_file" ]]; then
      tmux source-file "$tmux_file" 2>/dev/null || true
      tmux refresh-client -S 2>/dev/null || true
    fi
  '

  # Store current theme for restore on cancel
  local current_theme=""
  if [[ -f "$config_dir/current-theme.sh" ]]; then
    current_theme=$(grep "^MACOS_THEME=" "$config_dir/current-theme.sh" 2>/dev/null | cut -d= -f2 | tr -d '"'"'")
  fi

  # Run fzf with preview and live color application
  local selected
  selected=$(echo "$theme_list" | fzf \
    --ansi \
    --height=80% \
    --layout=reverse \
    --border=rounded \
    --prompt="Theme: " \
    --header=$'  FAMILY\tVARIANT\tMODE\n  ↑↓ navigate • enter select • esc cancel' \
    --preview="$preview_cmd" \
    --preview-window=right:40%:wrap \
    --bind="focus:execute-silent($execute_cmd)" \
    --delimiter=$'\t' \
    --with-nth=2,3,4 \
    --tabstop=22 \
  )

  # If cancelled (empty selection), restore original colors and tmux
  if [[ -z "$selected" ]]; then
    if [[ -n "$current_theme" ]]; then
      local family_key="${current_theme%%_*}"
      local variant_key="${current_theme#*_}"
      local theme_dir="$SCRIPT_DIR/$family_key/$variant_key"
      local colors_file="$theme_dir/colors.sh"
      local tmux_file="$theme_dir/tmux.conf"

      if [[ -f "$colors_file" ]]; then
        source "$colors_file"

        # Helper to convert hex to OSC rgb format
        _hex_to_rgb() {
          local hex="${1#\#}"
          echo "rgb:${hex:0:2}/${hex:2:2}/${hex:4:2}"
        }

        # Restore terminal colors - must write to /dev/tty to reach terminal
        {
          printf "\033]10;$(_hex_to_rgb "$FOREGROUND")\007"
          printf "\033]11;$(_hex_to_rgb "$BACKGROUND")\007"
          printf "\033]12;$(_hex_to_rgb "${CURSOR:-$FOREGROUND}")\007"
          for i in {0..15}; do
            eval "c=\${COLOR_$i:-}"
            if [[ -n "$c" ]]; then
              printf "\033]4;$i;$(_hex_to_rgb "$c")\007"
            fi
          done
        } > /dev/tty 2>/dev/null || true
      fi

      # Restore tmux theme using source-file (more reliable)
      if [[ -n "${TMUX:-}" ]] && [[ -f "$tmux_file" ]]; then
        tmux source-file "$tmux_file" 2>/dev/null || true
        tmux refresh-client -S 2>/dev/null || true
      fi
    fi
    echo "Cancelled - restored previous theme"
    return 1
  fi

  # Extract and return the selected theme name (first field)
  local theme_name
  theme_name=$(echo "$selected" | cut -f1)
  echo "$theme_name"
}

# Print shell export commands for local theming
# Used with: source <(switch-theme.sh --shell THEME)
print_shell_exports() {
  local starship_config="$(get_theme_path "$THEME")/starship.toml"
  local bat_theme=$(get_bat_theme "$THEME" "$VARIANT")
  local delta_theme=$(get_delta_theme "$THEME" "$VARIANT")
  local fzf_color=$(get_fzf_color "$VARIANT")
  cat <<EOF
export MACOS_THEME="$THEME"
export MACOS_VARIANT="$VARIANT"
export BAT_THEME="$bat_theme"
export DELTA_SYNTAX_THEME="$delta_theme"
export FZF_COLOR="$fzf_color"
export STARSHIP_CONFIG="$starship_config"
EOF
}

# Send OSC escape sequences to change THIS terminal's colors
# Only affects the current terminal instance, not all terminals
# Handles tmux passthrough automatically when inside tmux
set_terminal_colors() {
  local colors_file="$(get_theme_path "$THEME")/colors.sh"

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

# Check for help, list, pick, or auto options
case "${1:-}" in
  -h | --help | help)
    show_usage
    exit 0
    ;;
  -v | --verbose)
    VERBOSE=1
    shift
    ;;
  -l | --list)
    # Support: --list or --list <family>
    list_themes "${2:-}"
    exit 0
    ;;
  -p | --pick)
    # Force interactive picker
    THEME=$(interactive_picker) || exit 0
    shift
    ;;
  --auto)
    # Force auto-detect from system appearance
    if defaults read -g AppleInterfaceStyle 2>/dev/null | grep -q "Dark"; then
      THEME="${THEME_DARK:-tokyonight_storm}"
    else
      THEME="${THEME_LIGHT:-tokyonight_day}"
    fi
    echo "Auto-detected theme: $THEME"
    shift
    ;;
esac

# Configuration - support two-argument syntax: theme <family> <variant>
# First argument will be set later after flag handling
# This variable tracks potential second argument for two-word syntax
THEME_ARG2=""

# Check if this looks like two-argument syntax (both args non-flags)
# e.g., "theme github dark" but NOT "theme --local storm"
if [[ -n "${1:-}" ]] && [[ "${1:-}" != -* ]] && \
   [[ -n "${2:-}" ]] && [[ "${2:-}" != -* ]]; then
  # Both arguments are non-flags, likely two-argument theme syntax
  THEME_ARG2="${2}"
fi

# Set theme from first argument (unless already set by --pick or --auto)
[[ -z "${THEME:-}" ]] && THEME="${1:-}"

# Default themes (from JSON config or environment, with fallbacks)
if has_jq && [[ -f "$THEMES_JSON" ]]; then
  _json_light=$(jq -r '.defaults.light // "tokyonight_day"' "$THEMES_JSON" 2>/dev/null)
  _json_dark=$(jq -r '.defaults.dark // "tokyonight_storm"' "$THEMES_JSON" 2>/dev/null)
  LIGHT_THEME="${THEME_LIGHT:-$_json_light}"
  DARK_THEME="${THEME_DARK:-$_json_dark}"
else
  LIGHT_THEME="${THEME_LIGHT:-tokyonight_day}"
  DARK_THEME="${THEME_DARK:-tokyonight_storm}"
fi

# Interactive picker or auto-detect when no theme specified
if [[ -z "$THEME" ]]; then
  # If running interactively with a TTY, use interactive picker
  if [[ -t 0 ]] && [[ -t 1 ]] && command -v fzf &>/dev/null; then
    THEME=$(interactive_picker) || exit 0
  else
    # Non-interactive: auto-detect from macOS appearance
    if defaults read -g AppleInterfaceStyle 2>/dev/null | grep -q "Dark"; then
      THEME="$DARK_THEME"
    else
      THEME="$LIGHT_THEME"
    fi
    echo "Auto-detected theme: $THEME"
  fi
fi

# Configuration directories
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/theme"
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/theme"
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
# Supports: two-argument syntax (github dark), full names (github_dark), aliases (storm)
# Reads from JSON configuration for alias resolution and mode detection
determine_theme() {
  local arg1="${THEME:-}"
  local arg2="${THEME_ARG2:-}"

  # Two-argument syntax: theme <family> <variant>
  if [[ -n "$arg2" ]]; then
    THEME="${arg1}_${arg2}"
    [[ $DEBUG -eq 1 ]] && echo "DEBUG: Two-arg syntax -> $THEME" >&2
  fi

  # Try JSON-based resolution if jq is available
  if has_jq && [[ -f "$THEMES_JSON" ]]; then
    # Check aliases first
    local alias_target
    alias_target=$(jq -r ".aliases.\"$THEME\" // empty" "$THEMES_JSON" 2>/dev/null)

    if [[ -n "$alias_target" ]]; then
      if [[ "$alias_target" == "defaults."* ]]; then
        # Resolve defaults.light or defaults.dark
        local default_key="${alias_target#defaults.}"
        THEME=$(jq -r ".defaults.$default_key" "$THEMES_JSON" 2>/dev/null)
        [[ $DEBUG -eq 1 ]] && echo "DEBUG: Resolved default $default_key -> $THEME" >&2
      else
        THEME="$alias_target"
        [[ $DEBUG -eq 1 ]] && echo "DEBUG: Resolved alias -> $THEME" >&2
      fi
    fi

    # Get mode (light/dark) from JSON
    local family="${THEME%%_*}"
    local variant="${THEME#*_}"
    VARIANT=$(jq -r ".families.\"$family\".variants.\"$variant\".mode // empty" "$THEMES_JSON" 2>/dev/null)

    # Fallback to pattern matching if not in JSON
    if [[ -z "$VARIANT" ]]; then
      if [[ "$THEME" =~ (day|light|latte)($|_) ]]; then
        VARIANT="light"
      else
        VARIANT="dark"
      fi
    fi
  else
    # Fallback: hardcoded mappings for when jq is not available
    case "$THEME" in
      light)
        THEME="$LIGHT_THEME"
        VARIANT="light"
        ;;
      dark)
        THEME="$DARK_THEME"
        VARIANT="dark"
        ;;
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
      latte)
        THEME="catppuccin_latte"
        VARIANT="light"
        ;;
      mocha)
        THEME="catppuccin_mocha"
        VARIANT="dark"
        ;;
      *)
        # Auto-detect variant from theme name patterns
        if [[ "$THEME" =~ (day|light|latte)($|_) ]]; then
          VARIANT="light"
        else
          VARIANT="dark"
        fi
        ;;
    esac
  fi
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
  local bat_theme=$(get_bat_theme "$THEME" "$VARIANT")
  local delta_theme=$(get_delta_theme "$THEME" "$VARIANT")
  local fzf_color=$(get_fzf_color "$VARIANT")
  local starship_config="$(get_theme_path "$THEME")/starship.toml"
  cat >"$theme_file_tmp" <<EOF
# Current theme configuration
export MACOS_THEME="$THEME"
export MACOS_VARIANT="$VARIANT"
export BAT_THEME="$bat_theme"
export DELTA_SYNTAX_THEME="$delta_theme"
export FZF_COLOR="$fzf_color"
export STARSHIP_CONFIG="$starship_config"
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
  # Touch file to trigger Alacritty's live-reload watcher
  # (mv changes inode which some file watchers don't detect)
  touch "$theme_dest"

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
  local colors_file="$(get_theme_path "$THEME")/colors.sh"

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

  # STEP 1: Update theme.lua file (wezterm.lua imports this for colors)
  local theme_dir="$(get_theme_path "$THEME")"
  local wezterm_theme_src="$theme_dir/wezterm.lua"
  local wezterm_config_dir="$HOME/.config/wezterm"
  local wezterm_theme_dest="$wezterm_config_dir/theme.lua"
  local wezterm_main_config="$wezterm_config_dir/wezterm.lua"

  mkdir -p "$wezterm_config_dir"

  if [[ -f "$wezterm_theme_src" ]]; then
    cp "$wezterm_theme_src" "$wezterm_theme_dest"
    # Touch main config to trigger WezTerm's auto-reload (same fix as Alacritty)
    [[ -f "$wezterm_main_config" ]] && touch "$wezterm_main_config"
    log "Updated WezTerm theme.lua"
  fi

  # Also update current-theme file for reference
  echo "$THEME" > "$wezterm_config_dir/current-theme"

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
  local theme_dir="$(get_theme_path "$THEME")"
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
  local theme_dir="$(get_theme_path "$THEME")"

  [[ $DEBUG -eq 1 ]] && echo "DEBUG: Validating theme '$THEME'" >&2
  [[ $DEBUG -eq 1 ]] && echo "DEBUG: Checking directory: $theme_dir" >&2

  if [[ ! -d "$theme_dir" ]]; then
    echo "Error: Theme '$THEME' not found" >&2
    echo "Checked for directory: $theme_dir" >&2
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
  # Check for two-argument syntax: --local <family> <variant>
  if [[ -n "${1:-}" ]] && [[ "${1:-}" != -* ]] && \
     [[ -n "${2:-}" ]] && [[ "${2:-}" != -* ]]; then
    THEME_ARG2="${2}"
  fi
  if [[ -z "$THEME" ]]; then
    echo "Error: --local requires a theme name" >&2
    echo "Usage: $(basename "$0") --local [--tmux|--terminal|--shell] THEME" >&2
    exit 1
  fi
  determine_theme
  validate_theme

  # Helper: apply tmux theme to current session only (not global)
  _apply_tmux_session_theme() {
    local theme_file="$(get_theme_path "$THEME")/tmux.conf"
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
  if [[ -f "$(get_theme_path "$THEME")/tmux.conf" ]]; then
    tmux source-file "$(get_theme_path "$THEME")/tmux.conf" || {
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
