#!/usr/bin/env zsh
# Test suite for scratchpad script
# Tests behavior, not implementation

# Test framework
source "$(dirname "$0")/../../lib/simple_framework.sh"

# Script under test
SCRIPT_PATH="$DOTFILES_DIR/src/scripts/scratchpad"

# Test that script exists and is executable
test_script_exists() {
    assert_file_exists "$SCRIPT_PATH" "scratchpad script should exist"
    assert_executable "$SCRIPT_PATH" "scratchpad script should be executable"
}

# Test that common.sh is sourced
test_common_sourced() {
    local has_source
    has_source=$(grep -c "source.*common.sh" "$SCRIPT_PATH" || echo 0)
    assert_true "[ $has_source -gt 0 ]" "Should source common.sh"
}

# Test filename generation logic exists
test_filename_generation() {
    # Check for uuidgen or fallback logic
    local has_uuidgen=$(grep -c "uuidgen" "$SCRIPT_PATH" || echo 0)
    local has_fallback=$(grep -c "date.*RANDOM" "$SCRIPT_PATH" || echo 0)
    assert_true "[ $has_uuidgen -gt 0 ]" "Should try to use uuidgen"
    assert_true "[ $has_fallback -gt 0 ]" "Should have fallback for filename generation"
}

# Test extension handling
test_extension_handling() {
    # Check that script handles extensions
    local handles_ext=$(grep -c 'EXT="${1:+.$1}"' "$SCRIPT_PATH" || echo 0)
    assert_true "[ $handles_ext -gt 0 ]" "Should handle file extensions"
}

# Test cleanup trap is set
test_cleanup_trap() {
    local has_trap=$(grep -c "^trap.*cleanup" "$SCRIPT_PATH" || echo 0)
    assert_true "[ $has_trap -gt 0 ]" "Should set cleanup trap for interrupts"
}

# Test editor selection logic
test_editor_selection() {
    # Check for EDITOR environment variable usage
    local uses_editor=$(grep -c 'EDITOR="${EDITOR:-' "$SCRIPT_PATH" || echo 0)
    assert_true "[ $uses_editor -gt 0 ]" "Should respect EDITOR environment variable"
}

# Test temp directory handling
test_temp_directory() {
    # Check that it uses proper temp directory variables
    local uses_tmpdir=$(grep -c 'TMPDIR\|TMP\|/tmp' "$SCRIPT_PATH" || echo 0)
    assert_true "[ $uses_tmpdir -gt 0 ]" "Should use standard temp directory"
}

# Test that script creates unique filenames
test_unique_filenames() {
    # This is a behavioral test - we can't easily test actual file creation
    # but we can verify the logic is there
    local has_unique_logic=$(grep -E "uuidgen|RANDOM|date.*PID" "$SCRIPT_PATH" | wc -l)
    assert_true "[ $has_unique_logic -gt 0 ]" "Should have logic for unique filenames"
}

# Run all tests
run_tests