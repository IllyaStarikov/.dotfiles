#!/usr/bin/env zsh
# Test: Theme switcher script

test_case "Theme switcher script exists and is executable"
script="$DOTFILES_DIR/src/theme-switcher/switch-theme.sh"
if [[ -f "$script" ]]; then
  if [[ -x "$script" ]]; then
  pass
  else
  fail "Script not executable"
  fi
else
  fail "Theme switcher script not found"
fi

test_case "Theme switcher has no syntax errors"
if [[ -f "$script" ]] && zsh -n "$script" 2>/dev/null; then
  pass
else
  fail "Theme switcher has syntax errors"
fi

test_case "Theme configuration directory exists"
if [[ -d "$HOME/.config/theme-switcher" ]] \
  || grep -q "mkdir.*theme-switcher" "$script" 2>/dev/null; then
  pass
else
  skip "Theme config directory not created"
fi

test_case "Supports both light and dark themes"
if [[ -f "$script" ]]; then
  has_dark=$(grep -q "Dark\|dark\|tokyonight_moon" "$script" && echo 1 || echo 0)
  has_light=$(grep -q "Light\|light\|tokyonight_day" "$script" && echo 1 || echo 0)

  if [[ $has_dark -eq 1 ]] && [[ $has_light -eq 1 ]]; then
  pass
  else
  fail "Missing theme support"
  fi
else
  skip "Script not found"
fi
# Return success
exit 0
