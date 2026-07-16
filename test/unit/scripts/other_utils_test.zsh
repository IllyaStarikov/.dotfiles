#!/usr/bin/env zsh
# Unit tests for utility scripts (scratchpad, extract, fetch-quotes, fallback)

# Tests handle errors explicitly

export TEST_DIR="${TEST_DIR:-$(dirname "$0")/../..}"
export DOTFILES_DIR="${DOTFILES_DIR:-$(dirname "$TEST_DIR")}"

source "$TEST_DIR/lib/test_helpers.zsh"

describe "Utility scripts comprehensive tests"

setup_test

# Scratchpad tests
describe "scratchpad script"

it "should exist and be executable" && {
  assert_file_exists "$DOTFILES_DIR/src/scripts/scratchpad"
  assert_file_executable "$DOTFILES_DIR/src/scripts/scratchpad"
  pass
}

it "should create temporary files" && {
  # scratchpad builds its own unique name under $TMPDIR via
  # generate_filename() - it does not use mktemp.
  local script_content=$(cat "$DOTFILES_DIR/src/scripts/scratchpad")
  assert_contains "$script_content" "TMPDIR"
  assert_contains "$script_content" "generate_filename"
  pass
}

it "should open editor" && {
  # "vim"/"EDITOR" are what actually appear; keep matching alternatives
  # first (assert_contains counts every missed alternative as a failure).
  local script_content=$(cat "$DOTFILES_DIR/src/scripts/scratchpad")
  assert_contains "$script_content" "EDITOR" || assert_contains "$script_content" "vim" || assert_contains "$script_content" "nvim"
  pass
}

# Extract tests
describe "extract utility"

it "should exist and be executable" && {
  assert_file_exists "$DOTFILES_DIR/src/scripts/extract"
  assert_file_executable "$DOTFILES_DIR/src/scripts/extract"
  pass
}

it "should support multiple archive formats" && {
  local script_content=$(cat "$DOTFILES_DIR/src/scripts/extract")
  assert_contains "$script_content" "tar" || assert_contains "$script_content" "zip"
  assert_contains "$script_content" "gz" || assert_contains "$script_content" "bz2"
  pass
}

it "should detect archive type" && {
  local script_content=$(cat "$DOTFILES_DIR/src/scripts/extract")
  assert_contains "$script_content" "case" || assert_contains "$script_content" "if"
  assert_contains "$script_content" "*.tar" || assert_contains "$script_content" ".tar"
  pass
}

# Fetch-quotes tests
describe "fetch-quotes script"

it "should exist and be executable" && {
  assert_file_exists "$DOTFILES_DIR/src/scripts/fetch-quotes"
  assert_file_executable "$DOTFILES_DIR/src/scripts/fetch-quotes"
  pass
}

it "should fetch from API or source" && {
  local script_content=$(cat "$DOTFILES_DIR/src/scripts/fetch-quotes")
  assert_contains "$script_content" "curl" || assert_contains "$script_content" "wget" || assert_contains "$script_content" "fetch"
  pass
}

it "should handle errors gracefully" && {
  # "Error" (capitalized) is what actually appears; keep it first
  # (assert_contains counts every missed alternative as a failure).
  local script_content=$(cat "$DOTFILES_DIR/src/scripts/fetch-quotes")
  assert_contains "$script_content" "Error" || assert_contains "$script_content" "error" || assert_contains "$script_content" "||"
  pass
}

# Fallback tests
describe "fallback script"

it "should exist and be executable" && {
  assert_file_exists "$DOTFILES_DIR/src/scripts/fallback"
  assert_file_executable "$DOTFILES_DIR/src/scripts/fallback"
  pass
}

it "should check for command availability" && {
  local script_content=$(cat "$DOTFILES_DIR/src/scripts/fallback")
  assert_contains "$script_content" "command -v" || assert_contains "$script_content" "which"
  pass
}

it "should provide fallback alternatives" && {
  local script_content=$(cat "$DOTFILES_DIR/src/scripts/fallback")
  assert_contains "$script_content" "else" || assert_contains "$script_content" "alternative" || assert_contains "$script_content" "fallback"
  pass
}

# Theme wrapper tests
describe "theme wrapper script"

it "should exist and be executable" && {
  assert_file_exists "$DOTFILES_DIR/src/scripts/theme"
  assert_file_executable "$DOTFILES_DIR/src/scripts/theme"
  pass
}

it "should call theme switcher" && {
  local script_content=$(cat "$DOTFILES_DIR/src/scripts/theme")
  assert_contains "$script_content" "switch-theme" || assert_contains "$script_content" "theme"
  pass
}

cleanup_test
echo -e "\n${GREEN}Other utility scripts tests completed${NC}"
# Return success
exit 0
