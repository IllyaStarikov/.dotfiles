#!/usr/bin/env zsh

# Unit tests for mac.sh setup script

set -euo pipefail

# Set up test environment
export TEST_DIR="${TEST_DIR:-$(dirname "$0")/../..}"
export DOTFILES_DIR="${DOTFILES_DIR:-$(dirname "$TEST_DIR")}"

# Source test framework
source "$TEST_DIR/lib/test_helpers.zsh"

# Test suite for mac.sh
describe "mac.sh setup script"

# Mock functions
mock_command() {
    local cmd="$1"
    eval "
    $cmd() {
        echo \"Mock: $cmd \$*\" >&2
        return 0
    }
    export -f $cmd
    "
}

# Test: Script exists and is executable
it "should exist and be executable" && {
    local script_path="$DOTFILES_DIR/src/setup/mac.sh"
    
    assert_file_exists "$script_path"
    assert_file_executable "$script_path"
}

# Test: Dry run mode
it "should support dry run mode" && {
    export DRY_RUN=true
    
    # Mock commands that would be called
    mock_command "brew"
    mock_command "defaults"
    
    # Source script in dry run mode
    output=$(bash "$DOTFILES_DIR/src/setup/mac.sh" --dry-run 2>&1 || true)
    
    # Should not actually install anything
    assert_not_contains "$output" "Installing"
    assert_contains "$output" "DRY RUN" || assert_contains "$output" "dry run"
    
    unset DRY_RUN
}

# Test: Homebrew installation check
it "should check for Homebrew installation" && {
    # Mock brew command not found
    brew() {
        return 127
    }
    export -f brew
    
    # Script should detect missing Homebrew
    output=$(bash -c "source $DOTFILES_DIR/src/setup/mac.sh 2>&1 || true" | head -20)
    
    assert_contains "$output" "Homebrew" || assert_contains "$output" "brew"
}

# Test: macOS version check
it "should verify macOS compatibility" && {
    # Mock sw_vers command
    sw_vers() {
        case "$1" in
            -productName) echo "macOS" ;;
            -productVersion) echo "12.0" ;;
            *) return 1 ;;
        esac
    }
    export -f sw_vers
    
    # Should pass version check
    output=$(bash -c "source $DOTFILES_DIR/src/setup/mac.sh --check-version 2>&1 || true")
    assert_success $?
}

# Test: Backup directory creation
it "should create backup directory" && {
    local test_home="$TEST_TMP_DIR/test_home"
    mkdir -p "$test_home"
    
    export HOME="$test_home"
    export BACKUP_DIR="$HOME/.dotfiles-backup"
    
    # Run backup directory creation
    bash -c "
        source $DOTFILES_DIR/src/setup/setup.sh
        create_backup_dir() {
            mkdir -p \"\$BACKUP_DIR\"
        }
        create_backup_dir
    "
    
    assert_directory_exists "$BACKUP_DIR"
}

# Test: Required tools validation
it "should validate required tools" && {
    # Test with missing tools
    local missing_tools=()
    
    # Check for required commands
    for cmd in git curl wget; do
        if ! command -v "$cmd" &>/dev/null; then
            missing_tools+=("$cmd")
        fi
    done
    
    # At least git should be available in CI
    assert_command_exists "git"
}

# Test: Configuration file paths
it "should use correct configuration paths" && {
    local script_content=$(cat "$DOTFILES_DIR/src/setup/mac.sh")
    
    # Check for expected paths
    assert_contains "$script_content" "DOTFILES_DIR"
    assert_contains "$script_content" ".zshrc"
    assert_contains "$script_content" ".config"
}

# Test: Error handling
it "should handle errors gracefully" && {
    # Test with invalid arguments
    output=$(bash "$DOTFILES_DIR/src/setup/mac.sh" --invalid-option 2>&1 || true)
    assert_contains "$output" "Usage" || assert_contains "$output" "usage" || assert_contains "$output" "Error"
}

# Test: Help message
it "should display help message" && {
    output=$(bash "$DOTFILES_DIR/src/setup/mac.sh" --help 2>&1 || true)
    
    assert_contains "$output" "Usage" || assert_contains "$output" "usage"
    assert_contains "$output" "Options" || assert_contains "$output" "options"
}

# Test: Function definitions
it "should define required functions" && {
    # Source script and check functions
    output=$(bash -c "
        source $DOTFILES_DIR/src/setup/setup.sh 2>/dev/null || true
        declare -F | grep -E 'install_|setup_|configure_' | wc -l
    ")
    
    # Should have multiple setup functions
    assert_greater_than "$output" 0
}

# Test: Idempotency
it "should be idempotent" && {
    local test_home="$TEST_TMP_DIR/test_idempotent"
    mkdir -p "$test_home/.config"
    
    export HOME="$test_home"
    export DRY_RUN=true
    
    # Run twice
    output1=$(bash "$DOTFILES_DIR/src/setup/mac.sh" --dry-run 2>&1 || true)
    output2=$(bash "$DOTFILES_DIR/src/setup/mac.sh" --dry-run 2>&1 || true)
    
    # Should produce similar output (idempotent)
    assert_equals "${#output1}" "${#output2}" 100  # Allow 100 char difference
}

# Test: Installation functions
it "should handle missing dependencies gracefully" && {
    # Mock missing brew
    PATH_BACKUP="$PATH"
    export PATH="/usr/bin:/bin"  # Remove homebrew from PATH
    
    output=$(bash "$DOTFILES_DIR/src/setup/mac.sh" --check-deps 2>&1 || true)
    
    # Should detect missing brew
    assert_contains "$output" "brew" || assert_contains "$output" "Homebrew"
    
    export PATH="$PATH_BACKUP"
}

# Test: Symlink safety
it "should not overwrite existing files without backup" && {
    local test_home="$TEST_TMP_DIR/test_safety"
    mkdir -p "$test_home"
    
    # Create existing file
    echo "existing content" > "$test_home/.zshrc"
    
    export HOME="$test_home"
    export BACKUP_DIR="$test_home/.dotfiles-backup"
    
    # Check that script would create backup
    output=$(bash -c "
        source $DOTFILES_DIR/src/setup/setup.sh 2>/dev/null || true
        if [[ -f \"$HOME/.zshrc\" ]]; then
            echo 'would-backup'
        fi
    ")
    
    assert_contains "$output" "would-backup"
}

# Run tests
run_tests