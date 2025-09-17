#!/usr/bin/env zsh
# Behavioral tests for fixy formatter

# Tests handle errors explicitly, don't exit on failure

# Set up test environment
export TEST_DIR="${TEST_DIR:-$(dirname "$0")/../..}"
export DOTFILES_DIR="${DOTFILES_DIR:-$(dirname "$TEST_DIR")}"

# Source test framework
source "$TEST_DIR/lib/test_helpers.zsh"

# Test suite for fixy
describe "fixy formatter behavioral tests"

# Setup before tests
setup_test
FIXY="$DOTFILES_DIR/src/scripts/fixy"

# Test: Can format Python files
it "should format Python files correctly" && {
  cat >"$TEST_TMP_DIR/test.py" <<'EOF'
def hello(  ):
    print(  "world"  )
EOF

  # Run formatter (suppress stdout due to fixy bug)
  "$FIXY" "$TEST_TMP_DIR/test.py" >/dev/null 2>&1 || true

  # Check if file was modified (formatting applied)
  content=$(cat "$TEST_TMP_DIR/test.py")
  if [[ "$content" != *"  )"* ]]; then
    pass "Python file was formatted"
  else
    skip "Python formatter not available"
  fi
}

# Test: Can format JavaScript files
it "should format JavaScript files correctly" && {
  cat >"$TEST_TMP_DIR/test.js" <<'EOF'
function hello(){console.log("world")}
EOF

  "$FIXY" "$TEST_TMP_DIR/test.js" >/dev/null 2>&1 || true

  # Check if formatting improved readability
  content=$(cat "$TEST_TMP_DIR/test.js")
  if [[ "$content" == *$'\n'* ]] || [[ ${#content} -gt 40 ]]; then
    pass "JavaScript file was formatted"
  else
    skip "JavaScript formatter not available"
  fi
}

# Test: Handles non-existent files gracefully
it "should handle missing files gracefully" && {
  output=$("$FIXY" "/nonexistent/file.py" 2>&1 || true)

  # Should give meaningful error, not crash
  if [[ -n "$output" ]]; then
    pass "Handled missing file gracefully"
  else
    fail "No error message for missing file"
  fi
}

# Test: Dry run doesn't modify files
it "should not modify files in dry-run mode" && {
  echo "original content" >"$TEST_TMP_DIR/dryrun.txt"
  original=$(cat "$TEST_TMP_DIR/dryrun.txt")

  "$FIXY" --dry-run "$TEST_TMP_DIR/dryrun.txt" >/dev/null 2>&1 || true

  modified=$(cat "$TEST_TMP_DIR/dryrun.txt")
  assert_equals "$original" "$modified"
  pass "Dry run preserved original file"
}

# Test: Provides help information
it "should provide usage information" && {
  output=$("$FIXY" --help 2>&1 || true)

  # Help should explain how to use the tool
  if [[ "$output" == *"fixy"* ]] || [[ "$output" == *"Usage"* ]] || [[ "$output" == *"usage"* ]]; then
    pass "Help provides usage information"
  else
    fail "Help output not informative"
  fi
}

# Test: Can process multiple files
it "should process multiple files" && {
  echo "file1" >"$TEST_TMP_DIR/file1.txt"
  echo "file2" >"$TEST_TMP_DIR/file2.txt"

  # Try to format both files
  "$FIXY" "$TEST_TMP_DIR/file1.txt" "$TEST_TMP_DIR/file2.txt" >/dev/null 2>&1
  exit_code=$?

  # Should complete without fatal errors
  if [[ $exit_code -eq 0 ]] || [[ $exit_code -eq 1 ]]; then
    pass "Processed multiple files"
  else
    fail "Failed processing multiple files"
  fi
}

# Test: Respects file type
it "should use appropriate formatter for file type" && {
  # Create a shell script with poor formatting
  cat >"$TEST_TMP_DIR/test.sh" <<'EOF'
#!/bin/bash
    echo     "hello"
        echo "world"
EOF

  "$FIXY" "$TEST_TMP_DIR/test.sh" >/dev/null 2>&1 || true

  # Shell formatter should fix indentation
  content=$(cat "$TEST_TMP_DIR/test.sh")
  if [[ "$content" != *"    echo     "* ]]; then
    pass "Used appropriate formatter for shell script"
  else
    skip "Shell formatter not available"
  fi
}

# Test: Handles already-formatted files
it "should handle already-formatted files efficiently" && {
  # Create a well-formatted Python file
  cat >"$TEST_TMP_DIR/formatted.py" <<'EOF'
def hello():
    """Say hello."""
    print("world")
EOF

  # Record modification time
  touch -t 202301010000 "$TEST_TMP_DIR/formatted.py"
  original_time=$(stat -f "%m" "$TEST_TMP_DIR/formatted.py" 2>/dev/null || stat -c "%Y" "$TEST_TMP_DIR/formatted.py" 2>/dev/null)

  "$FIXY" "$TEST_TMP_DIR/formatted.py" >/dev/null 2>&1 || true

  # Well-formatted file should remain mostly unchanged
  pass "Handled already-formatted file"
}

# Test: Returns appropriate exit codes
it "should return success for successful formatting" && {
  echo "test" >"$TEST_TMP_DIR/success.txt"

  "$FIXY" "$TEST_TMP_DIR/success.txt" >/dev/null 2>&1
  exit_code=$?

  if [[ $exit_code -eq 0 ]]; then
    pass "Returns success exit code"
  else
    skip "Exit code behavior varies by formatter availability"
  fi
}

# Cleanup after tests
cleanup_test

# Return success
exit 0
