#!/usr/bin/env zsh
# Unit tests for library utilities

# Get the test directory path
TEST_DIR="$(cd "$(dirname "$(dirname "$(dirname "$0")")")" && pwd)"
DOTFILES_DIR="$(dirname "$TEST_DIR")"

# Test framework
source "${TEST_DIR}/lib/test_helpers.zsh"

# Test colors.zsh library exists and exports colors
test_colors_library() {
  local colors_lib="${DOTFILES_DIR}/src/lib/colors.zsh"

  assert_file_exists "$colors_lib" "Colors library should exist"

  # Check that the library defines color variables by checking the file content
  assert_file_contains "$colors_lib" "RED=" "Should define RED color"
  assert_file_contains "$colors_lib" "GREEN=" "Should define GREEN color"
  assert_file_contains "$colors_lib" "BLUE=" "Should define BLUE color"
  assert_file_contains "$colors_lib" "NC=" "Should define NC (no color)"
}

# Test colors.zsh handles non-terminal output
test_colors_no_terminal() {
  local colors_lib="${DOTFILES_DIR}/src/lib/colors.zsh"

  # Check that the library has terminal detection logic
  assert_file_contains "$colors_lib" "tty\|-t" "Should check for terminal output"
}

# Test library has proper shell directives
test_library_shell_safety() {
  local colors_lib="${DOTFILES_DIR}/src/lib/colors.zsh"

  # Check for proper shebang or sourcing protection
  local first_line=$(head -1 "$colors_lib")

  if [[ ! "$first_line" =~ ^#!/ ]] && [[ ! "$first_line" =~ ^# ]]; then
    fail "Library should start with shebang or comment"
  fi
}

# Test library documentation
test_library_documentation() {
  local colors_lib="${DOTFILES_DIR}/src/lib/colors.zsh"

  # Check for documentation comments
  assert_file_contains "$colors_lib" "#.*[Cc]olor" "Library should have color documentation"
}

# Run all tests
test_suite "Library Utilities" \
  test_colors_library \
  test_colors_no_terminal \
  test_library_shell_safety \
  test_library_documentation
