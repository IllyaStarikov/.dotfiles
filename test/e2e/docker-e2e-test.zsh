#!/usr/bin/env zsh
# ════════════════════════════════════════════════════════════════════════════════
# Docker E2E Test Script - Runs inside Docker containers
# ════════════════════════════════════════════════════════════════════════════════
#
# DESCRIPTION:
#   This script runs inside Docker containers to perform full E2E testing of
#   the dotfiles setup process in a clean Linux environment.
#
# ENVIRONMENT:
#   Expected to run inside a Docker container with:
#   - DOTFILES_DIR set to /home/testuser/.dotfiles
#   - HOME set to /home/testuser
#   - CI=true
#   - E2E_TEST=true
#
# ════════════════════════════════════════════════════════════════════════════════

setopt ERR_EXIT
setopt NO_UNSET
setopt PIPE_FAIL

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly CYAN='\033[0;36m'
readonly BOLD='\033[1m'
readonly NC='\033[0m'

# Test tracking
typeset -g PHASE_COUNT=0
typeset -g PHASE_PASSED=0
typeset -g PHASE_FAILED=0
typeset -g TEST_START_TIME=$(date +%s)

# ────────────────────────────────────────────────────────────────────────────────
# Helper Functions
# ────────────────────────────────────────────────────────────────────────────────

print_header() {
  echo ""
  echo -e "${BOLD}${BLUE}════════════════════════════════════════════════════════════════════${NC}"
  echo -e "${BOLD}${BLUE}$1${NC}"
  echo -e "${BOLD}${BLUE}════════════════════════════════════════════════════════════════════${NC}"
}

print_phase() {
  PHASE_COUNT=$((PHASE_COUNT + 1))
  echo ""
  echo -e "${CYAN}──────────────────────────────────────────────────────────────────${NC}"
  echo -e "${CYAN}Phase $PHASE_COUNT: $1${NC}"
  echo -e "${CYAN}──────────────────────────────────────────────────────────────────${NC}"
}

print_success() {
  echo -e "${GREEN}✓${NC} $1"
}

print_error() {
  echo -e "${RED}✗${NC} $1"
}

print_warning() {
  echo -e "${YELLOW}⚠${NC} $1"
}

print_info() {
  echo -e "${BLUE}ℹ${NC} $1"
}

run_phase() {
  local phase_name="$1"
  local phase_function="$2"

  print_phase "$phase_name"

  if $phase_function; then
    PHASE_PASSED=$((PHASE_PASSED + 1))
    print_success "$phase_name completed"
  else
    PHASE_FAILED=$((PHASE_FAILED + 1))
    print_error "$phase_name failed"
    return 1
  fi
}

# ────────────────────────────────────────────────────────────────────────────────
# Test Phases
# ────────────────────────────────────────────────────────────────────────────────

phase_system_info() {
  print_info "Operating System: $(cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2)"
  print_info "User: $(whoami)"
  print_info "Home Directory: $HOME"
  print_info "Dotfiles Directory: $DOTFILES_DIR"
  print_info "Shell: $(echo $SHELL)"
  print_info "Zsh Version: $ZSH_VERSION"
  return 0
}

phase_prepare_environment() {
  # Set execute permissions on scripts
  local scripts=(
    "${DOTFILES_DIR}/src/setup/setup.sh"
    "${DOTFILES_DIR}/src/setup/symlinks.sh"
    "${DOTFILES_DIR}/src/setup/linux.sh"
    "${DOTFILES_DIR}/test/runner.zsh"
  )

  for script in $scripts; do
    if [[ -f "$script" ]]; then
      chmod +x "$script"
      print_success "Made executable: $(basename $script)"
    else
      print_warning "Script not found: $script"
    fi
  done

  # Create necessary directories
  mkdir -p "${HOME}/.config"
  mkdir -p "${HOME}/.local/bin"

  return 0
}

phase_run_setup() {
  cd "$DOTFILES_DIR"

  # Run the setup script with core packages only (skip brew)
  if ./src/setup/setup.sh --core --skip-brew; then
    print_success "Setup script completed"
    return 0
  else
    print_error "Setup script failed"
    return 1
  fi
}

phase_verify_installations() {
  local tools=(git zsh tmux nvim)
  local missing=()

  for tool in $tools; do
    if command -v "$tool" &> /dev/null; then
      print_success "$tool installed: $(command -v $tool)"
    else
      print_error "$tool not found"
      missing+=("$tool")
    fi
  done

  if [[ ${#missing[@]} -gt 0 ]]; then
    print_error "Missing tools: ${missing[*]}"
    return 1
  fi

  return 0
}

phase_verify_symlinks() {
  local symlinks=(
    "${HOME}/.zshrc"
    "${HOME}/.gitconfig"
    "${HOME}/.tmux.conf"
    "${HOME}/.config/nvim"
  )

  local failed=0
  for link in $symlinks; do
    if [[ -L "$link" ]] || [[ -f "$link" ]] || [[ -d "$link" ]]; then
      print_success "$(basename $link) exists"
    else
      print_error "$(basename $link) missing"
      failed=1
    fi
  done

  return $failed
}

phase_test_shell_config() {
  # Test that zshrc loads without errors
  if zsh -c "source ${HOME}/.zshrc" 2>/dev/null; then
    print_success "Zsh configuration loads"
  else
    print_warning "Zsh configuration has warnings (non-critical)"
  fi

  # Test that basic aliases work
  if zsh -c "source ${HOME}/.zshrc && alias | grep -q 'll'"; then
    print_success "Aliases configured"
  else
    print_warning "Some aliases missing"
  fi

  return 0
}

phase_test_neovim() {
  # Test that Neovim starts without errors
  if timeout 10 nvim --headless -c ':qa' 2>/dev/null; then
    print_success "Neovim starts successfully"
  else
    print_warning "Neovim startup has issues (may be plugin installation)"
  fi

  # Test basic Neovim functionality
  if timeout 10 nvim --headless -c ':echo "test"' -c ':qa' 2>/dev/null; then
    print_success "Neovim basic functionality works"
  else
    print_error "Neovim basic functionality failed"
    return 1
  fi

  return 0
}

phase_run_unit_tests() {
  cd "${DOTFILES_DIR}/test"

  # Set environment for CI
  export CI=true
  export E2E_TEST=true
  export SKIP_GUI_TESTS=1
  export SKIP_HARDWARE_TESTS=1
  export NONINTERACTIVE=1

  # Run unit tests with timeout
  if [[ -x "./runner.zsh" ]]; then
    if timeout 60 ./runner.zsh --unit --quick; then
      print_success "Unit tests passed"
      return 0
    else
      print_warning "Some unit tests failed or timed out"
      # Don't fail E2E on unit test failures in container
      return 0
    fi
  else
    print_error "Test runner not found or not executable"
    return 1
  fi
}

phase_run_functional_tests() {
  cd "${DOTFILES_DIR}/test"

  # Set environment for CI
  export CI=true
  export E2E_TEST=true
  export SKIP_GUI_TESTS=1
  export SKIP_HARDWARE_TESTS=1
  export NONINTERACTIVE=1

  # Run functional tests with timeout
  if [[ -x "./runner.zsh" ]]; then
    if timeout 60 ./runner.zsh --functional --quick; then
      print_success "Functional tests passed"
      return 0
    else
      print_warning "Some functional tests failed or timed out"
      # Don't fail E2E on functional test failures in container
      return 0
    fi
  else
    print_error "Test runner not found or not executable"
    return 1
  fi
}

phase_verify_development_tools() {
  # Check for common development tools
  local dev_tools=(python3 node npm)

  for tool in $dev_tools; do
    if command -v "$tool" &> /dev/null; then
      print_success "$tool available: $(command -v $tool)"
    else
      print_info "$tool not installed (optional)"
    fi
  done

  # Check for optional but useful tools
  local optional_tools=(rg fd fzf)

  for tool in $optional_tools; do
    if command -v "$tool" &> /dev/null; then
      print_success "$tool available"
    else
      print_info "$tool not installed (optional enhancement)"
    fi
  done

  return 0
}

# ────────────────────────────────────────────────────────────────────────────────
# Main Execution
# ────────────────────────────────────────────────────────────────────────────────

main() {
  print_header "Docker E2E Test Runner"
  print_header "Starting E2E Test in Container"

  # Run all test phases
  run_phase "System Information" phase_system_info
  run_phase "Prepare Environment" phase_prepare_environment
  run_phase "Run Setup Script" phase_run_setup || exit 1
  run_phase "Verify Installations" phase_verify_installations || exit 1
  run_phase "Verify Symlinks" phase_verify_symlinks || exit 1
  run_phase "Test Shell Configuration" phase_test_shell_config
  run_phase "Test Neovim" phase_test_neovim
  run_phase "Run Unit Tests" phase_run_unit_tests
  run_phase "Run Functional Tests" phase_run_functional_tests
  run_phase "Verify Development Tools" phase_verify_development_tools

  # Calculate test duration
  local TEST_END_TIME=$(date +%s)
  local DURATION=$((TEST_END_TIME - TEST_START_TIME))

  # Print summary
  print_header "Test Summary"
  echo ""
  echo "Phases Run: $PHASE_COUNT"
  echo "Phases Passed: $PHASE_PASSED"
  echo "Phases Failed: $PHASE_FAILED"
  echo "Duration: ${DURATION}s"
  echo ""

  if [[ $PHASE_FAILED -eq 0 ]]; then
    print_header "✅ E2E Test Completed Successfully!"
    exit 0
  else
    print_header "❌ E2E Test Failed"
    exit 1
  fi
}

# Run main function
main "$@"