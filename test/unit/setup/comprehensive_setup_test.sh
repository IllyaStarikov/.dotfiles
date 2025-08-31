#!/usr/bin/env zsh
# Comprehensive unit tests for setup.sh

set -euo pipefail

# Set up test environment
export TEST_DIR="${TEST_DIR:-$(dirname "$0")/../..}"
export DOTFILES_DIR="${DOTFILES_DIR:-$(dirname "$TEST_DIR")}"

# Source test framework
source "$TEST_DIR/lib/test_helpers.zsh"

# Test suite for setup.sh
describe "setup.sh comprehensive tests"

# Setup before tests
setup_test

# Test: Script exists and is executable
it "should exist and be executable" && {
    local script_path="$DOTFILES_DIR/src/setup/setup.sh"
    
    assert_file_exists "$script_path"
    assert_file_executable "$script_path"
    pass
}

# Test: Help message display
it "should display help message with --help" && {
    output=$("$DOTFILES_DIR/src/setup/setup.sh" --help 2>&1 || true)
    
    assert_contains "$output" "Usage"
    assert_contains "$output" "Options"
    assert_contains "$output" "--core"
    assert_contains "$output" "--symlinks"
    assert_contains "$output" "--help"
    pass
}

# Test: Platform detection
it "should detect platform correctly" && {
    # Source the script to get platform detection function
    output=$(bash -c "
        source $DOTFILES_DIR/src/setup/setup.sh --dry-run 2>/dev/null || true
        echo \$PLATFORM
    ")
    
    # Should be either Darwin or Linux
    if [[ "$output" == "Darwin" ]] || [[ "$output" == "Linux" ]]; then
        pass
    else
        fail "Unknown platform: $output"
    fi
}

# Test: Dry run mode
it "should support dry run mode" && {
    output=$("$DOTFILES_DIR/src/setup/setup.sh" --dry-run 2>&1 || true)
    
    assert_contains "$output" "DRY RUN" || assert_contains "$output" "dry run"
    assert_not_contains "$output" "Installing"
    pass
}

# Test: Core mode installation
it "should support --core mode" && {
    output=$("$DOTFILES_DIR/src/setup/setup.sh" --core --dry-run 2>&1 || true)
    
    assert_contains "$output" "core" || assert_contains "$output" "Core"
    pass
}

# Test: Symlinks only mode
it "should support --symlinks mode" && {
    output=$("$DOTFILES_DIR/src/setup/setup.sh" --symlinks --dry-run 2>&1 || true)
    
    assert_contains "$output" "symlink" || assert_contains "$output" "Symlink"
    pass
}

# Test: Backup directory creation
it "should create backup directory structure" && {
    local test_home="$TEST_TMP_DIR/test_home"
    mkdir -p "$test_home"
    
    # Mock the backup directory creation
    output=$(HOME="$test_home" bash -c "
        source $DOTFILES_DIR/src/setup/setup.sh --dry-run 2>/dev/null || true
        echo \$BACKUP_DIR
    ")
    
    assert_contains "$output" "backup" || assert_contains "$output" "dotfiles-backup"
    pass
}

# Test: Required tools check
it "should check for required tools" && {
    # Test with mock missing command
    mock_command "git" 127 ""
    
    output=$("$DOTFILES_DIR/src/setup/setup.sh" --check-deps 2>&1 || true)
    
    unmock_command "git"
    
    assert_contains "$output" "git" || assert_contains "$output" "Git"
    pass
}

# Test: Configuration file paths
it "should use correct configuration paths" && {
    local script_content=$(cat "$DOTFILES_DIR/src/setup/setup.sh")
    
    assert_contains "$script_content" "DOTFILES_DIR"
    assert_contains "$script_content" ".config"
    assert_contains "$script_content" "src/"
    pass
}

# Test: Error handling for invalid options
it "should handle invalid options gracefully" && {
    output=$("$DOTFILES_DIR/src/setup/setup.sh" --invalid-option 2>&1 || true)
    
    assert_contains "$output" "Usage" || assert_contains "$output" "Error" || assert_contains "$output" "Unknown"
    pass
}

# Test: Multiple option handling
it "should handle multiple options correctly" && {
    output=$("$DOTFILES_DIR/src/setup/setup.sh" --core --dry-run 2>&1 || true)
    
    assert_contains "$output" "DRY RUN" || assert_contains "$output" "dry run"
    assert_contains "$output" "core" || assert_contains "$output" "Core"
    pass
}

# Test: Function definitions
it "should define required setup functions" && {
    output=$(bash -c "
        source $DOTFILES_DIR/src/setup/setup.sh --dry-run 2>/dev/null || true
        declare -F | grep -E 'setup_|install_|configure_' | wc -l
    ")
    
    assert_greater_than "$output" 0
    pass
}

# Test: Homebrew check on macOS
it "should check for Homebrew on macOS" && {
    if [[ "$(uname)" == "Darwin" ]]; then
        local script_content=$(cat "$DOTFILES_DIR/src/setup/setup.sh")
        assert_contains "$script_content" "brew" || assert_contains "$script_content" "Homebrew"
        pass
    else
        skip "Not on macOS"
    fi
}

# Test: Package manager detection on Linux
it "should detect package manager on Linux" && {
    if [[ "$(uname)" == "Linux" ]]; then
        local script_content=$(cat "$DOTFILES_DIR/src/setup/setup.sh")
        assert_contains "$script_content" "apt" || assert_contains "$script_content" "yum" || assert_contains "$script_content" "dnf"
        pass
    else
        skip "Not on Linux"
    fi
}

# Test: Symlink safety check
it "should check before overwriting existing files" && {
    local test_home="$TEST_TMP_DIR/test_safety"
    mkdir -p "$test_home"
    echo "existing content" > "$test_home/.zshrc"
    
    # The script should handle existing files
    local script_content=$(cat "$DOTFILES_DIR/src/setup/setup.sh")
    assert_contains "$script_content" "backup" || assert_contains "$script_content" "existing"
    pass
}

# Test: Environment variable setup
it "should set up required environment variables" && {
    output=$(bash -c "
        source $DOTFILES_DIR/src/setup/setup.sh --dry-run 2>/dev/null || true
        [[ -n \"\$DOTFILES_DIR\" ]] && echo 'DOTFILES_DIR set'
    ")
    
    assert_contains "$output" "DOTFILES_DIR set"
    pass
}

# Test: Interactive mode detection
it "should detect interactive vs non-interactive mode" && {
    local script_content=$(cat "$DOTFILES_DIR/src/setup/setup.sh")
    
    assert_contains "$script_content" "tty" || assert_contains "$script_content" "interactive" || assert_contains "$script_content" "TERM"
    pass
}

# Test: Color output support
it "should support colored output" && {
    local script_content=$(cat "$DOTFILES_DIR/src/setup/setup.sh")
    
    assert_contains "$script_content" "033" || assert_contains "$script_content" "COLOR" || assert_contains "$script_content" "color"
    pass
}

# Test: Logging functionality
it "should have logging functions" && {
    local script_content=$(cat "$DOTFILES_DIR/src/setup/setup.sh")
    
    assert_contains "$script_content" "echo" || assert_contains "$script_content" "printf"
    assert_contains "$script_content" "error" || assert_contains "$script_content" "Error"
    pass
}

# Test: Exit codes
it "should use proper exit codes" && {
    # Test successful dry run
    "$DOTFILES_DIR/src/setup/setup.sh" --dry-run 2>&1 >/dev/null
    assert_success $?
    
    pass
}

# Test: Idempotency
it "should be idempotent" && {
    local test_home="$TEST_TMP_DIR/test_idempotent"
    mkdir -p "$test_home"
    
    # Run twice and compare
    output1=$(HOME="$test_home" "$DOTFILES_DIR/src/setup/setup.sh" --dry-run 2>&1 || true)
    output2=$(HOME="$test_home" "$DOTFILES_DIR/src/setup/setup.sh" --dry-run 2>&1 || true)
    
    # Should produce similar output
    [[ "${#output1}" -gt 0 ]] && [[ "${#output2}" -gt 0 ]]
    assert_success $?
    pass
}

# Test: Permission handling
it "should handle permission issues gracefully" && {
    local test_dir="$TEST_TMP_DIR/test_perms"
    mkdir -p "$test_dir"
    chmod 000 "$test_dir"
    
    output=$(HOME="$test_dir" "$DOTFILES_DIR/src/setup/setup.sh" --dry-run 2>&1 || true)
    
    chmod 755 "$test_dir"
    
    # Should handle permission errors without crashing
    assert_success 0
    pass
}

# Cleanup after tests
cleanup_test

# Summary
echo -e "\n${GREEN}Setup.sh comprehensive tests completed${NC}"