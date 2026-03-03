#!/usr/bin/env zsh
# Functional tests for Git configuration

# Tests handle errors explicitly

export TEST_DIR="${TEST_DIR:-$(dirname "$0")/..}"
export DOTFILES_DIR="${DOTFILES_DIR:-$(dirname "$TEST_DIR")}"

source "$TEST_DIR/lib/test_helpers.zsh"

describe "Git configuration functional tests"

setup_test

it "gitconfig should exist" && {
  assert_file_exists "$DOTFILES_DIR/src/git/gitconfig"
  pass
}

it "should configure user information" && {
  local git_content=$(cat "$DOTFILES_DIR/src/git/gitconfig")
  assert_contains "$git_content" "user" && \
  assert_contains "$git_content" "email" && pass || fail "Missing user configuration"
}

it "should set up aliases" && {
  local git_content=$(cat "$DOTFILES_DIR/src/git/gitconfig")
  assert_contains "$git_content" "alias" && pass || fail "Missing alias section"
}

it "should configure core settings" && {
  local git_content=$(cat "$DOTFILES_DIR/src/git/gitconfig")
  assert_contains "$git_content" "core" && pass || fail "Missing core section"
}

it "should set up global gitignore" && {
  assert_file_exists "$DOTFILES_DIR/src/git/gitignore"
  local gitignore_content=$(cat "$DOTFILES_DIR/src/git/gitignore")
  assert_contains "$gitignore_content" ".DS_Store" && pass || fail "gitignore missing expected patterns"
}

it "should configure diff tool" && {
  local git_content=$(cat "$DOTFILES_DIR/src/git/gitconfig")
  assert_contains "$git_content" "diff" && pass || fail "Missing diff section"
}

it "should configure merge tool" && {
  local git_content=$(cat "$DOTFILES_DIR/src/git/gitconfig")
  assert_contains "$git_content" "merge" && pass || fail "Missing merge section"
}

it "should configure push behavior" && {
  local git_content=$(cat "$DOTFILES_DIR/src/git/gitconfig")
  assert_contains "$git_content" "push" && pass || fail "Missing push section"
}

it "should set up pull behavior" && {
  local git_content=$(cat "$DOTFILES_DIR/src/git/gitconfig")
  assert_contains "$git_content" "pull" && pass || fail "Missing pull section"
}

it "should configure credential handling" && {
  local git_content=$(cat "$DOTFILES_DIR/src/git/gitconfig")
  assert_contains "$git_content" "credential" && pass || fail "Missing credential section"
}

it "should set up GPG signing if configured" && {
  local git_content=$(cat "$DOTFILES_DIR/src/git/gitconfig")
  if [[ "$git_content" == *"signingkey"* ]]; then
    assert_contains "$git_content" "gpgsign"
    pass
  else
    skip "GPG signing not configured"
  fi
}

cleanup_test
echo -e "\n${GREEN}Git functional tests completed${NC}"
