#!/usr/bin/env zsh
# ════════════════════════════════════════════════════════════════════════════════
# E2E Test Runner - Docker-based testing for dotfiles
# ════════════════════════════════════════════════════════════════════════════════
#
# DESCRIPTION:
#   Runs end-to-end tests in Docker containers to validate the complete dotfiles
#   setup process in clean Linux environments.
#
# USAGE:
#   ./runner.zsh [--debug]
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
typeset -g EXIT_CODE=0
typeset -g DEBUG_MODE=false

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
      echo -e "${CYAN}[DEBUG]${NC} $message"
      ;;
  esac
}

# ────────────────────────────────────────────────────────────────────────────────
# Docker Functions
# ────────────────────────────────────────────────────────────────────────────────

check_docker() {
  if ! command -v docker &> /dev/null; then
    log ERROR "Docker not found. Please install Docker."
    exit 1
  fi

  if ! docker info &>/dev/null; then
    log WARN "Docker daemon is not running"
    log INFO "Attempting to start Docker..."

    # Try to start Colima if available
    if command -v colima &>/dev/null; then
      log INFO "Starting Colima..."
      if colima start --cpu 2 --memory 4 2>/dev/null; then
        # Wait for Docker to be ready
        for i in {1..30}; do
          if docker info &>/dev/null; then
            log SUCCESS "Colima started successfully"
            return 0
          fi
          sleep 1
        done
      fi
    fi

    # Try Docker Desktop on macOS
    if [[ "$(uname)" == "Darwin" ]]; then
      log INFO "Trying Docker Desktop..."
      for app_name in "Docker" "Docker Desktop"; do
        if open -a "$app_name" 2>/dev/null; then
          log INFO "Waiting for Docker daemon..."
          for i in {1..60}; do
            if docker info &>/dev/null; then
              log SUCCESS "Docker started successfully"
              return 0
            fi
            sleep 1
          done
        fi
      done
    fi

    log ERROR "Could not start Docker daemon"
    log INFO "Please start Docker manually and re-run"
    exit 1
  fi

  log SUCCESS "Docker is running"
}

create_dockerfile() {
  local dockerfile="${LOG_DIR}/Dockerfile"

  cat > "$dockerfile" << 'EOF'
FROM archlinux:latest

ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8
ENV TZ=UTC
ENV CI=true
ENV E2E_TEST=true

# Update system and install packages
RUN pacman -Syu --noconfirm && \
    pacman -S --noconfirm \
    base-devel \
    git \
    curl \
    wget \
    sudo \
    which \
    inetutils \
    python \
    python-pip \
    nodejs \
    npm \
    zsh \
    tmux \
    neovim \
    ripgrep \
    fd \
    fzf \
    bat \
    jq \
    tree \
    unzip \
    glibc \
    && pacman -Scc --noconfirm

# Generate locale
RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
    locale-gen

# Install Python packages for Neovim
RUN pip install --break-system-packages \
    pynvim \
    neovim

# Create test user with sudo privileges
RUN useradd -m -s /bin/zsh testuser && \
    echo 'testuser ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

USER testuser
WORKDIR /home/testuser

COPY --chown=testuser:testuser . /home/testuser/.dotfiles

ENV HOME=/home/testuser
ENV DOTFILES_DIR=/home/testuser/.dotfiles
ENV PATH="/home/testuser/.local/bin:$PATH"
ENV SHELL=/bin/zsh

ENTRYPOINT ["/bin/bash"]
EOF

  echo "$dockerfile"
}

run_docker_test() {
  local container_name="dotfiles-e2e-${TIMESTAMP}"
  local dockerfile=$(create_dockerfile)
  local log_file="${LOG_DIR}/test.log"

  log INFO "Building Docker image..."

  # Build Docker image
  if docker build -t "dotfiles-test:latest" -f "$dockerfile" "$PROJECT_ROOT" > "$log_file" 2>&1; then
    log SUCCESS "Docker image built"
  else
    log ERROR "Failed to build Docker image"
    tail -20 "$log_file"
    return 1
  fi

  log INFO "Running tests in container..."

  # Build the command based on debug mode
  local docker_cmd="cd /home/testuser/.dotfiles && chmod +x test/e2e/docker-e2e-test.zsh && "
  if [[ "$DEBUG_MODE" == true ]]; then
    docker_cmd+="DEBUG=true timeout 1800 zsh test/e2e/docker-e2e-test.zsh"  # Increased to 30 minutes
  else
    docker_cmd+="DEBUG=false timeout 1200 zsh test/e2e/docker-e2e-test.zsh"  # Increased to 20 minutes
  fi

  # Run the test script in the container
  if [[ "$DEBUG_MODE" == true ]]; then
    # In debug mode, show output in real-time (timeout: 33 minutes)
    timeout 2000 docker run --name "$container_name" \
      --rm \
      -e NONINTERACTIVE=1 \
      -e CI=true \
      -e DEBUG=true \
      "dotfiles-test:latest" \
      -c "$docker_cmd" 2>&1 | tee -a "$log_file"
    # In zsh, use pipestatus (lowercase) array
    local result=${pipestatus[1]:-$?}
  else
    # Normal mode, just log to file (timeout: 25 minutes)
    timeout 1500 docker run --name "$container_name" \
      --rm \
      -e NONINTERACTIVE=1 \
      -e CI=true \
      -e DEBUG=false \
      "dotfiles-test:latest" \
      -c "$docker_cmd" \
      >> "$log_file" 2>&1
    local result=$?
  fi

  if [[ $result -eq 0 ]]; then
    log SUCCESS "Tests completed successfully"
  else
    log ERROR "Tests failed (exit code: $result)"
    if [[ "$DEBUG_MODE" != true ]]; then
      echo ""
      echo "--- Last 50 lines of test log ---"
      tail -50 "$log_file"
      echo "--- End of log ---"
    fi
  fi

  # Clean up
  docker rm -f "$container_name" 2>/dev/null || true

  return $result
}

# ────────────────────────────────────────────────────────────────────────────────
# Report Generation
# ────────────────────────────────────────────────────────────────────────────────

generate_report() {
  local report_file="${LOG_DIR}/report.txt"

  cat > "$report_file" << EOF
E2E Test Report
Generated: $(date)

Project Root: $PROJECT_ROOT
Log Directory: $LOG_DIR

Test Results:
EOF

  if [[ $EXIT_CODE -eq 0 ]]; then
    echo "✅ All tests passed" >> "$report_file"
  else
    echo "❌ Tests failed" >> "$report_file"
  fi

  echo "" >> "$report_file"
  echo "Logs available at: $LOG_DIR" >> "$report_file"

  log INFO "Report generated: $report_file"
}

# ────────────────────────────────────────────────────────────────────────────────
# Main Execution
# ────────────────────────────────────────────────────────────────────────────────

parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --debug)
        DEBUG_MODE=true
        shift
        ;;
      --help)
        echo "Usage: ./runner.zsh [--debug]"
        echo ""
        echo "Run end-to-end tests in a Docker container"
        echo ""
        echo "Options:"
        echo "  --debug    Enable debug output and verbose logging"
        echo "             Shows real-time output and runs full test suite"
        echo "  --help     Show this help message"
        echo ""
        echo "Without --debug: Runs full tests with 10-minute timeout"
        echo "With --debug: Runs full tests with 15-minute timeout and live output"
        exit 0
        ;;
      *)
        echo "Unknown option: $1"
        echo "Use --help for usage information"
        exit 1
        ;;
    esac
  done
}

main() {
  parse_args "$@"

  setup_logging

  log INFO "Starting E2E Test Suite"
  if [[ "$DEBUG_MODE" == true ]]; then
    log INFO "Debug mode enabled"
  fi

  # Check Docker
  check_docker

  # Run Docker test
  if ! run_docker_test; then
    EXIT_CODE=1
  fi

  # Generate report
  generate_report

  # Final status
  echo ""
  if [[ $EXIT_CODE -eq 0 ]]; then
    log SUCCESS "════════════════════════════════════════════════════════════════════"
    log SUCCESS "E2E tests completed successfully!"
    log SUCCESS "Logs available at: $LOG_DIR"
    log SUCCESS "════════════════════════════════════════════════════════════════════"
  else
    log ERROR "════════════════════════════════════════════════════════════════════"
    log ERROR "E2E tests failed"
    log ERROR "Check logs at: $LOG_DIR"
    log ERROR "════════════════════════════════════════════════════════════════════"
  fi

  exit $EXIT_CODE
}

# Run main function if not being sourced
if [[ "${ZSH_EVAL_CONTEXT}" == "toplevel" ]]; then
  main "$@"
fi