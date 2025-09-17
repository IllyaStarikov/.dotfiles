#!/usr/bin/env zsh
# Test: tmux configuration

test_case "tmux.conf exists"
if [[ -f "$DOTFILES_DIR/src/tmux.conf" ]]; then
  pass
else
  fail "tmux.conf not found"
fi

test_case "tmux prefix key is configured"
if grep -q "prefix\|bind-key.*C-" "$DOTFILES_DIR/src/tmux.conf" 2>/dev/null; then
  pass
else
  fail "No prefix key configuration found"
fi

test_case "tmux plugin manager (TPM) is configured"
if grep -q "tpm\|tmux-plugins" "$DOTFILES_DIR/src/tmux.conf" 2>/dev/null; then
  pass
else
  skip "TPM not configured"
fi

test_case "Vi mode is enabled"
if grep -q "vi\|vim" "$DOTFILES_DIR/src/tmux.conf" 2>/dev/null; then
  pass
else
  fail "Vi mode not configured"
fi

test_case "Theme configuration exists"
if [[ -f "$HOME/.config/tmux/theme.conf" ]] \
  || grep -q "source.*theme" "$DOTFILES_DIR/src/tmux.conf" 2>/dev/null; then
  pass
else
  skip "Theme configuration not found"
fi
# Return success
exit 0
