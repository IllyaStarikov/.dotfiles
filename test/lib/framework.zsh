#!/usr/bin/env zsh
# Test Framework Core Library
# Comprehensive testing utilities with Google standards
# Version: 2.0.0

# Strict error handling
setopt NO_UNSET PIPE_FAIL ERR_RETURN
IFS=$'\n\t'

# Framework metadata
# Use different name to avoid conflicts when re-sourcing
[[ -z "${FRAMEWORK_VERSION:-}" ]] && readonly FRAMEWORK_VERSION="2.0.0"
[[ -z "${FRAMEWORK_NAME:-}" ]] && readonly FRAMEWORK_NAME="Dotfiles Test Framework"

# Test execution levels
[[ -z "${TEST_SIZE_SMALL:-}" ]] && readonly TEST_SIZE_SMALL="small"
[[ -z "${TEST_SIZE_MEDIUM:-}" ]] && readonly TEST_SIZE_MEDIUM="medium"
[[ -z "${TEST_SIZE_LARGE:-}" ]] && readonly TEST_SIZE_LARGE="large"

# Test categories
readonly -a TEST_CATEGORIES=(
    unit integration system acceptance smoke sanity regression e2e
    performance load stress volume scalability usability security
    compatibility reliability recovery api database configuration
    installation boot accessibility localization penetration chaos
    mutation fuzz snapshot contract cross_browser ab
)

# ANSI color codes
readonly BOLD='\033[1m'
readonly DIM='\033[2m'
readonly ITALIC='\033[3m'
readonly UNDERLINE='\033[4m'
readonly BLINK='\033[5m'
readonly REVERSE='\033[7m'
readonly HIDDEN='\033[8m'
readonly STRIKETHROUGH='\033[9m'

readonly BLACK='\033[0;30m'
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[0;33m'
readonly BLUE='\033[0;34m'
readonly MAGENTA='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly WHITE='\033[0;37m'
readonly GRAY='\033[0;90m'

readonly BG_BLACK='\033[40m'
readonly BG_RED='\033[41m'
readonly BG_GREEN='\033[42m'
readonly BG_YELLOW='\033[43m'
readonly BG_BLUE='\033[44m'
readonly BG_MAGENTA='\033[45m'
readonly BG_CYAN='\033[46m'
readonly BG_WHITE='\033[47m'

readonly NC='\033[0m' # No Color

# Unicode symbols
readonly CHECK_MARK="✓"
readonly CROSS_MARK="✗"
readonly ARROW="→"
readonly BULLET="•"
readonly WARNING_SIGN="⚠"
readonly INFO_SIGN="ℹ"
readonly GEAR="⚙"
readonly ROCKET="🚀"
readonly SHIELD="🛡"
readonly CHART="📊"
readonly FOLDER="📁"
readonly DOCUMENT="📄"
readonly PACKAGE="📦"
readonly BUG="🐛"
readonly FIRE="🔥"
readonly HOURGLASS="⏳"
readonly CLOCK="⏰"
readonly MAGNIFIER="🔍"
readonly LOCK="🔒"
readonly KEY="🔑"
readonly TOOLBOX="🧰"
readonly WRENCH="🔧"
readonly HAMMER="🔨"
readonly MICROSCOPE="🔬"
readonly TELESCOPE="🔭"
readonly SATELLITE="🛰"
readonly ROBOT="🤖"
readonly SPARKLES="✨"
readonly LIGHTNING="⚡"
readonly EXPLOSION="💥"
readonly COLLISION="💥"
readonly DIZZY="💫"
readonly STAR="⭐"
readonly DIAMOND="💎"
readonly GEM="💎"

# Test state management
typeset -gA TEST_STATE
typeset -gA TEST_METRICS
typeset -gA TEST_TIMINGS
typeset -gA TEST_RESULTS

# Declare global arrays but don't make them readonly
# Initialize as empty arrays immediately
typeset -ga TEST_ERRORS=()
typeset -ga TEST_WARNINGS=()
typeset -ga TEST_LOGS=()

# Initialize test state
initialize_test_state() {
    TEST_STATE[total]=0
    TEST_STATE[passed]=0
    TEST_STATE[failed]=0
    TEST_STATE[skipped]=0
    TEST_STATE[errors]=0
    TEST_STATE[warnings]=0
    TEST_STATE[current_suite]=""
    TEST_STATE[current_test]=""
    TEST_STATE[start_time]=$(date +%s)
    TEST_STATE[verbose]=${VERBOSE:-0}
    TEST_STATE[debug]=${DEBUG:-0}
    TEST_STATE[dry_run]=${DRY_RUN:-0}
    TEST_STATE[parallel]=${PARALLEL:-0}
    TEST_STATE[timeout]=${TIMEOUT:-300}
    TEST_STATE[log_level]=${LOG_LEVEL:-INFO}

    # Clear arrays by resetting them
    TEST_ERRORS=()
    TEST_WARNINGS=()
    TEST_LOGS=()
}

# Enhanced logging system with multiple levels and outputs
log() {
    local level="${1:-INFO}"
    shift
    local message="$*"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S.%3N')
    local caller_info="${funcfiletrace[1]:-unknown}:${funcstack[2]:-unknown}"

    # Sanitize sensitive information
    message=$(echo "$message" | sed -E \
        -e 's/(password|token|secret|key|api_key|credential|auth)=[^ ]*/\1=REDACTED/gi' \
        -e 's/[a-fA-F0-9]{40,}/REDACTED_HASH/g' \
        -e 's/[A-Za-z0-9+\/]{20,}={0,2}/REDACTED_TOKEN/g')

    # Format log entry
    local log_entry="[${timestamp}] [${level}] [${caller_info}] ${message}"
    # Only add to TEST_LOGS if it exists (might be called before initialization)
    # Add to log array if it exists
    [[ ${#TEST_LOGS[@]} -ge 0 ]] 2>/dev/null && TEST_LOGS+=("$log_entry")

    # Level-based filtering
    local show_output=0
    case "$level" in
        ERROR|FATAL)
            [[ ${#TEST_ERRORS[@]} -ge 0 ]] 2>/dev/null && TEST_ERRORS+=("$message")
            show_output=1
            ;;
        WARNING|WARN)
            [[ ${#TEST_WARNINGS[@]} -ge 0 ]] 2>/dev/null && TEST_WARNINGS+=("$message")
            [[ ${#TEST_STATE[@]} -ge 0 ]] 2>/dev/null && [[ ${TEST_STATE[log_level]:-INFO} != "ERROR" ]] && show_output=1
            ;;
        INFO|SUCCESS)
            [[ ${#TEST_STATE[@]} -ge 0 ]] 2>/dev/null && [[ ${TEST_STATE[log_level]:-INFO} =~ ^(DEBUG|INFO)$ ]] && show_output=1
            ;;
        DEBUG|TRACE)
            [[ ${#TEST_STATE[@]} -ge 0 ]] 2>/dev/null && [[ ${TEST_STATE[log_level]:-INFO} =~ ^(DEBUG|TRACE)$ ]] && show_output=1
            ;;
        *)
            show_output=1
            ;;
    esac

    # Output formatting based on level
    if [[ $show_output -eq 1 ]] || ([[ ${#TEST_STATE[@]} -ge 0 ]] 2>/dev/null && [[ ${TEST_STATE[verbose]:-0} -ge 1 ]]); then
        case "$level" in
            ERROR|FATAL)
                echo -e "${BOLD}${RED}${CROSS_MARK} ${level}${NC} ${message}" >&2
                ;;
            WARNING|WARN)
                echo -e "${BOLD}${YELLOW}${WARNING_SIGN} ${level}${NC} ${message}" >&2
                ;;
            SUCCESS|PASS)
                echo -e "${BOLD}${GREEN}${CHECK_MARK} ${level}${NC} ${message}"
                ;;
            INFO)
                echo -e "${BOLD}${BLUE}${INFO_SIGN} ${level}${NC} ${message}"
                ;;
            DEBUG)
                ([[ ${#TEST_STATE[@]} -ge 0 ]] 2>/dev/null && [[ ${TEST_STATE[debug]:-0} -eq 1 ]]) && \
                    echo -e "${DIM}${GRAY}${GEAR} ${level}${NC} ${message}"
                ;;
            TRACE)
                ([[ ${#TEST_STATE[@]} -ge 0 ]] 2>/dev/null && [[ ${TEST_STATE[debug]:-0} -eq 1 ]]) && \
                    echo -e "${DIM}${GRAY}• ${level}${NC} ${DIM}${message}${NC}"
                ;;
            HEADER)
                echo -e "\n${BOLD}${UNDERLINE}${WHITE}${message}${NC}\n"
                ;;
            SECTION)
                echo -e "\n${BOLD}${CYAN}━━━ ${message} ━━━${NC}"
                ;;
            SUBSECTION)
                echo -e "${BOLD}${BLUE}▶ ${message}${NC}"
                ;;
            *)
                echo -e "${message}"
                ;;
        esac
    fi

    # Write to log file if specified
    if [[ -n "${TEST_LOG_FILE:-}" ]]; then
        echo "$log_entry" >> "${TEST_LOG_FILE}"
    fi
}

# Progress indicator with ETA
show_progress() {
    local current=$1
    local total=$2
    local message="${3:-Processing}"
    local width=${4:-50}

    local percentage=$((current * 100 / total))
    local filled=$((current * width / total))
    local elapsed=$(($(date +%s) - ${TEST_STATE[start_time]:-$(date +%s)}))
    local rate=$((current > 0 ? elapsed / current : 0))
    local eta=$((rate * (total - current)))

    # Format time
    local eta_str=""
    if [[ $eta -gt 0 ]]; then
        local eta_min=$((eta / 60))
        local eta_sec=$((eta % 60))
        eta_str=" ETA: ${eta_min}m${eta_sec}s"
    fi

    printf "\r${CYAN}${message}: [${NC}"
    printf "%${filled}s" | tr ' ' '█'
    printf "%$((width - filled))s" | tr ' ' '░'
    printf "${CYAN}] ${percentage}%% (${current}/${total})${eta_str}${NC}"

    if [[ $current -eq $total ]]; then
        echo
    fi
}

# Advanced spinner with custom messages
spinner() {
    local pid=$1
    local message="${2:-Working}"
    local delay=${3:-0.1}
    local spinstr='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'

    while kill -0 "$pid" 2>/dev/null; do
        local temp=${spinstr#?}
        printf "\r${CYAN}${message} [%c]${NC} " "$spinstr"
        spinstr=$temp${spinstr%"$temp"}
        sleep "$delay"
    done
    printf "\r%*s\r" $((${#message} + 5)) ""
}

# Benchmark function execution
benchmark() {
    local name="$1"
    shift
    local start_time=$(date +%s%N)
    local start_memory=$(vm_stat | grep "Pages free" | awk '{print $3}' | sed 's/\.//')

    log "TRACE" "Starting benchmark: $name"

    # Execute command
    "$@"
    local exit_code=$?

    local end_time=$(date +%s%N)
    local end_memory=$(vm_stat | grep "Pages free" | awk '{print $3}' | sed 's/\.//')

    local duration=$(( (end_time - start_time) / 1000000 ))
    local memory_delta=$(( start_memory - end_memory ))

    TEST_METRICS["${name}_duration"]=$duration
    TEST_METRICS["${name}_memory"]=$memory_delta
    TEST_METRICS["${name}_exit_code"]=$exit_code

    log "DEBUG" "Benchmark $name: ${duration}ms, Memory: ${memory_delta} pages, Exit: $exit_code"

    return "$exit_code"
}

# Assert functions with detailed error reporting
assert() {
    local condition="$1"
    local message="${2:-Assertion failed}"
    local caller="${funcstack[2]:-unknown}"

    if ! eval "$condition"; then
        log "ERROR" "Assertion failed in $caller: $message (condition: $condition)"
        TEST_STATE[failed]=$((${TEST_STATE[failed]} + 1))
        return 1
    fi
    return 0
}

assert_equals() {
    local expected="$1"
    local actual="$2"
    local message="${3:-Values not equal}"

    if [[ "$expected" != "$actual" ]]; then
        log "ERROR" "$message
    Expected: '$expected'
    Actual:   '$actual'
    Diff:     $(diff -u <(echo "$expected") <(echo "$actual") 2>&1 || true)"
        TEST_STATE[failed]=$((${TEST_STATE[failed]} + 1))
        return 1
    fi
    return 0
}

assert_contains() {
    local haystack="$1"
    local needle="$2"
    local message="${3:-String not found}"

    if [[ ! "$haystack" == *"$needle"* ]]; then
        log "ERROR" "$message
    Looking for: '$needle'
    In: '$haystack'"
        TEST_STATE[failed]=$((${TEST_STATE[failed]} + 1))
        return 1
    fi
    return 0
}

assert_file_exists() {
    local file="$1"
    local message="${2:-File does not exist}"

    if [[ ! -f "$file" ]]; then
        log "ERROR" "$message: $file"
        TEST_STATE[failed]=$((${TEST_STATE[failed]} + 1))
        return 1
    fi
    return 0
}

assert_command_succeeds() {
    local command="$1"
    local message="${2:-Command failed}"

    if ! eval "$command" > /dev/null 2>&1; then
        log "ERROR" "$message: $command"
        TEST_STATE[failed]=$((${TEST_STATE[failed]} + 1))
        return 1
    fi
    return 0
}

# Test execution wrapper with timing and error handling
run_test() {
    local test_name="$1"
    local test_function="$2"
    local category="${3:-unit}"
    local size="${4:-small}"
    local timeout="${5:-${TEST_STATE[timeout]}}"

    TEST_STATE[current_test]="$test_name"
    TEST_STATE[total]=$((${TEST_STATE[total]} + 1))

    local start_time=$(date +%s%N)
    local test_output=""
    local test_status="UNKNOWN"
    local exit_code=0

    log "TRACE" "Starting test: $test_name (category: $category, size: $size)"

    # Create test sandbox
    local test_dir=$(mktemp -d -t "test_${test_name}_XXXXXX")
    local original_pwd=$(pwd)

    # Execute test with timeout and capture output
    # Note: Functions are already in scope from sourcing the test file
    (
        cd "$test_dir"
        export TEST_NAME="$test_name"
        export TEST_CATEGORY="$category"
        export TEST_SIZE="$size"
        export TEST_SANDBOX="$test_dir"

        # Simply call the function - it's already defined
        $test_function 2>&1
    ) | tee -a "${TEST_LOG_FILE:-/dev/null}" | while IFS= read -r line; do
        [[ ${TEST_STATE[verbose]} -ge 2 ]] && echo "    $line"
        test_output+="$line\n"
    done

    exit_code=${pipestatus[1]:-$?}  # zsh uses lowercase pipestatus, 1-indexed

    # Cleanup
    cd "$original_pwd"
    [[ -d "$test_dir" ]] && rm -rf "$test_dir"

    local end_time=$(date +%s%N)
    local duration=$(( (end_time - start_time) / 1000000 ))

    # Determine test status
    if [[ $exit_code -eq 0 ]]; then
        test_status="PASS"
        TEST_STATE[passed]=$((${TEST_STATE[passed]} + 1))
        log "SUCCESS" "Test passed: $test_name (${duration}ms)"
    elif [[ $exit_code -eq 124 ]]; then
        test_status="TIMEOUT"
        TEST_STATE[failed]=$((${TEST_STATE[failed]} + 1))
        log "ERROR" "Test timeout: $test_name (exceeded ${timeout}s)"
    elif [[ $exit_code -eq 77 ]]; then
        test_status="SKIP"
        TEST_STATE[skipped]=$((${TEST_STATE[skipped]} + 1))
        log "WARNING" "Test skipped: $test_name"
    else
        test_status="FAIL"
        TEST_STATE[failed]=$((${TEST_STATE[failed]} + 1))
        log "ERROR" "Test failed: $test_name (exit code: $exit_code)"
    fi

    # Record results
    TEST_RESULTS["${test_name}_status"]="$test_status"
    TEST_RESULTS["${test_name}_duration"]="$duration"
    TEST_RESULTS["${test_name}_category"]="$category"
    TEST_RESULTS["${test_name}_size"]="$size"
    TEST_TIMINGS["$category"]=$((${TEST_TIMINGS[$category]:-0} + duration))

    return "$exit_code"
}

# Test suite runner
run_test_suite() {
    local suite_name="$1"
    local suite_dir="$2"
    local category="${3:-$suite_name}"
    local size_filter="${4:-}"

    TEST_STATE[current_suite]="$suite_name"

    log "SECTION" "Test Suite: $suite_name"

    local suite_start=$(date +%s)
    local tests_run=0
    local tests_passed=0
    local tests_failed=0
    local tests_skipped=0

    # Find and run all test files in suite
    for test_file in "$suite_dir"/*.zsh "$suite_dir"/*.sh; do
        [[ ! -f "$test_file" ]] && continue

        local test_basename=$(basename "$test_file")
        local test_size="small"  # Default size

        # Determine test size from filename or content
        if [[ "$test_basename" == *_large.* ]]; then
            test_size="large"
        elif [[ "$test_basename" == *_medium.* ]]; then
            test_size="medium"
        elif grep -q "# TEST_SIZE: large" "$test_file" 2>/dev/null; then
            test_size="large"
        elif grep -q "# TEST_SIZE: medium" "$test_file" 2>/dev/null; then
            test_size="medium"
        fi

        # Apply size filter
        if [[ -n "$size_filter" ]]; then
            case "$size_filter" in
                small)
                    [[ "$test_size" != "small" ]] && continue
                    ;;
                medium)
                    [[ "$test_size" == "large" ]] && continue
                    ;;
                large)
                    # Run all tests for large
                    ;;
            esac
        fi

        log "SUBSECTION" "Running: $test_basename (size: $test_size)"

        if source "$test_file"; then
            # Look for test functions in the file
            for func in $(declare -F | awk '{print $3}' | grep "^test_"); do
                run_test "$func" "$func" "$category" "$test_size"
                local result=$?
                ((tests_run++))

                case $result in
                    0) ((tests_passed++)) ;;
                    77) ((tests_skipped++)) ;;
                    *) ((tests_failed++)) ;;
                esac
            done
        else
            log "ERROR" "Failed to source test file: $test_file"
            ((tests_failed++))
        fi
    done

    local suite_end=$(date +%s)
    local suite_duration=$((suite_end - suite_start))

    log "INFO" "Suite $suite_name completed in ${suite_duration}s"
    log "INFO" "  Tests run: $tests_run"
    log "INFO" "  Passed: $tests_passed"
    log "INFO" "  Failed: $tests_failed"
    log "INFO" "  Skipped: $tests_skipped"

    return "$([[ $tests_failed -eq 0 ]] && echo 0 || echo 1)"
}

# Parallel test execution
run_tests_parallel() {
    local -a test_commands=("$@")
    local max_jobs=${MAX_PARALLEL_JOBS:-4}
    local job_count=0
    local -a pids=()

    log "INFO" "Running ${#test_commands[@]} tests in parallel (max $max_jobs jobs)"

    for cmd in "${test_commands[@]}"; do
        while [[ $job_count -ge $max_jobs ]]; do
            # Wait for any job to finish
            for i in "${!pids[@]}"; do
                if ! kill -0 "${pids[$i]}" 2>/dev/null; then
                    wait "${pids[$i]}"
                    unset "pids[$i]"
                    ((job_count--))
                fi
            done
            sleep 0.1
        done

        # Start new job
        eval "$cmd" &
        pids+=($!)
        ((job_count++))
    done

    # Wait for all remaining jobs
    for pid in "${pids[@]}"; do
        wait "$pid"
    done
}

# Generate test report
generate_report() {
    local report_format="${1:-text}"
    local report_file="${2:-}"

    local total_duration=$(($(date +%s) - ${TEST_STATE[start_time]}))
    local pass_rate=0
    [[ ${TEST_STATE[total]} -gt 0 ]] && \
        pass_rate=$((${TEST_STATE[passed]} * 100 / ${TEST_STATE[total]}))

    case "$report_format" in
        text)
            cat <<EOF
╔════════════════════════════════════════════════════════════════════╗
║                     TEST EXECUTION REPORT                          ║
╚════════════════════════════════════════════════════════════════════╝

Execution Summary:
  Total Tests:    ${TEST_STATE[total]}
  Passed:         ${TEST_STATE[passed]} ${GREEN}${CHECK_MARK}${NC}
  Failed:         ${TEST_STATE[failed]} ${RED}${CROSS_MARK}${NC}
  Skipped:        ${TEST_STATE[skipped]} ${YELLOW}○${NC}
  Pass Rate:      ${pass_rate}%
  Total Duration: ${total_duration}s

Category Breakdown:
EOF
            for category in "${TEST_CATEGORIES[@]}"; do
                if [[ -n "${TEST_TIMINGS[$category]:-}" ]]; then
                    echo "  $category: ${TEST_TIMINGS[$category]}ms"
                fi
            done

            if [[ ${#TEST_ERRORS[@]} -gt 0 ]]; then
                echo -e "\n${RED}Errors:${NC}"
                for error in "${TEST_ERRORS[@]}"; do
                    echo "  • $error"
                done
            fi

            if [[ ${#TEST_WARNINGS[@]} -gt 0 ]]; then
                echo -e "\n${YELLOW}Warnings:${NC}"
                for warning in "${TEST_WARNINGS[@]}"; do
                    echo "  • $warning"
                done
            fi
            ;;

        json)
            cat <<EOF
{
  "summary": {
    "total": ${TEST_STATE[total]},
    "passed": ${TEST_STATE[passed]},
    "failed": ${TEST_STATE[failed]},
    "skipped": ${TEST_STATE[skipped]},
    "pass_rate": $pass_rate,
    "duration": $total_duration
  },
  "categories": {
EOF
            local first=1
            for category in "${TEST_CATEGORIES[@]}"; do
                if [[ -n "${TEST_TIMINGS[$category]:-}" ]]; then
                    [[ $first -eq 0 ]] && echo ","
                    echo -n "    \"$category\": ${TEST_TIMINGS[$category]}"
                    first=0
                fi
            done
            cat <<EOF

  },
  "errors": [
EOF
            local first=1
            for error in "${TEST_ERRORS[@]}"; do
                [[ $first -eq 0 ]] && echo ","
                echo -n "    \"$(echo "$error" | sed 's/"/\\"/g')\""
                first=0
            done
            cat <<EOF

  ],
  "warnings": [
EOF
            local first=1
            for warning in "${TEST_WARNINGS[@]}"; do
                [[ $first -eq 0 ]] && echo ","
                echo -n "    \"$(echo "$warning" | sed 's/"/\\"/g')\""
                first=0
            done
            cat <<EOF

  ]
}
EOF
            ;;

        junit)
            cat <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<testsuites name="${FRAMEWORK_NAME}" tests="${TEST_STATE[total]}" failures="${TEST_STATE[failed]}" skipped="${TEST_STATE[skipped]}" time="$total_duration">
EOF
            for test_name in "${(k)TEST_RESULTS[@]}"; do
                [[ "$test_name" == *_status ]] || continue
                local base_name="${test_name%_status}"
                local status="${TEST_RESULTS[${base_name}_status]}"
                local duration="${TEST_RESULTS[${base_name}_duration]:-0}"
                local category="${TEST_RESULTS[${base_name}_category]:-unknown}"

                echo "  <testsuite name=\"$category\">"
                echo "    <testcase name=\"$base_name\" time=\"$duration\">"

                case "$status" in
                    FAIL)
                        echo "      <failure message=\"Test failed\"/>"
                        ;;
                    SKIP)
                        echo "      <skipped message=\"Test skipped\"/>"
                        ;;
                esac

                echo "    </testcase>"
                echo "  </testsuite>"
            done
            echo "</testsuites>"
            ;;
    esac

    if [[ -n "$report_file" ]]; then
        generate_report "$report_format" > "$report_file"
        log "INFO" "Report saved to: $report_file"
    fi
}

# Cleanup function
cleanup_test_environment() {
    log "TRACE" "Cleaning up test environment"

    # Kill any remaining background processes
    jobs -p | xargs -r kill 2>/dev/null || true

    # Remove temporary files (handle glob properly in zsh)
    setopt local_options nullglob
    local temp_files=(/tmp/test_*)
    [[ ${#temp_files[@]} -gt 0 ]] && rm -rf "${temp_files[@]}" 2>/dev/null || true

    # Generate final report
    if [[ ${TEST_STATE[total]} -gt 0 ]]; then
        generate_report text
    fi
}

# Set up signal handlers
trap cleanup_test_environment EXIT INT TERM

# Functions are automatically available in zsh subshells
# No need to export them explicitly

# Initialize on sourcing
initialize_test_state

log "TRACE" "Test framework loaded (version: $FRAMEWORK_VERSION)"
