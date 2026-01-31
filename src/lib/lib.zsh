#!/usr/bin/env zsh

# lib.zsh - Master library loader with dependency management
# Provides centralized loading of ZSH library modules

# Library configuration
typeset -g LIB_DIR="${0:A:h}"
typeset -g LIB_VERBOSE=${LIB_VERBOSE:-0}
typeset -g LIB_STRICT=${LIB_STRICT:-0}
typeset -gA LIB_LOADED=()
typeset -gA LIB_DEPENDENCIES=(
  # Define library dependencies
  [array]=""
  [callstack]="colors"
  [cli]=""
  [colors]=""
  [config]=""
  [die]="colors callstack"
  [hash]=""
  [help]="colors textwrap"
  [json]=""
  [logging]="colors"
  [math]=""
  [ssh]=""
  [textwrap]=""
  [types]=""
  [unit]="colors logging"
  [utils]=""
  [yaml]=""
)

# Load a library module
lib_load() {
  local module="$1"
  local force="${2:-0}"

  # Check if already loaded (use :- for set -u compatibility)
  if [[ -n "${LIB_LOADED[$module]:-}" ]] && [[ $force -eq 0 ]]; then
    [[ $LIB_VERBOSE -eq 1 ]] && echo "Library already loaded: $module" >&2
    return 0
  fi

  # Check if library file exists
  local lib_file="${LIB_DIR}/${module}.zsh"
  if [[ ! -f "$lib_file" ]]; then
    if [[ $LIB_STRICT -eq 1 ]]; then
      echo "Library not found: $module" >&2
      return 1
    else
      [[ $LIB_VERBOSE -eq 1 ]] && echo "Library not found: $module (skipping)" >&2
      return 0
    fi
  fi

  # Load dependencies first
  if [[ -n "${LIB_DEPENDENCIES[$module]:-}" ]]; then
    for dep in ${=LIB_DEPENDENCIES[$module]}; do
      if ! lib_load "$dep"; then
        echo "Failed to load dependency '$dep' for module '$module'" >&2
        return 1
      fi
    done
  fi

  # Source the library
  [[ $LIB_VERBOSE -eq 1 ]] && echo "Loading library: $module" >&2
  if source "$lib_file"; then
    LIB_LOADED[$module]=1
    return 0
  else
    echo "Failed to load library: $module" >&2
    return 1
  fi
}

# Load multiple libraries
lib_load_all() {
  local failed=0

  for module in "$@"; do
    if ! lib_load "$module"; then
      ((failed++))
    fi
  done

  return $((failed > 0 ? 1 : 0))
}

# Load core libraries
lib_load_core() {
  lib_load_all colors utils logging die
}

# Load all available libraries
lib_load_everything() {
  local -a all_libs=(
    array
    callstack
    cli
    colors
    config
    die
    hash
    help
    json
    logging
    math
    ssh
    textwrap
    types
    unit
    utils
    yaml
  )

  lib_load_all "${all_libs[@]}"
}

# Check if a library is loaded
lib_is_loaded() {
  local module="$1"
  [[ -n "${LIB_LOADED[$module]:-}" ]]
}

# List loaded libraries
lib_list_loaded() {
  if [[ ${#LIB_LOADED[@]} -eq 0 ]]; then
    echo "No libraries loaded"
  else
    echo "Loaded libraries:"
    for module in ${(ok)LIB_LOADED}; do
      echo "  - $module"
    done
  fi
}

# List available libraries
lib_list_available() {
  echo "Available libraries:"
  for lib_file in "${LIB_DIR}"/*.zsh; do
    [[ "$lib_file" == */lib.zsh ]] && continue
    local module="${lib_file:t:r}"
    local status=""
    lib_is_loaded "$module" && status=" (loaded)"
    echo "  - $module$status"
  done
}

# Show library dependencies
lib_show_dependencies() {
  local module="${1:-}"

  if [[ -n "$module" ]]; then
    # Show dependencies for specific module
    if [[ -n "${LIB_DEPENDENCIES[$module]:-}" ]]; then
      echo "Dependencies for $module:"
      for dep in ${=LIB_DEPENDENCIES[$module]}; do
        echo "  - $dep"
      done
    else
      echo "$module has no dependencies"
    fi
  else
    # Show all dependencies
    echo "Library dependencies:"
    for module in ${(ok)LIB_DEPENDENCIES}; do
      if [[ -n "${LIB_DEPENDENCIES[$module]:-}" ]]; then
        echo "  $module:"
        for dep in ${=LIB_DEPENDENCIES[$module]}; do
            echo "    - $dep"
        done
      fi
    done
  fi
}

# Reload a library
lib_reload() {
  local module="$1"

  if lib_is_loaded "$module"; then
    [[ $LIB_VERBOSE -eq 1 ]] && echo "Reloading library: $module" >&2
    lib_load "$module" 1
  else
    lib_load "$module"
  fi
}

# Unload a library (limited functionality)
lib_unload() {
  local module="$1"

  if lib_is_loaded "$module"; then
    unset "LIB_LOADED[$module]"
    [[ $LIB_VERBOSE -eq 1 ]] && echo "Unloaded library: $module" >&2
    return 0
  else
    [[ $LIB_VERBOSE -eq 1 ]] && echo "Library not loaded: $module" >&2
    return 1
  fi
}

# Library version information
lib_version() {
  local module="${1:-lib}"

  case "$module" in
    lib) echo "ZSH Library System v1.0.0" ;;
    array) echo "Array Library v1.0.0" ;;
    callstack) echo "Callstack Library v1.0.0" ;;
    cli) echo "CLI Library v1.0.0" ;;
    colors) echo "Colors Library v1.0.0" ;;
    config) echo "Config Library v1.0.0" ;;
    die) echo "Die Library v1.0.0" ;;
    hash) echo "Hash Library v1.0.0" ;;
    help) echo "Help Library v1.0.0" ;;
    json) echo "JSON Library v1.0.0" ;;
    logging) echo "Logging Library v1.0.0" ;;
    math) echo "Math Library v1.0.0" ;;
    ssh) echo "SSH Library v1.0.0" ;;
    textwrap) echo "Textwrap Library v1.0.0" ;;
    types) echo "Types Library v1.0.0" ;;
    unit) echo "Unit Testing Library v1.0.0" ;;
    utils) echo "Utils Library v1.0.0" ;;
    yaml) echo "YAML Library v1.0.0" ;;
    *) echo "Unknown module: $module" ;;
  esac
}

# Library help
lib_help() {
  cat <<EOF
ZSH Library System

Usage:
  source \$DOTFILES_DIR/src/lib/lib.zsh
  lib_load <module>           # Load a specific library
  lib_load_all <modules...>   # Load multiple libraries
  lib_load_core              # Load core libraries
  lib_load_everything        # Load all libraries

Commands:
  lib_load <module>          Load a library module
  lib_load_all <modules...>  Load multiple modules
  lib_load_core             Load core modules (colors, utils, logging, die)
  lib_load_everything       Load all available modules
  lib_is_loaded <module>    Check if module is loaded
  lib_list_loaded          List loaded modules
  lib_list_available       List available modules
  lib_show_dependencies    Show module dependencies
  lib_reload <module>      Reload a module
  lib_unload <module>      Unload a module
  lib_version [module]     Show version information
  lib_help                Show this help

Available Modules:
  array       - Array manipulation
  callstack   - Stack traces and debugging
  cli         - Command-line argument parsing
  colors      - Terminal colors and styling
  config      - JSON config file reading from config/ directory
  die         - Error handling and exit functions
  hash        - Hash/dictionary operations
  help        - Help text generation
  json        - JSON parsing and generation
  logging     - Logging with levels and formatting
  math        - Mathematical functions
  ssh         - SSH operations and key management
  textwrap    - Text formatting and wrapping
  types       - Type checking and validation
  unit        - Unit testing framework
  utils       - General utility functions
  yaml        - YAML parsing and generation

Environment Variables:
  LIB_DIR      - Library directory (auto-detected)
  LIB_VERBOSE  - Verbose loading messages (0/1)
  LIB_STRICT   - Strict mode, fail on missing libs (0/1)

Examples:
  # Load specific libraries
  lib_load colors
  lib_load logging

  # Load multiple libraries
  lib_load_all colors utils logging

  # Load core libraries
  lib_load_core

  # Check if loaded
  if lib_is_loaded colors; then
    echo "Colors library is available"
  fi

  # List what's loaded
  lib_list_loaded
EOF
}

# Auto-load core libraries if LIB_AUTOLOAD is set
if [[ "${LIB_AUTOLOAD:-0}" -eq 1 ]]; then
  lib_load_core
fi

# Note: In zsh, functions are available in subshells by default
# No need to export them (export -f is a bash-ism that prints function defs in zsh)
