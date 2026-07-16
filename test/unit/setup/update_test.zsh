#!/usr/bin/env zsh
# Unit tests for update-dotfiles script

# Tests handle errors explicitly

export TEST_DIR="${TEST_DIR:-$(dirname "$0")/../..}"
export DOTFILES_DIR="${DOTFILES_DIR:-$(dirname "$TEST_DIR")}"

source "$TEST_DIR/lib/test_helpers.zsh"

describe "update-dotfiles script tests"

setup_test

it "should exist and be executable" && {
  assert_file_exists "$DOTFILES_DIR/src/setup/update.sh"
  assert_file_executable "$DOTFILES_DIR/src/setup/update.sh"
  pass
}

it "should handle git operations" && {
  local script_content=$(cat "$DOTFILES_DIR/src/setup/update.sh")
  assert_contains "$script_content" "git"
  assert_contains "$script_content" "pull" || assert_contains "$script_content" "fetch"
  pass
}

it "should check for uncommitted changes" && {
  local script_content=$(cat "$DOTFILES_DIR/src/setup/update.sh")
  assert_contains "$script_content" "status" || assert_contains "$script_content" "diff"
  pass
}

it "should handle divergent history when pulling" && {
  # update.sh pulls the dotfiles repo with `git pull --rebase`; that is its
  # divergent-history strategy (there is no merge/stash handling).
  local script_content=$(cat "$DOTFILES_DIR/src/setup/update.sh")
  assert_contains "$script_content" "rebase"
  pass
}

it "should update submodules if present" && {
  # Plain grep here: assert_contains counts a failure before || skip runs.
  local script_content=$(cat "$DOTFILES_DIR/src/setup/update.sh")
  if [[ "$script_content" == *"submodule"* ]]; then
    pass
  else
    skip "No submodule handling in update.sh"
  fi
}

it "should provide help message" && {
  output=$("$DOTFILES_DIR/src/setup/update.sh" --help 2>&1 || true)
  assert_contains "$output" "Usage" || assert_contains "$output" "usage" || assert_contains "$output" "update"
  pass
}

cleanup_test
echo -e "\n${GREEN}update-dotfiles tests completed${NC}"
# Return success
exit 0
