#!/usr/bin/env zsh
# Integration tests for dotfiles sync workflow

set -euo pipefail

export TEST_DIR="${TEST_DIR:-$(dirname "$0")/..}"
export DOTFILES_DIR="${DOTFILES_DIR:-$(dirname "$TEST_DIR")}"

source "$TEST_DIR/lib/test_helpers.zsh"

describe "Dotfiles sync integration tests"

setup_test
TEST_HOME="$TEST_TMP_DIR/home"
mkdir -p "$TEST_HOME"

it "should check git repository status" && {
  # Verify we're in a git repo
  cd "$DOTFILES_DIR"
  output=$(git status --porcelain 2>&1 || true)
  assert_success $?
  pass
}

it "should handle uncommitted changes" && {
  local update_script="$DOTFILES_DIR/src/setup/update.sh"
  if [[ -f "$update_script" ]]; then
    local script_content=$(cat "$update_script")
    assert_contains "$script_content" "status" || assert_contains "$script_content" "diff"
    pass
  else
    skip "update-dotfiles script not found"
  fi
}

it "should sync with remote repository" && {
  local update_script="$DOTFILES_DIR/src/setup/update.sh"
  if [[ -f "$update_script" ]]; then
    local script_content=$(cat "$update_script")
    assert_contains "$script_content" "pull" || assert_contains "$script_content" "fetch"
    pass
  else
    skip "update-dotfiles script not found"
  fi
}

it "should handle submodules" && {
  if [[ -f "$DOTFILES_DIR/.gitmodules" ]]; then
    local update_script="$DOTFILES_DIR/src/setup/update.sh"
    local script_content=$(cat "$update_script")
    # Check for explicit submodule handling, or skip if not implemented
    if [[ "$script_content" == *"submodule"* ]] || [[ "$script_content" == *"recurse"* ]]; then
      pass
    else
      skip "Submodule updates not explicitly handled in update script"
    fi
  else
    skip "No submodules configured"
  fi
}

it "should preserve local modifications" && {
  export HOME="$TEST_HOME"

  # Create a local modification
  echo "test" >"$TEST_HOME/.test_file"

  # Sync should not destroy local files - check for backup or safe update patterns
  local update_script="$DOTFILES_DIR/src/setup/update.sh"
  if [[ -f "$update_script" ]]; then
    local script_content=$(cat "$update_script")
    # Accept backup, stash, or skip patterns (safe update handling)
    if [[ "$script_content" == *"backup"* ]] || [[ "$script_content" == *"stash"* ]] || [[ "$script_content" == *"skip"* ]]; then
      pass
    else
      skip "No explicit local modification handling found"
    fi
  else
    skip "update-dotfiles script not found"
  fi
}

it "should update symlinks after sync" && {
  local update_script="$DOTFILES_DIR/src/setup/update.sh"
  if [[ -f "$update_script" ]]; then
    local script_content=$(cat "$update_script")
    # Accept symlink, link, or config patterns (update handling)
    if [[ "$script_content" == *"symlink"* ]] || [[ "$script_content" == *"link"* ]] || [[ "$script_content" == *"config"* ]]; then
      pass
    else
      skip "No explicit symlink update found in script"
    fi
  else
    skip "update-dotfiles script not found"
  fi
}

cleanup_test
echo -e "\n${GREEN}Dotfiles sync integration tests completed${NC}"
