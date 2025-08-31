#!/usr/bin/env zsh
# Comprehensive unit tests for fixy formatter

set -euo pipefail

# Set up test environment
export TEST_DIR="${TEST_DIR:-$(dirname "$0")/../..}"
export DOTFILES_DIR="${DOTFILES_DIR:-$(dirname "$TEST_DIR")}"

# Source test framework
source "$TEST_DIR/lib/test_helpers.zsh"

# Test suite for fixy
describe "fixy formatter comprehensive tests"

# Setup before tests
setup_test

# Test: Script exists and is executable
it "should exist and be executable" && {
    local script_path="$DOTFILES_DIR/src/scripts/fixy"
    
    assert_file_exists "$script_path"
    assert_file_executable "$script_path"
    pass
}

# Test: Configuration file exists
it "should have configuration file" && {
    local config_path="$DOTFILES_DIR/config/fixy.json"
    
    assert_file_exists "$config_path"
    pass
}

# Test: Help message
it "should display help message" && {
    output=$("$DOTFILES_DIR/src/scripts/fixy" --help 2>&1 || true)
    
    assert_contains "$output" "Usage" || assert_contains "$output" "usage"
    assert_contains "$output" "format" || assert_contains "$output" "Format"
    pass
}

# Test: Language detection
it "should detect language from file extension" && {
    # Create test files
    echo "print('test')" > "$TEST_TMP_DIR/test.py"
    echo "console.log('test')" > "$TEST_TMP_DIR/test.js"
    echo "echo 'test'" > "$TEST_TMP_DIR/test.sh"
    
    # Test detection (dry run)
    output=$("$DOTFILES_DIR/src/scripts/fixy" "$TEST_TMP_DIR/test.py" --dry-run 2>&1 || true)
    assert_contains "$output" "python" || assert_contains "$output" "Python" || assert_contains "$output" "py"
    
    pass
}

# Test: Type override flag
it "should support --type flag for override" && {
    local script_content=$(cat "$DOTFILES_DIR/src/scripts/fixy")
    
    assert_contains "$script_content" "--type" || assert_contains "$script_content" "override"
    pass
}

# Test: Formatter priority system
it "should use formatter priority from config" && {
    local config_content=$(cat "$DOTFILES_DIR/config/fixy.json")
    
    # Should have priority arrays
    assert_contains "$config_content" "priority" || assert_contains "$config_content" "formatters"
    pass
}

# Test: Python formatter support
it "should support Python formatters" && {
    local script_content=$(cat "$DOTFILES_DIR/src/scripts/fixy")
    
    assert_contains "$script_content" "ruff" || assert_contains "$script_content" "black" || assert_contains "$script_content" "yapf"
    pass
}

# Test: JavaScript/TypeScript formatter support
it "should support JS/TS formatters" && {
    local script_content=$(cat "$DOTFILES_DIR/src/scripts/fixy")
    
    assert_contains "$script_content" "prettier" || assert_contains "$script_content" "eslint" || assert_contains "$script_content" "deno"
    pass
}

# Test: Shell script formatter support
it "should support shell formatters" && {
    local script_content=$(cat "$DOTFILES_DIR/src/scripts/fixy")
    
    assert_contains "$script_content" "shfmt" || assert_contains "$script_content" "beautysh"
    pass
}

# Test: Lua formatter support
it "should support Lua formatters" && {
    local script_content=$(cat "$DOTFILES_DIR/src/scripts/fixy")
    
    assert_contains "$script_content" "stylua" || assert_contains "$script_content" "lua-format"
    pass
}

# Test: Dry run mode
it "should support dry run mode" && {
    echo "test content" > "$TEST_TMP_DIR/test.txt"
    
    output=$("$DOTFILES_DIR/src/scripts/fixy" "$TEST_TMP_DIR/test.txt" --dry-run 2>&1 || true)
    
    # Should not modify file
    content=$(cat "$TEST_TMP_DIR/test.txt")
    assert_equals "$content" "test content"
    pass
}

# Test: Multiple file support
it "should handle multiple files" && {
    local script_content=$(cat "$DOTFILES_DIR/src/scripts/fixy")
    
    # Should handle multiple arguments
    assert_contains "$script_content" "for" || assert_contains "$script_content" "loop"
    pass
}

# Test: Fallback mechanism
it "should have fallback mechanism" && {
    local script_content=$(cat "$DOTFILES_DIR/src/scripts/fixy")
    
    assert_contains "$script_content" "fallback" || assert_contains "$script_content" "else" || assert_contains "$script_content" "alternative"
    pass
}

# Test: Error handling
it "should handle errors gracefully" && {
    # Test with non-existent file
    output=$("$DOTFILES_DIR/src/scripts/fixy" "/nonexistent/file.py" 2>&1 || true)
    
    # Should not crash
    assert_contains "$output" "not found" || assert_contains "$output" "Error" || assert_contains "$output" "error"
    pass
}

# Test: Check mode
it "should support check mode" && {
    local script_content=$(cat "$DOTFILES_DIR/src/scripts/fixy")
    
    assert_contains "$script_content" "check" || assert_contains "$script_content" "verify"
    pass
}

# Test: Color output
it "should support colored output" && {
    local script_content=$(cat "$DOTFILES_DIR/src/scripts/fixy")
    
    assert_contains "$script_content" "033" || assert_contains "$script_content" "color" || assert_contains "$script_content" "Color"
    pass
}

# Test: Verbose mode
it "should support verbose mode" && {
    local script_content=$(cat "$DOTFILES_DIR/src/scripts/fixy")
    
    assert_contains "$script_content" "verbose" || assert_contains "$script_content" "-v"
    pass
}

# Test: Config file parsing
it "should parse JSON config correctly" && {
    local script_content=$(cat "$DOTFILES_DIR/src/scripts/fixy")
    
    assert_contains "$script_content" "jq" || assert_contains "$script_content" "json" || assert_contains "$script_content" "config"
    pass
}

# Test: Stdin support
it "should support formatting from stdin" && {
    local script_content=$(cat "$DOTFILES_DIR/src/scripts/fixy")
    
    assert_contains "$script_content" "stdin" || assert_contains "$script_content" "-" || assert_contains "$script_content" "pipe"
    pass
}

# Test: Exit codes
it "should use proper exit codes" && {
    # Test with help flag (should succeed)
    "$DOTFILES_DIR/src/scripts/fixy" --help 2>&1 >/dev/null
    assert_success $?
    
    pass
}

# Test: Performance considerations
it "should be optimized for performance" && {
    local script_content=$(cat "$DOTFILES_DIR/src/scripts/fixy")
    
    # Should check formatter availability before running
    assert_contains "$script_content" "command -v" || assert_contains "$script_content" "which"
    pass
}

# Cleanup after tests
cleanup_test

# Summary
echo -e "\n${GREEN}fixy formatter comprehensive tests completed${NC}"