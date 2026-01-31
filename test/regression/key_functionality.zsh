#!/usr/bin/env zsh
# Regression Tests: Ensure key functionality doesn't break
# TEST_SIZE: medium

source "${TEST_DIR}/lib/framework.zsh"

# Baseline metrics file
readonly BASELINE_FILE="$TEST_SNAPSHOTS/regression_baseline.json"

test_neovim_plugin_loading() {
  log "TRACE" "Testing Neovim plugin loading regression"

  local output=$(timeout 10 nvim --headless -c "
    lua vim.defer_fn(function()
      local loaded_count = 0
      for k, v in pairs(package.loaded) do
        if string.match(k, '^[^_]') then
            loaded_count = loaded_count + 1
        end
      end
      print('loaded_modules:' .. loaded_count)
      vim.cmd('qa!')
    end, 2000)
  " 2>&1)

  local current_count=$(echo "$output" | grep -o "loaded_modules:[0-9]*" | cut -d':' -f2)

  if [[ -z "$current_count" ]]; then
    log "WARNING" "Could not determine loaded module count"
    return 77 # Skip
  fi

  # Check against baseline
  if [[ -f "$BASELINE_FILE" ]]; then
    local baseline_count=$(jq -r '.nvim_loaded_modules' "$BASELINE_FILE" 2>/dev/null)

    if [[ -n "$baseline_count" ]]; then
      local min_expected=$((baseline_count * 80 / 100)) # Allow 20% variance

      if [[ $current_count -lt $min_expected ]]; then
        log "ERROR" "Module loading regression: $current_count < $min_expected (baseline: $baseline_count)"
        return 1
      fi
    fi
  else
    # Create baseline
    echo "{\"nvim_loaded_modules\": $current_count}" >"$BASELINE_FILE"
    log "INFO" "Baseline created with $current_count modules"
  fi

  log "INFO" "Neovim loaded $current_count modules"
  return 0
}

test_zsh_alias_count() {
  log "TRACE" "Testing shell alias regression"

  local alias_count=$(
    zsh -c "
      source $DOTFILES_DIR/src/zsh/zshrc 2>/dev/null || true
      alias | wc -l
    " 2>/dev/null
  )

  if [[ -z "$alias_count" ]] || [[ "$alias_count" -eq 0 ]]; then
    log "WARNING" "Could not count aliases"
    return 77 # Skip
  fi

  # Minimum expected aliases
  local min_aliases=10

  if [[ $alias_count -lt $min_aliases ]]; then
    log "ERROR" "Too few aliases loaded: $alias_count < $min_aliases"
    return 1
  fi

  log "INFO" "Shell has $alias_count aliases"
  return 0
}

test_theme_switching_still_works() {
  log "TRACE" "Testing theme switching functionality"

  local theme_script="$DOTFILES_DIR/src/theme-switcher/switch-theme.sh"

  if [[ ! -x "$theme_script" ]]; then
    log "ERROR" "Theme switcher not executable or missing"
    return 1
  fi

  # Test dry run
  local output=$("$theme_script" --dry-run dark 2>&1)
  local exit_code=$?

  if [[ $exit_code -ne 0 ]]; then
    log "ERROR" "Theme switcher failed with exit code: $exit_code"
    return 1
  fi

  # Check that it would modify expected files
  local expected_configs=(
    "alacritty"
    "tmux"
    "neovim"
  )

  for config in "${expected_configs[@]}"; do
    if [[ "$output" != *"$config"* ]]; then
      log "WARNING" "Theme switcher output missing: $config"
    fi
  done

  return 0
}

test_fixy_script_functionality() {
  log "TRACE" "Testing fixy formatter regression"

  local fixy_script="$DOTFILES_DIR/src/scripts/fixy"

  if [[ ! -x "$fixy_script" ]]; then
    log "ERROR" "fixy script not executable or missing"
    return 1
  fi

  # Create a test file
  local test_file=$(mktemp -t fixy_test.sh)
  cat >"$test_file" <<'EOF'
#!/bin/bash
echo "test"
   echo "indented"
echo "test"
EOF

  # Run fixy in dry-run mode
  local output=$("$fixy_script" --dry-run "$test_file" 2>&1)
  local exit_code=$?

  rm -f "$test_file"

  if [[ $exit_code -ne 0 ]]; then
    log "ERROR" "fixy failed with exit code: $exit_code"
    return 1
  fi

  return 0
}

test_update_script_functionality() {
  log "TRACE" "Testing update-dotfiles script"

  local update_script="$DOTFILES_DIR/src/scripts/update-dotfiles"

  if [[ ! -x "$update_script" ]]; then
    log "ERROR" "update-dotfiles script not executable or missing"
    return 1
  fi

  # Test help output
  local output=$("$update_script" --help 2>&1)

  if [[ "$output" != *"update"* ]]; then
    log "ERROR" "update-dotfiles help output invalid"
    return 1
  fi

  return 0
}

test_git_hooks_present() {
  log "TRACE" "Testing git hooks presence"

  local pre_commit="$DOTFILES_DIR/src/git/hooks/pre-commit"

  if [[ ! -f "$pre_commit" ]]; then
    log "WARNING" "pre-commit hook not found"
  # Not a failure, just a warning
  else
    # Check it's valid shell script
    if ! bash -n "$pre_commit" 2>/dev/null; then
      log "ERROR" "pre-commit hook has syntax errors"
      return 1
    fi
  fi

  return 0
}

test_critical_keybindings() {
  log "TRACE" "Testing critical Neovim keybindings"

  local output=$(timeout 5 nvim --headless -c "
    lua xpcall(function()
      local keymaps = vim.api.nvim_get_keymap('n')
      local critical_maps = {
        ['<leader>'] = false,
        ['<C-p>'] = false,
        ['<C-n>'] = false,
      }

      for _, map in ipairs(keymaps) do
        for key, _ in pairs(critical_maps) do
            if string.match(map.lhs, key) then
                critical_maps[key] = true
            end
        end
      end

      local missing = {}
      for key, found in pairs(critical_maps) do
        if not found then
            table.insert(missing, key)
        end
      end

      if #missing > 0 then
        print('missing_keys:' .. table.concat(missing, ','))
      else
        print('all_keys_present')
      end
    end, function(err)
      print('error:' .. tostring(err))
    end)
    vim.cmd('qa!')
  " 2>&1)

  if [[ "$output" == *"missing_keys:"* ]]; then
    local missing=$(echo "$output" | grep -o "missing_keys:.*" | cut -d':' -f2)
    log "WARNING" "Missing keybindings: $missing"
  elif [[ "$output" == *"all_keys_present"* ]]; then
    log "INFO" "All critical keybindings present"
  fi

  return 0
}

test_no_conflicting_aliases() {
  log "TRACE" "Testing for conflicting shell aliases"

  local conflicts=$(
    zsh -c "
      source $DOTFILES_DIR/src/zsh/zshrc 2>/dev/null || true
      alias | cut -d'=' -f1 | sort | uniq -d
    " 2>/dev/null
  )

  if [[ -n "$conflicts" ]]; then
    log "ERROR" "Conflicting aliases found:"
    echo "$conflicts" | while read -r alias; do
      log "ERROR" "  - $alias"
    done
    return 1
  fi

  log "INFO" "No conflicting aliases found"
  return 0
}

test_completion_system() {
  log "TRACE" "Testing shell completion system"

  local output=$(
    zsh -c "
      source $DOTFILES_DIR/src/zsh/zshrc 2>/dev/null || true
      compdef 2>&1 | head -1
    " 2>&1
  )

  if [[ "$output" == *"command not found"* ]]; then
    log "ERROR" "Completion system not loaded"
    return 1
  fi

  log "INFO" "Completion system loaded"
  return 0
}

test_lsp_server_availability() {
  log "TRACE" "Testing LSP server configuration"

  local output=$(timeout 10 nvim --headless -c "
    lua vim.defer_fn(function()
      local servers = {}
      local lspconfig_ok, lspconfig = pcall(require, 'lspconfig')
      if lspconfig_ok then
        -- Check for common servers
        local common = {'lua_ls', 'tsserver', 'pyright', 'gopls'}
        for _, server in ipairs(common) do
            if lspconfig[server] then
                table.insert(servers, server)
            end
        end
      end
      print('lsp_servers:' .. table.concat(servers, ','))
      vim.cmd('qa!')
    end, 2000)
  " 2>&1)

  local servers=$(echo "$output" | grep -o "lsp_servers:.*" | cut -d':' -f2)

  if [[ -z "$servers" ]]; then
    log "WARNING" "No LSP servers configured"
  else
    log "INFO" "LSP servers available: $servers"
  fi

  return 0
}
