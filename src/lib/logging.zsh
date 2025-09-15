#!/usr/bin/env zsh

# log.zsh - Clean, simple logging library for ZSH scripts
# Usage: LOG <LEVEL> <MESSAGE>
# Example: LOG INFO "Starting application"
#          LOG ERROR "Failed to connect"

# Default log level if not set
: ${LOG_LEVEL:=INFO}

# Color codes
readonly LOG_COLOR_RESET="\033[0m"
readonly LOG_COLOR_BOLD="\033[1m"
readonly LOG_COLOR_RED="\033[31m"
readonly LOG_COLOR_GREEN="\033[32m"
readonly LOG_COLOR_YELLOW="\033[33m"
readonly LOG_COLOR_BLUE="\033[34m"
readonly LOG_COLOR_MAGENTA="\033[35m"
readonly LOG_COLOR_CYAN="\033[36m"
readonly LOG_COLOR_GRAY="\033[90m"

# Log level hierarchy
readonly -A LOG_LEVELS=(
    [TRACE]=0
    [DEBUG]=1
    [INFO]=2
    [WARN]=3
    [ERROR]=4
    [FATAL]=5
)

# Log level colors
readonly -A LOG_COLORS=(
    [TRACE]="${LOG_COLOR_GRAY}"
    [DEBUG]="${LOG_COLOR_GRAY}"
    [INFO]="${LOG_COLOR_CYAN}"
    [WARN]="${LOG_COLOR_YELLOW}"
    [ERROR]="${LOG_COLOR_RED}"
    [FATAL]="${LOG_COLOR_BOLD}${LOG_COLOR_RED}"
)

# Get numeric value for log level
_get_log_level_value() {
    local level="${1:u}"  # Convert to uppercase
    echo "${LOG_LEVELS[$level]:-2}"  # Default to INFO level
}

# Main logging function
LOG() {
    local level="${1:u}"  # Convert to uppercase
    shift
    local message="$*"

    # Get current and message log level values
    local current_level_value=$(_get_log_level_value "$LOG_LEVEL")
    local message_level_value=$(_get_log_level_value "$level")

    # Only log if message level >= current log level
    if [[ $message_level_value -ge $current_level_value ]]; then
        local color="${LOG_COLORS[$level]:-${LOG_COLOR_RESET}}"
        local timestamp=""

        # Add timestamp if LOG_TIMESTAMP is set
        if [[ -n "${LOG_TIMESTAMP:-}" ]]; then
            timestamp="[$(date '+%Y-%m-%d %H:%M:%S')] "
        fi

        # Output format: [LEVEL] message
        echo -e "${color}${timestamp}[${level}]${LOG_COLOR_RESET} ${message}" >&2
    fi
}

# Convenience functions for common log levels
TRACE() { LOG TRACE "$@"; }
DEBUG() { LOG DEBUG "$@"; }
INFO()  { LOG INFO "$@"; }
WARN()  { LOG WARN "$@"; }
ERROR() { LOG ERROR "$@"; }
FATAL() { LOG FATAL "$@"; }

# Set log level function
SET_LOG_LEVEL() {
    local level="${1:u}"
    if [[ -n "${LOG_LEVELS[$level]}" ]]; then
        export LOG_LEVEL="$level"
        LOG DEBUG "Log level set to $level"
    else
        LOG ERROR "Invalid log level: $1"
        LOG INFO "Valid levels: ${(k)LOG_LEVELS}"
        return 1
    fi
}

# Check if we should log at a given level
SHOULD_LOG() {
    local level="${1:u}"
    local current_level_value=$(_get_log_level_value "$LOG_LEVEL")
    local check_level_value=$(_get_log_level_value "$level")
    [[ $check_level_value -ge $current_level_value ]]
}

# Pretty print with indentation
LOG_INDENT() {
    local level="$1"
    local indent="$2"
    shift 2
    local message="$*"
    local spaces=""
    for ((i=0; i<indent; i++)); do
        spaces="  $spaces"
    done
    LOG "$level" "${spaces}${message}"
}

# Log a separator line
LOG_SEPARATOR() {
    local level="${1:-INFO}"
    local char="${2:--}"
    local width="${3:-50}"
    local line=""
    for ((i=0; i<width; i++)); do
        line="${line}${char}"
    done
    LOG "$level" "$line"
}

# Log with a header
LOG_HEADER() {
    local level="$1"
    local title="$2"
    LOG_SEPARATOR "$level" "━" 50
    LOG "$level" "$title"
    LOG_SEPARATOR "$level" "━" 50
}

# Log success/failure with icons
LOG_SUCCESS() {
    LOG INFO "✓ $*"
}

LOG_FAILURE() {
    LOG ERROR "✗ $*"
}

LOG_WARNING() {
    LOG WARN "⚠ $*"
}

LOG_INFO() {
    LOG INFO "ℹ $*"
}

# Progress indicators
LOG_PROGRESS() {
    local level="${1:-INFO}"
    shift
    LOG "$level" "▶ $*"
}

LOG_DONE() {
    local level="${1:-INFO}"
    shift
    LOG "$level" "✓ $*"
}

# Functions are automatically available when sourced in ZSH
# No need to export them