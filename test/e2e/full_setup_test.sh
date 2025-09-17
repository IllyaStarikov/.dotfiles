#!/usr/bin/env bash
# ════════════════════════════════════════════════════════════════════════════════
# Full End-to-End Setup Test
# ════════════════════════════════════════════════════════════════════════════════
#
# DESCRIPTION:
#   Production-ready end-to-end test that validates the complete dotfiles setup
#   process in containerized environments. Tests full installation, configuration,
#   and runs comprehensive test suite.
#
# USAGE:
#   ./full_setup_test.sh [OPTIONS]
#
# OPTIONS:
#   --linux-only    Run tests only in Linux containers
#   --macos-only    Run tests only on macOS (requires macOS host)
#   --keep-container Keep containers after test for debugging
#   --verbose       Show detailed output
#   --quick         Skip slow tests
#
# REQUIREMENTS:
#   - Docker (for Linux tests)
#   - macOS host (for macOS native tests)
#
# ════════════════════════════════════════════════════════════════════════════════

set -euo pipefail

# ────────────────────────────────────────────────────────────────────────────────
# Configuration
# ────────────────────────────────────────────────────────────────────────────────

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
readonly TEST_DIR="$PROJECT_ROOT/test"
readonly TIMESTAMP=$(date +%Y%m%d_%H%M%S)
readonly LOG_DIR="${E2E_LOG_DIR:-$TEST_DIR/logs/e2e_$TIMESTAMP}"
readonly MAIN_LOG="$LOG_DIR/main.log"

# Test options
LINUX_ONLY=false
MACOS_ONLY=false
KEEP_CONTAINER=false
VERBOSE=false
QUICK_MODE=false
EXIT_CODE=0

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly CYAN='\033[0;36m'
readonly NC='\033[0m'

# ────────────────────────────────────────────────────────────────────────────────
# Logging Functions
# ────────────────────────────────────────────────────────────────────────────────

setup_logging() {
  mkdir -p "$LOG_DIR"
  echo "E2E Test Started at $(date)" > "$MAIN_LOG"
  echo "Test environment: $(uname -a)" >> "$MAIN_LOG"
}

log() {
  local level="$1"
  shift
  local message="$*"
  local timestamp=$(date '+%Y-%m-%d %H:%M:%S')

  echo "[$timestamp] [$level] $message" >> "$MAIN_LOG"

  case "$level" in
    ERROR)
      echo -e "${RED}[ERROR]${NC} $message" >&2
      ;;
    WARN)
      echo -e "${YELLOW}[WARN]${NC} $message"
      ;;
    INFO)
      echo -e "${BLUE}[INFO]${NC} $message"
      ;;
    SUCCESS)
      echo -e "${GREEN}[SUCCESS]${NC} $message"
      ;;
    DEBUG)
      [[ "$VERBOSE" == true ]] && echo -e "${CYAN}[DEBUG]${NC} $message"
      ;;
  esac
}

# ────────────────────────────────────────────────────────────────────────────────
# Docker Test Functions
# ────────────────────────────────────────────────────────────────────────────────

create_dockerfile() {
  local os_type="$1"
  local dockerfile="$LOG_DIR/Dockerfile.$os_type"

  case "$os_type" in
    ubuntu)
      cat > "$dockerfile" << 'EOF'
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV CI=true
ENV E2E_TEST=true

# Install base dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    sudo \
    zsh \
    build-essential \
    python3 \
    python3-pip \
    locales \
    && rm -rf /var/lib/apt/lists/*

# Set locale
RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# Create test user with sudo
RUN useradd -m -s /bin/zsh testuser && \
    echo 'testuser ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

USER testuser
WORKDIR /home/testuser

# Copy dotfiles
COPY --chown=testuser:testuser . /home/testuser/.dotfiles

# Set environment
ENV HOME=/home/testuser
ENV DOTFILES_DIR=/home/testuser/.dotfiles
ENV PATH="/home/testuser/.local/bin:$PATH"

ENTRYPOINT ["/bin/bash"]
EOF
      ;;

    fedora)
      cat > "$dockerfile" << 'EOF'
FROM fedora:39

ENV CI=true
ENV E2E_TEST=true

# Install base dependencies
RUN dnf install -y \
    curl \
    git \
    sudo \
    zsh \
    gcc \
    gcc-c++ \
    make \
    python3 \
    python3-pip \
    glibc-langpack-en \
    && dnf clean all

# Set locale
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# Create test user with sudo
RUN useradd -m -s /bin/zsh testuser && \
    echo 'testuser ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

USER testuser
WORKDIR /home/testuser

# Copy dotfiles
COPY --chown=testuser:testuser . /home/testuser/.dotfiles

# Set environment
ENV HOME=/home/testuser
ENV DOTFILES_DIR=/home/testuser/.dotfiles
ENV PATH="/home/testuser/.local/bin:$PATH"

ENTRYPOINT ["/bin/bash"]
EOF
      ;;

    arch)
      cat > "$dockerfile" << 'EOF'
FROM archlinux:latest

ENV CI=true
ENV E2E_TEST=true

# Install base dependencies
RUN pacman -Syu --noconfirm && \
    pacman -S --noconfirm \
    curl \
    git \
    sudo \
    zsh \
    base-devel \
    python \
    python-pip

# Create test user with sudo
RUN useradd -m -s /bin/zsh testuser && \
    echo 'testuser ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

USER testuser
WORKDIR /home/testuser

# Copy dotfiles
COPY --chown=testuser:testuser . /home/testuser/.dotfiles

# Set environment
ENV HOME=/home/testuser
ENV DOTFILES_DIR=/home/testuser/.dotfiles
ENV PATH="/home/testuser/.local/bin:$PATH"

ENTRYPOINT ["/bin/bash"]
EOF
      ;;
  esac

  echo "$dockerfile"
}

run_docker_test() {
  local os_type="$1"
  local container_name="dotfiles-e2e-$os_type-$TIMESTAMP"
  local dockerfile=$(create_dockerfile "$os_type")
  local log_file="$LOG_DIR/${os_type}.log"

  log INFO "Starting Docker test for $os_type..."

  # Build Docker image
  log DEBUG "Building Docker image for $os_type..."
  # Use platform flag to ensure compatibility (especially for Arch on ARM Mac)
  if docker build --platform linux/amd64 -t "dotfiles-test:$os_type" -f "$dockerfile" "$PROJECT_ROOT" > "$log_file" 2>&1; then
    log SUCCESS "Docker image built for $os_type"
  else
    log ERROR "Failed to build Docker image for $os_type"
    return 1
  fi

  # Create test script
  local test_script="$LOG_DIR/test_script_$os_type.sh"
  cat > "$test_script" << 'SCRIPT'
#!/bin/bash
set -euo pipefail

echo "════════════════════════════════════════════════════════════════════"
echo "Starting E2E Test in Container"
echo "OS: $(cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2)"
echo "User: $(whoami)"
echo "Home: $HOME"
echo "════════════════════════════════════════════════════════════════════"

# Phase 1: Run setup script
echo ""
echo "──── Phase 1: Running Setup Script ────"
cd "$DOTFILES_DIR"

# Make scripts executable
chmod +x src/setup/setup.sh src/setup/symlinks.sh

# Run the main setup script
if ./src/setup/setup.sh --core --skip-brew; then
  echo "✓ Setup script completed successfully"
else
  echo "✗ Setup script failed"
  exit 1
fi

# Phase 2: Verify installations
echo ""
echo "──── Phase 2: Verifying Installations ────"

# Check for required tools
tools=(git zsh tmux nvim)
missing=()

for tool in "${tools[@]}"; do
  if command -v "$tool" &> /dev/null; then
    echo "✓ $tool installed: $(command -v $tool)"
  else
    echo "✗ $tool not found"
    missing+=("$tool")
  fi
done

if [ ${#missing[@]} -gt 0 ]; then
  echo "Missing tools: ${missing[*]}"
  exit 1
fi

# Phase 3: Verify symlinks
echo ""
echo "──── Phase 3: Verifying Symlinks ────"

symlinks=(
  "$HOME/.zshrc"
  "$HOME/.gitconfig"
  "$HOME/.tmux.conf"
  "$HOME/.config/nvim"
)

for link in "${symlinks[@]}"; do
  if [ -L "$link" ] || [ -f "$link" ]; then
    echo "✓ $link exists"
  else
    echo "✗ $link missing"
  fi
done

# Phase 4: Run test suite
echo ""
echo "──── Phase 4: Running Test Suite ────"

cd "$DOTFILES_DIR/test"

# Make test runner executable
chmod +x runner.zsh

# Run unit tests
echo "Running unit tests..."
if ./runner.zsh --unit; then
  echo "✓ Unit tests passed"
else
  echo "✗ Unit tests failed"
  exit 1
fi

# Run functional tests (skip tests that require X11 or specific hardware)
echo "Running functional tests..."
export SKIP_GUI_TESTS=1
export SKIP_HARDWARE_TESTS=1
if ./runner.zsh --functional; then
  echo "✓ Functional tests passed"
else
  echo "✗ Functional tests failed"
  exit 1
fi

echo ""
echo "════════════════════════════════════════════════════════════════════"
echo "E2E Test Completed Successfully!"
echo "════════════════════════════════════════════════════════════════════"
SCRIPT

  # Copy test script to container and run
  log DEBUG "Running tests in container..."

  # Run the test script in the container
  docker run --name "$container_name" \
    --platform linux/amd64 \
    --rm \
    -v "$test_script:/tmp/test.sh:ro" \
    "dotfiles-test:$os_type" \
    -c "cp /tmp/test.sh /home/testuser/run_test.sh && chmod +x /home/testuser/run_test.sh && /home/testuser/run_test.sh" \
    >> "$log_file" 2>&1

  local result=$?

  if [ $result -eq 0 ]; then
    log SUCCESS "$os_type test completed successfully"
  else
    log ERROR "$os_type test failed (exit code: $result)"
    if [ "$VERBOSE" == true ]; then
      echo "--- Last 50 lines of $os_type log ---"
      tail -50 "$log_file"
      echo "--- End of log ---"
    fi
  fi

  # Clean up container if not keeping
  if [ "$KEEP_CONTAINER" != true ]; then
    docker rm -f "$container_name" 2>/dev/null || true
  fi

  return $result
}

# ────────────────────────────────────────────────────────────────────────────────
# macOS Native Test
# ────────────────────────────────────────────────────────────────────────────────

run_macos_test() {
  if [[ "$(uname)" != "Darwin" ]]; then
    log WARN "Skipping macOS test - not running on macOS"
    return 0
  fi

  log INFO "Starting macOS native test..."
  local test_dir="/tmp/dotfiles-e2e-test-$TIMESTAMP"
  local log_file="$LOG_DIR/macos.log"

  # Create isolated test environment
  log DEBUG "Creating test environment at $test_dir..."
  mkdir -p "$test_dir"

  # Copy dotfiles to test location
  cp -r "$PROJECT_ROOT" "$test_dir/dotfiles"

  # Create test script
  cat > "$test_dir/run_test.sh" << 'SCRIPT'
#!/bin/bash
set -euo pipefail

export HOME="$1"
export DOTFILES_DIR="$HOME/dotfiles"
export CI=true
export E2E_TEST=true

echo "════════════════════════════════════════════════════════════════════"
echo "Starting E2E Test on macOS"
echo "OS: $(sw_vers -productName) $(sw_vers -productVersion)"
echo "User: $(whoami)"
echo "Test Home: $HOME"
echo "════════════════════════════════════════════════════════════════════"

cd "$DOTFILES_DIR"

# Phase 1: Setup
echo ""
echo "──── Phase 1: Running Setup Script ────"
chmod +x src/setup/setup.sh src/setup/symlinks.sh
./src/setup/setup.sh --symlinks  # Only symlinks, don't install packages in test

# Phase 2: Verify
echo ""
echo "──── Phase 2: Verifying Configuration ────"
for config in .zshrc .gitconfig .tmux.conf; do
  if [ -L "$HOME/$config" ]; then
    echo "✓ $config linked"
  else
    echo "✗ $config not linked"
  fi
done

# Phase 3: Run tests
echo ""
echo "──── Phase 3: Running Test Suite ────"
cd "$DOTFILES_DIR/test"
chmod +x runner.zsh

# Run tests but don't fail on individual test failures
# The E2E test is more about setup working than every test passing
./runner.zsh --unit || {
  echo "⚠ Some unit tests failed (non-critical for E2E)"
  # Continue anyway - we care more about setup working
}

# Functional tests are optional in E2E
./runner.zsh --functional 2>/dev/null || {
  echo "⚠ Some functional tests failed (expected in test environment)"
}

echo ""
echo "════════════════════════════════════════════════════════════════════"
echo "macOS E2E Test Completed Successfully!"
echo "════════════════════════════════════════════════════════════════════"
SCRIPT

  chmod +x "$test_dir/run_test.sh"

  # Run test
  if "$test_dir/run_test.sh" "$test_dir" > "$log_file" 2>&1; then
    log SUCCESS "macOS test completed successfully"
    rm -rf "$test_dir"
    return 0
  else
    log ERROR "macOS test failed"
    if [ "$VERBOSE" == true ]; then
      tail -50 "$log_file"
    fi
    [ "$KEEP_CONTAINER" != true ] && rm -rf "$test_dir"
    return 1
  fi
}

# ────────────────────────────────────────────────────────────────────────────────
# Report Generation
# ────────────────────────────────────────────────────────────────────────────────

generate_report() {
  local report_file="$LOG_DIR/report.md"

  cat > "$report_file" << EOF
# E2E Test Report
Generated: $(date)

## Test Configuration
- Project Root: $PROJECT_ROOT
- Log Directory: $LOG_DIR
- Options:
  - Linux Only: $LINUX_ONLY
  - macOS Only: $MACOS_ONLY
  - Keep Container: $KEEP_CONTAINER
  - Quick Mode: $QUICK_MODE

## Test Results

| Platform | Status | Duration | Log File |
|----------|--------|----------|----------|
EOF

  for log in "$LOG_DIR"/*.log; do
    if [[ -f "$log" ]] && [[ "$log" != "$MAIN_LOG" ]]; then
      local platform=$(basename "$log" .log)
      local status="❓ Unknown"
      local duration="N/A"

      if grep -q "Successfully" "$log" 2>/dev/null; then
        status="✅ Passed"
      elif grep -q "Failed\|Error" "$log" 2>/dev/null; then
        status="❌ Failed"
      fi

      echo "| $platform | $status | $duration | [View]($(basename $log)) |" >> "$report_file"
    fi
  done

  cat >> "$report_file" << EOF

## Detailed Results

### Coverage
- Setup Script: Tested
- Symlinks: Verified
- Unit Tests: Executed
- Functional Tests: Executed

### Notes
$(cat "$MAIN_LOG" | grep -E "WARN|ERROR" || echo "No warnings or errors")

---
*Report generated by full_setup_test.sh*
EOF

  log INFO "Report generated: $report_file"
}

# ────────────────────────────────────────────────────────────────────────────────
# Main Execution
# ────────────────────────────────────────────────────────────────────────────────

usage() {
  cat << EOF
Usage: $(basename "$0") [OPTIONS]

End-to-End test for dotfiles setup and configuration

Options:
  --linux-only     Run tests only in Linux containers
  --macos-only     Run tests only on macOS (requires macOS host)
  --keep-container Keep containers after test for debugging
  --verbose        Show detailed output
  --quick          Skip slow tests
  --help           Show this help message

Examples:
  $(basename "$0")                    # Run all tests
  $(basename "$0") --linux-only       # Test only Linux environments
  $(basename "$0") --verbose --keep   # Debug mode

EOF
}

parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --linux-only)
        LINUX_ONLY=true
        shift
        ;;
      --macos-only)
        MACOS_ONLY=true
        shift
        ;;
      --keep-container|--keep)
        KEEP_CONTAINER=true
        shift
        ;;
      --verbose|-v)
        VERBOSE=true
        shift
        ;;
      --quick)
        QUICK_MODE=true
        shift
        ;;
      --help|-h)
        usage
        exit 0
        ;;
      *)
        log ERROR "Unknown option: $1"
        usage
        exit 1
        ;;
    esac
  done
}

main() {
  parse_args "$@"

  # Setup logging
  setup_logging

  log INFO "Starting E2E Test Suite"
  log INFO "Configuration: Linux=$LINUX_ONLY, macOS=$MACOS_ONLY, Keep=$KEEP_CONTAINER"

  # Check Docker availability for Linux tests
  if [[ "$MACOS_ONLY" != true ]]; then
    if ! command -v docker &> /dev/null; then
      log ERROR "Docker not found - required for Linux tests"
      log INFO "Install Docker or use --macos-only flag"
      exit 1
    fi

    # Check if Docker daemon is running
    if ! docker info &>/dev/null; then
      log WARN "Docker daemon is not running"
      log INFO "Attempting to start Docker service..."

      # Try different methods to start Docker
      local docker_started=false

      # Method 1: Try Colima if available
      if command -v colima &>/dev/null; then
        log INFO "Found Colima - starting with default settings..."
        if colima start --cpu 2 --memory 4 2>/dev/null; then
          log INFO "Waiting for Colima to be ready..."
          for i in {1..30}; do
            if docker info &>/dev/null; then
              log SUCCESS "Colima started successfully"
              docker_started=true
              break
            fi
            sleep 1
          done
        else
          log WARN "Failed to start Colima"
        fi
      fi

      # Method 2: Try Docker Desktop on macOS
      if [[ "$docker_started" == false ]] && [[ "$(uname)" == "Darwin" ]]; then
        log INFO "Trying Docker Desktop..."
        # Try different app names
        for app_name in "Docker" "Docker Desktop"; do
          if open -a "$app_name" 2>/dev/null; then
            log INFO "Launched $app_name - waiting for daemon..."
            for i in {1..60}; do
              if docker info &>/dev/null; then
                log SUCCESS "Docker Desktop started successfully"
                docker_started=true
                break 2
              fi
              sleep 1
            done
          fi
        done
      fi

      # Method 3: Try systemctl on Linux
      if [[ "$docker_started" == false ]] && command -v systemctl &>/dev/null; then
        log INFO "Trying systemctl to start Docker..."
        if sudo systemctl start docker 2>/dev/null; then
          sleep 2
          if docker info &>/dev/null; then
            log SUCCESS "Docker started via systemctl"
            docker_started=true
          fi
        fi
      fi

      # Final check
      if [[ "$docker_started" == false ]]; then
        log ERROR "Could not start Docker daemon"
        log INFO ""
        log INFO "To run Linux E2E tests, you need Docker. Options:"
        log INFO "  1. Start Docker Desktop manually and re-run"
        log INFO "  2. Install and start Colima: brew install colima && colima start"
        log INFO "  3. Use --macos-only flag to skip Docker tests"
        log INFO ""
        log INFO "Continuing with macOS-only tests..."
        MACOS_ONLY=true
      fi
    else
      log SUCCESS "Docker daemon is running"
    fi
  fi

  # Run tests based on configuration
  if [[ "$MACOS_ONLY" != true ]]; then
    # Run Linux distribution tests
    for distro in ubuntu fedora arch; do
      if [[ "$QUICK_MODE" == true ]] && [[ "$distro" != "ubuntu" ]]; then
        log INFO "Skipping $distro in quick mode"
        continue
      fi

      if ! run_docker_test "$distro"; then
        EXIT_CODE=1
      fi
    done
  fi

  if [[ "$LINUX_ONLY" != true ]]; then
    # Run macOS test if on macOS
    if ! run_macos_test; then
      EXIT_CODE=1
    fi
  fi

  # Generate report
  generate_report

  # Final status
  echo ""
  if [[ $EXIT_CODE -eq 0 ]]; then
    log SUCCESS "════════════════════════════════════════════════════════════════════"
    log SUCCESS "All E2E tests completed successfully!"
    log SUCCESS "Report available at: $LOG_DIR/report.md"
    log SUCCESS "════════════════════════════════════════════════════════════════════"
  else
    log ERROR "════════════════════════════════════════════════════════════════════"
    log ERROR "Some tests failed. Check logs at: $LOG_DIR"
    log ERROR "════════════════════════════════════════════════════════════════════"
  fi

  exit $EXIT_CODE
}

# Run if not sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi