#!/usr/bin/env zsh

# callstack.zsh - Stack trace and debugging utilities
# Provides call stack inspection, tracing, and debugging tools

# Configuration
typeset -g CALLSTACK_MAX_DEPTH=${CALLSTACK_MAX_DEPTH:-50}
typeset -g CALLSTACK_SHOW_ARGS=${CALLSTACK_SHOW_ARGS:-1}
typeset -g CALLSTACK_SHOW_SOURCE=${CALLSTACK_SHOW_SOURCE:-1}
typeset -g CALLSTACK_COLOR=${CALLSTACK_COLOR:-1}

# Source dependencies if available
[[ -f "${0:A:h}/colors.zsh" ]] && source "${0:A:h}/colors.zsh"

# Get current call stack
callstack() {
  local skip="${1:-1}"  # Number of frames to skip
  local max_depth="${2:-$CALLSTACK_MAX_DEPTH}"

  local frame=0
  local stack_output=""

  # Use ZSH's funcstack and funcsourcetrace
  for ((i=skip+1; i<=max_depth && i<=${#funcstack[@]}; i++)); do
    local func="${funcstack[$i]}"
    local source_info="${funcsourcetrace[$i]}"

    # Parse source info (file:line)
    local file="${source_info%:*}"
    local line="${source_info##*:}"

    # Format frame
    if [[ $CALLSTACK_COLOR -eq 1 ]] && [[ -n "${COLORS[CYAN]}" ]]; then
      stack_output+="${COLORS[CYAN]}#$frame${COLORS[RESET]} "
      stack_output+="${COLORS[YELLOW]}$func${COLORS[RESET]} "
      stack_output+="${COLORS[GRAY]}at $file:$line${COLORS[RESET]}\n"
    else
      stack_output+="#$frame $func at $file:$line\n"
    fi

    ((frame++))
  done

  echo -e "$stack_output"
}

# Print stack trace to stderr
stack_trace() {
  local skip="${1:-1}"
  local header="${2:-Stack trace:}"

  if [[ $CALLSTACK_COLOR -eq 1 ]] && [[ -n "${COLORS[RED]}" ]]; then
    echo -e "${COLORS[RED]}${header}${COLORS[RESET]}" >&2
  else
    echo "$header" >&2
  fi

  callstack "$skip" >&2
}

# Get caller information
caller_info() {
  local level="${1:-1}"  # How many levels up

  if [[ $((level + 1)) -le ${#funcstack[@]} ]]; then
    local func="${funcstack[$((level + 1))]}"
    local source_info="${funcsourcetrace[$((level + 1))]}"
    local file="${source_info%:*}"
    local line="${source_info##*:}"

    echo "Function: $func"
    echo "File: $file"
    echo "Line: $line"
  else
    echo "No caller at level $level"
  fi
}

# Get just the caller function name
caller_name() {
  local level="${1:-1}"

  if [[ $((level + 1)) -le ${#funcstack[@]} ]]; then
    echo "${funcstack[$((level + 1))]}"
  fi
}

# Get just the caller file
caller_file() {
  local level="${1:-1}"

  if [[ $((level + 1)) -le ${#funcstack[@]} ]]; then
    local source_info="${funcsourcetrace[$((level + 1))]}"
    echo "${source_info%:*}"
  fi
}

# Get just the caller line number
caller_line() {
  local level="${1:-1}"

  if [[ $((level + 1)) -le ${#funcstack[@]} ]]; then
    local source_info="${funcsourcetrace[$((level + 1))]}"
    echo "${source_info##*:}"
  fi
}

# Check if we're in a specific function
in_function() {
  local func_name="$1"

  for func in "${funcstack[@]}"; do
    if [[ "$func" == "$func_name" ]]; then
      return 0
    fi
  done

  return 1
}

# Get call depth
call_depth() {
  echo "${#funcstack[@]}"
}

# Assert with stack trace
assert_with_trace() {
  local condition="$1"
  local message="${2:-Assertion failed: $condition}"

  if ! eval "$condition"; then
    if [[ $CALLSTACK_COLOR -eq 1 ]] && [[ -n "${COLORS[RED]}" ]]; then
      echo -e "${COLORS[RED]}ASSERTION FAILED: $message${COLORS[RESET]}" >&2
    else
      echo "ASSERTION FAILED: $message" >&2
    fi
    stack_trace 2
    return 1
  fi
}

# Debug print with location
debug_print() {
  local message="$1"
  local show_location="${2:-1}"

  if [[ $show_location -eq 1 ]]; then
    local func=$(caller_name 1)
    local file=$(caller_file 1)
    local line=$(caller_line 1)

    if [[ $CALLSTACK_COLOR -eq 1 ]] && [[ -n "${COLORS[BLUE]}" ]]; then
      echo -e "${COLORS[GRAY]}[$file:$line]${COLORS[RESET]} ${COLORS[BLUE]}$func()${COLORS[RESET]}: $message"
    else
      echo "[$file:$line] $func(): $message"
    fi
  else
    echo "$message"
  fi
}

# Trace function entry/exit
typeset -gA TRACE_INDENT_LEVELS=()
typeset -gi TRACE_CURRENT_INDENT=0

trace_enter() {
  local func_name="${1:-${funcstack[2]}}"
  shift
  local args="$*"

  local indent=$(repeat_string "  " $TRACE_CURRENT_INDENT)

  if [[ $CALLSTACK_COLOR -eq 1 ]] && [[ -n "${COLORS[GREEN]}" ]]; then
    echo -e "${indent}${COLORS[GREEN]}→ $func_name${COLORS[RESET]}${args:+ ($args)}"
  else
    echo "${indent}→ $func_name${args:+ ($args)}"
  fi

  TRACE_INDENT_LEVELS[$func_name]=$TRACE_CURRENT_INDENT
  ((TRACE_CURRENT_INDENT++))
}

trace_exit() {
  local func_name="${1:-${funcstack[2]}}"
  local return_value="${2:-}"

  ((TRACE_CURRENT_INDENT--))
  local indent=$(repeat_string "  " $TRACE_CURRENT_INDENT)

  if [[ $CALLSTACK_COLOR -eq 1 ]] && [[ -n "${COLORS[YELLOW]}" ]]; then
    echo -e "${indent}${COLORS[YELLOW]}← $func_name${COLORS[RESET]}${return_value:+ = $return_value}"
  else
    echo "${indent}← $func_name${return_value:+ = $return_value}"
  fi

  unset "TRACE_INDENT_LEVELS[$func_name]"
}

# Helper to repeat a string
repeat_string() {
  local str="$1"
  local count="$2"
  local result=""

  for ((i=0; i<count; i++)); do
    result+="$str"
  done

  echo "$result"
}

# Breakpoint simulation
breakpoint() {
  local message="${1:-Breakpoint reached}"

  if [[ $CALLSTACK_COLOR -eq 1 ]] && [[ -n "${COLORS[MAGENTA]}" ]]; then
    echo -e "${COLORS[MAGENTA]}⏸ BREAKPOINT: $message${COLORS[RESET]}" >&2
  else
    echo "⏸ BREAKPOINT: $message" >&2
  fi

  # Show context
  echo "Location: $(caller_info 1)" >&2
  echo "Call stack:" >&2
  callstack 2 5 >&2

  # Interactive prompt
  echo -n "Press Enter to continue, 's' for shell, 'q' to quit: " >&2
  read -r response

  case "$response" in
    s|shell)
      echo "Entering debug shell. Type 'exit' to continue." >&2
      $SHELL
      ;;
    q|quit)
      echo "Quitting..." >&2
      exit 1
      ;;
  esac
}

# Watch variable changes
typeset -gA WATCH_VARS=()
typeset -gA WATCH_OLD_VALUES=()

watch_var() {
  local var_name="$1"
  local callback="${2:-}"

  WATCH_VARS[$var_name]="$callback"
  WATCH_OLD_VALUES[$var_name]="${(P)var_name}"
}

unwatch_var() {
  local var_name="$1"
  unset "WATCH_VARS[$var_name]"
  unset "WATCH_OLD_VALUES[$var_name]"
}

check_watches() {
  for var_name in ${(k)WATCH_VARS}; do
    local current_value="${(P)var_name}"
    local old_value="${WATCH_OLD_VALUES[$var_name]}"

    if [[ "$current_value" != "$old_value" ]]; then
      local callback="${WATCH_VARS[$var_name]}"

      if [[ $CALLSTACK_COLOR -eq 1 ]] && [[ -n "${COLORS[CYAN]}" ]]; then
        echo -e "${COLORS[CYAN]}Watch: $var_name changed from '$old_value' to '$current_value'${COLORS[RESET]}" >&2
      else
        echo "Watch: $var_name changed from '$old_value' to '$current_value'" >&2
      fi

      WATCH_OLD_VALUES[$var_name]="$current_value"

      if [[ -n "$callback" ]]; then
        eval "$callback"
      fi
    fi
  done
}

# Performance profiling
typeset -gA PROFILE_TIMERS=()
typeset -gA PROFILE_COUNTS=()
typeset -gA PROFILE_TOTALS=()

profile_start() {
  local name="${1:-${funcstack[2]}}"
  PROFILE_TIMERS[$name]=$(date +%s%N)
  ((PROFILE_COUNTS[$name]++))
}

profile_end() {
  local name="${1:-${funcstack[2]}}"

  if [[ -n "${PROFILE_TIMERS[$name]}" ]]; then
    local start="${PROFILE_TIMERS[$name]}"
    local end=$(date +%s%N)
    local elapsed=$((end - start))

    PROFILE_TOTALS[$name]=$((${PROFILE_TOTALS[$name]:-0} + elapsed))
    unset "PROFILE_TIMERS[$name]"

    # Convert to milliseconds
    local ms=$((elapsed / 1000000))
    echo "Profile: $name took ${ms}ms" >&2
  fi
}

profile_report() {
  echo "Performance Profile Report:" >&2
  echo "===========================" >&2

  for name in ${(k)PROFILE_COUNTS}; do
    local count="${PROFILE_COUNTS[$name]}"
    local total="${PROFILE_TOTALS[$name]:-0}"
    local avg=$((total / count / 1000000))  # Convert to ms
    local total_ms=$((total / 1000000))

    printf "%-30s: %5d calls, %8dms total, %6dms avg\n" \
      "$name" "$count" "$total_ms" "$avg" >&2
  done
}

profile_reset() {
  PROFILE_TIMERS=()
  PROFILE_COUNTS=()
  PROFILE_TOTALS=()
}

# Memory debugging (basic)
check_memory() {
  local label="${1:-Memory check}"

  if command -v vm_stat >/dev/null 2>&1; then
    # macOS
    local mem_info=$(vm_stat | grep "Pages free" | awk '{print $3}' | sed 's/\.//')
    local free_pages=$mem_info
    local free_mb=$((free_pages * 4096 / 1024 / 1024))
    echo "$label: ${free_mb}MB free" >&2
  elif [[ -f /proc/meminfo ]]; then
    # Linux
    local free_kb=$(grep MemAvailable /proc/meminfo | awk '{print $2}')
    local free_mb=$((free_kb / 1024))
    echo "$label: ${free_mb}MB available" >&2
  fi
}

# Function to dump all variables
dump_vars() {
  local pattern="${1:-*}"

  echo "Variable dump (pattern: $pattern):" >&2
  echo "===================================" >&2

  for var in ${(k)parameters[(I)$pattern]}; do
    local type="${parameters[$var]}"
    local value="${(P)var}"

    case "$type" in
      *array*)
        echo "$var (array): (${(P)#var} elements)" >&2
        for elem in "${(@P)var}"; do
            echo "  - $elem" >&2
        done
        ;;
      *association*)
        echo "$var (hash):" >&2
        for key in ${(Pk)var}; do
            echo "  [$key] = ${${(P)var}[$key]}" >&2
        done
        ;;
      *)
        echo "$var = $value" >&2
        ;;
    esac
  done
}

# Error handler with stack trace
trap_error() {
  local exit_code=$?
  local line_no=$1

  if [[ $CALLSTACK_COLOR -eq 1 ]] && [[ -n "${COLORS[RED]}" ]]; then
    echo -e "${COLORS[RED]}ERROR: Command failed with exit code $exit_code at line $line_no${COLORS[RESET]}" >&2
  else
    echo "ERROR: Command failed with exit code $exit_code at line $line_no" >&2
  fi

  stack_trace 1 "Error stack trace:"

  return $exit_code
}

# Install error trap
install_error_trap() {
  trap 'trap_error $LINENO' ERR
}

# Uninstall error trap
uninstall_error_trap() {
  trap - ERR
}

# Debug mode toggle
typeset -gi DEBUG_MODE=0

debug_on() {
  DEBUG_MODE=1
  set -x  # Enable command tracing
  install_error_trap
  echo "Debug mode ON" >&2
}

debug_off() {
  DEBUG_MODE=0
  set +x  # Disable command tracing
  uninstall_error_trap
  echo "Debug mode OFF" >&2
}

is_debug() {
  [[ $DEBUG_MODE -eq 1 ]]
}

# Function timing wrapper
time_function() {
  local func="$1"
  shift

  local start=$(date +%s%N)
  "$func" "$@"
  local result=$?
  local end=$(date +%s%N)

  local elapsed=$((end - start))
  local ms=$((elapsed / 1000000))

  if [[ $CALLSTACK_COLOR -eq 1 ]] && [[ -n "${COLORS[BLUE]}" ]]; then
    echo -e "${COLORS[BLUE]}Timing: $func took ${ms}ms${COLORS[RESET]}" >&2
  else
    echo "Timing: $func took ${ms}ms" >&2
  fi

  return $result
}

# Inspect function
inspect_function() {
  local func_name="$1"

  if ! declare -f "$func_name" >/dev/null 2>&1; then
    echo "Function '$func_name' not found" >&2
    return 1
  fi

  echo "Function: $func_name" >&2
  echo "===================" >&2

  # Show function definition
  declare -f "$func_name" >&2

  # Show function file if available
  if [[ -n "${functions_source[$func_name]}" ]]; then
    echo "Source: ${functions_source[$func_name]}" >&2
  fi
}

# List all functions
list_functions() {
  local pattern="${1:-*}"

  echo "Functions matching '$pattern':" >&2
  echo "==============================" >&2

  for func in ${(ok)functions[(I)$pattern]}; do
    echo "  $func" >&2
  done
}

# Execution trace
typeset -ga EXECUTION_LOG=()

log_execution() {
  local command="$1"
  local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
  local caller=$(caller_name 1)

  EXECUTION_LOG+=("[$timestamp] $caller: $command")
}

show_execution_log() {
  echo "Execution Log:" >&2
  echo "==============" >&2

  for entry in "${EXECUTION_LOG[@]}"; do
    echo "$entry" >&2
  done
}

clear_execution_log() {
  EXECUTION_LOG=()
}

# Conditional breakpoint
conditional_breakpoint() {
  local condition="$1"
  local message="${2:-Conditional breakpoint}"

  if eval "$condition"; then
    breakpoint "$message (condition: $condition)"
  fi
}

# Function call counter
typeset -gA CALL_COUNTS=()

count_calls() {
  local func_name="${1:-${funcstack[2]}}"
  ((CALL_COUNTS[$func_name]++))
}

show_call_counts() {
  echo "Function Call Counts:" >&2
  echo "=====================" >&2

  for func in ${(k)CALL_COUNTS}; do
    printf "%-30s: %5d calls\n" "$func" "${CALL_COUNTS[$func]}" >&2
  done
}

reset_call_counts() {
  CALL_COUNTS=()
}
