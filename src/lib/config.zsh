#!/usr/bin/env zsh

# config.zsh - Configuration file reading library
# Provides helper functions for reading JSON config files from config/ directory

# Get the dotfiles directory
typeset -g CONFIG_DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"
typeset -g CONFIG_DIR="${CONFIG_DOTFILES_DIR}/config"

# Read a value from a config JSON file
# Usage: get_config "packages.json" ".brew.core[]"
# Args:
#   $1 - config file name (relative to config/ directory)
#   $2 - jq query string
#   $3 - default value if query fails or file missing (optional)
# Returns: the value from config, or default if not found
get_config() {
  local config_file="${CONFIG_DIR}/$1"
  local query="$2"
  local default="${3:-}"

  # Check if config file exists and jq is available
  if [[ -f "$config_file" ]] && command -v jq &>/dev/null; then
    local result
    result=$(jq -r "$query // empty" "$config_file" 2>/dev/null)
    if [[ -n "$result" ]] && [[ "$result" != "null" ]]; then
      echo "$result"
    else
      echo "$default"
    fi
  else
    echo "$default"
  fi
}

# Read an array from config as newline-separated values
# Usage: get_config_array "packages.json" ".brew.core"
# Args:
#   $1 - config file name (relative to config/ directory)
#   $2 - jq query string (should point to an array)
# Returns: array values, one per line
get_config_array() {
  local config_file="${CONFIG_DIR}/$1"
  local query="$2"

  if [[ -f "$config_file" ]] && command -v jq &>/dev/null; then
    jq -r "$query[]?" "$config_file" 2>/dev/null
  fi
}

# Read an array from config as a space-separated string
# Usage: packages=$(get_config_array_string "packages.json" ".brew.core")
# Args:
#   $1 - config file name (relative to config/ directory)
#   $2 - jq query string (should point to an array)
# Returns: array values as space-separated string
get_config_array_string() {
  local config_file="${CONFIG_DIR}/$1"
  local query="$2"

  if [[ -f "$config_file" ]] && command -v jq &>/dev/null; then
    jq -r "$query | @sh" "$config_file" 2>/dev/null | tr -d "'" | tr '\n' ' '
  fi
}

# Read config into a zsh array variable
# Usage: load_config_array packages "packages.json" ".brew.core"
# Args:
#   $1 - variable name to store array in
#   $2 - config file name (relative to config/ directory)
#   $3 - jq query string (should point to an array)
load_config_array() {
  local var_name="$1"
  local config_file="${CONFIG_DIR}/$2"
  local query="$3"

  if [[ -f "$config_file" ]] && command -v jq &>/dev/null; then
    # Use process substitution to populate array
    local -a items
    while IFS= read -r item; do
      [[ -n "$item" ]] && items+=("$item")
    done < <(jq -r "$query[]?" "$config_file" 2>/dev/null)

    # Set the variable using nameref-like pattern
    eval "${var_name}=(\"\${items[@]}\")"
  fi
}

# Check if a config file exists
# Usage: if has_config "packages.json"; then ...
# Args:
#   $1 - config file name (relative to config/ directory)
# Returns: 0 if exists, 1 if not
has_config() {
  local config_file="${CONFIG_DIR}/$1"
  [[ -f "$config_file" ]]
}

# Get all keys from a JSON object
# Usage: get_config_keys "symlinks.json" "."
# Args:
#   $1 - config file name (relative to config/ directory)
#   $2 - jq query string (should point to an object)
# Returns: keys, one per line
get_config_keys() {
  local config_file="${CONFIG_DIR}/$1"
  local query="${2:-.}"

  if [[ -f "$config_file" ]] && command -v jq &>/dev/null; then
    jq -r "$query | keys[]?" "$config_file" 2>/dev/null
  fi
}

# Expand tilde in path strings from config
# Usage: expanded=$(expand_config_path "~/.config/nvim")
# Args:
#   $1 - path string that may contain ~
# Returns: expanded path
expand_config_path() {
  local path="$1"
  echo "${path/#\~/$HOME}"
}

# Get a path from config and expand it
# Usage: get_config_path "paths.json" ".backup.dotfiles"
# Args:
#   $1 - config file name
#   $2 - jq query string
#   $3 - default value (optional)
# Returns: expanded path
get_config_path() {
  local raw_path
  raw_path=$(get_config "$1" "$2" "$3")
  expand_config_path "$raw_path"
}

# Validate that required config files exist
# Usage: validate_configs "packages.json" "symlinks.json"
# Args: list of config file names
# Returns: 0 if all exist, 1 if any missing
validate_configs() {
  local missing=0
  for config in "$@"; do
    if ! has_config "$config"; then
      echo "Warning: Config file missing: ${CONFIG_DIR}/$config" >&2
      missing=1
    fi
  done
  return $missing
}

# Read entire config file as JSON string
# Usage: json=$(read_config_file "packages.json")
# Args:
#   $1 - config file name
# Returns: JSON content or empty object
read_config_file() {
  local config_file="${CONFIG_DIR}/$1"
  if [[ -f "$config_file" ]]; then
    cat "$config_file"
  else
    echo "{}"
  fi
}
