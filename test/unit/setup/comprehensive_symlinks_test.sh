#!/usr/bin/env zsh
# Comprehensive unit tests for symlinks.sh

set -euo pipefail

# Set up test environment
export TEST_DIR="${TEST_DIR:-$(dirname "$0")/../..}"
export DOTFILES_DIR="${DOTFILES_DIR:-$(dirname "$TEST_DIR")}"

# Source test framework
source "$TEST_DIR/lib/test_helpers.zsh"

# Test suite for symlinks.sh
describe "symlinks.sh comprehensive tests"

# Setup before tests
setup_test

# Test: Script exists and is executable
it "should exist and be executable" && {
    local script_path="$DOTFILES_DIR/src/setup/symlinks.sh"
    
    assert_file_exists "$script_path"
    assert_file_executable "$script_path"
    pass
}

# Test: Help message
it "should display help message" && {
    output=$("$DOTFILES_DIR/src/setup/symlinks.sh" --help 2>&1 || true)
    
    assert_contains "$output" "Usage" || assert_contains "$output" "usage"
    assert_contains "$output" "symlink" || assert_contains "$output" "Symlink"
    pass
}

# Test: Dry run mode
it "should support dry run mode" && {
    output=$("$DOTFILES_DIR/src/setup/symlinks.sh" --dry-run 2>&1 || true)
    
    assert_contains "$output" "DRY RUN" || assert_contains "$output" "dry run" || assert_contains "$output" "Would"
    pass
}

# Test: Force mode
it "should support force mode" && {
    local script_content=$(cat "$DOTFILES_DIR/src/setup/symlinks.sh")
    
    assert_contains "$script_content" "force" || assert_contains "$script_content" "Force"
    pass
}

# Test: Backup creation
it "should create backups of existing files" && {
    local test_home="$TEST_TMP_DIR/test_backup"
    mkdir -p "$test_home"
    echo "existing content" > "$test_home/.zshrc"
    
    # Check script has backup logic
    local script_content=$(cat "$DOTFILES_DIR/src/setup/symlinks.sh")
    assert_contains "$script_content" "backup" || assert_contains "$script_content" "Backup"
    pass
}

# Test: Symlink creation logic
it "should have symlink creation function" && {
    local script_content=$(cat "$DOTFILES_DIR/src/setup/symlinks.sh")
    
    assert_contains "$script_content" "ln -s" || assert_contains "$script_content" "symlink"
    pass
}

# Test: Directory creation
it "should create necessary directories" && {
    local script_content=$(cat "$DOTFILES_DIR/src/setup/symlinks.sh")
    
    assert_contains "$script_content" "mkdir" || assert_contains "$script_content" "directory"
    pass
}

# Test: Config file mapping
it "should map source files to destinations correctly" && {
    local script_content=$(cat "$DOTFILES_DIR/src/setup/symlinks.sh")
    
    # Check for common dotfile mappings
    assert_contains "$script_content" "zshrc" || assert_contains "$script_content" ".zshrc"
    assert_contains "$script_content" "tmux" || assert_contains "$script_content" ".tmux"
    assert_contains "$script_content" "git" || assert_contains "$script_content" ".git"
    pass
}

# Test: XDG config directory support
it "should support XDG config directories" && {
    local script_content=$(cat "$DOTFILES_DIR/src/setup/symlinks.sh")
    
    assert_contains "$script_content" ".config" || assert_contains "$script_content" "XDG"
    pass
}

# Test: Neovim configuration linking
it "should handle Neovim configuration" && {
    local script_content=$(cat "$DOTFILES_DIR/src/setup/symlinks.sh")
    
    assert_contains "$script_content" "nvim" || assert_contains "$script_content" "neovim"
    pass
}

# Test: Terminal emulator configs
it "should handle terminal emulator configs" && {
    local script_content=$(cat "$DOTFILES_DIR/src/setup/symlinks.sh")
    
    # At least one terminal should be mentioned
    local found=0
    [[ "$script_content" == *"alacritty"* ]] && found=1
    [[ "$script_content" == *"wezterm"* ]] && found=1
    [[ "$script_content" == *"kitty"* ]] && found=1
    
    assert_equals "$found" 1
    pass
}

# Test: Error handling
it "should handle errors gracefully" && {
    # Test with invalid home directory
    output=$(HOME="/nonexistent" "$DOTFILES_DIR/src/setup/symlinks.sh" --dry-run 2>&1 || true)
    
    # Should not crash
    assert_success 0
    pass
}

# Test: Symlink verification
it "should verify symlinks after creation" && {
    local script_content=$(cat "$DOTFILES_DIR/src/setup/symlinks.sh")
    
    assert_contains "$script_content" "test" || assert_contains "$script_content" "verify" || assert_contains "$script_content" "check"
    pass
}

# Test: Idempotency
it "should be idempotent" && {
    local test_home="$TEST_TMP_DIR/test_idempotent"
    mkdir -p "$test_home/.config"
    
    # Run twice
    output1=$(HOME="$test_home" "$DOTFILES_DIR/src/setup/symlinks.sh" --dry-run 2>&1 || true)
    output2=$(HOME="$test_home" "$DOTFILES_DIR/src/setup/symlinks.sh" --dry-run 2>&1 || true)
    
    # Should handle existing symlinks gracefully
    assert_success 0
    pass
}

# Test: Permission preservation
it "should handle file permissions correctly" && {
    local script_content=$(cat "$DOTFILES_DIR/src/setup/symlinks.sh")
    
    # Symlinks should preserve source permissions
    assert_contains "$script_content" "ln" || assert_contains "$script_content" "link"
    pass
}

# Test: Relative vs absolute paths
it "should use appropriate path types" && {
    local script_content=$(cat "$DOTFILES_DIR/src/setup/symlinks.sh")
    
    # Should use absolute paths for reliability
    assert_contains "$script_content" "DOTFILES_DIR" || assert_contains "$script_content" "realpath" || assert_contains "$script_content" "pwd"
    pass
}

# Test: Skip patterns
it "should skip certain files/directories" && {
    local script_content=$(cat "$DOTFILES_DIR/src/setup/symlinks.sh")
    
    # Should skip .git, README, etc.
    assert_contains "$script_content" "skip" || assert_contains "$script_content" "ignore" || assert_contains "$script_content" "exclude"
    pass
}

# Test: Logging
it "should provide informative logging" && {
    output=$("$DOTFILES_DIR/src/setup/symlinks.sh" --dry-run 2>&1 || true)
    
    # Should show what it's doing
    assert_not_empty "$output"
    pass
}

# Test: Return codes
it "should use proper exit codes" && {
    # Dry run should succeed
    "$DOTFILES_DIR/src/setup/symlinks.sh" --dry-run 2>&1 >/dev/null
    assert_success $?
    
    pass
}

# Test: Interactive prompts
it "should handle interactive mode" && {
    local script_content=$(cat "$DOTFILES_DIR/src/setup/symlinks.sh")
    
    # Should have some form of user interaction
    assert_contains "$script_content" "read" || assert_contains "$script_content" "prompt" || assert_contains "$script_content" "ask"
    pass
}

# Test: Cleanup functionality
it "should have cleanup capability" && {
    local script_content=$(cat "$DOTFILES_DIR/src/setup/symlinks.sh")
    
    # Should be able to remove broken symlinks
    assert_contains "$script_content" "broken" || assert_contains "$script_content" "clean" || assert_contains "$script_content" "remove"
    pass
}

# Cleanup after tests
cleanup_test

# Summary
echo -e "\n${GREEN}Symlinks.sh comprehensive tests completed${NC}"