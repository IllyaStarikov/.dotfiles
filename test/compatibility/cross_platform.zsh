#!/usr/bin/env zsh
# Compatibility Tests: Cross-Platform and Version Compatibility
# TEST_SIZE: medium
# Tests compatibility across different platforms and versions

source "${TEST_DIR}/lib/framework.zsh"

# Test OS compatibility
test_os_compatibility() {
  log "TRACE" "Testing OS compatibility"
  [[ $VERBOSE -ge 1 ]] && log "DEBUG" "Checking current OS and compatibility"

  local os_type=$(uname -s)
  [[ $VERBOSE -ge 1 ]] && log "INFO" "Current OS: $os_type"

  case "$os_type" in
  Darwin)
    # macOS specific tests
    [[ $VERBOSE -ge 1 ]] && log "INFO" "Running macOS compatibility tests"

    # Check for macOS version
    local macos_version=$(sw_vers -productVersion)
    [[ $VERBOSE -ge 1 ]] && log "INFO" "macOS version: $macos_version"

    # Check for Homebrew
    if command -v brew >/dev/null 2>&1; then
    [[ $VERBOSE -ge 1 ]] && log "SUCCESS" "Homebrew is installed"
    else
    log "WARNING" "Homebrew not found (expected on macOS)"
    fi

    # Check for macOS specific commands
    local mac_commands=(pbcopy pbpaste open defaults)
    for cmd in "${mac_commands[@]}"; do
    if command -v "$cmd" >/dev/null 2>&1; then
      [[ $VERBOSE -ge 2 ]] && log "DEBUG" "✓ macOS command: $cmd"
    else
      log "WARNING" "Missing macOS command: $cmd"
    fi
    done
    ;;

  Linux)
    # Linux specific tests
    [[ $VERBOSE -ge 1 ]] && log "INFO" "Running Linux compatibility tests"

    # Check distribution
    if [[ -f /etc/os-release ]]; then
    local distro=$(grep "^ID=" /etc/os-release | cut -d= -f2 | tr -d '"')
    [[ $VERBOSE -ge 1 ]] && log "INFO" "Linux distribution: $distro"
    fi

    # Check for common Linux commands
    local linux_commands=(xclip xsel systemctl)
    for cmd in "${linux_commands[@]}"; do
    if command -v "$cmd" >/dev/null 2>&1; then
      [[ $VERBOSE -ge 2 ]] && log "DEBUG" "✓ Linux command: $cmd"
    else
      [[ $VERBOSE -ge 2 ]] && log "DEBUG" "○ Optional Linux command not found: $cmd"
    fi
    done
    ;;

  *)
    log "WARNING" "Unknown OS: $os_type"
    ;;
  esac

  return 0
}

# Test shell compatibility
test_shell_compatibility() {
  log "TRACE" "Testing shell compatibility"
  [[ $VERBOSE -ge 1 ]] && log "DEBUG" "Checking shell versions and features"

  # Check Zsh version
  local zsh_version=$ZSH_VERSION
  [[ $VERBOSE -ge 1 ]] && log "INFO" "Zsh version: $zsh_version"

  # Check for minimum Zsh version (5.0)
  local major_version=${zsh_version%%.*}
  if [[ $major_version -ge 5 ]]; then
  [[ $VERBOSE -ge 1 ]] && log "SUCCESS" "Zsh version compatible"
  else
  log "WARNING" "Old Zsh version: $zsh_version (recommend 5.0+)"
  fi

  # Check Bash compatibility
  if command -v bash >/dev/null 2>&1; then
  local bash_version=$(bash --version | head -1)
  [[ $VERBOSE -ge 1 ]] && log "INFO" "Bash available: $bash_version"

  # Test if scripts work in Bash
  local bash_test=$(bash -c "echo 'test'" 2>&1)
  if [[ "$bash_test" == "test" ]]; then
    [[ $VERBOSE -ge 2 ]] && log "DEBUG" "Bash execution works"
  fi
  fi

  # Check POSIX sh
  if command -v sh >/dev/null 2>&1; then
  local sh_test=$(sh -c "echo 'test'" 2>&1)
  if [[ "$sh_test" == "test" ]]; then
    [[ $VERBOSE -ge 2 ]] && log "DEBUG" "POSIX sh execution works"
  fi
  fi

  return 0
}

# Test terminal compatibility
test_terminal_compatibility() {
  log "TRACE" "Testing terminal compatibility"
  [[ $VERBOSE -ge 1 ]] && log "DEBUG" "Checking terminal emulator and capabilities"

  # Check terminal type
  local term_type=$TERM
  [[ $VERBOSE -ge 1 ]] && log "INFO" "TERM: $term_type"

  # Check terminal program
  local term_program=${TERM_PROGRAM:-"unknown"}
  [[ $VERBOSE -ge 1 ]] && log "INFO" "Terminal program: $term_program"

  # Check color support
  local colors=$(tput colors 2>/dev/null || echo 0)
  [[ $VERBOSE -ge 1 ]] && log "INFO" "Terminal colors: $colors"

  if [[ $colors -ge 256 ]]; then
  [[ $VERBOSE -ge 1 ]] && log "SUCCESS" "256-color support available"
  elif [[ $colors -ge 8 ]]; then
  log "WARNING" "Limited color support: $colors colors"
  else
  log "WARNING" "No color support detected"
  fi

  # Check for true color support
  if [[ "$COLORTERM" == "truecolor" ]] || [[ "$COLORTERM" == "24bit" ]]; then
  [[ $VERBOSE -ge 1 ]] && log "SUCCESS" "True color support available"
  fi

  # Check terminal emulators
  local terminals=(alacritty kitty wezterm iterm2 gnome-terminal konsole)
  for term in "${terminals[@]}"; do
  if command -v "$term" >/dev/null 2>&1; then
    [[ $VERBOSE -ge 1 ]] && log "INFO" "Found terminal: $term"
  fi
  done

  return 0
}

# Test Neovim version compatibility
test_neovim_version_compatibility() {
  log "TRACE" "Testing Neovim version compatibility"
  [[ $VERBOSE -ge 1 ]] && log "DEBUG" "Checking Neovim version and features"

  local nvim_version=$(nvim --version | head -1)
  [[ $VERBOSE -ge 1 ]] && log "INFO" "Neovim version: $nvim_version"

  # Extract version number
  local version_number=$(nvim --version | head -1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')

  if [[ -n "$version_number" ]]; then
  local major=$(echo "$version_number" | cut -d. -f1)
  local minor=$(echo "$version_number" | cut -d. -f2)

  if [[ $major -eq 0 ]] && [[ $minor -ge 8 ]]; then
    [[ $VERBOSE -ge 1 ]] && log "SUCCESS" "Neovim version compatible (0.8+)"
  elif [[ $major -gt 0 ]]; then
    [[ $VERBOSE -ge 1 ]] && log "SUCCESS" "Neovim version compatible (1.0+)"
  else
    log "WARNING" "Old Neovim version: $version_number (recommend 0.8+)"
  fi
  fi

  # Check for Lua support
  local lua_test=$(nvim --headless -c "lua print('lua_ok')" -c "qa!" 2>&1)
  if [[ "$lua_test" == *"lua_ok"* ]]; then
  [[ $VERBOSE -ge 1 ]] && log "SUCCESS" "Lua support working"
  else
  log "ERROR" "Lua support not working"
  fi

  # Check for treesitter support
  local ts_test=$(nvim --headless -c "echo has('nvim-0.5')" -c "qa!" 2>&1)
  if [[ "$ts_test" == *"1"* ]]; then
  [[ $VERBOSE -ge 2 ]] && log "DEBUG" "Treesitter support available"
  fi

  return 0
}

# Test Git version compatibility
test_git_version_compatibility() {
  log "TRACE" "Testing Git version compatibility"
  [[ $VERBOSE -ge 1 ]] && log "DEBUG" "Checking Git version and features"

  local git_version=$(git --version)
  [[ $VERBOSE -ge 1 ]] && log "INFO" "$git_version"

  # Extract version number
  local version_number=$(git --version | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')

  if [[ -n "$version_number" ]]; then
  local major=$(echo "$version_number" | cut -d. -f1)
  local minor=$(echo "$version_number" | cut -d. -f2)

  if [[ $major -ge 2 ]]; then
    [[ $VERBOSE -ge 1 ]] && log "SUCCESS" "Git version compatible (2.0+)"
  else
    log "WARNING" "Old Git version: $version_number"
  fi
  fi

  # Check for Git features
  if git config --get-regexp alias >/dev/null 2>&1; then
  [[ $VERBOSE -ge 2 ]] && log "DEBUG" "Git aliases supported"
  fi

  if git config --global credential.helper >/dev/null 2>&1; then
  [[ $VERBOSE -ge 2 ]] && log "DEBUG" "Git credential helper configured"
  fi

  return 0
}

# Test Python compatibility
test_python_compatibility() {
  log "TRACE" "Testing Python compatibility"
  [[ $VERBOSE -ge 1 ]] && log "DEBUG" "Checking Python versions and packages"

  # Check Python 3
  if command -v python3 >/dev/null 2>&1; then
  local py3_version=$(python3 --version 2>&1)
  [[ $VERBOSE -ge 1 ]] && log "INFO" "$py3_version"

  # Check for pip
  if command -v pip3 >/dev/null 2>&1; then
    [[ $VERBOSE -ge 2 ]] && log "DEBUG" "pip3 available"
  fi

  # Check for common packages
  local py_packages=(neovim pynvim)
  for pkg in "${py_packages[@]}"; do
    if python3 -c "import $pkg" 2>/dev/null; then
    [[ $VERBOSE -ge 2 ]] && log "DEBUG" "Python package available: $pkg"
    else
    [[ $VERBOSE -ge 2 ]] && log "DEBUG" "Python package not found: $pkg"
    fi
  done
  else
  log "WARNING" "Python 3 not found"
  fi

  # Check Python 2 (legacy)
  if command -v python2 >/dev/null 2>&1; then
  log "WARNING" "Python 2 found (deprecated)"
  fi

  return 0
}

# Test Node.js compatibility
test_nodejs_compatibility() {
  log "TRACE" "Testing Node.js compatibility"
  [[ $VERBOSE -ge 1 ]] && log "DEBUG" "Checking Node.js and npm"

  if command -v node >/dev/null 2>&1; then
  local node_version=$(node --version)
  [[ $VERBOSE -ge 1 ]] && log "INFO" "Node.js version: $node_version"

  # Check npm
  if command -v npm >/dev/null 2>&1; then
    local npm_version=$(npm --version)
    [[ $VERBOSE -ge 2 ]] && log "DEBUG" "npm version: $npm_version"
  fi

  # Check for yarn
  if command -v yarn >/dev/null 2>&1; then
    local yarn_version=$(yarn --version 2>/dev/null)
    [[ $VERBOSE -ge 2 ]] && log "DEBUG" "Yarn version: $yarn_version"
  fi
  else
  log "INFO" "Node.js not installed"
  fi

  return 0
}

# Test tmux compatibility
test_tmux_compatibility() {
  log "TRACE" "Testing tmux compatibility"
  [[ $VERBOSE -ge 1 ]] && log "DEBUG" "Checking tmux version and features"

  if command -v tmux >/dev/null 2>&1; then
  local tmux_version=$(tmux -V)
  [[ $VERBOSE -ge 1 ]] && log "INFO" "$tmux_version"

  # Extract version number
  local version_number=$(tmux -V | grep -oE '[0-9]+\.[0-9]+')

  if [[ -n "$version_number" ]]; then
    local major=$(echo "$version_number" | cut -d. -f1)

    if [[ $major -ge 3 ]]; then
    [[ $VERBOSE -ge 1 ]] && log "SUCCESS" "tmux version compatible (3.0+)"
    elif [[ $major -eq 2 ]]; then
    log "WARNING" "tmux 2.x (consider upgrading to 3.0+)"
    else
    log "WARNING" "Old tmux version: $version_number"
    fi
  fi
  else
  log "INFO" "tmux not installed"
  fi

  return 0
}

# Test architecture compatibility
test_architecture_compatibility() {
  log "TRACE" "Testing architecture compatibility"
  [[ $VERBOSE -ge 1 ]] && log "DEBUG" "Checking system architecture"

  local arch=$(uname -m)
  [[ $VERBOSE -ge 1 ]] && log "INFO" "Architecture: $arch"

  case "$arch" in
  x86_64 | amd64)
    [[ $VERBOSE -ge 1 ]] && log "SUCCESS" "x86_64 architecture"
    ;;
  arm64 | aarch64)
    [[ $VERBOSE -ge 1 ]] && log "SUCCESS" "ARM64 architecture"

    # Check for Rosetta on macOS
    if [[ "$(uname)" == "Darwin" ]]; then
    if [[ -d "/Library/Apple" ]]; then
      [[ $VERBOSE -ge 2 ]] && log "DEBUG" "Apple Silicon Mac detected"
    fi
    fi
    ;;
  i386 | i686)
    log "WARNING" "32-bit architecture (limited support)"
    ;;
  *)
    log "WARNING" "Unknown architecture: $arch"
    ;;
  esac

  return 0
}

# Test locale compatibility
test_locale_compatibility() {
  log "TRACE" "Testing locale compatibility"
  [[ $VERBOSE -ge 1 ]] && log "DEBUG" "Checking locale settings"

  local lang=$LANG
  [[ $VERBOSE -ge 1 ]] && log "INFO" "LANG: ${lang:-not set}"

  # Check for UTF-8 support
  if [[ "$lang" == *"UTF-8"* ]] || [[ "$lang" == *"utf8"* ]]; then
  [[ $VERBOSE -ge 1 ]] && log "SUCCESS" "UTF-8 locale set"
  else
  log "WARNING" "Non-UTF-8 locale: $lang"
  fi

  # Check locale command
  if command -v locale >/dev/null 2>&1; then
  local all_locales=$(locale -a 2>/dev/null | wc -l)
  [[ $VERBOSE -ge 2 ]] && log "DEBUG" "Available locales: $all_locales"
  fi

  return 0
}
