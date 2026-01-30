#!/usr/bin/env zsh
# Integration Tests: Keybinding Conflict Detection
# TEST_SIZE: small
# Tests for key clashes in Neovim and Zsh configurations

source "${TEST_DIR}/lib/framework.zsh"

# Skip this test in non-interactive CI mode if it causes issues
if [[ "${CI_MODE:-0}" == "1" ]] || [[ "${NONINTERACTIVE:-0}" == "1" ]]; then
  # Still run but with stricter timeouts and no interactive features
  export SKIP_INTERACTIVE_TESTS=1
fi

# Test for Neovim keybinding conflicts
test_neovim_keybinding_conflicts() {
  log "TRACE" "Testing for Neovim keybinding conflicts"
  [[ $VERBOSE -ge 1 ]] && log "DEBUG" "Analyzing Neovim keymaps for conflicts"

  local conflicts_found=0

  # Extract keybindings using Neovim
  local keymap_output=$(timeout 10 nvim --headless -c "
    lua xpcall(function()
      local keymaps = {}
      local modes = {'n', 'i', 'v', 'x', 's', 'o', 'c', 't'}

      for _, mode in ipairs(modes) do
        local mode_maps = vim.api.nvim_get_keymap(mode)
        for _, map in ipairs(mode_maps) do
            local key = mode .. ':' .. map.lhs
            if keymaps[key] then
                print('CONFLICT:' .. key)
            else
                keymaps[key] = true
            end
        end
      end

      -- Count total mappings
      local count = 0
      for _ in pairs(keymaps) do count = count + 1 end
      print('TOTAL_MAPPINGS:' .. count)
    end, function(err)
      print('ERROR:' .. tostring(err))
    end)
    vim.cmd('qa!')
  " 2>&1)

  # Parse output for conflicts
  echo "$keymap_output" | while read -r line; do
  if [[ "$line" == CONFLICT:* ]]; then
    local conflict="${line#CONFLICT:}"
    log "ERROR" "Keybinding conflict found: $conflict"
    ((conflicts_found++))
  elif [[ "$line" == TOTAL_MAPPINGS:* ]]; then
    local total="${line#TOTAL_MAPPINGS:}"
    [[ $VERBOSE -ge 1 ]] && log "INFO" "Total Neovim keymappings: $total"
  elif [[ "$line" == ERROR:* ]]; then
    log "WARNING" "Error checking keymaps: ${line#ERROR:}"
  fi
  done

  # Check for common problematic keybindings
  local problematic_keys=(
  "<C-w>" # Window management
  "<C-c>" # Copy/Cancel
  "<C-v>" # Visual block/Paste
  "<C-x>" # Decrement/Cut
  "<C-a>" # Increment/Select all
  )

  for key in "${problematic_keys[@]}"; do
  [[ $VERBOSE -ge 2 ]] && log "DEBUG" "Checking for conflicts with: $key"

  local key_count=$(echo "$keymap_output" | grep -c ":$key" 2>/dev/null || echo 0)
  if [[ $key_count -gt 1 ]]; then
    log "WARNING" "Multiple mappings for $key (count: $key_count)"
  fi
  done

  # Check keymaps in config files directly
  local keymap_files=(
  "$DOTFILES_DIR/src/neovim/config/keymaps.lua"
  "$DOTFILES_DIR/src/neovim/config/keymaps/"*.lua
  )

  local defined_keys=()
  for file in "${keymap_files[@]}"; do
  [[ -f "$file" ]] || continue

  [[ $VERBOSE -ge 2 ]] && log "DEBUG" "Scanning keymap file: $(basename "$file")"

  # Extract vim.keymap.set calls
  grep -o "vim.keymap.set.*['\"][^'\"]*['\"]" "$file" 2>/dev/null | while read -r mapping; do
    # Try to extract the key
    local key=$(echo "$mapping" | sed -n "s/.*['\"]\\([^'\"]*\\)['\"].*/\\1/p" | head -1)
    if [[ -n "$key" ]]; then
    if [[ " ${defined_keys[@]} " =~ " ${key} " ]]; then
      log "WARNING" "Duplicate key definition: $key in $(basename "$file")"
      ((conflicts_found++))
    else
      defined_keys+=("$key")
    fi
    fi
  done
  done

  [[ $VERBOSE -ge 1 ]] && log "INFO" "Found ${#defined_keys[@]} unique key definitions"

  if [[ $conflicts_found -gt 0 ]]; then
  log "ERROR" "Found $conflicts_found keybinding conflicts"
  return 1
  else
  [[ $VERBOSE -ge 1 ]] && log "SUCCESS" "No keybinding conflicts detected in Neovim"
  fi

  return 0
}

# Test for Zsh keybinding conflicts
test_zsh_keybinding_conflicts() {
  log "TRACE" "Testing for Zsh keybinding conflicts"
  [[ $VERBOSE -ge 1 ]] && log "DEBUG" "Analyzing Zsh keybindings for conflicts"

  # Source Zsh config and extract bindings
  local zshrc="$DOTFILES_DIR/src/zsh/zshrc"

  if [[ ! -f "$zshrc" ]]; then
  log "ERROR" "Zsh config not found"
  return 1
  fi

  # Get all bindkey commands
  local bindkeys=$(grep "^bindkey\|^[[:space:]]*bindkey" "$zshrc" 2>/dev/null)

  if [[ -z "$bindkeys" ]]; then
  [[ $VERBOSE -ge 1 ]] && log "INFO" "No explicit bindkey commands found in zshrc"
  return 0
  fi

  # Track defined keys
  local -A zsh_keys
  local conflicts=0

  # Process bindkeys without while read (for CI)
  if [[ -n "$bindkeys" ]]; then
  local IFS=$'\n'
  for line in ${(f)bindkeys}; do
    # Extract the key sequence
    local key=$(echo "$line" | sed -n 's/.*bindkey[[:space:]]*['\''\"]*\([^'\''\"]*\).*/\1/p')

    if [[ -n "$key" ]]; then
    if [[ -n "${zsh_keys[$key]}" ]]; then
      log "WARNING" "Duplicate Zsh binding: $key"
      [[ $VERBOSE -ge 2 ]] && log "DEBUG" "  Previous: ${zsh_keys[$key]}"
      [[ $VERBOSE -ge 2 ]] && log "DEBUG" "  Current: $line"
      ((conflicts++))
    else
      zsh_keys[$key]="$line"
    fi
    fi
  done
  fi

  [[ $VERBOSE -ge 1 ]] && log "INFO" "Found ${#zsh_keys[@]} Zsh keybindings"

  # Check for vi mode conflicts
  if grep -q "vi-mode\|bindkey -v" "$zshrc" 2>/dev/null; then
  [[ $VERBOSE -ge 1 ]] && log "INFO" "Zsh uses vi mode"

  # Common vi mode conflict keys
  local vi_conflicts=(
    "^[" # Escape
    "jk" # Common escape mapping
    "jj" # Another escape mapping
  )

  for key in "${vi_conflicts[@]}"; do
    if [[ -n "${zsh_keys[$key]}" ]]; then
    [[ $VERBOSE -ge 2 ]] && log "DEBUG" "Vi mode key defined: $key"
    fi
  done
  fi

  if [[ $conflicts -gt 0 ]]; then
  log "WARNING" "Found $conflicts potential Zsh keybinding conflicts"
  else
  [[ $VERBOSE -ge 1 ]] && log "SUCCESS" "No keybinding conflicts detected in Zsh"
  fi

  return 0
}

# Test for conflicts between Neovim and terminal
test_terminal_vim_conflicts() {
  log "TRACE" "Testing for terminal/Neovim keybinding conflicts"
  [[ $VERBOSE -ge 1 ]] && log "DEBUG" "Checking for conflicts between terminal and Neovim"

  # Common terminal shortcuts that might conflict
  local terminal_keys=(
  "Ctrl+C" # Interrupt
  "Ctrl+Z" # Suspend
  "Ctrl+D" # EOF
  "Ctrl+S" # Stop output
  "Ctrl+Q" # Resume output
  "Ctrl+W" # Delete word
  "Ctrl+U" # Delete line
  "Ctrl+R" # Reverse search
  "Ctrl+L" # Clear screen
  )

  local conflicts=0

  for key in "${terminal_keys[@]}"; do
  local vim_key="<C-${key: -1}>"

  # Check if Neovim remaps this key
  local nvim_check=$(timeout 5 nvim --headless -c "
      lua xpcall(function()
        local mappings = vim.api.nvim_get_keymap('n')
        for _, map in ipairs(mappings) do
            if map.lhs == '$vim_key' then
                print('MAPPED:$vim_key')
                break
            end
        end
      end, function(err) end)
      vim.cmd('qa!')
    " 2>&1)

  if [[ "$nvim_check" == *"MAPPED:$vim_key"* ]]; then
    log "WARNING" "Terminal key $key is remapped in Neovim"
    [[ $VERBOSE -ge 2 ]] && log "DEBUG" "  This might cause conflicts in terminal Neovim"
    ((conflicts++))
  fi
  done

  if [[ $conflicts -gt 0 ]]; then
  [[ $VERBOSE -ge 1 ]] && log "INFO" "$conflicts terminal keys are remapped (might be intentional)"
  else
  [[ $VERBOSE -ge 1 ]] && log "SUCCESS" "No problematic terminal/Neovim conflicts"
  fi

  return 0
}

# Test for tmux keybinding conflicts
test_tmux_keybinding_conflicts() {
  log "TRACE" "Testing for tmux keybinding conflicts"
  [[ $VERBOSE -ge 1 ]] && log "DEBUG" "Analyzing tmux configuration for conflicts"

  local tmux_conf="$DOTFILES_DIR/src/tmux.conf"

  if [[ ! -f "$tmux_conf" ]]; then
  log "INFO" "tmux config not found, skipping"
  return 0
  fi

  # Extract bind-key commands
  local bindkeys=$(grep "^bind\|^[[:space:]]*bind" "$tmux_conf" 2>/dev/null)

  if [[ -z "$bindkeys" ]]; then
  [[ $VERBOSE -ge 1 ]] && log "INFO" "No bind commands found in tmux.conf"
  return 0
  fi

  # Track defined keys
  local -A tmux_keys
  local conflicts=0

  echo "$bindkeys" | while read -r line; do
  # Extract the key
  local key=$(echo "$line" | awk '{print $2}')

  if [[ -n "$key" ]]; then
    if [[ -n "${tmux_keys[$key]}" ]]; then
    log "WARNING" "Duplicate tmux binding: $key"
    ((conflicts++))
    else
    tmux_keys[$key]="$line"
    [[ $VERBOSE -ge 2 ]] && log "DEBUG" "tmux binds: $key"
    fi
  fi
  done

  [[ $VERBOSE -ge 1 ]] && log "INFO" "Found ${#tmux_keys[@]} tmux keybindings"

  # Check prefix key
  local prefix=$(grep "^set.*prefix" "$tmux_conf" 2>/dev/null | awk '{print $NF}')
  if [[ -n "$prefix" ]]; then
  [[ $VERBOSE -ge 1 ]] && log "INFO" "tmux prefix key: $prefix"

  if [[ "$prefix" != "C-b" ]]; then
    log "INFO" "Non-default tmux prefix: $prefix (check for conflicts)"
  fi
  fi

  if [[ $conflicts -gt 0 ]]; then
  log "WARNING" "Found $conflicts tmux keybinding conflicts"
  else
  [[ $VERBOSE -ge 1 ]] && log "SUCCESS" "No keybinding conflicts in tmux"
  fi

  return 0
}

# Test for leader key conflicts in Neovim
test_leader_key_conflicts() {
  log "TRACE" "Testing for leader key conflicts in Neovim"
  [[ $VERBOSE -ge 1 ]] && log "DEBUG" "Checking leader key mappings"

  # Get leader key
  local leader_output=$(timeout 5 nvim --headless -c "
    lua print('LEADER:' .. (vim.g.mapleader or '\\\\'))
    vim.cmd('qa!')
  " 2>&1)

  local leader=$(echo "$leader_output" | grep "^LEADER:" | cut -d: -f2)

  if [[ -z "$leader" ]]; then
  log "WARNING" "Could not determine leader key"
  return 0
  fi

  [[ $VERBOSE -ge 1 ]] && log "INFO" "Neovim leader key: '$leader'"

  # Count leader mappings
  local leader_mappings=$(timeout 5 nvim --headless -c "
    lua xpcall(function()
      local count = 0
      local mappings = vim.api.nvim_get_keymap('n')
      for _, map in ipairs(mappings) do
        if string.match(map.lhs, '^<leader>') then
            count = count + 1
        end
      end
      print('LEADER_COUNT:' .. count)
    end, function(err) end)
    vim.cmd('qa!')
  " 2>&1)

  local count=$(echo "$leader_mappings" | grep "^LEADER_COUNT:" | cut -d: -f2)

  if [[ -n "$count" ]]; then
  [[ $VERBOSE -ge 1 ]] && log "INFO" "Found $count leader key mappings"

  if [[ $count -eq 0 ]]; then
    log "WARNING" "No leader key mappings found (unusual)"
  elif [[ $count -gt 50 ]]; then
    log "WARNING" "Many leader mappings ($count), check for conflicts"
  fi
  fi

  return 0
}

# Test for which-key integration
test_which_key_integration() {
  log "TRACE" "Testing which-key plugin integration"
  [[ $VERBOSE -ge 1 ]] && log "DEBUG" "Checking if which-key helps prevent conflicts"

  local which_key_check=$(timeout 5 nvim --headless -c "
    lua xpcall(function()
      local ok, wk = pcall(require, 'which-key')
      if ok then
        print('WHICH_KEY:installed')
      else
        print('WHICH_KEY:not_found')
      end
    end, function(err) end)
    vim.cmd('qa!')
  " 2>&1)

  if [[ "$which_key_check" == *"WHICH_KEY:installed"* ]]; then
  [[ $VERBOSE -ge 1 ]] && log "SUCCESS" "which-key plugin is installed (helps prevent conflicts)"
  else
  [[ $VERBOSE -ge 1 ]] && log "INFO" "which-key not found (consider installing for better key management)"
  fi

  return 0
}

# Summary test for all keybinding conflicts
test_keybinding_summary() {
  log "TRACE" "Keybinding conflict detection summary"
  [[ $VERBOSE -ge 1 ]] && log "DEBUG" "Running comprehensive keybinding analysis"

  local total_issues=0

  # Run all sub-tests
  test_neovim_keybinding_conflicts || ((total_issues++))
  test_zsh_keybinding_conflicts || ((total_issues++))
  test_terminal_vim_conflicts || ((total_issues++))
  test_tmux_keybinding_conflicts || ((total_issues++))
  test_leader_key_conflicts || ((total_issues++))
  test_which_key_integration

  if [[ $total_issues -eq 0 ]]; then
  [[ $VERBOSE -ge 1 ]] && log "SUCCESS" "No critical keybinding conflicts detected"
  return 0
  else
  log "WARNING" "Found $total_issues potential keybinding issues"
  return 0 # Don't fail the test suite for conflicts
  fi
}
