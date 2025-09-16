#!/usr/bin/env zsh
# Unified Test Runner for Dotfiles
# Consolidates all test functionality into a single, comprehensive runner

set -uo pipefail

# ============================================================================
# CONFIGURATION
# ============================================================================

# Paths
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
export TEST_DIR="$SCRIPT_DIR"
export DOTFILES_DIR="$(dirname "$TEST_DIR")"
export TEST_TMP_DIR="${TEST_TMP_DIR:-/tmp/dotfiles_test_$$}"

# Test levels and options
TEST_LEVEL="standard"
DEBUG=0
VERBOSE=0
CI_MODE=0
NO_COLOR=0
PARALLEL=0
COVERAGE=0
BAIL_ON_FAIL=0

# Test selection
RUN_UNIT=0
RUN_FUNCTIONAL=0
RUN_INTEGRATION=0
RUN_PERFORMANCE=0
RUN_WORKFLOWS=0
RUN_ALL=0

# Counters
PASSED=0
FAILED=0
SKIPPED=0
WARNINGS=0
TOTAL_TIME=0

# Test patterns
TEST_PATTERN=""
EXCLUDE_PATTERN=""

# ============================================================================
# COLORS AND OUTPUT
# ============================================================================

setup_colors() {
    if [[ -t 1 ]] && [[ $NO_COLOR -eq 0 ]]; then
        RED='\033[0;31m'
        GREEN='\033[0;32m'
        YELLOW='\033[0;33m'
        BLUE='\033[0;34m'
        MAGENTA='\033[0;35m'
        CYAN='\033[0;36m'
        WHITE='\033[0;37m'
        BOLD='\033[1m'
        DIM='\033[2m'
        NC='\033[0m' # No Color
    else
        RED=''
        GREEN=''
        YELLOW=''
        BLUE=''
        MAGENTA=''
        CYAN=''
        WHITE=''
        BOLD=''
        DIM=''
        NC=''
    fi
}

# Logging functions
log() {
    local level="$1"
    shift
    local message="$*"
    local timestamp=$(date '+%H:%M:%S')

    case "$level" in
        ERROR)
            echo -e "${RED}[ERROR]${NC} ${timestamp} - $message" >&2
            ;;
        WARN)
            echo -e "${YELLOW}[WARN]${NC} ${timestamp} - $message" >&2
            ((WARNINGS++))
            ;;
        INFO)
            echo -e "${BLUE}[INFO]${NC} ${timestamp} - $message"
            ;;
        SUCCESS)
            echo -e "${GREEN}[✓]${NC} $message"
            ;;
        FAIL)
            echo -e "${RED}[✗]${NC} $message"
            ;;
        DEBUG)
            [[ $DEBUG -eq 1 ]] && echo -e "${DIM}[DEBUG]${NC} ${timestamp} - $message" >&2
            ;;
        *)
            echo "$message"
            ;;
    esac
}

# Progress indicator
show_progress() {
    local current=$1
    local total=$2
    local percent=$((current * 100 / total))
    local filled=$((percent / 2))
    local empty=$((50 - filled))

    printf "\r[${GREEN}"
    printf "%0.s█" $(seq 1 $filled)
    printf "${NC}"
    printf "%0.s░" $(seq 1 $empty)
    printf "] ${percent}%% ($current/$total)"
}

# ============================================================================
# USAGE AND HELP
# ============================================================================

usage() {
    # Initialize colors if not already done
    [[ -z "${BOLD:-}" ]] && setup_colors

    cat << EOF
${BOLD}Dotfiles Unified Test Runner${NC}

${BOLD}Usage:${NC} $0 [OPTIONS] [TEST_PATTERN]

${BOLD}Test Levels:${NC}
  --quick         Run essential tests only (< 30s)
  --standard      Run standard test suite (default, < 2min)
  --full          Run complete test suite including performance tests
  --ci            CI mode with artifacts and reporting

${BOLD}Test Categories:${NC}
  --unit          Run unit tests only
  --functional    Run functional tests only
  --integration   Run integration tests only
  --performance   Run performance tests only
  --workflows     Run workflow tests only
  --all           Run all test categories

${BOLD}Output Options:${NC}
  -v, --verbose   Show detailed output
  -d, --debug     Enable debug logging
  --no-color      Disable colored output
  --coverage      Generate coverage report
  --junit         Output JUnit XML report

${BOLD}Execution Options:${NC}
  --parallel      Run tests in parallel
  --bail          Stop on first failure
  --timeout SEC   Set test timeout (default: 300s)
  --exclude PAT   Exclude tests matching pattern

${BOLD}Examples:${NC}
  $0                          # Run standard tests
  $0 --quick                  # Quick sanity check
  $0 --unit nvim              # Run Neovim unit tests
  $0 --full --ci              # Full CI test run
  $0 --debug "test_*.sh"      # Debug specific tests

${BOLD}Environment Variables:${NC}
  TEST_TMP_DIR    Temporary directory for tests
  CI              Set to 1 for CI mode
  DEBUG           Set to 1 for debug output
  NO_COLOR        Set to 1 to disable colors

EOF
    exit 0
}

# ============================================================================
# TEST DISCOVERY
# ============================================================================

discover_tests() {
    local category="$1"
    local pattern="${2:-*.sh}"
    local test_files=()

    case "$category" in
        unit)
            test_files=($(find "$TEST_DIR/unit" -name "$pattern" -type f 2>/dev/null | sort))
            ;;
        functional)
            test_files=($(find "$TEST_DIR/functional" -name "$pattern" -type f 2>/dev/null | sort))
            ;;
        integration)
            test_files=($(find "$TEST_DIR/integration" -name "$pattern" -type f 2>/dev/null | sort))
            ;;
        performance)
            test_files=($(find "$TEST_DIR/performance" -name "$pattern" -type f 2>/dev/null | sort))
            ;;
        workflows)
            test_files=($(find "$TEST_DIR/workflows" -name "$pattern" -type f 2>/dev/null | sort))
            ;;
        all)
            test_files=($(find "$TEST_DIR" -name "$pattern" -type f \
                ! -path "*/helpers/*" \
                ! -path "*/.git/*" \
                2>/dev/null | sort))
            ;;
    esac

    # Apply exclude pattern if set
    if [[ -n "$EXCLUDE_PATTERN" ]]; then
        local filtered=()
        for file in "${test_files[@]}"; do
            if [[ ! "$file" =~ $EXCLUDE_PATTERN ]]; then
                filtered+=("$file")
            fi
        done
        test_files=("${filtered[@]}")
    fi

    echo "${test_files[@]}"
}

# ============================================================================
# TEST EXECUTION
# ============================================================================

run_test() {
    local test_file="$1"
    local test_name=$(basename "$test_file" .sh)
    local test_dir=$(dirname "$test_file")
    local start_time=$(date +%s)

    log DEBUG "Running test: $test_file"

    # Create test-specific temp dir
    local test_tmp="$TEST_TMP_DIR/$test_name"
    mkdir -p "$test_tmp"

    # Set up test environment
    export DOTFILES_DIR
    export TEST_DIR
    export TEST_TMP_DIR

    # Create a wrapper script that sources helpers and runs the test
    local wrapper_script="$test_tmp/wrapper.zsh"
    cat > "$wrapper_script" << 'EOF'
#!/usr/bin/env zsh
# Source test helpers if not already sourced
if ! type test_case >/dev/null 2>&1; then
    if [[ -f "$TEST_DIR/lib/test_helpers.zsh" ]]; then
        source "$TEST_DIR/lib/test_helpers.zsh"
    fi
fi

# Add missing test functions that some tests expect
if ! type test_suite >/dev/null 2>&1; then
    test_suite() { echo "=== $* ==="; }
fi

if ! type test_plugin_loaded >/dev/null 2>&1; then
    test_plugin_loaded() {
        # Simple check if plugin exists in lazy directory
        local plugin=$1
        if [[ -d "$HOME/.local/share/nvim/lazy/$plugin" ]]; then
            echo "  ✓ $plugin loaded"
            return 0
        else
            echo "  ✗ $plugin not found"
            return 1
        fi
    }
fi

if ! type nvim_test >/dev/null 2>&1; then
    nvim_test() {
        # Simple nvim headless test
        local cmd=$1
        nvim --headless -c "$cmd" -c 'qa!' 2>/dev/null
        return $?
    }
fi

# Set default values if not set
: ${DOTFILES_DIR:=/Users/starikov/.dotfiles}
: ${TEST_DIR:=$DOTFILES_DIR/test}
: ${TEST_TMP_DIR:=/tmp/test-$$}

# Run the actual test
source "$1"
EOF

    # Run test through wrapper
    local test_output
    local test_status

    if [[ $VERBOSE -eq 1 ]]; then
        zsh "$wrapper_script" "$test_file" 2>&1
        test_status=$?
    else
        test_output=$(zsh "$wrapper_script" "$test_file" 2>&1)
        test_status=$?
    fi

    local end_time=$(date +%s)
    local duration=$((end_time - start_time))

    # Process result
    if [[ $test_status -eq 0 ]]; then
        log SUCCESS "$test_name (${duration}s)"
        ((PASSED++))
    elif [[ $test_status -eq 124 ]]; then
        log FAIL "$test_name - TIMEOUT"
        ((FAILED++))
        if [[ $VERBOSE -eq 0 ]] && [[ -n "${test_output:-}" ]]; then
            echo "$test_output" | grep -v "^[a-z_]* ()" | head -20
        fi
    else
        log FAIL "$test_name - EXIT $test_status"
        ((FAILED++))
        if [[ $VERBOSE -eq 0 ]] && [[ -n "${test_output:-}" ]]; then
            echo "$test_output" | grep -v "^[a-z_]* ()" | head -20
        fi

        # Bail on first failure if requested
        [[ $BAIL_ON_FAIL -eq 1 ]] && return 1
    fi

    # Clean up test temp dir
    rm -rf "$test_tmp"

    return 0
}

run_test_category() {
    local category="$1"
    local pattern="${TEST_PATTERN:-*.sh}"

    log INFO "Running $category tests..."

    local test_files=($(discover_tests "$category" "$pattern"))
    local total=${#test_files[@]}

    if [[ $total -eq 0 ]]; then
        log WARN "No $category tests found matching pattern: $pattern"
        return 0
    fi

    log INFO "Found $total $category test(s)"

    local count=0
    for test_file in "${test_files[@]}"; do
        ((count++))
        [[ $VERBOSE -eq 0 ]] && show_progress $count $total

        if [[ $PARALLEL -eq 1 ]]; then
            run_test "$test_file" &
        else
            run_test "$test_file"
            if [[ $? -ne 0 ]] && [[ $BAIL_ON_FAIL -eq 1 ]]; then
                return 1
            fi
        fi
    done

    # Wait for parallel tests
    [[ $PARALLEL -eq 1 ]] && wait

    [[ $VERBOSE -eq 0 ]] && echo # New line after progress bar
}

# ============================================================================
# TEST HELPERS
# ============================================================================

setup_test_environment() {
    # Create temp directory
    mkdir -p "$TEST_TMP_DIR"

    # Export environment variables for tests
    export DOTFILES_DIR
    export TEST_DIR
    export TEST_TMP_DIR

    # Source test helpers if available
    if [[ -f "$TEST_DIR/helpers/common.sh" ]]; then
        source "$TEST_DIR/helpers/common.sh"
    fi

    log DEBUG "Test environment ready"
}

cleanup_test_environment() {
    # Clean up temp directory
    if [[ -d "$TEST_TMP_DIR" ]]; then
        rm -rf "$TEST_TMP_DIR"
    fi

    log DEBUG "Test environment cleaned up"
}

# ============================================================================
# ASSERTIONS
# ============================================================================

assert_equals() {
    local expected="$1"
    local actual="$2"
    local message="${3:-Assertion failed}"

    if [[ "$expected" != "$actual" ]]; then
        echo "FAIL: $message"
        echo "  Expected: $expected"
        echo "  Actual:   $actual"
        return 1
    fi
    return 0
}

assert_true() {
    local condition="$1"
    local message="${2:-Assertion failed}"

    if ! eval "$condition"; then
        echo "FAIL: $message"
        echo "  Condition: $condition"
        return 1
    fi
    return 0
}

assert_false() {
    local condition="$1"
    local message="${2:-Assertion failed}"

    if eval "$condition"; then
        echo "FAIL: $message"
        echo "  Condition should be false: $condition"
        return 1
    fi
    return 0
}

assert_file_exists() {
    local file="$1"
    local message="${2:-File should exist}"

    if [[ ! -f "$file" ]]; then
        echo "FAIL: $message"
        echo "  File not found: $file"
        return 1
    fi
    return 0
}

assert_dir_exists() {
    local dir="$1"
    local message="${2:-Directory should exist}"

    if [[ ! -d "$dir" ]]; then
        echo "FAIL: $message"
        echo "  Directory not found: $dir"
        return 1
    fi
    return 0
}

assert_command_succeeds() {
    local command="$1"
    local message="${2:-Command should succeed}"

    if ! eval "$command" >/dev/null 2>&1; then
        echo "FAIL: $message"
        echo "  Command failed: $command"
        return 1
    fi
    return 0
}

skip_if() {
    local condition="$1"
    local message="${2:-Test skipped}"

    if eval "$condition"; then
        echo "SKIP: $message"
        exit 0
    fi
}

# ============================================================================
# REPORTING
# ============================================================================

generate_report() {
    local total=$((PASSED + FAILED + SKIPPED))
    local success_rate=0
    [[ $total -gt 0 ]] && success_rate=$((PASSED * 100 / total))

    echo
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "${BOLD}Test Results Summary${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo
    echo "  ${GREEN}Passed:${NC}  $PASSED"
    echo "  ${RED}Failed:${NC}  $FAILED"
    echo "  ${YELLOW}Skipped:${NC} $SKIPPED"
    [[ $WARNINGS -gt 0 ]] && echo "  ${YELLOW}Warnings:${NC} $WARNINGS"
    echo
    echo "  ${BOLD}Total:${NC}   $total"
    echo "  ${BOLD}Success:${NC} ${success_rate}%"
    echo "  ${BOLD}Time:${NC}    ${TOTAL_TIME}s"
    echo

    if [[ $FAILED -eq 0 ]]; then
        echo "${GREEN}${BOLD}All tests passed! ✅${NC}"
    else
        echo "${RED}${BOLD}Tests failed! ❌${NC}"
    fi

    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

generate_junit_report() {
    local report_file="${1:-test-results.xml}"
    local timestamp=$(date -Iseconds)

    cat > "$report_file" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<testsuites name="Dotfiles Tests" time="$TOTAL_TIME" tests="$((PASSED + FAILED))" failures="$FAILED" skipped="$SKIPPED">
    <testsuite name="Test Suite" timestamp="$timestamp" tests="$((PASSED + FAILED))" failures="$FAILED" skipped="$SKIPPED" time="$TOTAL_TIME">
        <!-- Test cases would be added here in a real implementation -->
    </testsuite>
</testsuites>
EOF

    log INFO "JUnit report saved to: $report_file"
}

# ============================================================================
# MAIN EXECUTION
# ============================================================================

main() {
    local start_time=$(date +%s)

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            # Test levels
            --quick)
                TEST_LEVEL="quick"
                shift
                ;;
            --standard)
                TEST_LEVEL="standard"
                shift
                ;;
            --full)
                TEST_LEVEL="full"
                shift
                ;;
            --ci)
                CI_MODE=1
                TEST_LEVEL="full"
                shift
                ;;

            # Test categories
            --unit)
                RUN_UNIT=1
                shift
                ;;
            --functional)
                RUN_FUNCTIONAL=1
                shift
                ;;
            --integration)
                RUN_INTEGRATION=1
                shift
                ;;
            --performance)
                RUN_PERFORMANCE=1
                shift
                ;;
            --workflows)
                RUN_WORKFLOWS=1
                shift
                ;;
            --all)
                RUN_ALL=1
                shift
                ;;

            # Output options
            -v|--verbose)
                VERBOSE=1
                shift
                ;;
            -d|--debug)
                DEBUG=1
                VERBOSE=1
                shift
                ;;
            --no-color)
                NO_COLOR=1
                shift
                ;;
            --coverage)
                COVERAGE=1
                shift
                ;;
            --junit)
                JUNIT=1
                shift
                ;;

            # Execution options
            --parallel)
                PARALLEL=1
                shift
                ;;
            --bail)
                BAIL_ON_FAIL=1
                shift
                ;;
            --timeout)
                TEST_TIMEOUT="$2"
                shift 2
                ;;
            --exclude)
                EXCLUDE_PATTERN="$2"
                shift 2
                ;;

            # Help
            -h|--help)
                usage
                ;;

            # Test pattern
            *)
                TEST_PATTERN="$1"
                shift
                ;;
        esac
    done

    # Setup
    setup_colors
    setup_test_environment

    # Determine what to run based on level
    if [[ $RUN_ALL -eq 1 ]]; then
        RUN_UNIT=1
        RUN_FUNCTIONAL=1
        RUN_INTEGRATION=1
        RUN_PERFORMANCE=1
        RUN_WORKFLOWS=1
    elif [[ $RUN_UNIT -eq 0 && $RUN_FUNCTIONAL -eq 0 && $RUN_INTEGRATION -eq 0 && $RUN_PERFORMANCE -eq 0 && $RUN_WORKFLOWS -eq 0 ]]; then
        # No specific category selected, use test level
        case "$TEST_LEVEL" in
            quick)
                RUN_UNIT=1
                ;;
            standard)
                RUN_UNIT=1
                RUN_FUNCTIONAL=1
                ;;
            full)
                RUN_UNIT=1
                RUN_FUNCTIONAL=1
                RUN_INTEGRATION=1
                RUN_PERFORMANCE=1
                RUN_WORKFLOWS=1
                ;;
        esac
    fi

    # Print header
    echo
    echo "${BOLD}Dotfiles Test Runner${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Level: $TEST_LEVEL"
    [[ -n "$TEST_PATTERN" ]] && echo "Pattern: $TEST_PATTERN"
    [[ -n "$EXCLUDE_PATTERN" ]] && echo "Exclude: $EXCLUDE_PATTERN"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo

    # Run tests
    [[ $RUN_UNIT -eq 1 ]] && run_test_category "unit"
    [[ $RUN_FUNCTIONAL -eq 1 ]] && run_test_category "functional"
    [[ $RUN_INTEGRATION -eq 1 ]] && run_test_category "integration"
    [[ $RUN_PERFORMANCE -eq 1 ]] && run_test_category "performance"
    [[ $RUN_WORKFLOWS -eq 1 ]] && run_test_category "workflows"

    # Calculate total time
    local end_time=$(date +%s)
    TOTAL_TIME=$((end_time - start_time))

    # Generate reports
    generate_report
    [[ ${JUNIT:-0} -eq 1 ]] && generate_junit_report

    # Cleanup
    cleanup_test_environment

    # Exit with appropriate code
    [[ $FAILED -eq 0 ]] && exit 0 || exit 1
}

# Run main function
main "$@"