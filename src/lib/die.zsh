#!/usr/bin/env zsh

# die.zsh - Error handling and graceful exit library
# Provides clean error reporting and exit mechanisms

# Source dependencies if available
[[ -f "${0:A:h}/colors.zsh" ]] && source "${0:A:h}/colors.zsh"
[[ -f "${0:A:h}/logging.zsh" ]] && source "${0:A:h}/logging.zsh"

# Exit codes
readonly -A EXIT_CODES=(
    [SUCCESS]=0
    [GENERAL_ERROR]=1
    [MISUSE]=2
    [CANNOT_EXECUTE]=126
    [NOT_FOUND]=127
    [INVALID_ARGUMENT]=128
    [SIGINT]=130
    [SIGTERM]=143

    # Custom exit codes (64-113 are available for user-defined codes)
    [CONFIG_ERROR]=64
    [NETWORK_ERROR]=65
    [PERMISSION_ERROR]=66
    [DEPENDENCY_ERROR]=67
    [VALIDATION_ERROR]=68
    [TIMEOUT_ERROR]=69
    [RESOURCE_ERROR]=70
    [STATE_ERROR]=71
    [IO_ERROR]=72
    [FORMAT_ERROR]=73
)

# Global error handler state
typeset -g DIE_CLEANUP_FUNCTIONS=()
typeset -g DIE_TEMP_FILES=()
typeset -g DIE_STACK_TRACE=${DIE_STACK_TRACE:-1}
typeset -g DIE_COLOR=${DIE_COLOR:-1}

# Main die function - exit with error message
die() {
    local exit_code="${1:-1}"
    shift
    local message="$*"

    # If exit_code is a name, look it up
    if [[ -n "${EXIT_CODES[$exit_code]}" ]]; then
        exit_code="${EXIT_CODES[$exit_code]}"
    fi

    # Ensure exit_code is numeric
    if ! [[ "$exit_code" =~ ^[0-9]+$ ]]; then
        message="$exit_code $message"
        exit_code=1
    fi

    # Print error message
    if [[ -n "$message" ]]; then
        error_message "$message"
    fi

    # Print stack trace if enabled
    if [[ "$DIE_STACK_TRACE" -eq 1 ]]; then
        print_stack_trace >&2
    fi

    # Run cleanup functions
    run_cleanup

    # Exit with code
    exit "$exit_code"
}

# Print formatted error message
error_message() {
    local message="$1"
    local prefix="ERROR"

    if [[ "$DIE_COLOR" -eq 1 ]] && [[ -t 2 ]]; then
        # Use colors if available
        if declare -f LOG >/dev/null 2>&1; then
            LOG ERROR "$message"
        elif [[ -n "${COLORS[RED]}" ]]; then
            echo -e "${COLORS[RED]}${STYLES[BOLD]}[$prefix]${STYLES[RESET]} $message" >&2
        else
            echo -e "\033[31m\033[1m[$prefix]\033[0m $message" >&2
        fi
    else
        echo "[$prefix] $message" >&2
    fi
}

# Warn without exiting
warn() {
    local message="$1"
    local prefix="WARNING"

    if [[ "$DIE_COLOR" -eq 1 ]] && [[ -t 2 ]]; then
        if declare -f LOG >/dev/null 2>&1; then
            LOG WARN "$message"
        elif [[ -n "${COLORS[YELLOW]}" ]]; then
            echo -e "${COLORS[YELLOW]}${STYLES[BOLD]}[$prefix]${STYLES[RESET]} $message" >&2
        else
            echo -e "\033[33m\033[1m[$prefix]\033[0m $message" >&2
        fi
    else
        echo "[$prefix] $message" >&2
    fi
}

# Assert condition or die
assert() {
    local condition="$1"
    local message="${2:-Assertion failed: $condition}"

    if ! eval "$condition"; then
        die VALIDATION_ERROR "$message"
    fi
}

# Assert command exists or die
require_command() {
    local cmd="$1"
    local message="${2:-Required command not found: $cmd}"

    if ! command -v "$cmd" >/dev/null 2>&1; then
        die DEPENDENCY_ERROR "$message"
    fi
}

# Assert file exists or die
require_file() {
    local file="$1"
    local message="${2:-Required file not found: $file}"

    if [[ ! -f "$file" ]]; then
        die NOT_FOUND "$message"
    fi
}

# Assert directory exists or die
require_dir() {
    local dir="$1"
    local message="${2:-Required directory not found: $dir}"

    if [[ ! -d "$dir" ]]; then
        die NOT_FOUND "$message"
    fi
}

# Assert variable is set or die
require_var() {
    local var_name="$1"
    local message="${2:-Required variable not set: $var_name}"

    if [[ -z "${!var_name+x}" ]]; then
        die CONFIG_ERROR "$message"
    fi
}

# Assert user is root or die
require_root() {
    local message="${1:-This script must be run as root}"

    if [[ $EUID -ne 0 ]]; then
        die PERMISSION_ERROR "$message"
    fi
}

# Assert user is NOT root or die
require_not_root() {
    local message="${1:-This script must not be run as root}"

    if [[ $EUID -eq 0 ]]; then
        die PERMISSION_ERROR "$message"
    fi
}

# Register cleanup function to run on exit
register_cleanup() {
    local func="$1"
    DIE_CLEANUP_FUNCTIONS+=("$func")
}

# Register temporary file for cleanup
register_temp_file() {
    local file="$1"
    DIE_TEMP_FILES+=("$file")
}

# Run all registered cleanup functions
run_cleanup() {
    # Clean up temporary files
    for file in "${DIE_TEMP_FILES[@]}"; do
        if [[ -e "$file" ]]; then
            rm -rf "$file" 2>/dev/null || true
        fi
    done

    # Run cleanup functions
    for func in "${DIE_CLEANUP_FUNCTIONS[@]}"; do
        if declare -f "$func" >/dev/null 2>&1; then
            "$func" 2>/dev/null || true
        fi
    done
}

# Setup automatic cleanup on exit
setup_cleanup() {
    trap run_cleanup EXIT INT TERM
}

# Print stack trace
print_stack_trace() {
    echo "Stack trace:" >&2
    local frame=0
    while true; do
        if ! caller $frame >/dev/null 2>&1; then
            break
        fi
        local line_info=$(caller $frame)
        echo "  $line_info" >&2
        ((frame++))
    done
}

# Try to execute command, die on failure
try() {
    local message="${1:-Command failed}"
    shift

    if ! "$@"; then
        local exit_code=$?
        die "$exit_code" "$message: $*"
    fi
}

# Try to execute command, warn on failure but continue
try_warn() {
    local message="${1:-Command failed}"
    shift

    if ! "$@"; then
        warn "$message: $*"
        return 1
    fi
}

# Execute command or die with custom error
execute_or_die() {
    local cmd="$1"
    local error_msg="${2:-Failed to execute: $cmd}"

    if ! eval "$cmd"; then
        die CANNOT_EXECUTE "$error_msg"
    fi
}

# Timeout wrapper with die on timeout
timeout_or_die() {
    local timeout="$1"
    local message="${2:-Command timed out after ${timeout}s}"
    shift 2

    if command -v timeout >/dev/null 2>&1; then
        if ! timeout "$timeout" "$@"; then
            if [[ $? -eq 124 ]]; then
                die TIMEOUT_ERROR "$message"
            else
                die GENERAL_ERROR "Command failed: $*"
            fi
        fi
    else
        # Fallback without timeout command
        "$@" || die GENERAL_ERROR "Command failed: $*"
    fi
}

# Check condition periodically or die
wait_for_or_die() {
    local condition="$1"
    local timeout="${2:-30}"
    local message="${3:-Condition not met within ${timeout}s: $condition}"
    local interval="${4:-1}"

    local elapsed=0
    while [[ $elapsed -lt $timeout ]]; do
        if eval "$condition"; then
            return 0
        fi
        sleep "$interval"
        ((elapsed += interval))
    done

    die TIMEOUT_ERROR "$message"
}

# Validate input or die
validate_or_die() {
    local value="$1"
    local pattern="$2"
    local message="${3:-Invalid input: $value}"

    if ! [[ "$value" =~ $pattern ]]; then
        die VALIDATION_ERROR "$message"
    fi
}

# Check minimum version or die
require_version() {
    local current="$1"
    local required="$2"
    local name="${3:-version}"

    if ! version_compare "$current" ">=" "$required"; then
        die DEPENDENCY_ERROR "$name $current is below minimum required version $required"
    fi
}

# Compare versions (basic implementation)
version_compare() {
    local v1="$1"
    local op="$2"
    local v2="$3"

    # Convert versions to comparable format
    local v1_parts=(${(s:.:)v1})
    local v2_parts=(${(s:.:)v2})

    # Pad with zeros
    while [[ ${#v1_parts[@]} -lt ${#v2_parts[@]} ]]; do
        v1_parts+=(0)
    done
    while [[ ${#v2_parts[@]} -lt ${#v1_parts[@]} ]]; do
        v2_parts+=(0)
    done

    # Compare each part
    for i in {1..${#v1_parts[@]}}; do
        local p1=${v1_parts[$i]:-0}
        local p2=${v2_parts[$i]:-0}

        if [[ $p1 -lt $p2 ]]; then
            [[ "$op" == "<" || "$op" == "<=" || "$op" == "!=" ]] && return 0
            return 1
        elif [[ $p1 -gt $p2 ]]; then
            [[ "$op" == ">" || "$op" == ">=" || "$op" == "!=" ]] && return 0
            return 1
        fi
    done

    # Versions are equal
    [[ "$op" == "=" || "$op" == "<=" || "$op" == ">=" ]] && return 0
    return 1
}

# Panic - immediate abort with core dump
panic() {
    local message="${1:-PANIC: Fatal error}"

    echo "================== PANIC ==================" >&2
    echo "$message" >&2
    echo "==========================================" >&2

    if [[ "$DIE_STACK_TRACE" -eq 1 ]]; then
        print_stack_trace >&2
    fi

    # Trigger core dump
    kill -ABRT $$
}

# Interactive confirmation or die
confirm_or_die() {
    local message="${1:-Are you sure you want to continue?}"
    local default="${2:-n}"

    local prompt="$message"
    if [[ "${default:l}" == "y" ]]; then
        prompt="$prompt [Y/n]: "
    else
        prompt="$prompt [y/N]: "
    fi

    echo -n "$prompt" >&2
    read -r response

    response="${response:l}"
    [[ -z "$response" ]] && response="$default"

    if [[ "$response" != "y" ]]; then
        die SUCCESS "Operation cancelled by user"
    fi
}

# Export main functions
typeset -gx die warn assert require_command require_file require_dir
typeset -gx require_var require_root require_not_root try execute_or_die
typeset -gx panic confirm_or_die
