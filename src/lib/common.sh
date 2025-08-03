#!/usr/bin/env bash
# Common library for cross-platform dotfiles scripts
# Provides utilities for OS detection and platform-specific command execution

# Strict mode
set -euo pipefail

# ============================================================================
# OS Detection
# ============================================================================

# Detect the operating system
# Returns: "macos", "linux", or "unknown"
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
      # Fallback detection using uname
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
is_macos() {
  [[ "$(detect_os)" == "macos" ]]
}

# Check if running on Linux
# Returns: 0 if Linux, 1 otherwise
is_linux() {
  [[ "$(detect_os)" == "linux" ]]
}

# ============================================================================
# Cross-Platform Command Execution
# ============================================================================

# Execute platform-specific commands
# Usage: platform_command "macos_command" "linux_command" [fallback_command]
# Returns: Exit code of the executed command
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
# Platform-Specific Utilities
# ============================================================================

# Get number of CPU cores
# Returns: Number of CPU cores
get_cpu_count() {
  platform_command \
    "sysctl -n hw.ncpu 2>/dev/null || echo 1" \
    "nproc 2>/dev/null || grep -c ^processor /proc/cpuinfo 2>/dev/null || echo 1"
}

# Get total memory in MB
# Returns: Total memory in megabytes
get_memory_mb() {
  platform_command \
    "echo \$(($(sysctl -n hw.memsize) / 1024 / 1024))" \
    "free -m | awk '/^Mem:/ {print \$2}'"
}

# Open URL or file in default application
# Usage: open_in_default "url_or_file"
open_in_default() {
  local target="${1:?Error: target required}"
  
  platform_command \
    "open '${target}'" \
    "xdg-open '${target}' 2>/dev/null || sensible-browser '${target}' 2>/dev/null"
}

# Copy to clipboard
# Usage: echo "text" | copy_to_clipboard
copy_to_clipboard() {
  platform_command \
    "pbcopy" \
    "xclip -selection clipboard 2>/dev/null || xsel --clipboard --input 2>/dev/null"
}

# Paste from clipboard
# Returns: Clipboard contents
paste_from_clipboard() {
  platform_command \
    "pbpaste" \
    "xclip -selection clipboard -o 2>/dev/null || xsel --clipboard --output 2>/dev/null"
}

# ============================================================================
# Package Manager Detection
# ============================================================================

# Check if a command exists
# Usage: has_command "command_name"
# Returns: 0 if command exists, 1 otherwise
has_command() {
  command -v "${1}" &>/dev/null
}

# Detect package manager
# Returns: Package manager name or "unknown"
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

# Install package using appropriate package manager
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
    dnf|yum)
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
      echo "Error: Unknown package manager" >&2
      return 1
      ;;
  esac
}

# ============================================================================
# File System Utilities
# ============================================================================

# Get real path (resolving symlinks)
# Usage: realpath_portable "path"
realpath_portable() {
  local path="${1:?Error: path required}"
  
  if has_command realpath; then
    realpath "${path}"
  elif has_command readlink; then
    # macOS compatibility
    if is_macos; then
      # macOS readlink doesn't have -f by default
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

# Create temporary directory
# Returns: Path to created temporary directory
create_temp_dir() {
  platform_command \
    "mktemp -d -t 'tmp.XXXXXX'" \
    "mktemp -d"
}

# ============================================================================
# Process Management
# ============================================================================

# Check if process is running
# Usage: is_process_running "process_name"
is_process_running() {
  local process="${1:?Error: process name required}"
  
  platform_command \
    "pgrep -x '${process}' &>/dev/null" \
    "pgrep -x '${process}' &>/dev/null"
}

# Kill process by name
# Usage: kill_process "process_name" [signal]
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

# Get current user's shell
# Returns: Path to user's shell
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

# Get home directory
# Returns: Path to home directory
get_home_dir() {
  echo "${HOME:-$(eval echo ~)}"
}

# ============================================================================
# Display Utilities
# ============================================================================

# Check if terminal supports colors
# Returns: 0 if colors supported, 1 otherwise
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

# Print colored output
# Usage: print_color "color_name" "message"
# Colors: red, green, yellow, blue, magenta, cyan
print_color() {
  local color="${1:?Error: color required}"
  local message="${2:?Error: message required}"
  
  if ! supports_colors; then
    echo "${message}"
    return
  fi
  
  local color_code
  case "${color}" in
    red)     color_code="31" ;;
    green)   color_code="32" ;;
    yellow)  color_code="33" ;;
    blue)    color_code="34" ;;
    magenta) color_code="35" ;;
    cyan)    color_code="36" ;;
    *)       color_code="0" ;;
  esac
  
  echo -e "\033[0;${color_code}m${message}\033[0m"
}

# ============================================================================
# Export Functions
# ============================================================================

# Export all functions for use in subshells
export -f detect_os is_macos is_linux platform_command
export -f get_cpu_count get_memory_mb open_in_default
export -f copy_to_clipboard paste_from_clipboard
export -f has_command detect_package_manager install_package
export -f realpath_portable create_temp_dir
export -f is_process_running kill_process
export -f get_user_shell get_home_dir
export -f supports_colors print_color