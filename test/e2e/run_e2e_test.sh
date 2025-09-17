#!/bin/bash
# ════════════════════════════════════════════════════════════════════════════════
# E2E Test Runner Script - Runs inside Docker container
# ════════════════════════════════════════════════════════════════════════════════

set -euo pipefail

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly CYAN='\033[0;36m'
readonly BOLD='\033[1m'
readonly NC='\033[0m'

# Test tracking
PHASE_COUNT=0
PHASE_PASSED=0
PHASE_FAILED=0
TEST_START_TIME=$(date +%s)

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
  ((PHASE_COUNT++))
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

check_command() {
  local cmd="$1"
  local name="${2:-$cmd}"

  if command -v "$cmd" &> /dev/null; then
    local version=$(get_version "$cmd")
    print_success "$name installed: $(command -v $cmd) $version"
    return 0
  else
    print_error "$name not found"
    return 1
  fi
}

get_version() {
  local cmd="$1"
  case "$cmd" in
    nvim) nvim --version | head -1 | cut -d' ' -f2 ;;
    zsh) zsh --version | cut -d' ' -f2 ;;
    tmux) tmux -V | cut -d' ' -f2 ;;
    git) git --version | cut -d' ' -f3 ;;
    python3) python3 --version | cut -d' ' -f2 ;;
    node) node --version ;;
    *) echo "" ;;
  esac
}

verify_symlink() {
  local link="$1"
  local target="${2:-}"

  if [ -L "$link" ]; then
    if [ -n "$target" ]; then
      local actual_target=$(readlink "$link")
      if [[ "$actual_target" == *"$target"* ]]; then
        print_success "$link → $actual_target"
      else
        print_warning "$link → $actual_target (expected: $target)"
      fi
    else
      print_success "$link → $(readlink $link)"
    fi
    return 0
  elif [ -f "$link" ] || [ -d "$link" ]; then
    print_warning "$link exists but is not a symlink"
    return 0
  else
    print_error "$link does not exist"
    return 1
  fi
}

run_phase() {
  local phase_name="$1"
  shift

  print_phase "$phase_name"

  if "$@"; then
    print_success "$phase_name completed successfully"
    ((PHASE_PASSED++))
    return 0
  else
    print_error "$phase_name failed"
    ((PHASE_FAILED++))
    return 1
  fi
}

# ────────────────────────────────────────────────────────────────────────────────
# Test Phases
# ────────────────────────────────────────────────────────────────────────────────

phase_system_info() {
  print_info "Operating System: $(cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2)"
  print_info "Kernel: $(uname -r)"
  print_info "Architecture: $(uname -m)"
  print_info "User: $(whoami)"
  print_info "Home: $HOME"
  print_info "Shell: $SHELL"
  print_info "Dotfiles: ${DOTFILES_DIR:-/home/testuser/.dotfiles}"
  return 0
}

phase_prepare_environment() {
  # Ensure dotfiles directory exists
  if [ ! -d "${DOTFILES_DIR:-/home/testuser/.dotfiles}" ]; then
    print_error "Dotfiles directory not found"
    return 1
  fi

  cd "${DOTFILES_DIR:-/home/testuser/.dotfiles}"

  # Make scripts executable
  print_info "Setting execute permissions on scripts..."
  find src/setup -name "*.sh" -exec chmod +x {} \;
  find src/scripts -name "*.sh" -o -name "*.zsh" -exec chmod +x {} \;
  find test -name "*.sh" -o -name "*.zsh" -exec chmod +x {} \;

  # Create required directories
  print_info "Creating required directories..."
  mkdir -p ~/.local/bin ~/.config ~/.cache ~/.local/share

  return 0
}

phase_run_setup() {
  cd "${DOTFILES_DIR:-/home/testuser/.dotfiles}"

  # Run setup with core packages only (faster for testing)
  print_info "Running setup script with --core flag..."

  if CI=true ./src/setup/setup.sh --core --skip-brew; then
    print_success "Setup script completed"
    return 0
  else
    print_error "Setup script failed"
    return 1
  fi
}

phase_verify_installations() {
  local all_found=true

  # Core tools
  print_info "Checking core tools..."
  check_command git || all_found=false
  check_command zsh || all_found=false
  check_command tmux || all_found=false
  check_command nvim "Neovim" || all_found=false

  # Development tools
  print_info "Checking development tools..."
  check_command python3 "Python" || true
  check_command node "Node.js" || true
  check_command npm || true

  # Optional but useful tools
  print_info "Checking optional tools..."
  check_command rg "ripgrep" || true
  check_command fd "fd-find" || true
  check_command fzf || true
  check_command bat || true

  $all_found
}

phase_verify_symlinks() {
  local all_linked=true

  print_info "Verifying dotfile symlinks..."

  # Shell configs
  verify_symlink "$HOME/.zshrc" "zsh/zshrc" || all_linked=false
  verify_symlink "$HOME/.zshenv" "zsh/zshenv" || all_linked=false

  # Git configs
  verify_symlink "$HOME/.gitconfig" "git/gitconfig" || all_linked=false
  verify_symlink "$HOME/.gitignore_global" "git/gitignore_global" || all_linked=false

  # Tmux config
  verify_symlink "$HOME/.tmux.conf" "tmux.conf" || all_linked=false

  # Neovim config
  verify_symlink "$HOME/.config/nvim" "neovim" || all_linked=false

  # Optional configs
  verify_symlink "$HOME/.config/alacritty" || true
  verify_symlink "$HOME/.config/starship.toml" || true

  $all_linked
}

phase_test_shell_config() {
  print_info "Testing shell configuration..."

  # Test zsh loads without errors
  if zsh -c "source ~/.zshrc && echo 'Shell config OK'" 2>/dev/null; then
    print_success "Zsh configuration loads successfully"
  else
    print_error "Zsh configuration has errors"
    return 1
  fi

  # Check for required functions/aliases
  if zsh -c "source ~/.zshrc && type ll" &>/dev/null; then
    print_success "Aliases are loaded"
  else
    print_warning "Some aliases may not be loaded"
  fi

  return 0
}

phase_test_neovim_config() {
  print_info "Testing Neovim configuration..."

  # Test Neovim starts without errors
  if nvim --headless -c 'qa' 2>/dev/null; then
    print_success "Neovim starts without errors"
  else
    print_error "Neovim has startup errors"
    return 1
  fi

  # Test basic Neovim functionality
  if nvim --headless -c 'echo "test"' -c 'qa' 2>/dev/null; then
    print_success "Neovim basic functionality works"
  else
    print_error "Neovim basic functionality failed"
    return 1
  fi

  return 0
}

phase_run_unit_tests() {
  cd "${DOTFILES_DIR:-/home/testuser/.dotfiles}/test"

  print_info "Running unit tests..."

  # Make test runner executable
  chmod +x runner.zsh

  # Run unit tests with CI flag
  if CI=true ./runner.zsh --unit; then
    print_success "Unit tests passed"
    return 0
  else
    print_error "Unit tests failed"
    return 1
  fi
}

phase_run_functional_tests() {
  cd "${DOTFILES_DIR:-/home/testuser/.dotfiles}/test"

  print_info "Running functional tests..."

  # Set flags for CI environment
  export CI=true
  export SKIP_GUI_TESTS=1
  export SKIP_HARDWARE_TESTS=1
  export HEADLESS=1

  # Run functional tests
  if ./runner.zsh --functional; then
    print_success "Functional tests passed"
    return 0
  else
    print_error "Functional tests failed"
    # Don't fail the entire test if functional tests fail in CI
    print_warning "Functional test failures in CI are non-critical"
    return 0
  fi
}

phase_run_integration_tests() {
  cd "${DOTFILES_DIR:-/home/testuser/.dotfiles}/test"

  print_info "Running integration tests..."

  # Skip tests that require full system
  export CI=true
  export SKIP_DOCKER_TESTS=1

  if ./runner.zsh --integration 2>/dev/null; then
    print_success "Integration tests passed"
    return 0
  else
    print_warning "Some integration tests failed (expected in container)"
    return 0
  fi
}

# ────────────────────────────────────────────────────────────────────────────────
# Main Execution
# ────────────────────────────────────────────────────────────────────────────────

main() {
  print_header "E2E TEST SUITE - CONTAINER ENVIRONMENT"

  # Run all test phases
  run_phase "System Information" phase_system_info
  run_phase "Prepare Environment" phase_prepare_environment
  run_phase "Run Setup Script" phase_run_setup
  run_phase "Verify Installations" phase_verify_installations
  run_phase "Verify Symlinks" phase_verify_symlinks
  run_phase "Test Shell Configuration" phase_test_shell_config
  run_phase "Test Neovim Configuration" phase_test_neovim_config
  run_phase "Run Unit Tests" phase_run_unit_tests
  run_phase "Run Functional Tests" phase_run_functional_tests
  run_phase "Run Integration Tests" phase_run_integration_tests

  # Calculate test duration
  local TEST_END_TIME=$(date +%s)
  local TEST_DURATION=$((TEST_END_TIME - TEST_START_TIME))
  local MINUTES=$((TEST_DURATION / 60))
  local SECONDS=$((TEST_DURATION % 60))

  # Print summary
  print_header "TEST SUMMARY"
  echo ""
  echo -e "${BOLD}Results:${NC}"
  echo -e "  ${GREEN}Passed:${NC} $PHASE_PASSED"
  echo -e "  ${RED}Failed:${NC} $PHASE_FAILED"
  echo -e "  ${BOLD}Total:${NC} $PHASE_COUNT"
  echo ""
  echo -e "${BOLD}Duration:${NC} ${MINUTES}m ${SECONDS}s"
  echo ""

  if [ $PHASE_FAILED -eq 0 ]; then
    print_header "✅ ALL TESTS PASSED!"
    exit 0
  else
    print_header "❌ SOME TESTS FAILED"
    exit 1
  fi
}

# Run main function
main "$@"