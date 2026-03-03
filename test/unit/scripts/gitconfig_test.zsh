#!/usr/bin/env zsh
# Test: Git configuration

test_case "gitconfig exists"
if [[ -f "$DOTFILES_DIR/src/git/gitconfig" ]]; then
  pass
else
  fail "gitconfig not found"
fi

test_case "User name and email are configured"
if [[ -f "$DOTFILES_DIR/src/git/gitconfig" ]]; then
  has_name=$(grep -q "name =" "$DOTFILES_DIR/src/git/gitconfig" && echo 1 || echo 0)
  has_email=$(grep -q "email =" "$DOTFILES_DIR/src/git/gitconfig" && echo 1 || echo 0)

  if [[ $has_name -eq 1 ]] && [[ $has_email -eq 1 ]]; then
    pass
  else
    fail "Missing user configuration"
  fi
else
  skip "gitconfig not found"
fi

test_case "Common git aliases exist"
if [[ -f "$DOTFILES_DIR/src/git/gitconfig" ]]; then
  expected_aliases=(
    "s"
    "co"
    "b"
  )

  found=0
  for a in "${expected_aliases[@]}"; do
    if grep -q "$a =" "$DOTFILES_DIR/src/git/gitconfig"; then
      ((found++))
    fi
  done

  if [[ $found -ge 2 ]]; then
    pass
  else
    fail "Only $found/${#expected_aliases[@]} git aliases found"
  fi
else
  skip "gitconfig not found"
fi
# Return success
exit 0
