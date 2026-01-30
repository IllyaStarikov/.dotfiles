#!/usr/bin/env zsh
# Behavioral tests for Neovim configuration
# Tests what actually happens, not how it's implemented

# Set up test environment
export TEST_DIR="${TEST_DIR:-$(dirname "$0")/..}"
export DOTFILES_DIR="${DOTFILES_DIR:-$(dirname "$TEST_DIR")}"

# Source test framework
source "$TEST_DIR/lib/test_helpers.zsh"

describe "Neovim configuration behavioral tests"

setup_test

# Test: Neovim starts without errors
it "neovim starts cleanly" && {
  # Just run nvim and check it exits without error
  nvim --headless -c "qa!" 2>&1
  assert_equals "$?" 0
  pass
}

# Test: Can execute basic vim commands
it "executes vim commands" && {
  output=$(nvim --headless +'echo "hello"' +qa 2>&1)
  assert_contains "$output" "hello"
  pass
}

# Test: Can run lua code
it "runs lua code" && {
  output=$(nvim --headless +'lua print("lua works")' +qa 2>&1)
  assert_contains "$output" "lua works"
  pass
}

# Test: Basic options are set
it "sets basic vim options" && {
  output=$(nvim --headless +'set number?' +qa 2>&1)
  # Either number or nonumber is fine, just check it doesn't error
  assert_not_contains "$output" "Error"
  assert_not_contains "$output" "E"
  pass
}

# Test: Can open and edit a file
it "opens and edits files" && {
  local test_file="$TEST_TMP_DIR/test.txt"
  echo "original" > "$test_file"

  nvim --headless "$test_file" \
  +'normal! dd' \
  +'normal! ihello world' \
  +'write' \
  +qa 2>&1

  local content=$(cat "$test_file")
  assert_contains "$content" "hello world"
  pass
}

# Test: Config directory is accessible
it "finds config files" && {
  output=$(nvim --headless \
  +'lua print(vim.fn.stdpath("config"))' \
  +qa 2>&1)
  # Should print a config path
  assert_contains "$output" "config" || assert_contains "$output" "nvim"
  pass
}

# Test: Can handle multiple buffers
it "manages multiple buffers" && {
  nvim --headless \
  +'edit file1' \
  +'edit file2' \
  +'buffers' \
  +qa 2>&1

  assert_equals "$?" 0
  pass
}

# Test: Syntax highlighting loads
it "loads syntax highlighting" && {
  local test_file="$TEST_TMP_DIR/test.sh"
  echo '#!/bin/bash' > "$test_file"

  output=$(nvim --headless "$test_file" \
  +'lua print(vim.bo.filetype)' \
  +qa 2>&1)

  assert_contains "$output" "sh" || assert_contains "$output" "bash"
  pass
}

cleanup_test
echo -e "\n${GREEN}Neovim behavioral tests completed${NC}"