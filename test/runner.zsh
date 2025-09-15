#!/usr/bin/env zsh

# Dotfiles Test Suite - ZSH Implementation
# A focused, signal-driven test suite for validating dotfiles functionality

# Don't use pipefail as it can cause issues with command substitution in ZSH
set -eu

# Test configuration
readonly DOTFILES_DIR="${DOTFILES_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
readonly TEST_DIR="${DOTFILES_DIR}/test"
readonly ARTIFACTS_DIR="${TEST_DIR}/artifacts"
readonly TIMESTAMP=$(date +"%Y%m%d-%H%M%S")

# Source library system
source "${DOTFILES_DIR}/src/lib/lib.zsh"

# Load required libraries
lib_load_all logging colors cli unit

# Set default log level
: ${LOG_LEVEL:=INFO}
typeset -g CI_MODE=${CI:-false}

# Test counters (using unit library)
typeset -i PASSED=0
typeset -i FAILED=0
typeset -i SKIPPED=0
typeset -g -a FAILED_TESTS=()

# Create artifacts directory
mkdir -p "$ARTIFACTS_DIR"

print_header() {
    print_color "╔════════════════════════════════════════════════╗" "BLUE" "BOLD"
    print_color "║              Dotfiles Test Suite               ║" "BLUE" "BOLD"
    print_color "╚════════════════════════════════════════════════╝" "BLUE" "BOLD"
    echo
}

print_section() {
    print_color "━━━ $1 ━━━" "CYAN"
}

run_test() {
    LOG DEBUG "run_test called with: $1, $2"
    local test_name="$1"
    local test_function="$2"

    echo -n "${COLORS[BLUE]}▶${COLORS[RESET]} ${test_name}.... "

    local start_time=$(date +%s)
    LOG DEBUG "Start time: $start_time"

    # Run the test function directly (not in subshell) and check return code
    local test_passed=true
    local test_error=""

    # Temporarily disable errexit for test execution
    LOG DEBUG "Running test function: $test_function"
    set +e
    $test_function
    local exit_code=$?
    set -e
    LOG DEBUG "Test function completed with exit code: $exit_code"

    if [[ $exit_code -eq 0 ]]; then
        test_passed=true
    else
        test_passed=false
        test_error="Test returned exit code $exit_code"
    fi

    local end_time=$(date +%s)
    local duration=$((end_time - start_time))

    if [[ "$test_passed" == "true" ]]; then
        print_color "✓ PASSED" "GREEN"
        PASSED=$((PASSED + 1))
    else
        print_color "✗ FAILED" "RED"
        [[ -n "$test_error" ]] && print_color "  ${test_error}" "GRAY"
        FAILED=$((FAILED + 1))
        FAILED_TESTS+=("$test_name")
    fi

    LOG DEBUG "Test duration: ${duration}s"
}

# Test functions
test_essential_files() {
    local essential_files=(
        "src/neovim/init.lua"
        "src/zsh/zshrc"
        "src/tmux.conf"
        "src/git/gitconfig"
        "src/scripts/fixy"
        "src/theme-switcher/switch-theme.sh"
    )

    for file in "${essential_files[@]}"; do
        local full_path="${DOTFILES_DIR}/${file}"
        if [[ ! -f "$full_path" ]]; then
            LOG DEBUG "Missing: $file"
            return 1
        fi
        if [[ ! -r "$full_path" ]]; then
            LOG DEBUG "Not readable: $file"
            return 1
        fi
    done

    LOG DEBUG "All ${#essential_files[@]} essential files exist and are readable"
    return 0
}

test_neovim_config() {
    local temp_config=$(mktemp)
    cat > "$temp_config" << 'NVIM_TEST_EOF'
-- Minimal test config that loads the main configuration
vim.opt.runtimepath:prepend(vim.fn.expand("~/.dotfiles/src/neovim"))
vim.opt.packpath:prepend(vim.fn.expand("~/.dotfiles/src/neovim"))

local ok, err = pcall(function()
    dofile(vim.fn.expand("~/.dotfiles/src/neovim/init.lua"))
end)

if ok then
    print("CONFIG_OK")
    vim.cmd("qa!")
else
    print("CONFIG_ERROR: " .. tostring(err))
    vim.cmd("cq 1")
end
NVIM_TEST_EOF

    LOG DEBUG "Running: nvim --headless -u $temp_config"
    local output
    # Add timeout to prevent hanging
    if command -v timeout >/dev/null 2>&1; then
        output=$(timeout 3 nvim --headless -u "$temp_config" 2>&1)
    else
        output=$(nvim --headless -u "$temp_config" 2>&1)
    fi
    local exit_code=$?

    rm -f "$temp_config"

    if [[ $exit_code -ne 0 ]] || ! echo "$output" | grep -q "CONFIG_OK"; then
        LOG DEBUG "Neovim config failed to load"
        return 1
    fi

    LOG DEBUG "Neovim configuration loaded successfully"
    return 0
}

test_shell_scripts() {
    local shell_files=()
    while IFS= read -r -d '' file; do
        shell_files+=("$file")
    done < <(find "$DOTFILES_DIR/src" -type f -name "*.sh" -o -name "*.zsh" -print0)

    local errors=()
    for script in "${shell_files[@]}"; do
        local shell="sh"
        if [[ "$script" == *.zsh ]]; then
            shell="zsh"
        elif head -1 "$script" 2>/dev/null | grep -q "bash"; then
            shell="bash"
        elif head -1 "$script" 2>/dev/null | grep -q "zsh"; then
            shell="zsh"
        fi

        LOG DEBUG "Checking syntax: $script (with $shell)"
        if ! $shell -n "$script" 2>/dev/null; then
            errors+=("$(basename "$script")")
        fi
    done

    if [[ ${#errors[@]} -gt 0 ]]; then
        LOG DEBUG "Syntax errors in: ${errors[*]}"
        return 1
    fi

    LOG DEBUG "Checked ${#shell_files[@]} shell scripts"
    return 0
}

test_language_configs() {
    local configs=(
        "src/language/ruff.toml"
        "src/language/stylua.toml"
        "src/language/.clang-format"
        "src/language/pyproject.toml"
    )

    for config in "${configs[@]}"; do
        local full_path="${DOTFILES_DIR}/${config}"
        if [[ ! -f "$full_path" ]]; then
            LOG DEBUG "Missing config: $config"
            return 1
        fi
    done

    # Test Python config
    if command -v python3 >/dev/null 2>&1; then
        if ! python3 -c "import tomllib; tomllib.load(open('${DOTFILES_DIR}/src/language/ruff.toml', 'rb'))" 2>/dev/null; then
            LOG DEBUG "Invalid ruff.toml"
            return 1
        fi
    fi

    LOG DEBUG "All language configurations are valid"
    return 0
}

test_theme_switcher() {
    local switcher="${DOTFILES_DIR}/src/theme-switcher/switch-theme.sh"
    if [[ ! -x "$switcher" ]]; then
        LOG DEBUG "Theme switcher not executable"
        return 1
    fi

    # Run from theme-switcher directory
    local output
    output=$(cd "$(dirname "$switcher")" && ./switch-theme.sh --list 2>&1)
    local exit_code=$?

    if [[ $exit_code -ne 0 ]]; then
        LOG DEBUG "Failed to list themes"
        return 1
    fi

    local themes=("tokyonight_day" "tokyonight_storm" "tokyonight_night" "tokyonight_moon")
    for theme in "${themes[@]}"; do
        if ! echo "$output" | grep -q "$theme"; then
            LOG DEBUG "Missing theme: $theme"
            return 1
        fi
    done

    LOG DEBUG "All themes available"
    return 0
}

test_symlinks() {
    local symlinks_script="${DOTFILES_DIR}/src/setup/symlinks.sh"
    if [[ ! -x "$symlinks_script" ]]; then
        LOG DEBUG "Symlinks script not executable"
        return 1
    fi

    # Test dry run
    LOG DEBUG "Running: $symlinks_script --dry-run"
    if ! bash "$symlinks_script" --dry-run >/dev/null 2>&1; then
        LOG DEBUG "Symlinks script dry-run failed"
        return 1
    fi

    LOG DEBUG "Symlinks script validated"
    return 0
}

test_critical_commands() {
    local commands=(
        "${DOTFILES_DIR}/src/scripts/theme:--help"
        "${DOTFILES_DIR}/src/scripts/fixy:--help"
    )

    for cmd_spec in "${commands[@]}"; do
        local cmd="${cmd_spec%%:*}"
        local arg="${cmd_spec#*:}"

        if [[ ! -x "$cmd" ]]; then
            LOG DEBUG "Command not executable: $(basename "$cmd")"
            return 1
        fi

        LOG DEBUG "Testing: $cmd $arg"
        if ! "$cmd" "$arg" >/dev/null 2>&1; then
            LOG DEBUG "Command failed: $(basename "$cmd")"
            return 1
        fi
    done

    LOG DEBUG "All critical commands work"
    return 0
}

test_git_hooks() {
    # Check if gitleaks is available
    if ! command -v gitleaks >/dev/null 2>&1; then
        if [[ "$CI_MODE" == "true" ]]; then
            LOG DEBUG "Gitleaks not installed (CI mode)"
            return 0  # Skip in CI
        else
            LOG DEBUG "Gitleaks not installed"
            return 1
        fi
    fi

    # Check gitleaks config exists
    if [[ ! -f "${DOTFILES_DIR}/src/gitleaks.toml" ]] && [[ ! -f "${DOTFILES_DIR}/.gitleaks.toml" ]]; then
        LOG DEBUG "Gitleaks config not found"
        return 1
    fi

    LOG DEBUG "Git security hooks configured"
    return 0
}

test_neovim_startup() {
    local startup_log="${ARTIFACTS_DIR}/nvim-startup.log"

    LOG DEBUG "Running: nvim --headless --startuptime $startup_log -c qa"
    nvim --headless --startuptime "$startup_log" -c qa 2>/dev/null

    if [[ ! -f "$startup_log" ]]; then
        LOG DEBUG "Failed to generate startup log"
        return 1
    fi

    # Parse startup time
    local total_time
    total_time=$(grep "^[0-9]" "$startup_log" | tail -1 | awk '{print $1}')

    if [[ -z "$total_time" ]]; then
        LOG DEBUG "Could not parse startup time"
        return 1
    fi

    # Convert to integer for comparison (remove decimal)
    local time_ms=${total_time%.*}

    LOG DEBUG "Neovim startup time: ${time_ms}ms"

    if [[ $time_ms -gt 500 ]]; then
        LOG DEBUG "Startup too slow: ${time_ms}ms (>500ms)"
        return 1
    elif [[ $time_ms -gt 300 ]]; then
        LOG DEBUG "Startup acceptable but could be improved: ${time_ms}ms"
    else
        LOG DEBUG "Excellent startup time: ${time_ms}ms"
    fi

    return 0
}

# Generate JSON report
generate_json_report() {
    local report_file="${ARTIFACTS_DIR}/test-report-${TIMESTAMP}.json"
    local total=$((PASSED + FAILED + SKIPPED))
    local duration=$(date +%s.%N)

    cat > "$report_file" << EOF
{
  "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "summary": {
    "total": $total,
    "passed": $PASSED,
    "failed": $FAILED,
    "skipped": $SKIPPED
  },
  "failed_tests": [$(printf '"%s",' "${FAILED_TESTS[@]}" | sed 's/,$//')],
  "environment": {
    "os": "$(uname -s)",
    "arch": "$(uname -m)",
    "ci": $([[ "$CI_MODE" == "true" ]] && echo "true" || echo "false")
  }
}
EOF

    print_color "Report saved to: $report_file" "GRAY"
}

# Print summary
print_summary() {
    local total=$((PASSED + FAILED + SKIPPED))

    echo
    print_color "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" "BLUE"
    print_color "Test Summary" "WHITE" "BOLD"
    print_color "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" "BLUE"
    echo "  $(print_color_inline "Passed:" "GREEN")  $PASSED"
    echo "  $(print_color_inline "Failed:" "RED")  $FAILED"
    echo "  $(print_color_inline "Skipped:" "YELLOW") $SKIPPED"
    echo "  $(print_color_inline "Total:" "CYAN")   $total"

    if [[ $FAILED -eq 0 ]]; then
        echo
        print_color "✓ All tests passed!" "GREEN" "BOLD"
    else
        echo
        print_color "✗ ${FAILED} test(s) failed" "RED" "BOLD"
        echo
        print_color "Failed tests:" "RED"
        for test in "${FAILED_TESTS[@]}"; do
            echo "  • $test"
        done
    fi
}

# Main function to run tests
main() {
    # Setup CLI parser
    cli_program "test-runner" "Dotfiles test suite runner" "1.0.0"
    cli_flag "debug" "d" "Enable debug output" "" "bool"
    cli_flag "log-level" "l" "Set log level" "INFO" "string"
    cli_flag "ci" "" "Run in CI mode" "" "bool"
    cli_flag "artifacts" "a" "Artifacts directory" "$ARTIFACTS_DIR" "string"

    # Parse arguments
    if ! cli_parse_with_help "$@"; then
        exit $?
    fi

    # Apply settings from CLI
    if cli_has "debug"; then
        SET_LOG_LEVEL DEBUG
    elif cli_has "log-level"; then
        SET_LOG_LEVEL "$(cli_get "log-level")"
    fi

    if cli_has "ci"; then
        CI_MODE=true
    fi

    if cli_has "artifacts"; then
        ARTIFACTS_DIR="$(cli_get "artifacts")"
        mkdir -p "$ARTIFACTS_DIR"
    fi

    # Main test execution
    print_header

    # Core Validation Tests
    print_section "Core Validation"
    run_test "Essential files exist" test_essential_files
    run_test "Neovim configuration loads" test_neovim_config
    run_test "Shell scripts syntax" test_shell_scripts
    run_test "Language configurations" test_language_configs

    # Integration Tests
    echo
    print_section "Integration Tests"
    run_test "Theme switcher functionality" test_theme_switcher
    run_test "Symlinks script validation" test_symlinks
    run_test "Critical commands work" test_critical_commands
    run_test "Git hooks configured" test_git_hooks

    # Performance Tests
    echo
    print_section "Performance Tests"
    run_test "Neovim startup performance" test_neovim_startup

    # Generate report and summary
    generate_json_report
    print_summary

    # Exit with appropriate code
    [[ $FAILED -eq 0 ]] && exit 0 || exit 1
}

# Run main function with all arguments
main "$@"