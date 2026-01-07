#!/usr/bin/env zsh
# common.sh - Shared library for dotfiles scripts
#
# DESCRIPTION:
#   Provides cross-platform utilities for OS detection, command execution,
#   colored output, and error handling. All dotfiles scripts source this
#   library for consistent functionality across macOS and Linux.
#   Based on Google Shell Style Guide: https://google.github.io/styleguide/shellguide.html
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
#   print_color green "✓ Success"
#   print_color red "✗ Failed"
#
#   # Platform-specific commands
#   platform_command "brew install git" "apt install git"
#
# FUNCTIONS:
#   detect_os()         - Returns "macos", "linux", or "unknown"
#   is_macos()          - Returns 0 if running on macOS
#   is_linux()          - Returns 0 if running on Linux
#   platform_command()  - Execute platform-specific commands
#   get_cpu_count()     - Get number of CPU cores
#   get_memory_gb()     - Get total memory in GB
#   print_color()       - Print colored text to stdout
#   check_command()     - Check if command exists
#   error_exit()        - Exit with error message

# Note: Strict mode (set -euo pipefail) should be set in individual scripts,
# not here, as this file is sourced and would affect the calling script's behavior

# ============================================================================
# Operating System Detection
# Cross-platform compatibility layer for different Unix-like systems
# ============================================================================

# Detect the operating system reliably across environments
# Returns: "macos", "linux", or "unknown"
# Uses both OSTYPE and uname fallback for maximum compatibility
# Example: os="$(detect_os)"; echo "Running on $os"
detect_os() {
  local os="unknown"

  case "${OSTYPE:-}" in
    darwin*)
      os="macos"
      ;;
    linux*)
      os="linux"
      ;;
    *)
      # Fallback detection using uname for unknown OSTYPE values
      # Some environments don't set OSTYPE or use non-standard values
      local uname_output
      uname_output="$(uname -s 2>/dev/null || true)"
      case "${uname_output}" in
        Darwin*)
          os="macos"
          ;;
        Linux*)
          os="linux"
          ;;
      esac
      ;;
  esac

  echo "${os}"
}

# Check if running on macOS
# Returns: 0 if macOS, 1 otherwise
# Example: if is_macos; then echo "On Mac"; fi
is_macos() {
  [[ "$(detect_os)" == "macos" ]]
}

# Check if running on Linux
# Returns: 0 if Linux, 1 otherwise
# Example: if is_linux; then echo "On Linux"; fi
is_linux() {
  [[ "$(detect_os)" == "linux" ]]
}

# ============================================================================
# Cross-Platform Command Execution
# Abstracts platform-specific commands for consistent script behavior
# ============================================================================

# Execute platform-specific commands with automatic OS detection
# Provides unified interface for cross-platform operations
# Usage: platform_command "macos_command" "linux_command" [fallback_command]
# Args:
#   $1 - Command to run on macOS
#   $2 - Command to run on Linux
#   $3 - Optional fallback command for unknown systems
# Returns: Exit code of the executed command
# Example: platform_command "brew install jq" "apt install jq" "echo 'Please install jq'"
platform_command() {
  local macos_cmd="${1:-}"
  local linux_cmd="${2:-}"
  local fallback_cmd="${3:-true}"
  local os

  os="$(detect_os)"

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
# Hardware and system utilities that vary between operating systems
# ============================================================================

# Get number of CPU cores for parallel processing
# Different systems expose this information through different interfaces
# Returns: Number of CPU cores (minimum 1)
# Example: cores="$(get_cpu_count)"; make -j"$cores"
get_cpu_count() {
  platform_command \
    "sysctl -n hw.ncpu 2>/dev/null || echo 1" \
    "nproc 2>/dev/null || grep -c ^processor /proc/cpuinfo 2>/dev/null || echo 1"
}

# Get total system memory for resource planning
# Memory information location varies between platforms
# Returns: Total memory in megabytes
# Example: mem="$(get_memory_mb)"; echo "${mem}MB available"
get_memory_mb() {
  platform_command \
    "echo \$(($(sysctl -n hw.memsize) / 1024 / 1024))" \
    "free -m | awk '/^Mem:/ {print \$2}'"
}

# Open URL or file in default application
# Usage: open_in_default "url_or_file"
# Args:
#   $1 - URL or file path to open
# Example: open_in_default "https://github.com" || open_in_default "README.md"
open_in_default() {
  local target="${1:?Error: target required}"

  platform_command \
    "open '${target}'" \
    "xdg-open '${target}' 2>/dev/null || sensible-browser '${target}' 2>/dev/null"
}

# Copy text to system clipboard
# Usage: echo "text" | copy_to_clipboard
# Example: git remote -v | copy_to_clipboard
copy_to_clipboard() {
  platform_command \
    "pbcopy" \
    "xclip -selection clipboard 2>/dev/null || xsel --clipboard --input 2>/dev/null"
}

# Paste text from system clipboard
# Returns: Clipboard contents to stdout
# Example: paste_from_clipboard | grep "pattern"
paste_from_clipboard() {
  platform_command \
    "pbpaste" \
    "xclip -selection clipboard -o 2>/dev/null || xsel --clipboard --output 2>/dev/null"
}

# ============================================================================
# Package Manager Detection and Operations
# Abstracts different Linux distributions' package management systems
# ============================================================================

# Check if a command exists in PATH efficiently
# Uses command -v which is POSIX-compliant and faster than which
# Usage: has_command "command_name"
# Args:
#   $1 - Name of command to check
# Returns: 0 if command exists, 1 otherwise
# Example: if has_command "docker"; then docker ps; fi
has_command() {
  command -v "${1}" &>/dev/null
}

# Find and return the first available command from a list
# Useful for implementing silent fallback chains
# Usage: cmd=$(first_available_command nvim vim vi)
# Args:
#   $@ - List of commands to try in order of preference
# Returns: Name of first available command (stdout), 0 if found, 1 if none found
# Example: editor=$(first_available_command nvim vim vi nano)
first_available_command() {
  local cmd
  for cmd in "$@"; do
    if command -v "${cmd}" &>/dev/null; then
      echo "${cmd}"
      return 0
    fi
  done
  return 1
}

# Detect system package manager for automated installations
# Checks in order of preference and availability
# Returns: "brew", "apt", "dnf", "yum", "pacman", "zypper", or "unknown"
# Example: pm="$(detect_package_manager)"; echo "Using $pm"
detect_package_manager() {
  if is_macos && has_command brew; then
    echo "brew"
  elif has_command apt-get; then
    echo "apt"
  elif has_command dnf; then
    echo "dnf"
  elif has_command yum; then
    echo "yum"
  elif has_command pacman; then
    echo "pacman"
  elif has_command zypper; then
    echo "zypper"
  elif has_command apk; then
    echo "apk"
  else
    echo "unknown"
  fi
}

# Install package using appropriate system package manager
# Handles package name variations across different systems
# Usage: install_package "package_name" ["brew_name"] ["apt_name"]
# Args:
#   $1 - Default package name
#   $2 - Optional brew-specific package name
#   $3 - Optional apt-specific package name
# Example: install_package "ripgrep" "ripgrep" "ripgrep"
#          install_package "node" "node" "nodejs"
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
      echo "Error: No supported package manager found. Install packages manually." >&2
      echo "Supported: brew (macOS), apt (Debian/Ubuntu), dnf/yum (RHEL/Fedora), pacman (Arch), zypper (openSUSE), apk (Alpine)" >&2
      return 1
      ;;
  esac
}

# ============================================================================
# File System Utilities
# Cross-platform file operations with fallbacks for older systems
# ============================================================================

# Get real path resolving symlinks across platforms
# Provides fallbacks for systems without realpath command
# Usage: realpath_portable "path"
# Args:
#   $1 - Path to resolve
# Returns: Absolute path with symlinks resolved
# Example: real="$(realpath_portable ~/.vimrc)"; echo "Actual location: $real"
realpath_portable() {
  local path="${1:?Error: path required}"

  if has_command realpath; then
    realpath "${path}"
  elif has_command readlink; then
    # Handle macOS vs Linux readlink differences
    if is_macos; then
      # macOS readlink doesn't have -f flag by default
      local dir file
      dir="$(dirname "${path}")"
      file="$(basename "${path}")"
      (cd "${dir}" && echo "$(pwd)/${file}")
    else
      readlink -f "${path}"
    fi
  else
    # Fallback: just resolve relative paths
    if [[ "${path}" = /* ]]; then
      echo "${path}"
    else
      echo "$(pwd)/${path}"
    fi
  fi
}

# Create temporary directory with platform-appropriate flags
# macOS and Linux mktemp have different syntax requirements
# Returns: Path to created temporary directory
# Example: tmpdir="$(create_temp_dir)"; echo "Working in $tmpdir"
create_temp_dir() {
  platform_command \
    "mktemp -d -t 'tmp.XXXXXX'" \
    "mktemp -d"
}

# ============================================================================
# Process Management
# ============================================================================

# Check if process is running by exact name
# Usage: is_process_running "process_name"
# Args:
#   $1 - Exact process name to check
# Returns: 0 if running, 1 if not
# Example: if is_process_running "tmux"; then echo "tmux is running"; fi
is_process_running() {
  local process="${1:?Error: process name required}"

  platform_command \
    "pgrep -x '${process}' &>/dev/null" \
    "pgrep -x '${process}' &>/dev/null"
}

# Kill process by exact name
# Usage: kill_process "process_name" [signal]
# Args:
#   $1 - Exact process name to kill
#   $2 - Optional signal (default: -TERM)
# Example: kill_process "node" || kill_process "firefox" "-KILL"
kill_process() {
  local process="${1:?Error: process name required}"
  local signal="${2:--TERM}"

  platform_command \
    "pkill ${signal} -x '${process}'" \
    "pkill ${signal} -x '${process}'"
}

# ============================================================================
# System Information
# ============================================================================

# Get current user's default shell
# Returns: Path to user's shell (e.g., /bin/zsh)
# Example: shell="$(get_user_shell)"; echo "Using $shell"
get_user_shell() {
  local shell

  # Try environment variable first
  shell="${SHELL:-}"

  if [[ -z "${shell}" ]]; then
    # Fallback to passwd entry
    shell="$(getent passwd "${USER}" 2>/dev/null | cut -d: -f7 || true)"
  fi

  if [[ -z "${shell}" ]]; then
    # Final fallback
    shell="/bin/bash"
  fi

  echo "${shell}"
}

# Get user's home directory portably
# Returns: Path to home directory
# Example: home="$(get_home_dir)"; cd "$home/Documents"
get_home_dir() {
  echo "${HOME:-$(eval echo ~)}"
}

# ============================================================================
# Display Utilities
# ============================================================================

# Check if terminal supports ANSI color codes
# Returns: 0 if colors supported, 1 otherwise
# Example: if supports_colors; then echo -e "\033[32mGreen\033[0m"; fi
supports_colors() {
  local term="${TERM:-}"

  # Check various indicators of color support
  if [[ -t 1 ]] && [[ -n "${term}" ]] && [[ "${term}" != "dumb" ]]; then
    # Check if terminal advertises color support
    [[ "${term}" =~ (color|256) ]] || has_command tput && tput colors &>/dev/null
  else
    return 1
  fi
}

# Print colored output to stdout
# Usage: print_color "color_name" "message"
# Args:
#   $1 - Color name: red, green, yellow, blue, magenta, cyan
#   $2 - Message to print
# Example: print_color green "✓ Success" || print_color red "✗ Failed"
print_color() {
  local color="${1:?Error: color required}"
  local message="${2:?Error: message required}"

  if ! supports_colors; then
    echo "${message}"
    return
  fi

  local color_code
  case "${color}" in
    red) color_code="31" ;;
    green) color_code="32" ;;
    yellow) color_code="33" ;;
    blue) color_code="34" ;;
    magenta) color_code="35" ;;
    cyan) color_code="36" ;;
    *) color_code="0" ;;
  esac

  echo -e "\033[0;${color_code}m${message}\033[0m"
}

# ============================================================================
# Export Functions
# ============================================================================

# Note: zsh doesn't support 'export -f' like bash does
# Functions are automatically available in subshells in zsh
# If needed in child processes, use 'typeset -f' or source this file again
