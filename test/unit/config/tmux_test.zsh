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

test_case "Undercurl passthrough is configured (spell/diagnostic squiggles)"
if grep -q "Smulx" "$DOTFILES_DIR/src/tmux.conf" 2>/dev/null \
  && grep -q "Setulc" "$DOTFILES_DIR/src/tmux.conf" 2>/dev/null; then
  pass
else
  fail "tmux.conf must pass through Smulx/Setulc or Neovim undercurls vanish"
fi

test_case "OSC 52 clipboard is fully enabled (set-clipboard + Ms capability)"
if grep -q "set-clipboard on" "$DOTFILES_DIR/src/tmux.conf" 2>/dev/null \
  && grep -qF "terminal-features ',*:clipboard'" "$DOTFILES_DIR/src/tmux.conf" 2>/dev/null; then
  pass
else
  fail "tmux.conf needs set-clipboard on AND the ',*:clipboard' terminal-feature, or OSC 52 copies silently drop"
fi
# Return success
exit 0
