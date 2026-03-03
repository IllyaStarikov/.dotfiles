#!/usr/bin/env zsh
# common.sh - Shared library for dotfiles scripts
#
# DESCRIPTION:
#   Provides cross-platform utilities for OS detection, command execution,
#   colored output, and error handling. All dotfiles scripts source this
#   library for consistent functionality across macOS and Linux.
#
#   NOTE: This file is a compatibility wrapper around src/lib/.
#   New scripts should use: source "$DOTFILES/src/lib/init.zsh"
#
# USAGE:
#   source "${SCRIPT_DIR}/common.sh"
#
#   # OS detection
#   if is_macos; then
#     brew install package
#   elif is_linux; then
#     apt install package
#   fi
#
#   # Colored output
#   print_color green "Success"
#   print_color red "Failed"
#
#   # Platform-specific commands
#   platform_command "brew install git" "apt install git"

# Note: Strict mode (set -euo pipefail) should be set in individual scripts,
# not here, as this file is sourced and would affect the calling script's behavior

# ============================================================================
# Load Core Library
# ============================================================================

# Determine DOTFILES path from this script's location
_COMMON_SH_DIR="${0:A:h}"
export DOTFILES="${DOTFILES:-${_COMMON_SH_DIR}/../..}"

# Source the library (provides colors, utils, logging, die)
source "${DOTFILES}/src/lib/init.zsh"

# ============================================================================
# Backwards Compatibility Wrappers
# These map old function names to library equivalents
# ============================================================================

# has_command - alias for command_exists
has_command() { command_exists "$1"; }

# print_color - wrapper around colorize for backwards compatibility
# Usage: print_color "color" "message"
print_color() {
  local color="${1:?Error: color required}"
  local message="${2:?Error: message required}"

  # Convert to uppercase for colorize compatibility
  local color_upper="${color:u}"

  # Check if output is a terminal
  if [[ ! -t 1 ]]; then
    echo "${message}"
    return
  fi

  colorize "${color_upper}" "${message}"
}

# ============================================================================
# Cross-Platform Command Execution
# These functions are unique to common.sh (not in library)
# ============================================================================

# Execute platform-specific commands with automatic OS detection
# Usage: platform_command "macos_command" "linux_command" [fallback_command]
platform_command() {
  local macos_cmd="${1:-}"
  local linux_cmd="${2:-}"
  local fallback_cmd="${3:-true}"
  local os

  os="$(get_os)"

  case "${os}" in
    macos)
      if [[ -n "${macos_cmd}" ]]; then
        eval "${macos_cmd}"
      else
        eval "${fallback_cmd}"
      fi
      ;;
    linux)
      if [[ -n "${linux_cmd}" ]]; then
        eval "${linux_cmd}"
      else
        eval "${fallback_cmd}"
      fi
      ;;
    *)
      eval "${fallback_cmd}"
      ;;
  esac
}
