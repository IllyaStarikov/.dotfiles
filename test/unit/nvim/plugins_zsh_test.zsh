#!/usr/bin/env zsh
# Test: Neovim plugin configuration

test_case "Plugin manager (lazy.nvim) is bootstrapped"
lazy_path="$HOME/.local/share/nvim/lazy/lazy.nvim"
if [[ -d "$lazy_path" ]] || [[ -f "$DOTFILES_DIR/src/neovim/config/plugins.lua" ]]; then
  pass
else
  fail "lazy.nvim not found and no bootstrap config"
fi

test_case "Plugin configuration files exist"
plugin_files=(
  "plugins.lua"
  "telescope.lua"
  "lsp/servers.lua"
  "plugins/completion.lua"
  "plugins/snacks.lua"
)

missing=()
for file in "${plugin_files[@]}"; do
  if [[ ! -f "$DOTFILES_DIR/src/neovim/config/$file" ]]; then
  missing+=("$file")
  fi
done

if [[ ${#missing[@]} -eq 0 ]]; then
  pass
else
  fail "Missing plugin configs: ${missing[*]}"
fi

test_case "Critical plugins are specified"
critical_plugins=(
  "telescope"
  "gitsigns"
  "nvim-treesitter"
  "lazy.nvim"
)

found=0
for plugin in "${critical_plugins[@]}"; do
  if grep -q "$plugin" "$DOTFILES_DIR/src/neovim/config/plugins.lua" 2>/dev/null \
  || grep -q "$plugin" "$DOTFILES_DIR/src/neovim/config/plugins/"*.lua 2>/dev/null; then
  ((found++))
  fi
done

if [[ $found -eq ${#critical_plugins[@]} ]]; then
  pass
else
  fail "Only $found/${#critical_plugins[@]} critical plugins found"
fi
# Return success
exit 0
