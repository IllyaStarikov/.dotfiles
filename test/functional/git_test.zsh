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
  assert_contains "$git_content" "user" || assert_contains "$git_content" "User"
  assert_contains "$git_content" "email" || assert_contains "$git_content" "name"
  pass
}

it "should set up aliases" && {
  local git_content=$(cat "$DOTFILES_DIR/src/git/gitconfig")
  assert_contains "$git_content" "alias" || assert_contains "$git_content" "Alias"
  pass
}

it "should configure core settings" && {
  local git_content=$(cat "$DOTFILES_DIR/src/git/gitconfig")
  assert_contains "$git_content" "core" || assert_contains "$git_content" "Core"
  pass
}

it "should set up global gitignore" && {
  assert_file_exists "$DOTFILES_DIR/src/git/gitignore_global"
  local gitignore_content=$(cat "$DOTFILES_DIR/src/git/gitignore_global")
  assert_contains "$gitignore_content" ".DS_Store" || assert_contains "$gitignore_content" "node_modules"
  pass
}

it "should configure diff tool" && {
  local git_content=$(cat "$DOTFILES_DIR/src/git/gitconfig")
  assert_contains "$git_content" "diff" || assert_contains "$git_content" "Diff"
  pass
}

it "should configure merge tool" && {
  local git_content=$(cat "$DOTFILES_DIR/src/git/gitconfig")
  assert_contains "$git_content" "merge" || assert_contains "$git_content" "Merge"
  pass
}

it "should set up color output" && {
  local git_content=$(cat "$DOTFILES_DIR/src/git/gitconfig")
  assert_contains "$git_content" "color" || assert_contains "$git_content" "Color"
  pass
}

it "should configure push behavior" && {
  local git_content=$(cat "$DOTFILES_DIR/src/git/gitconfig")
  assert_contains "$git_content" "push" || assert_contains "$git_content" "Push"
  pass
}

it "should set up pull behavior" && {
  local git_content=$(cat "$DOTFILES_DIR/src/git/gitconfig")
  assert_contains "$git_content" "pull" || assert_contains "$git_content" "Pull"
  pass
}

it "should configure credential handling" && {
  local git_content=$(cat "$DOTFILES_DIR/src/git/gitconfig")
  assert_contains "$git_content" "credential" || assert_contains "$git_content" "Credential"
  pass
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
