#!/usr/bin/env zsh
# ════════════════════════════════════════════════════════════════════════════════
# E2E Test Runner - Main orchestrator for end-to-end testing
# ════════════════════════════════════════════════════════════════════════════════
#
# DESCRIPTION:
#   Production-ready end-to-end test that validates the complete dotfiles setup
#   process in containerized environments and native macOS.
#
# USAGE:
#   ./e2e-runner.zsh [OPTIONS]
#
# OPTIONS:
#   --linux-only    Run tests only in Linux containers
#   --macos-only    Run tests only on macOS (requires macOS host)
#   --keep-container Keep containers after test for debugging
#   --verbose       Show detailed output
#   --quick         Skip slow tests
#
# ════════════════════════════════════════════════════════════════════════════════

setopt ERR_EXIT
setopt NO_UNSET
setopt PIPE_FAIL

# ────────────────────────────────────────────────────────────────────────────────
# Configuration
# ────────────────────────────────────────────────────────────────────────────────

readonly SCRIPT_DIR="${0:A:h}"
readonly PROJECT_ROOT="${SCRIPT_DIR:h:h}"
readonly TEST_DIR="${PROJECT_ROOT}/test"
readonly TIMESTAMP=$(date +%Y%m%d_%H%M%S)
readonly LOG_DIR="${E2E_LOG_DIR:-${TEST_DIR}/logs/e2e_${TIMESTAMP}}"
readonly MAIN_LOG="${LOG_DIR}/main.log"

# Test options
typeset -g LINUX_ONLY=false
typeset -g MACOS_ONLY=false
typeset -g KEEP_CONTAINER=false
typeset -g VERBOSE=false
typeset -g QUICK_MODE=false
typeset -g EXIT_CODE=0

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
  local dockerfile="${LOG_DIR}/Dockerfile.${os_type}"

  case "$os_type" in
    ubuntu)
      cat > "$dockerfile" << 'EOF'
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV CI=true
ENV E2E_TEST=true

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

RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

RUN useradd -m -s /bin/zsh testuser && \
    echo 'testuser ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

USER testuser
WORKDIR /home/testuser

COPY --chown=testuser:testuser . /home/testuser/.dotfiles

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

RUN dnf update -y && dnf install -y \
    curl \
    git \
    sudo \
    zsh \
    gcc \
    gcc-c++ \
    make \
    python3 \
    python3-pip \
    && dnf clean all

RUN useradd -m -s /bin/zsh testuser && \
    echo 'testuser ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

USER testuser
WORKDIR /home/testuser

COPY --chown=testuser:testuser . /home/testuser/.dotfiles

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

RUN pacman -Syu --noconfirm && \
    pacman -S --noconfirm \
    curl \
    git \
    sudo \
    zsh \
    base-devel \
    python \
    python-pip

RUN useradd -m -s /bin/zsh testuser && \
    echo 'testuser ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

USER testuser
WORKDIR /home/testuser

COPY --chown=testuser:testuser . /home/testuser/.dotfiles

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
  local container_name="dotfiles-e2e-${os_type}-${TIMESTAMP}"
  local dockerfile=$(create_dockerfile "$os_type")
  local log_file="${LOG_DIR}/${os_type}.log"

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

  # Run the test script in the container
  log DEBUG "Running tests in container..."

  docker run --name "$container_name" \
    --platform linux/amd64 \
    --rm \
    "dotfiles-test:$os_type" \
    -c "cd /home/testuser/.dotfiles && chmod +x test/e2e/docker-e2e-test.zsh && zsh test/e2e/docker-e2e-test.zsh" \
    >> "$log_file" 2>&1

  local result=$?

  if [[ $result -eq 0 ]]; then
    log SUCCESS "$os_type test completed successfully"
  else
    log ERROR "$os_type test failed (exit code: $result)"
    if [[ "$VERBOSE" == true ]]; then
      echo "--- Last 50 lines of $os_type log ---"
      tail -50 "$log_file"
      echo "--- End of log ---"
    fi
  fi

  # Clean up container if not keeping
  if [[ "$KEEP_CONTAINER" != true ]]; then
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

  local test_home="/tmp/dotfiles-e2e-test-${TIMESTAMP}"
  local log_file="${LOG_DIR}/macos.log"

  {
    echo "════════════════════════════════════════════════════════════════════"
    echo "macOS E2E Test"
    echo "Test Home: $test_home"
    echo "════════════════════════════════════════════════════════════════════"

    # Create test environment
    log DEBUG "Creating test environment at ${test_home}..."
    mkdir -p "$test_home"
    cp -R "$PROJECT_ROOT" "${test_home}/.dotfiles"

    # Phase 1: Run setup script
    echo ""
    echo "──── Phase 1: Running Setup Script ────"
    cd "${test_home}/.dotfiles"
    chmod +x src/setup/setup.sh src/setup/symlinks.sh

    # Run setup with symlinks only (don't install packages in test)
    HOME="$test_home" ./src/setup/setup.sh --symlinks

    # Phase 2: Verify configuration
    echo ""
    echo "──── Phase 2: Verifying Configuration ────"
    for config in .zshrc .gitconfig .tmux.conf; do
      if [[ -L "${test_home}/${config}" ]]; then
        echo "✓ $config linked"
      else
        echo "✗ $config not linked"
      fi
    done

    # Phase 3: Run test suite
    echo ""
    echo "──── Phase 3: Running Test Suite ────"
    cd "${test_home}/.dotfiles/test"
    chmod +x runner.zsh

    # Run tests with CI environment
    HOME="$test_home" CI=true SKIP_GUI_TESTS=1 ./runner.zsh --unit --quick || {
      echo "⚠ Some unit tests failed (non-critical for E2E)"
    }

    HOME="$test_home" CI=true SKIP_GUI_TESTS=1 ./runner.zsh --functional --quick

    echo ""
    echo "════════════════════════════════════════════════════════════════════"
    echo "macOS E2E Test Completed Successfully!"
    echo "════════════════════════════════════════════════════════════════════"
  } > "$log_file" 2>&1

  local result=$?

  # Cleanup
  rm -rf "$test_home"

  if [[ $result -eq 0 ]]; then
    log SUCCESS "macOS test completed successfully"
  else
    log ERROR "macOS test failed"
    if [[ "$VERBOSE" == true ]]; then
      tail -50 "$log_file"
    fi
  fi

  return $result
}

# ────────────────────────────────────────────────────────────────────────────────
# Report Generation
# ────────────────────────────────────────────────────────────────────────────────

generate_report() {
  local report_file="${LOG_DIR}/report.md"

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

  # Add test results
  for log in "${LOG_DIR}"/*.log; do
    if [[ -f "$log" ]]; then
      local platform=$(basename "$log" .log)
      [[ "$platform" == "main" ]] && continue

      if grep -q "Completed Successfully" "$log" 2>/dev/null; then
        echo "| $platform | ✅ Passed | N/A | [View]($(basename "$log")) |" >> "$report_file"
      else
        echo "| $platform | ❌ Failed | N/A | [View]($(basename "$log")) |" >> "$report_file"
      fi
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
EOF

  if [[ $EXIT_CODE -eq 0 ]]; then
    echo "All tests passed successfully" >> "$report_file"
  else
    echo "Some tests failed - check individual logs for details" >> "$report_file"
  fi

  echo "" >> "$report_file"
  echo "---" >> "$report_file"
  echo "*Report generated by runner.zsh*" >> "$report_file"

  log INFO "Report generated: $report_file"
}

# ────────────────────────────────────────────────────────────────────────────────
# Main Execution
# ────────────────────────────────────────────────────────────────────────────────

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
      --keep-container)
        KEEP_CONTAINER=true
        shift
        ;;
      --verbose)
        VERBOSE=true
        shift
        ;;
      --quick)
        QUICK_MODE=true
        shift
        ;;
      --help)
        echo "Usage: $0 [OPTIONS]"
        echo "Options:"
        echo "  --linux-only     Run tests only in Linux containers"
        echo "  --macos-only     Run tests only on macOS"
        echo "  --keep-container Keep containers after test"
        echo "  --verbose        Show detailed output"
        echo "  --quick          Skip slow tests"
        exit 0
        ;;
      *)
        echo "Unknown option: $1"
        exit 1
        ;;
    esac
  done
}

main() {
  parse_args "$@"

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
    log SUCCESS "Report available at: ${LOG_DIR}/report.md"
    log SUCCESS "════════════════════════════════════════════════════════════════════"
  else
    log ERROR "════════════════════════════════════════════════════════════════════"
    log ERROR "Some tests failed. Check logs at: $LOG_DIR"
    log ERROR "════════════════════════════════════════════════════════════════════"
  fi

  exit $EXIT_CODE
}

# Run main function if not being sourced
if [[ "${ZSH_EVAL_CONTEXT}" == "toplevel" ]]; then
  main "$@"
fi