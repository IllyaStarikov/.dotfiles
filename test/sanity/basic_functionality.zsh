#!/usr/bin/env zsh
# Sanity Tests: Basic Functionality Verification
# TEST_SIZE: small
# Quick checks to ensure basic dotfiles functionality works

source "${TEST_DIR}/lib/framework.zsh"

# Test that basic environment is sane
test_environment_sanity() {
  log "TRACE" "Testing basic environment sanity"
  [[ $VERBOSE -ge 1 ]] && log "DEBUG" "Checking essential environment variables"

  local issues=0

  # Essential environment variables
  if [[ -z "$HOME" ]]; then
  log "ERROR" "HOME is not set"
  ((issues++))
  else
  [[ $VERBOSE -ge 2 ]] && log "DEBUG" "HOME=$HOME"
  fi

  if [[ -z "$PATH" ]]; then
  log "ERROR" "PATH is not set"
  ((issues++))
  else
  local path_entries=$(echo "$PATH" | tr ':' '\n' | wc -l)
  [[ $VERBOSE -ge 1 ]] && log "DEBUG" "PATH has $path_entries entries"
  fi

  if [[ -z "$SHELL" ]]; then
  log "WARNING" "SHELL is not set"
  else
  [[ $VERBOSE -ge 2 ]] && log "DEBUG" "SHELL=$SHELL"
  fi

  # Check if we're in the right directory
  if [[ ! -d "$DOTFILES_DIR" ]]; then
  log "ERROR" "DOTFILES_DIR does not exist: $DOTFILES_DIR"
  ((issues++))
  else
  [[ $VERBOSE -ge 1 ]] && log "SUCCESS" "Dotfiles directory exists"
  fi

  [[ $issues -eq 0 ]] || return 1
  return 0
}

# Test that essential commands exist
test_essential_commands() {
  log "TRACE" "Testing essential command availability"
  [[ $VERBOSE -ge 1 ]] && log "DEBUG" "Checking for required system commands"

  local -a essential_commands=(
  git
  zsh
  nvim
  curl
  grep
  sed
  awk
  find
  )

  local missing=0
  for cmd in "${essential_commands[@]}"; do
  if command -v "$cmd" >/dev/null 2>&1; then
    [[ $VERBOSE -ge 2 ]] && log "DEBUG" "✓ Found: $cmd ($(command -v "$cmd"))"
  else
    log "ERROR" "Missing essential command: $cmd"
    ((missing++))
  fi
  done

  if [[ $missing -eq 0 ]]; then
  [[ $VERBOSE -ge 1 ]] && log "SUCCESS" "All essential commands available"
  return 0
  else
  log "ERROR" "$missing essential commands missing"
  return 1
  fi
}

# Test that config files are readable
test_config_files_readable() {
  log "TRACE" "Testing configuration file readability"
  [[ $VERBOSE -ge 1 ]] && log "DEBUG" "Checking if all config files are readable"

  local -a config_files=(
  "$DOTFILES_DIR/src/neovim/init.lua"
  "$DOTFILES_DIR/src/zsh/zshrc"
  "$DOTFILES_DIR/src/git/gitconfig"
  "$DOTFILES_DIR/src/tmux.conf"
  )

  local unreadable=0
  for file in "${config_files[@]}"; do
  if [[ -r "$file" ]]; then
    local size=$(wc -c <"$file" 2>/dev/null)
    [[ $VERBOSE -ge 2 ]] && log "DEBUG" "✓ Readable: $(basename "$file") ($size bytes)"
  elif [[ -f "$file" ]]; then
    log "ERROR" "File exists but not readable: $file"
    ((unreadable++))
  else
    log "WARNING" "File does not exist: $file"
  fi
  done

  if [[ $unreadable -eq 0 ]]; then
  [[ $VERBOSE -ge 1 ]] && log "SUCCESS" "All config files are readable"
  return 0
  else
  return 1
  fi
}

# Test that we can start Neovim
test_neovim_starts() {
  log "TRACE" "Testing Neovim startup"
  [[ $VERBOSE -ge 1 ]] && log "DEBUG" "Attempting to start Neovim headless"

  local start_time=$(date +%s%N)
  local output=$(timeout 5 nvim --headless -c "echo 'sanity_check_ok'" -c "qa!" 2>&1)
  local exit_code=$?
  local end_time=$(date +%s%N)
  local duration=$(((end_time - start_time) / 1000000))

  [[ $VERBOSE -ge 1 ]] && log "DEBUG" "Neovim startup took ${duration}ms"

  if [[ $exit_code -eq 124 ]]; then
  log "ERROR" "Neovim startup timeout (>5s)"
  return 1
  elif [[ $exit_code -ne 0 ]]; then
  log "ERROR" "Neovim failed to start (exit code: $exit_code)"
  [[ $VERBOSE -ge 1 ]] && echo "$output" | head -5 | while read -r line; do
    log "DEBUG" "  $line"
  done
  return 1
  fi

  if [[ "$output" == *"sanity_check_ok"* ]]; then
  [[ $VERBOSE -ge 1 ]] && log "SUCCESS" "Neovim starts and executes commands"
  return 0
  else
  log "WARNING" "Neovim started but output unexpected"
  return 0
  fi
}

# Test that we can source Zsh config
test_zsh_config_sourceable() {
  log "TRACE" "Testing Zsh configuration sourcing"
  [[ $VERBOSE -ge 1 ]] && log "DEBUG" "Attempting to source zshrc"

  local zshrc="$DOTFILES_DIR/src/zsh/zshrc"

  if [[ ! -f "$zshrc" ]]; then
  log "ERROR" "zshrc not found"
  return 1
  fi

  # Try to source in a subshell
  local output=$(zsh -c "source '$zshrc' 2>&1 && echo 'source_ok'" 2>&1)

  if [[ "$output" == *"source_ok"* ]]; then
  [[ $VERBOSE -ge 1 ]] && log "SUCCESS" "Zsh config is sourceable"
  return 0
  else
  log "ERROR" "Failed to source zshrc"
  [[ $VERBOSE -ge 1 ]] && echo "$output" | grep -E "error|Error|ERROR" | head -5 | while read -r line; do
    log "DEBUG" "  $line"
  done
  return 1
  fi
}

# Test Git is configured
test_git_configured() {
  log "TRACE" "Testing Git configuration"
  [[ $VERBOSE -ge 1 ]] && log "DEBUG" "Checking Git user configuration"

  # Check for user name and email
  local user_name=$(git config --global user.name 2>/dev/null)
  local user_email=$(git config --global user.email 2>/dev/null)

  if [[ -z "$user_name" ]]; then
  log "WARNING" "Git user.name not configured"
  else
  [[ $VERBOSE -ge 1 ]] && log "DEBUG" "Git user: $user_name"
  fi

  if [[ -z "$user_email" ]]; then
  log "WARNING" "Git user.email not configured"
  else
  [[ $VERBOSE -ge 1 ]] && log "DEBUG" "Git email: $user_email"
  fi

  # Check for core settings
  local editor=$(git config --global core.editor 2>/dev/null)
  if [[ -n "$editor" ]]; then
  [[ $VERBOSE -ge 1 ]] && log "DEBUG" "Git editor: $editor"
  fi

  return 0
}

# Test directory structure
test_directory_structure() {
  log "TRACE" "Testing dotfiles directory structure"
  [[ $VERBOSE -ge 1 ]] && log "DEBUG" "Verifying expected directories exist"

  local -a expected_dirs=(
  "$DOTFILES_DIR/src"
  "$DOTFILES_DIR/src/neovim"
  "$DOTFILES_DIR/src/zsh"
  "$DOTFILES_DIR/src/scripts"
  "$DOTFILES_DIR/src/setup"
  "$DOTFILES_DIR/src/git"
  "$DOTFILES_DIR/test"
  )

  local missing=0
  for dir in "${expected_dirs[@]}"; do
  if [[ -d "$dir" ]]; then
    local count=$(find "$dir" -maxdepth 1 -type f | wc -l)
    [[ $VERBOSE -ge 2 ]] && log "DEBUG" "✓ $(basename "$dir")/ ($count files)"
  else
    log "ERROR" "Missing directory: $dir"
    ((missing++))
  fi
  done

  if [[ $missing -eq 0 ]]; then
  [[ $VERBOSE -ge 1 ]] && log "SUCCESS" "Directory structure is intact"
  return 0
  else
  return 1
  fi
}

# Test file permissions
test_file_permissions() {
  log "TRACE" "Testing file permissions"
  [[ $VERBOSE -ge 1 ]] && log "DEBUG" "Checking for permission issues"

  # Check for world-writable files (security risk)
  local world_writable=$(find "$DOTFILES_DIR" -type f -perm -002 2>/dev/null | head -5)

  if [[ -n "$world_writable" ]]; then
  log "WARNING" "World-writable files found:"
  echo "$world_writable" | while read -r file; do
    log "WARNING" "  $file"
  done
  else
  [[ $VERBOSE -ge 1 ]] && log "SUCCESS" "No world-writable files"
  fi

  # Check scripts are executable
  local non_exec_scripts=0
  for script in "$DOTFILES_DIR"/src/scripts/*; do
  [[ -f "$script" ]] || continue
  [[ "$script" == *.md ]] && continue
  [[ "$script" == *.json ]] && continue

  if [[ ! -x "$script" ]]; then
    ((non_exec_scripts++))
  fi
  done

  if [[ $non_exec_scripts -gt 0 ]]; then
  log "WARNING" "$non_exec_scripts scripts are not executable"
  fi

  return 0
}

# Test for obvious syntax errors
test_no_obvious_syntax_errors() {
  log "TRACE" "Testing for obvious syntax errors"
  [[ $VERBOSE -ge 1 ]] && log "DEBUG" "Quick syntax validation"

  local errors=0

  # Check Lua files
  if command -v luac >/dev/null 2>&1; then
  local lua_errors=$(find "$DOTFILES_DIR/src/neovim" -name "*.lua" -exec luac -p {} \; 2>&1 | grep -c "error")
  if [[ $lua_errors -gt 0 ]]; then
    log "ERROR" "Found $lua_errors Lua syntax errors"
    ((errors++))
  else
    [[ $VERBOSE -ge 1 ]] && log "SUCCESS" "No Lua syntax errors"
  fi
  fi

  # Check shell scripts
  local shell_errors=0
  for script in "$DOTFILES_DIR"/src/{scripts,setup,theme-switcher}/*.sh; do
  [[ -f "$script" ]] || continue

  if ! bash -n "$script" 2>/dev/null; then
    ((shell_errors++))
  fi
  done

  if [[ $shell_errors -gt 0 ]]; then
  log "ERROR" "Found $shell_errors shell syntax errors"
  ((errors++))
  else
  [[ $VERBOSE -ge 1 ]] && log "SUCCESS" "No shell syntax errors"
  fi

  [[ $errors -eq 0 ]] || return 1
  return 0
}

# Test that theme switcher exists
test_theme_switcher_exists() {
  log "TRACE" "Testing theme switcher existence"
  [[ $VERBOSE -ge 1 ]] && log "DEBUG" "Checking for theme switching capability"

  local theme_script="$DOTFILES_DIR/src/theme-switcher/switch-theme.sh"

  if [[ -f "$theme_script" ]]; then
  if [[ -x "$theme_script" ]]; then
    [[ $VERBOSE -ge 1 ]] && log "SUCCESS" "Theme switcher found and executable"

    # Check if it has expected functionality
    if grep -q "dark\|light" "$theme_script" 2>/dev/null; then
    [[ $VERBOSE -ge 2 ]] && log "DEBUG" "Theme switcher handles dark/light modes"
    fi
  else
    log "WARNING" "Theme switcher exists but not executable"
  fi
  else
  log "WARNING" "Theme switcher not found"
  fi

  return 0
}

# Quick connectivity test
test_basic_connectivity() {
  log "TRACE" "Testing basic network connectivity"
  [[ $VERBOSE -ge 1 ]] && log "DEBUG" "Checking if we can reach common hosts"

  # Try to reach common hosts (don't fail if offline)
  local hosts=("github.com" "google.com")
  local reachable=0

  for host in "${hosts[@]}"; do
  if ping -c 1 -W 1 "$host" >/dev/null 2>&1; then
    ((reachable++))
    [[ $VERBOSE -ge 2 ]] && log "DEBUG" "Can reach: $host"
  fi
  done

  if [[ $reachable -eq 0 ]]; then
  log "WARNING" "No network connectivity (tests may be limited)"
  else
  [[ $VERBOSE -ge 1 ]] && log "INFO" "Network connectivity OK ($reachable/${#hosts[@]} hosts reachable)"
  fi

  return 0
}
