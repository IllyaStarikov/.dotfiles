#!/usr/bin/env zsh
# ════════════════════════════════════════════════════════════════════════════════
# Comprehensive Test Suite Runner for Dotfiles
# ════════════════════════════════════════════════════════════════════════════════
#
# DESCRIPTION:
#   Production-ready test suite with extensive coverage for all test types.
#   Follows Google testing standards with comprehensive logging and reporting.
#
# USAGE:
#   ./run-tests.zsh [OPTIONS]
#
# OPTIONS:
#   --small    Run quick tests (unit, smoke, sanity) - < 1 minute
#   --medium   Run integration and functional tests - < 5 minutes
#   --large    Run all tests including performance/stress - < 30 minutes (default)
#   --debug    Enable extensive debug logging
#   --report   Generate detailed HTML/JSON test reports
#   --parallel Run tests in parallel where possible
#   --category Run specific test category (e.g., --category=security)
#
# TEST CATEGORIES:
#   Functional: unit, integration, system, acceptance, smoke, sanity, regression, e2e
#   Non-Functional: performance, load, stress, volume, scalability, usability,
#                   security, compatibility, reliability, recovery
#   Specialized: api, database, configuration, installation, boot, accessibility,
#                localization, penetration, chaos, mutation, fuzz, snapshot, contract
#
# ════════════════════════════════════════════════════════════════════════════════

set -euo pipefail

# ═══════════════════════════════════════════════════════════════════════════
# Configuration
# ═══════════════════════════════════════════════════════════════════════════

readonly SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
readonly DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"
readonly TEST_DIR="$SCRIPT_DIR"
readonly REPORTS_DIR="$TEST_DIR/reports"
readonly LOGS_DIR="$TEST_DIR/logs"
readonly TIMESTAMP=$(date +%Y%m%d_%H%M%S)
readonly TEST_RUN_ID="test_run_${TIMESTAMP}_$$"

# Test configuration
TEST_SIZE="${TEST_SIZE:-large}"
DEBUG_MODE=0
GENERATE_REPORT=0
PARALLEL_EXECUTION=0
SPECIFIC_CATEGORY=""
EXIT_ON_FIRST_FAILURE=0
VERBOSE=0

# Timing
START_TIME=$(date +%s)

# Results tracking
declare -A TEST_RESULTS
declare -A TEST_TIMES
declare -A TEST_LOGS
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0
SKIPPED_TESTS=0

# ═══════════════════════════════════════════════════════════════════════════
# Test Categories by Size
# ═══════════════════════════════════════════════════════════════════════════

# Small tests (< 1 minute)
SMALL_CATEGORIES=(
    "unit"
    "smoke"
    "sanity"
    "configuration"
)

# Medium tests (< 5 minutes)
MEDIUM_CATEGORIES=(
    "${SMALL_CATEGORIES[@]}"
    "integration"
    "functional"
    "system"
    "acceptance"
    "regression"
    "api"
    "database"
    "snapshot"
    "contract"
    "compatibility"
    "boot"
)

# Large tests (all tests)
LARGE_CATEGORIES=(
    "${MEDIUM_CATEGORIES[@]}"
    "e2e"
    "performance"
    "load"
    "stress"
    "volume"
    "scalability"
    "usability"
    "security"
    "reliability"
    "recovery"
    "installation"
    "accessibility"
    "localization"
    "penetration"
    "chaos"
    "mutation"
    "fuzz"
)

# ═══════════════════════════════════════════════════════════════════════════
# Color Output
# ═══════════════════════════════════════════════════════════════════════════

# Colors for output
if [[ -t 1 ]]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    MAGENTA='\033[0;35m'
    CYAN='\033[0;36m'
    WHITE='\033[1;37m'
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

# ═══════════════════════════════════════════════════════════════════════════
# Logging Functions
# ═══════════════════════════════════════════════════════════════════════════

log() {
    local level="$1"
    shift
    local message="$*"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S.%3N')

    case "$level" in
        DEBUG)
            [[ $DEBUG_MODE -eq 1 ]] && echo -e "${DIM}[$timestamp] [DEBUG] $message${NC}" >&2
            ;;
        INFO)
            echo -e "${BLUE}[$timestamp] [INFO]${NC} $message"
            ;;
        SUCCESS)
            echo -e "${GREEN}[$timestamp] [✓]${NC} $message"
            ;;
        WARNING)
            echo -e "${YELLOW}[$timestamp] [⚠]${NC} $message"
            ;;
        ERROR)
            echo -e "${RED}[$timestamp] [✗]${NC} $message" >&2
            ;;
        HEADER)
            echo -e "\n${CYAN}════════════════════════════════════════════════════════════════${NC}"
            echo -e "${CYAN}  $message${NC}"
            echo -e "${CYAN}════════════════════════════════════════════════════════════════${NC}"
            ;;
        SUBHEADER)
            echo -e "\n${MAGENTA}━━━ $message ━━━${NC}"
            ;;
        *)
            echo "[$timestamp] $message"
            ;;
    esac

    # Also log to file if in debug mode
    if [[ $DEBUG_MODE -eq 1 ]]; then
        echo "[$timestamp] [$level] $message" >> "$LOGS_DIR/${TEST_RUN_ID}.log"
    fi
}

debug() {
    log DEBUG "$@"
}

info() {
    log INFO "$@"
}

success() {
    log SUCCESS "$@"
}

warn() {
    log WARNING "$@"
}

error() {
    log ERROR "$@"
}

header() {
    log HEADER "$@"
}

subheader() {
    log SUBHEADER "$@"
}

# ═══════════════════════════════════════════════════════════════════════════
# Test Discovery
# ═══════════════════════════════════════════════════════════════════════════

discover_tests() {
    local category="$1"
    local test_files=()

    debug "Discovering tests for category: $category"

    # Find all test files in the category directory
    local category_dir="$TEST_DIR/$category"
    if [[ -d "$category_dir" ]]; then
        while IFS= read -r -d '' file; do
            test_files+=("$file")
        done < <(find "$category_dir" -type f \( -name "*.zsh" -o -name "*.sh" \) -print0 2>/dev/null)
    fi

    # Also check for category-specific tests in subdirectories
    while IFS= read -r -d '' file; do
        if [[ "$file" == *"${category}_test"* ]] || [[ "$file" == *"test_${category}"* ]]; then
            test_files+=("$file")
        fi
    done < <(find "$TEST_DIR" -type f \( -name "*${category}*.zsh" -o -name "*${category}*.sh" \) -print0 2>/dev/null)

    # Remove duplicates
    local unique_files=($(printf '%s\n' "${test_files[@]}" | sort -u))

    debug "Found ${#unique_files[@]} test files for $category"
    printf '%s\n' "${unique_files[@]}"
}

# ═══════════════════════════════════════════════════════════════════════════
# Test Execution
# ═══════════════════════════════════════════════════════════════════════════

run_test_file() {
    local test_file="$1"
    local test_name=$(basename "$test_file" | sed 's/\.[^.]*$//')
    local test_log="$LOGS_DIR/${TEST_RUN_ID}_${test_name}.log"
    local start_time=$(date +%s%N)

    debug "Running test: $test_name from $test_file"

    # Create test environment
    export TEST_DIR="$TEST_DIR"
    export DOTFILES_DIR="$DOTFILES_DIR"
    export TEST_TMP_DIR="/tmp/dotfiles_test_$$"
    export DEBUG_MODE="$DEBUG_MODE"
    export TEST_RUN_ID="$TEST_RUN_ID"

    mkdir -p "$TEST_TMP_DIR"

    # Run the test
    local exit_code=0
    if [[ -x "$test_file" ]]; then
        if [[ $DEBUG_MODE -eq 1 ]]; then
            "$test_file" 2>&1 | tee "$test_log" || exit_code=$?
        else
            "$test_file" > "$test_log" 2>&1 || exit_code=$?
        fi
    else
        warn "Test file not executable: $test_file"
        exit_code=1
    fi

    # Calculate execution time
    local end_time=$(date +%s%N)
    local duration=$(( (end_time - start_time) / 1000000 )) # Convert to milliseconds

    # Store results
    TEST_RESULTS["$test_name"]=$exit_code
    TEST_TIMES["$test_name"]=$duration
    TEST_LOGS["$test_name"]="$test_log"

    # Update counters
    ((TOTAL_TESTS++))
    if [[ $exit_code -eq 0 ]]; then
        ((PASSED_TESTS++))
        success "PASSED: $test_name (${duration}ms)"
    else
        ((FAILED_TESTS++))
        error "FAILED: $test_name (${duration}ms)"
        if [[ $EXIT_ON_FIRST_FAILURE -eq 1 ]]; then
            error "Exiting due to test failure (--fail-fast enabled)"
            cleanup
            exit 1
        fi
    fi

    # Cleanup test environment
    rm -rf "$TEST_TMP_DIR" 2>/dev/null || true

    return $exit_code
}

run_category() {
    local category="$1"

    subheader "Running $category tests"

    local test_files=($(discover_tests "$category"))

    if [[ ${#test_files[@]} -eq 0 ]]; then
        warn "No tests found for category: $category"
        return 0
    fi

    info "Found ${#test_files[@]} test files in $category"

    for test_file in "${test_files[@]}"; do
        run_test_file "$test_file"
    done
}

run_tests_parallel() {
    local categories=("$@")
    local pids=()

    for category in "${categories[@]}"; do
        (run_category "$category") &
        pids+=($!)
    done

    # Wait for all tests to complete
    local failed=0
    for pid in "${pids[@]}"; do
        wait $pid || ((failed++))
    done

    return $failed
}

# ═══════════════════════════════════════════════════════════════════════════
# Report Generation
# ═══════════════════════════════════════════════════════════════════════════

generate_html_report() {
    local report_file="$REPORTS_DIR/${TEST_RUN_ID}_report.html"

    cat > "$report_file" << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Test Report - {{TEST_RUN_ID}}</title>
    <style>
        body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; margin: 0; padding: 20px; background: #f5f5f5; }
        .container { max-width: 1200px; margin: 0 auto; background: white; padding: 30px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        h1 { color: #333; border-bottom: 3px solid #007bff; padding-bottom: 10px; }
        .summary { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 20px; margin: 30px 0; }
        .stat-card { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 20px; border-radius: 10px; }
        .stat-card.passed { background: linear-gradient(135deg, #56ab2f 0%, #a8e063 100%); }
        .stat-card.failed { background: linear-gradient(135deg, #e74c3c 0%, #c0392b 100%); }
        .stat-card.skipped { background: linear-gradient(135deg, #f39c12 0%, #f1c40f 100%); }
        .stat-value { font-size: 2.5em; font-weight: bold; }
        .stat-label { font-size: 0.9em; opacity: 0.9; margin-top: 5px; }
        table { width: 100%; border-collapse: collapse; margin-top: 30px; }
        th { background: #f8f9fa; padding: 12px; text-align: left; font-weight: 600; color: #495057; border-bottom: 2px solid #dee2e6; }
        td { padding: 12px; border-bottom: 1px solid #dee2e6; }
        tr:hover { background: #f8f9fa; }
        .status { padding: 4px 12px; border-radius: 20px; font-size: 0.85em; font-weight: 600; display: inline-block; }
        .status.passed { background: #d4edda; color: #155724; }
        .status.failed { background: #f8d7da; color: #721c24; }
        .status.skipped { background: #fff3cd; color: #856404; }
        .duration { color: #6c757d; font-size: 0.9em; }
        .progress-bar { width: 100%; height: 30px; background: #e9ecef; border-radius: 15px; overflow: hidden; margin: 20px 0; }
        .progress-fill { height: 100%; background: linear-gradient(90deg, #56ab2f 0%, #a8e063 100%); transition: width 0.3s; }
        .timestamp { color: #6c757d; font-size: 0.9em; margin-top: 20px; }
        .category-header { background: #007bff; color: white; padding: 10px 15px; border-radius: 5px; margin: 20px 0 10px 0; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🧪 Dotfiles Test Report</h1>
        <div class="timestamp">Generated: {{TIMESTAMP}}</div>

        <div class="summary">
            <div class="stat-card">
                <div class="stat-value">{{TOTAL_TESTS}}</div>
                <div class="stat-label">Total Tests</div>
            </div>
            <div class="stat-card passed">
                <div class="stat-value">{{PASSED_TESTS}}</div>
                <div class="stat-label">Passed</div>
            </div>
            <div class="stat-card failed">
                <div class="stat-value">{{FAILED_TESTS}}</div>
                <div class="stat-label">Failed</div>
            </div>
            <div class="stat-card skipped">
                <div class="stat-value">{{SKIPPED_TESTS}}</div>
                <div class="stat-label">Skipped</div>
            </div>
        </div>

        <div class="progress-bar">
            <div class="progress-fill" style="width: {{PASS_PERCENTAGE}}%"></div>
        </div>

        <h2>Test Results</h2>
        <table>
            <thead>
                <tr>
                    <th>Test Name</th>
                    <th>Status</th>
                    <th>Duration</th>
                    <th>Category</th>
                </tr>
            </thead>
            <tbody>
                {{TEST_ROWS}}
            </tbody>
        </table>

        <div class="timestamp">Test Suite: {{TEST_SIZE}} | Duration: {{TOTAL_DURATION}}s</div>
    </div>
</body>
</html>
EOF

    # Calculate statistics
    local pass_percentage=0
    if [[ $TOTAL_TESTS -gt 0 ]]; then
        pass_percentage=$(( (PASSED_TESTS * 100) / TOTAL_TESTS ))
    fi

    local total_duration=$(( $(date +%s) - START_TIME ))

    # Generate test rows
    local test_rows=""
    for test_name in "${!TEST_RESULTS[@]}"; do
        local status="failed"
        [[ ${TEST_RESULTS[$test_name]} -eq 0 ]] && status="passed"

        local duration="${TEST_TIMES[$test_name]}ms"
        local category=$(echo "$test_name" | cut -d'_' -f1)

        test_rows+="<tr>"
        test_rows+="<td>$test_name</td>"
        test_rows+="<td><span class='status $status'>$status</span></td>"
        test_rows+="<td class='duration'>$duration</td>"
        test_rows+="<td>$category</td>"
        test_rows+="</tr>"
    done

    # Replace placeholders
    sed -i '' "s|{{TEST_RUN_ID}}|$TEST_RUN_ID|g" "$report_file"
    sed -i '' "s|{{TIMESTAMP}}|$(date '+%Y-%m-%d %H:%M:%S')|g" "$report_file"
    sed -i '' "s|{{TOTAL_TESTS}}|$TOTAL_TESTS|g" "$report_file"
    sed -i '' "s|{{PASSED_TESTS}}|$PASSED_TESTS|g" "$report_file"
    sed -i '' "s|{{FAILED_TESTS}}|$FAILED_TESTS|g" "$report_file"
    sed -i '' "s|{{SKIPPED_TESTS}}|$SKIPPED_TESTS|g" "$report_file"
    sed -i '' "s|{{PASS_PERCENTAGE}}|$pass_percentage|g" "$report_file"
    sed -i '' "s|{{TEST_SIZE}}|$TEST_SIZE|g" "$report_file"
    sed -i '' "s|{{TOTAL_DURATION}}|$total_duration|g" "$report_file"
    sed -i '' "s|{{TEST_ROWS}}|$test_rows|g" "$report_file"

    success "HTML report generated: $report_file"
}

generate_json_report() {
    local report_file="$REPORTS_DIR/${TEST_RUN_ID}_report.json"

    cat > "$report_file" << EOF
{
    "test_run_id": "$TEST_RUN_ID",
    "timestamp": "$(date -Iseconds)",
    "test_size": "$TEST_SIZE",
    "duration_seconds": $(( $(date +%s) - START_TIME )),
    "summary": {
        "total": $TOTAL_TESTS,
        "passed": $PASSED_TESTS,
        "failed": $FAILED_TESTS,
        "skipped": $SKIPPED_TESTS,
        "pass_rate": $(echo "scale=2; $PASSED_TESTS * 100 / $TOTAL_TESTS" | bc)
    },
    "tests": [
EOF

    local first=1
    for test_name in "${!TEST_RESULTS[@]}"; do
        [[ $first -eq 0 ]] && echo "," >> "$report_file"
        first=0

        cat >> "$report_file" << EOF
        {
            "name": "$test_name",
            "status": $([ ${TEST_RESULTS[$test_name]} -eq 0 ] && echo '"passed"' || echo '"failed"'),
            "duration_ms": ${TEST_TIMES[$test_name]},
            "log_file": "${TEST_LOGS[$test_name]}"
        }
EOF
    done

    cat >> "$report_file" << EOF
    ],
    "environment": {
        "os": "$(uname -s)",
        "arch": "$(uname -m)",
        "hostname": "$(hostname)",
        "user": "$USER",
        "dotfiles_dir": "$DOTFILES_DIR"
    }
}
EOF

    success "JSON report generated: $report_file"
}

# ═══════════════════════════════════════════════════════════════════════════
# Cleanup
# ═══════════════════════════════════════════════════════════════════════════

cleanup() {
    debug "Cleaning up test environment"

    # Clean up any remaining temp directories
    rm -rf /tmp/dotfiles_test_* 2>/dev/null || true

    # Archive logs if needed
    if [[ $DEBUG_MODE -eq 0 ]] && [[ -d "$LOGS_DIR" ]]; then
        # Keep only last 10 test runs
        ls -t "$LOGS_DIR" | tail -n +11 | xargs -I {} rm -rf "$LOGS_DIR/{}" 2>/dev/null || true
    fi
}

# ═══════════════════════════════════════════════════════════════════════════
# Usage and Help
# ═══════════════════════════════════════════════════════════════════════════

show_usage() {
    cat << EOF
$(basename "$0") - Comprehensive Test Suite Runner

USAGE:
    $(basename "$0") [OPTIONS]

OPTIONS:
    --small        Run quick tests (< 1 minute)
    --medium       Run integration tests (< 5 minutes)
    --large        Run all tests (< 30 minutes) [default]
    --debug        Enable extensive debug logging
    --report       Generate HTML and JSON reports
    --parallel     Run tests in parallel
    --fail-fast    Exit on first test failure
    --category=X   Run specific test category
    --verbose      Show detailed output
    --help         Show this help message

CATEGORIES:
    Functional Testing:
        unit, integration, system, acceptance, smoke, sanity, regression, e2e

    Non-Functional Testing:
        performance, load, stress, volume, scalability, usability,
        security, compatibility, reliability, recovery

    Specialized Testing:
        api, database, configuration, installation, boot, accessibility,
        localization, penetration, chaos, mutation, fuzz, snapshot, contract

EXAMPLES:
    # Run quick unit and smoke tests
    $(basename "$0") --small

    # Run all tests with debug output and reports
    $(basename "$0") --large --debug --report

    # Run only security tests
    $(basename "$0") --category=security

    # Run medium tests in parallel with fail-fast
    $(basename "$0") --medium --parallel --fail-fast

EOF
}

# ═══════════════════════════════════════════════════════════════════════════
# Main Execution
# ═══════════════════════════════════════════════════════════════════════════

main() {
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --small)
                TEST_SIZE="small"
                shift
                ;;
            --medium)
                TEST_SIZE="medium"
                shift
                ;;
            --large)
                TEST_SIZE="large"
                shift
                ;;
            --debug)
                DEBUG_MODE=1
                VERBOSE=1
                shift
                ;;
            --report)
                GENERATE_REPORT=1
                shift
                ;;
            --parallel)
                PARALLEL_EXECUTION=1
                shift
                ;;
            --fail-fast)
                EXIT_ON_FIRST_FAILURE=1
                shift
                ;;
            --category=*)
                SPECIFIC_CATEGORY="${1#*=}"
                shift
                ;;
            --verbose)
                VERBOSE=1
                shift
                ;;
            --help|-h)
                show_usage
                exit 0
                ;;
            *)
                error "Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
    done

    # Setup directories
    mkdir -p "$REPORTS_DIR" "$LOGS_DIR"

    # Print header
    header "Dotfiles Test Suite - $TEST_SIZE"
    info "Test Run ID: $TEST_RUN_ID"
    info "Debug Mode: $([ $DEBUG_MODE -eq 1 ] && echo "Enabled" || echo "Disabled")"
    info "Parallel Execution: $([ $PARALLEL_EXECUTION -eq 1 ] && echo "Enabled" || echo "Disabled")"

    # Determine which categories to run
    local categories_to_run=()

    if [[ -n "$SPECIFIC_CATEGORY" ]]; then
        categories_to_run=("$SPECIFIC_CATEGORY")
    else
        case "$TEST_SIZE" in
            small)
                categories_to_run=("${SMALL_CATEGORIES[@]}")
                ;;
            medium)
                categories_to_run=("${MEDIUM_CATEGORIES[@]}")
                ;;
            large)
                categories_to_run=("${LARGE_CATEGORIES[@]}")
                ;;
        esac
    fi

    info "Running test categories: ${categories_to_run[*]}"

    # Run tests
    if [[ $PARALLEL_EXECUTION -eq 1 ]]; then
        info "Running tests in parallel..."
        run_tests_parallel "${categories_to_run[@]}"
    else
        for category in "${categories_to_run[@]}"; do
            run_category "$category"
        done
    fi

    # Generate reports if requested
    if [[ $GENERATE_REPORT -eq 1 ]]; then
        subheader "Generating Reports"
        generate_html_report
        generate_json_report
    fi

    # Print summary
    header "Test Summary"

    local pass_rate=0
    if [[ $TOTAL_TESTS -gt 0 ]]; then
        pass_rate=$(echo "scale=2; $PASSED_TESTS * 100 / $TOTAL_TESTS" | bc)
    fi

    echo -e "${BOLD}Total Tests:${NC} $TOTAL_TESTS"
    echo -e "${GREEN}Passed:${NC} $PASSED_TESTS"
    echo -e "${RED}Failed:${NC} $FAILED_TESTS"
    echo -e "${YELLOW}Skipped:${NC} $SKIPPED_TESTS"
    echo -e "${BOLD}Pass Rate:${NC} ${pass_rate}%"
    echo -e "${BOLD}Duration:${NC} $(( $(date +%s) - START_TIME ))s"

    # Cleanup
    cleanup

    # Exit with appropriate code
    if [[ $FAILED_TESTS -gt 0 ]]; then
        error "Test suite failed with $FAILED_TESTS failures"
        exit 1
    else
        success "All tests passed!"
        exit 0
    fi
}

# Run main function
main "$@"