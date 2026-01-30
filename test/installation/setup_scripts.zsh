#!/usr/bin/env zsh
# Installation Tests: Setup Script Validation
# TEST_SIZE: medium
# Tests that setup scripts work correctly and install everything properly

source "${TEST_DIR}/lib/framework.zsh"

# Test setup script exists and is executable
test_setup_script_exists() {
  log "TRACE" "Checking setup script existence and permissions"
  [[ $VERBOSE -ge 1 ]] && log "DEBUG" "Looking for setup scripts in: $DOTFILES_DIR/src/setup/"

  local setup_script="$DOTFILES_DIR/src/setup/setup.sh"

  if [[ ! -f "$setup_script" ]]; then
  log "ERROR" "Setup script not found at: $setup_script"
  return 1
  fi

  if [[ ! -x "$setup_script" ]]; then
  log "ERROR" "Setup script is not executable: $setup_script"
  log "DEBUG" "Current permissions: $(ls -l "$setup_script")"
  return 1
  fi

  [[ $VERBOSE -ge 1 ]] && log "SUCCESS" "Setup script found and executable"
  return 0
}

# Test symlinks script
test_symlinks_script() {
  log "TRACE" "Testing symlinks.sh script"
  [[ $VERBOSE -ge 1 ]] && log "DEBUG" "Checking symlinks script functionality"

  local symlinks_script="$DOTFILES_DIR/src/setup/symlinks.sh"

  if [[ ! -f "$symlinks_script" ]]; then
  log "ERROR" "Symlinks script not found: $symlinks_script"
  return 1
  fi

  # Check syntax
  if ! zsh -n "$symlinks_script" 2>/dev/null; then
  log "ERROR" "Syntax error in symlinks script"
  [[ $VERBOSE -ge 1 ]] && zsh -n "$symlinks_script" 2>&1 | while read -r line; do
    log "DEBUG" "  $line"
  done
  return 1
  fi

  # Test dry-run capability
  local dry_run_output=$("$symlinks_script" --dry-run 2>&1)
  if [[ $? -ne 0 ]]; then
  log "WARNING" "Symlinks script dry-run failed"
  [[ $VERBOSE -ge 1 ]] && echo "$dry_run_output" | while read -r line; do
    log "DEBUG" "  $line"
  done
  fi

  [[ $VERBOSE -ge 1 ]] && log "SUCCESS" "Symlinks script validated"
  return 0
}

# Test platform-specific setup scripts
test_platform_setup_scripts() {
  log "TRACE" "Testing platform-specific setup scripts"
  [[ $VERBOSE -ge 1 ]] && log "DEBUG" "Checking for mac.sh and linux.sh"

  local platform_scripts=(
  "$DOTFILES_DIR/src/setup/mac.sh"
  "$DOTFILES_DIR/src/setup/linux.sh"
  )

  local found_count=0
  for script in "${platform_scripts[@]}"; do
  if [[ -f "$script" ]]; then
    ((found_count++))
    [[ $VERBOSE -ge 1 ]] && log "DEBUG" "Found: $(basename "$script")"

    # Check syntax
    if ! bash -n "$script" 2>/dev/null; then
    log "ERROR" "Syntax error in $(basename "$script")"
    return 1
    fi
  fi
  done

  if [[ $found_count -eq 0 ]]; then
  log "ERROR" "No platform-specific setup scripts found"
  return 1
  fi

  [[ $VERBOSE -ge 1 ]] && log "SUCCESS" "Platform scripts validated ($found_count found)"
  return 0
}

# Test that setup would create necessary directories
test_setup_creates_directories() {
  log "TRACE" "Testing directory creation logic"
  [[ $VERBOSE -ge 1 ]] && log "DEBUG" "Verifying setup creates required directories"

  # Directories that should be created
  local required_dirs=(
  "\$HOME/.config"
  "\$HOME/.local/bin"
  "\$HOME/.local/share"
  "\$HOME/.cache"
  )

  # Check if setup script references these
  local setup_script="$DOTFILES_DIR/src/setup/setup.sh"
  if [[ -f "$setup_script" ]]; then
  for dir in "${required_dirs[@]}"; do
    if grep -q "mkdir.*$(echo "$dir" | sed 's/\$HOME//')" "$setup_script" 2>/dev/null; then
    [[ $VERBOSE -ge 1 ]] && log "DEBUG" "Setup creates: $dir"
    else
    log "WARNING" "Setup might not create: $dir"
    fi
  done
  fi

  return 0
}

# Test homebrew installation detection
test_homebrew_detection() {
  log "TRACE" "Testing Homebrew detection in setup"
  [[ $VERBOSE -ge 1 ]] && log "DEBUG" "Checking if setup handles Homebrew properly"

  if [[ "$(uname)" != "Darwin" ]]; then
  log "INFO" "Skipping Homebrew test on non-macOS"
  return 77 # Skip
  fi

  local mac_setup="$DOTFILES_DIR/src/setup/mac.sh"
  if [[ ! -f "$mac_setup" ]]; then
  log "WARNING" "Mac setup script not found"
  return 0
  fi

  # Check for Homebrew handling
  if grep -q "brew" "$mac_setup" 2>/dev/null; then
  [[ $VERBOSE -ge 1 ]] && log "DEBUG" "Mac setup handles Homebrew"

  # Check if it installs Homebrew if missing
  if grep -q "install.*homebrew\|/bin/bash.*install.sh" "$mac_setup" 2>/dev/null; then
    [[ $VERBOSE -ge 1 ]] && log "SUCCESS" "Setup can install Homebrew"
  else
    log "WARNING" "Setup might not install Homebrew if missing"
  fi
  else
  log "ERROR" "Mac setup doesn't handle Homebrew"
  return 1
  fi

  return 0
}

# Test package installation lists
test_package_lists() {
  log "TRACE" "Testing package installation lists"
  [[ $VERBOSE -ge 1 ]] && log "DEBUG" "Checking for Brewfile or package lists"

  local brewfile="$DOTFILES_DIR/Brewfile"
  local found_packages=0

  if [[ -f "$brewfile" ]]; then
  [[ $VERBOSE -ge 1 ]] && log "DEBUG" "Found Brewfile"

  # Count packages
  local brew_count=$(grep -c "^brew\|^cask\|^tap" "$brewfile" 2>/dev/null || echo 0)
  [[ $VERBOSE -ge 1 ]] && log "DEBUG" "Brewfile contains $brew_count packages"
  found_packages=1
  fi

  # Check for package lists in setup scripts
  for setup_file in "$DOTFILES_DIR"/src/setup/*.sh; do
  [[ -f "$setup_file" ]] || continue

  if grep -q "brew install\|apt install\|yum install\|pacman -S" "$setup_file" 2>/dev/null; then
    [[ $VERBOSE -ge 1 ]] && log "DEBUG" "Found package installations in $(basename "$setup_file")"
    found_packages=1
  fi
  done

  if [[ $found_packages -eq 0 ]]; then
  log "WARNING" "No package installation lists found"
  else
  [[ $VERBOSE -ge 1 ]] && log "SUCCESS" "Package lists found"
  fi

  return 0
}

# Test Git configuration setup
test_git_setup() {
  log "TRACE" "Testing Git configuration setup"
  [[ $VERBOSE -ge 1 ]] && log "DEBUG" "Checking if setup configures Git properly"

  local gitconfig="$DOTFILES_DIR/src/git/gitconfig"

  if [[ ! -f "$gitconfig" ]]; then
  log "ERROR" "Git config template not found: $gitconfig"
  return 1
  fi

  # Check for essential Git settings
  local essential_settings=(
  "core.editor"
  "user.name"
  "user.email"
  )

  for setting in "${essential_settings[@]}"; do
  if grep -q "$setting" "$gitconfig" 2>/dev/null; then
    [[ $VERBOSE -ge 1 ]] && log "DEBUG" "Git config includes: $setting"
  else
    log "WARNING" "Git config missing: $setting"
  fi
  done

  return 0
}

# Test Neovim plugin manager installation
test_neovim_plugin_manager_setup() {
  log "TRACE" "Testing Neovim plugin manager setup"
  [[ $VERBOSE -ge 1 ]] && log "DEBUG" "Checking for lazy.nvim installation logic"

  local nvim_init="$DOTFILES_DIR/src/neovim/init.lua"

  if [[ ! -f "$nvim_init" ]]; then
  log "ERROR" "Neovim init.lua not found"
  return 1
  fi

  # Check for lazy.nvim bootstrap
  if grep -q "lazy.nvim\|lazypath" "$nvim_init" 2>/dev/null; then
  [[ $VERBOSE -ge 1 ]] && log "DEBUG" "Neovim config includes lazy.nvim setup"

  # Check for auto-installation
  if grep -q "git clone.*lazy.nvim" "$nvim_init" 2>/dev/null; then
    [[ $VERBOSE -ge 1 ]] && log "SUCCESS" "Lazy.nvim auto-installation found"
  else
    log "WARNING" "Lazy.nvim might not auto-install"
  fi
  else
  log "ERROR" "No plugin manager setup found in Neovim config"
  return 1
  fi

  return 0
}

# Test shell plugin manager setup
test_shell_plugin_manager() {
  log "TRACE" "Testing shell plugin manager setup"
  [[ $VERBOSE -ge 1 ]] && log "DEBUG" "Checking for Zinit or other plugin managers"

  local zshrc="$DOTFILES_DIR/src/zsh/zshrc"

  if [[ ! -f "$zshrc" ]]; then
  log "ERROR" "Zsh config not found"
  return 1
  fi

  # Check for Zinit
  if grep -q "zinit" "$zshrc" 2>/dev/null; then
  [[ $VERBOSE -ge 1 ]] && log "DEBUG" "Zsh uses Zinit plugin manager"

  # Check for auto-installation
  if grep -q "git clone.*zinit" "$zshrc" 2>/dev/null; then
    [[ $VERBOSE -ge 1 ]] && log "SUCCESS" "Zinit auto-installation found"
  fi
  else
  log "INFO" "No Zsh plugin manager found (might be intentional)"
  fi

  return 0
}

# Test dependency verification
test_dependency_checks() {
  log "TRACE" "Testing dependency verification in setup"
  [[ $VERBOSE -ge 1 ]] && log "DEBUG" "Checking if setup verifies dependencies"

  local setup_script="$DOTFILES_DIR/src/setup/setup.sh"

  if [[ ! -f "$setup_script" ]]; then
  return 1
  fi

  # Check for command existence checks
  local commands_to_check=(
  "git"
  "curl"
  "wget"
  )

  for cmd in "${commands_to_check[@]}"; do
  if grep -q "command -v $cmd\|which $cmd\|type $cmd" "$setup_script" 2>/dev/null; then
    [[ $VERBOSE -ge 1 ]] && log "DEBUG" "Setup checks for: $cmd"
  else
    log "WARNING" "Setup might not check for: $cmd"
  fi
  done

  return 0
}

# Test idempotency - setup can be run multiple times
test_setup_idempotency() {
  log "TRACE" "Testing setup script idempotency"
  [[ $VERBOSE -ge 1 ]] && log "DEBUG" "Checking if setup can be run multiple times safely"

  local symlinks_script="$DOTFILES_DIR/src/setup/symlinks.sh"

  if [[ -f "$symlinks_script" ]]; then
  # Check for backup functionality
  if grep -q "backup\|.bak\|.old" "$symlinks_script" 2>/dev/null; then
    [[ $VERBOSE -ge 1 ]] && log "SUCCESS" "Setup creates backups (idempotent)"
  else
    log "WARNING" "Setup might not be idempotent (no backup logic found)"
  fi

  # Check for force flag
  if grep -q "force\|-f" "$symlinks_script" 2>/dev/null; then
    [[ $VERBOSE -ge 1 ]] && log "DEBUG" "Setup supports force flag"
  fi
  fi

  return 0
}

# Test error handling in setup
test_setup_error_handling() {
  log "TRACE" "Testing error handling in setup scripts"
  [[ $VERBOSE -ge 1 ]] && log "DEBUG" "Checking for proper error handling"

  local errors=0

  for setup_file in "$DOTFILES_DIR"/src/setup/*.sh; do
  [[ -f "$setup_file" ]] || continue

  local basename=$(basename "$setup_file")

  # Check for set -e or error handling
  if grep -q "set -e\|set -o errexit\|\|\| exit\|\|\| return" "$setup_file" 2>/dev/null; then
    [[ $VERBOSE -ge 1 ]] && log "DEBUG" "$basename has error handling"
  else
    log "WARNING" "$basename might lack error handling"
    ((errors++))
  fi
  done

  [[ $errors -eq 0 ]] && return 0
  return 0 # Warning only, not a failure
}

# Test logging in setup scripts
test_setup_logging() {
  log "TRACE" "Testing logging capabilities in setup"
  [[ $VERBOSE -ge 1 ]] && log "DEBUG" "Checking if setup provides adequate logging"

  local setup_script="$DOTFILES_DIR/src/setup/setup.sh"

  if [[ -f "$setup_script" ]]; then
  # Check for echo/printf statements
  local log_count=$(grep -c "echo\|printf\|log" "$setup_script" 2>/dev/null || echo 0)

  if [[ $log_count -gt 5 ]]; then
    [[ $VERBOSE -ge 1 ]] && log "SUCCESS" "Setup has logging ($log_count log statements)"
  else
    log "WARNING" "Setup has minimal logging ($log_count statements)"
  fi

  # Check for verbose mode
  if grep -q "verbose\|VERBOSE\|-v" "$setup_script" 2>/dev/null; then
    [[ $VERBOSE -ge 1 ]] && log "DEBUG" "Setup supports verbose mode"
  fi
  fi

  return 0
}
