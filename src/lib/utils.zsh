#!/usr/bin/env zsh

# utils.zsh - General utility functions for ZSH scripts

# String manipulation utilities
# ==============================

# Trim whitespace from string
trim() {
  local str="$1"
  # Remove leading whitespace
  str="${str#"${str%%[![:space:]]*}"}"
  # Remove trailing whitespace
  str="${str%"${str##*[![:space:]]}"}"
  echo "$str"
}

# Convert to uppercase
to_upper() {
  echo "${1:u}"
}

# Convert to lowercase
to_lower() {
  echo "${1:l}"
}

# Capitalize first letter
capitalize() {
  echo "${1:0:1:u}${1:1}"
}

# Check if string contains substring
contains() {
  local string="$1"
  local substring="$2"
  [[ "$string" == *"$substring"* ]]
}

# Check if string starts with prefix
starts_with() {
  local string="$1"
  local prefix="$2"
  [[ "$string" == "$prefix"* ]]
}

# Check if string ends with suffix
ends_with() {
  local string="$1"
  local suffix="$2"
  [[ "$string" == *"$suffix" ]]
}

# Replace all occurrences in string
replace_all() {
  local string="$1"
  local search="$2"
  local replace="$3"
  echo "${string//$search/$replace}"
}

# Split string into array
split() {
  local string="$1"
  local delimiter="${2:- }"
  local -a result
  IFS="$delimiter" read -rA result <<< "$string"
  echo "${result[@]}"
}

# Join array into string
join() {
  local delimiter="$1"
  shift
  local first=1
  local result=""
  for item in "$@"; do
    if [[ $first -eq 1 ]]; then
      result="$item"
      first=0
    else
      result="${result}${delimiter}${item}"
    fi
  done
  echo "$result"
}

# Repeat string n times
str_repeat() {
  local string="$1"
  local count="$2"
  local result=""
  for ((i=0; i<count; i++)); do
    result+="$string"
  done
  echo "$result"
}

# File and directory utilities
# =============================

# Check if file exists and is readable
file_exists() {
  [[ -f "$1" && -r "$1" ]]
}

# Check if directory exists
dir_exists() {
  [[ -d "$1" ]]
}

# Check if path is absolute
is_absolute_path() {
  [[ "$1" == /* ]]
}

# Get absolute path
absolute_path() {
  local path="$1"
  if is_absolute_path "$path"; then
    echo "$path"
  else
    echo "$(pwd)/$path"
  fi
}

# Get file extension
file_extension() {
  local filename="$1"
  echo "${filename##*.}"
}

# Get filename without extension
file_basename() {
  local filename="$1"
  echo "${filename%.*}"
}

# Get directory from path
file_dirname() {
  local path="$1"
  echo "${path%/*}"
}

# Create directory if it doesn't exist
ensure_dir() {
  local dir="$1"
  if [[ ! -d "$dir" ]]; then
    mkdir -p "$dir"
  fi
}

# Copy with backup
backup_copy() {
  local source="$1"
  local dest="$2"
  if [[ -f "$dest" ]]; then
    cp "$dest" "${dest}.bak.$(date +%Y%m%d_%H%M%S)"
  fi
  cp "$source" "$dest"
}

# Safe move with backup
safe_move() {
  local source="$1"
  local dest="$2"
  if [[ -e "$dest" ]]; then
    local backup="${dest}.bak.$(date +%Y%m%d_%H%M%S)"
    mv "$dest" "$backup"
    echo "Backed up existing file to: $backup" >&2
  fi
  mv "$source" "$dest"
}

# Find files by pattern
find_files() {
  local dir="${1:-.}"
  local pattern="$2"
  find "$dir" -type f -name "$pattern" 2>/dev/null
}

# Get file size in human readable format
file_size() {
  local file="$1"
  if [[ -f "$file" ]]; then
    if command -v gstat >/dev/null 2>&1; then
      gstat -c%s "$file" | numfmt --to=iec
    elif command -v stat >/dev/null 2>&1; then
      stat -f%z "$file" 2>/dev/null || stat -c%s "$file" 2>/dev/null | numfmt --to=iec
    else
      ls -lh "$file" | awk '{print $5}'
    fi
  fi
}

# Array utilities
# ===============

# Check if array contains element
array_contains() {
  local needle="$1"
  shift
  local item
  for item in "$@"; do
    [[ "$item" == "$needle" ]] && return 0
  done
  return 1
}

# Get array length
array_length() {
  echo $#
}

# Remove duplicates from array
array_unique() {
  local -A seen
  local -a result
  local item
  for item in "$@"; do
    if [[ -z "${seen[$item]}" ]]; then
      seen[$item]=1
      result+=("$item")
    fi
  done
  echo "${result[@]}"
}

# Reverse array
array_reverse() {
  local -a result
  local i
  for ((i=$#; i>0; i--)); do
    result+=("${!i}")
  done
  echo "${result[@]}"
}

# System utilities
# ================

# Check if command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Check if running as root
is_root() {
  [[ $EUID -eq 0 ]]
}

# Check if running in CI environment
is_ci() {
  [[ -n "${CI:-}" ]] || [[ -n "${CONTINUOUS_INTEGRATION:-}" ]] || [[ -n "${GITHUB_ACTIONS:-}" ]]
}

# Check if running in Docker container
is_docker() {
  [[ -f /.dockerenv ]] || grep -q docker /proc/1/cgroup 2>/dev/null
}

# Get current OS
get_os() {
  case "$(uname -s)" in
    Darwin) echo "macos" ;;
    Linux) echo "linux" ;;
    MINGW*|MSYS*|CYGWIN*) echo "windows" ;;
    *) echo "unknown" ;;
  esac
}

# Get OS architecture
get_arch() {
  case "$(uname -m)" in
    x86_64) echo "amd64" ;;
    aarch64|arm64) echo "arm64" ;;
    armv7l) echo "arm" ;;
    i386|i686) echo "386" ;;
    *) echo "unknown" ;;
  esac
}

# Check if running on macOS
is_macos() {
  [[ "$(get_os)" == "macos" ]]
}

# Check if running on Linux
is_linux() {
  [[ "$(get_os)" == "linux" ]]
}

# Get number of CPU cores
cpu_cores() {
  if is_macos; then
    sysctl -n hw.ncpu
  elif is_linux; then
    nproc
  else
    echo 1
  fi
}

# Get memory in MB
memory_mb() {
  if is_macos; then
    echo $(( $(sysctl -n hw.memsize) / 1024 / 1024 ))
  elif is_linux; then
    echo $(( $(grep MemTotal /proc/meminfo | awk '{print $2}') / 1024 ))
  else
    echo 0
  fi
}

# Validation utilities
# ====================

# Check if string is empty
is_empty() {
  [[ -z "$1" ]]
}

# Check if string is not empty
is_not_empty() {
  [[ -n "$1" ]]
}

# Check if variable is set
is_set() {
  [[ -n "${!1+x}" ]]
}

# Check if string is numeric
is_numeric() {
  [[ "$1" =~ ^[0-9]+$ ]]
}

# Check if string is decimal
is_decimal() {
  [[ "$1" =~ ^[0-9]+\.[0-9]+$ ]]
}

# Check if string is boolean
is_boolean() {
  [[ "$1" =~ ^(true|false|yes|no|1|0)$ ]]
}

# Convert to boolean
to_boolean() {
  case "${1:l}" in
    true|yes|1) echo "true" ;;
    false|no|0|"") echo "false" ;;
    *) echo "false" ;;
  esac
}

# URL/Path utilities
# ==================

# URL encode string
url_encode() {
  local string="$1"
  local encoded=""
  local length="${#string}"
  local c
  for (( i = 0; i < length; i++ )); do
    c="${string:$i:1}"
    case "$c" in
      [a-zA-Z0-9.~_-]) encoded+="$c" ;;
      *) printf -v hex '%%%02X' "'$c"; encoded+="$hex" ;;
    esac
  done
  echo "$encoded"
}

# URL decode string
url_decode() {
  local url="$1"
  printf '%b' "${url//%/\\x}"
}

# Extract domain from URL
extract_domain() {
  local url="$1"
  echo "$url" | sed -E 's|^[^/]*//||' | sed -E 's|/.*$||'
}

# Temporary file utilities
# ========================

# Create temporary file
temp_file() {
  local prefix="${1:-tmp}"
  local suffix="${2:-.tmp}"
  mktemp "${TMPDIR:-/tmp}/${prefix}.XXXXXX${suffix}"
}

# Create temporary directory
temp_dir() {
  local prefix="${1:-tmpdir}"
  mktemp -d "${TMPDIR:-/tmp}/${prefix}.XXXXXX"
}

# Cleanup temporary files on exit
cleanup_on_exit() {
  local temp_files=("$@")
  trap "rm -rf ${temp_files[*]}" EXIT INT TERM
}

# Miscellaneous utilities
# =======================

# Generate UUID
generate_uuid() {
  if command_exists uuidgen; then
    uuidgen | to_lower
  else
    # Fallback to random generation
    printf '%04x%04x-%04x-%04x-%04x-%04x%04x%04x\n' \
      $RANDOM $RANDOM $RANDOM \
      $((RANDOM & 0x0fff | 0x4000)) \
      $((RANDOM & 0x3fff | 0x8000)) \
      $RANDOM $RANDOM $RANDOM
  fi
}

# Get current timestamp
timestamp() {
  date +%s
}

# Get formatted date
date_format() {
  local format="${1:-%Y-%m-%d %H:%M:%S}"
  date +"$format"
}

# Sleep with message
sleep_with_message() {
  local seconds="$1"
  local message="${2:-Sleeping for $seconds seconds...}"
  echo "$message" >&2
  sleep "$seconds"
}

# Retry command with delay
retry() {
  local max_attempts="${1:-3}"
  local delay="${2:-1}"
  local command="${@:3}"
  local attempt=1

  until eval "$command"; do
    if [[ $attempt -ge $max_attempts ]]; then
      echo "Command failed after $max_attempts attempts" >&2
      return 1
    fi
    echo "Attempt $attempt failed, retrying in ${delay}s..." >&2
    sleep "$delay"
    ((attempt++))
  done
}

# Run command with timeout
with_timeout() {
  local timeout="$1"
  shift
  if command_exists timeout; then
    timeout "$timeout" "$@"
  elif command_exists gtimeout; then
    gtimeout "$timeout" "$@"
  else
    "$@"
  fi
}
