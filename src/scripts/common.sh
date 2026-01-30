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

# OS detection - library uses get_os, we also provide detect_os
detect_os() { get_os; }

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

# ============================================================================
# Platform-Specific System Information
# ============================================================================

# Get number of CPU cores for parallel processing
get_cpu_count() { cpu_cores; }

# Get total system memory in MB
get_memory_mb() { memory_mb; }

# Open URL or file in default application
open_in_default() {
  local target="${1:?Error: target required}"

  platform_command \
    "open '${target}'" \
    "xdg-open '${target}' 2>/dev/null || sensible-browser '${target}' 2>/dev/null"
}

# Copy text to system clipboard
copy_to_clipboard() {
  platform_command \
    "pbcopy" \
    "xclip -selection clipboard 2>/dev/null || xsel --clipboard --input 2>/dev/null"
}

# Paste text from system clipboard
paste_from_clipboard() {
  platform_command \
    "pbpaste" \
    "xclip -selection clipboard -o 2>/dev/null || xsel --clipboard --output 2>/dev/null"
}

# ============================================================================
# Package Manager Detection and Operations
# ============================================================================

# Detect system package manager
detect_package_manager() {
  if is_macos && command_exists brew; then
    echo "brew"
  elif command_exists apt-get; then
    echo "apt"
  elif command_exists dnf; then
    echo "dnf"
  elif command_exists yum; then
    echo "yum"
  elif command_exists pacman; then
    echo "pacman"
  elif command_exists zypper; then
    echo "zypper"
  elif command_exists apk; then
    echo "apk"
  else
    echo "unknown"
  fi
}

# Install package using appropriate system package manager
# Usage: install_package "package_name" ["brew_name"] ["apt_name"]
install_package() {
  local package="${1:?Error: package name required}"
  local brew_name="${2:-${package}}"
  local apt_name="${3:-${package}}"

  local pm
  pm="$(detect_package_manager)"

  case "${pm}" in
    brew)
      brew install "${brew_name}"
      ;;
    apt)
      sudo apt-get update && sudo apt-get install -y "${apt_name}"
      ;;
    dnf | yum)
      sudo "${pm}" install -y "${package}"
      ;;
    pacman)
      sudo pacman -S --noconfirm "${package}"
      ;;
    zypper)
      sudo zypper install -y "${package}"
      ;;
    apk)
      sudo apk add "${package}"
      ;;
    *)
      echo "Error: No supported package manager found." >&2
      return 1
      ;;
  esac
}

# ============================================================================
# File System Utilities
# ============================================================================

# Get real path resolving symlinks (wrapper around library)
realpath_portable() { absolute_path "$1"; }

# Create temporary directory
create_temp_dir() { temp_dir; }

# ============================================================================
# Process Management
# ============================================================================

# Check if process is running by exact name
is_process_running() {
  local process="${1:?Error: process name required}"
  pgrep -x "${process}" &>/dev/null
}

# Kill process by exact name
kill_process() {
  local process="${1:?Error: process name required}"
  local signal="${2:--TERM}"
  pkill "${signal}" -x "${process}"
}

# ============================================================================
# System Information
# ============================================================================

# Get current user's default shell
get_user_shell() {
  echo "${SHELL:-/bin/bash}"
}

# Get user's home directory
get_home_dir() {
  echo "${HOME:-$(eval echo ~)}"
}
