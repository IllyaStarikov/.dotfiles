#!/usr/bin/env zsh
# setup.sh - Unified dotfiles installation and configuration script
#
# DESCRIPTION:
#   Complete development environment setup for macOS and Linux. Installs packages,
#   creates symlinks, configures shells, and initializes all development tools.
#   Based on Google's best practices for shell scripting:
#   https://google.github.io/styleguide/shellguide.html
#
# USAGE:
#   ./setup.sh [MODE] [OPTIONS]
#
#   ./setup.sh                # Full installation (interactive)
#   ./setup.sh --core        # Core packages only
#   ./setup.sh --symlinks    # Create symlinks only
#
# MODES:
#   full      - Complete setup with all packages and configurations (default)
#   --core    - Essential packages only (git, vim, tmux, zsh)
#   --symlinks - Create/update dotfile symlinks only
#
# OPTIONS:
#   --skip-brew   - Skip Homebrew package installation
#   --force-brew  - Force reinstall all Homebrew packages
#   --verbose     - Show detailed output
#   --help        - Display this help message
#
# PLATFORMS:
#   macOS: Intel and Apple Silicon
#   Linux: Ubuntu, Debian, Fedora, Arch
#
# EXAMPLES:
#   ./setup.sh                     # Full interactive setup
#   ./setup.sh --core             # Quick essential setup
#   ./setup.sh --symlinks         # Update symlinks after changes
#   VERBOSE=true ./setup.sh       # Debug mode with detailed output
#
# FILES:
#   Log: ~/.dotfiles-setup-YYYYMMDD_HHMMSS.log
#   Backup: ~/.dotfiles-backup/ (if files exist)
#

set -euo pipefail
IFS=$'\n\t'

# Configuration constants
# Define paths early to avoid repeated calculations and ensure consistency

readonly SCRIPT_DIR="$(cd "$(dirname "${0}")" && pwd)"
readonly DOTFILES_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")"
readonly LOG_FILE="$HOME/.dotfiles-setup-$(date +%Y%m%d_%H%M%S).log"

# ANSI color codes for user feedback
# Standard colors following Google Shell Style Guide conventions
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly MAGENTA='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly NC='\033[0m'

# Command line argument defaults
# Initialize early to prevent undefined variable errors in strict mode
INSTALL_MODE="full" # full, core, symlinks
VERBOSE="${VERBOSE:-false}"
SKIP_BREW_PACKAGES=""
FORCE_BREW=""

# Process arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    core | --core)
      INSTALL_MODE="core"
      shift
      ;;
    symlinks | --symlinks)
      INSTALL_MODE="symlinks"
      shift
      ;;
    --skip-brew)
      SKIP_BREW_PACKAGES="true"
      shift
      ;;
    --force-brew)
      FORCE_BREW="true"
      SKIP_BREW_PACKAGES=""
      shift
      ;;
    --help | -h)
      echo "Usage: $0 [OPTIONS]"
      echo ""
      echo "Options:"
      echo "  core, --core       Install core packages only"
      echo "  symlinks, --symlinks  Create symlinks only"
      echo "  --skip-brew        Skip Homebrew package installation (for work machines)"
      echo "  --force-brew       Force Homebrew packages even on work machines"
      echo "  --help, -h         Show this help message"
      echo ""
      echo "Examples:"
      echo "  $0                 Full installation"
      echo "  $0 core            Core packages only"
      echo "  $0 symlinks        Symlinks only"
      echo "  $0 --skip-brew     Full setup but skip Homebrew packages"
      exit 0
      ;;
    *)
      # Support legacy positional argument
      if [[ -z "$INSTALL_MODE" ]] || [[ "$INSTALL_MODE" == "full" ]]; then
        INSTALL_MODE="$1"
      fi
      shift
      ;;
  esac
done

# Logging utilities
# Provide consistent output format with timestamps and color coding

log() {
  local level="$1"
  shift
  local timestamp=$(date "+%Y-%m-%d %H:%M:%S")
  local message="${timestamp} $level $*"
  echo -e "$message"
  echo -e "$message" | sed 's/\x1b\[[0-9;]*m//g' >>"$LOG_FILE"
}

info() { log "${BLUE}[INFO]${NC}" "$@"; }
success() { log "${GREEN}[✓]${NC}" "$@"; }
warning() { log "${YELLOW}[⚠]${NC}" "$@"; }
error() { log "${RED}[✗]${NC}" "$@" >&2; }
progress() { log "${CYAN}[➜]${NC}" "$@"; }

# System detection utilities
# Determine OS, architecture, and environment configuration

detect_system() {
  info "Detecting system configuration..."

  # OS Detection
  if [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
    OS_NAME="macOS"

    # Detect architecture and actual Homebrew location
    ARCH=$(uname -m)

    # Detect actual Homebrew location (not just based on architecture)
    if command -v brew &>/dev/null; then
      BREW_PREFIX="$(brew --prefix)"
      local brew_binary="$(which brew)"
      if [[ -f "$brew_binary" ]]; then
        local brew_arch=$(file "$brew_binary" | grep -o 'arm64\|x86_64' | head -1)
        if [[ -n "$brew_arch" ]]; then
          info "Detected $ARCH Mac with $brew_arch Homebrew at $BREW_PREFIX"
        else
          info "Detected $ARCH Mac with Homebrew at $BREW_PREFIX"
        fi
      else
        info "Detected $ARCH Mac with Homebrew at $BREW_PREFIX"
      fi
    elif [[ "$ARCH" == "arm64" ]]; then
      BREW_PREFIX="/opt/homebrew"
      info "Detected Apple Silicon Mac (no Homebrew found)"
    else
      BREW_PREFIX="/usr/local"
      info "Detected Intel Mac (no Homebrew found)"
    fi
  elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS="linux"
    OS_NAME="Linux"
    ARCH=$(uname -m)

    # Detect distribution
    if [[ -f /etc/os-release ]]; then
      . /etc/os-release
      DISTRO=${ID:-unknown}
      DISTRO_VERSION=${VERSION_ID:-unknown}
      info "Detected $DISTRO $DISTRO_VERSION"
    fi

    # Detect package manager
    if command -v apt-get &>/dev/null; then
      PKG_MANAGER="apt"
      PKG_INSTALL="sudo apt-get install -y"
      PKG_UPDATE="sudo apt-get update"
    elif command -v dnf &>/dev/null; then
      PKG_MANAGER="dnf"
      PKG_INSTALL="sudo dnf install -y"
      PKG_UPDATE="sudo dnf upgrade -y"
    elif command -v pacman &>/dev/null; then
      PKG_MANAGER="pacman"
      PKG_INSTALL="sudo pacman -S --noconfirm"
      PKG_UPDATE="sudo pacman -Syu --noconfirm"
    else
      error "No supported package manager found. Please install one of: apt-get, dnf, or pacman"
      error "For manual installation, see: https://github.com/yourusername/dotfiles#manual-setup"
      exit 1
    fi
  else
    error "Unsupported operating system: $OSTYPE. This script supports macOS and Linux only."
    error "For other platforms, please install packages manually or contribute support."
    exit 1
  fi

  success "System: $OS_NAME ($ARCH)"

  # Detect if we're on a work machine
  detect_work_environment
}

# Corporate environment detection
# Apply special configurations for work machines with restricted environments

detect_work_environment() {
  IS_WORK_MACHINE=false

  # Get current hostname
  CURRENT_HOSTNAME=$(hostname -f 2>/dev/null || hostname)

  # Check hostname patterns to identify corporate work machines
  # Pattern matching for various corporate domain suffixes
  case "$CURRENT_HOSTNAME" in
    starikov-mac.roam.internal | \
      starikov.c.googlers.com | \
      starikov-desktop.mtv.corp.google.com | \
      *.c.googlers.com | \
      *.corp.google.com | \
      *.roam.internal)
      IS_WORK_MACHINE=true
      info "Detected corporate work machine: $CURRENT_HOSTNAME"
      info "Will use work-specific configurations (PyPy, timeouts, workarounds)"
      ;;
    *)
      info "Personal machine detected: $CURRENT_HOSTNAME"
      ;;
  esac

  export IS_WORK_MACHINE
}

# macOS-specific setup functions
# Handle Xcode CLI tools, Homebrew, and platform-specific packages

setup_macos_xcode() {
  progress "Installing Xcode Command Line Tools..."
  if ! xcode-select -p &>/dev/null; then
    xcode-select --install
    warning "Please complete Xcode installation in the popup, then press Enter to continue..."
    read -r
  else
    success "Xcode Command Line Tools already installed"
  fi
}

setup_homebrew() {
  progress "Setting up Homebrew..."

  if ! command -v brew &>/dev/null; then
    info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Add Homebrew to PATH
    if [[ "$ARCH" == "arm64" ]]; then
      echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >>"$HOME/.zprofile"
      eval "$(/opt/homebrew/bin/brew shellenv)"
    else
      echo 'eval "$(/usr/local/bin/brew shellenv)"' >>"$HOME/.zprofile"
      eval "$(/usr/local/bin/brew shellenv)"
    fi
  else
    success "Homebrew already installed"
  fi

  info "Checking Homebrew directory permissions..."
  local brew_dirs=("/usr/local/bin" "/usr/local/etc" "/usr/local/sbin" "/usr/local/share" "/usr/local/share/doc")
  local non_writable_dirs=()
  for dir in "${brew_dirs[@]}"; do
    if [[ -d "$dir" ]] && [[ ! -w "$dir" ]]; then
      non_writable_dirs+=("$dir")
    fi
  done

  if [[ ${#non_writable_dirs[@]} -gt 0 ]]; then
    warning "Detected non-writable Homebrew directories."
    info "Attempting to fix permissions with sudo. You may be prompted for your password."
    sudo chown -R "$USER" "${non_writable_dirs[@]}"
    chmod u+w "${non_writable_dirs[@]}"
    success "Homebrew directory permissions fixed."
  else
    success "Homebrew directory permissions are correct."
  fi

  # Apply corporate environment workarounds to prevent conflicts
  # Corporate networks often redirect Homebrew to non-standard paths like /usr/local/Homebrew
  # Reference: https://docs.brew.sh/Installation for standard paths
  # Use parameter expansion to prevent "unbound variable" errors in strict mode
  if [[ "${IS_WORK_MACHINE:-false}" == true ]]; then
    export HOMEBREW_PREFIX="/usr/local/Homebrew"
    export HOMEBREW_CELLAR="/usr/local/Homebrew/Cellar"
  fi

  # Update Homebrew (with timeout for work machines)
  if [[ "${IS_WORK_MACHINE:-false}" == true ]]; then
    timeout 30 brew update 2>/dev/null || info "Brew update skipped (timeout or restricted)"
  else
    brew update
  fi
  # Check if Homebrew architecture matches system architecture
  if ! command -v brew &>/dev/null; then
    warning "Homebrew command not found, cannot check architecture or upgrade."
    return
  fi

  local brew_prefix
  brew_prefix=$(brew --prefix)
  local brew_arch=""

  if [[ "$brew_prefix" == "/opt/homebrew" ]]; then
    brew_arch="arm64"
  elif [[ "$brew_prefix" == "/usr/local" ]]; then
    brew_arch="x86_64"
  fi

  if [[ -z "$brew_arch" ]]; then
    warning "Could not determine Homebrew architecture from prefix: $brew_prefix"
    info "Attempting to upgrade packages anyway..."
    brew upgrade || warning "Some packages failed to upgrade"
  elif [[ "$brew_arch" != "$ARCH" ]]; then
    warning "Architecture mismatch: System is $ARCH but Homebrew is $brew_arch (prefix: $brew_prefix)"
    warning "Skipping brew upgrade to avoid architecture conflicts."
    info "If this is a Rosetta environment, this may be expected."
    info "Consider reinstalling Homebrew for your native architecture if you encounter issues."
  else
    info "Upgrading Homebrew packages for $ARCH architecture..."
    brew upgrade || warning "Some packages failed to upgrade"
  fi
}

install_macos_packages() {
  # Check if we should skip Homebrew packages
  if [[ "$SKIP_BREW_PACKAGES" == "true" ]]; then
    warning "Skipping Homebrew package installation (--skip-brew flag set)"
    info "You can manually install packages later or use --force-brew to override"
    return 0
  fi

  progress "Installing packages via Homebrew..."

  # Core packages
  local core_packages=(
    "git"
    "git-extras"
    "git-lfs"
    "neovim"
    "vim"
    "tmux"
    "tmuxinator"
    "alacritty" # Terminal emulator 1
    "starship"
    "ripgrep"
    "fd"
    "bat"
    "eza"
    "fzf"
    "zoxide"
    "gh"
    "jq"
    "tree"
    "htop"
    "ranger"
    "wget"
    "curl"
    "gnupg"
    "pinentry-mac"
    "colordiff"
    "coreutils"
    "readline"
    "ncurses"
    "sqlite"
    "openssl@3"
    "ca-certificates"
    "lua"
    "luajit"
    "luarocks"
  )

  # Development packages
  local dev_packages=(
    "pyenv"
    "pyenv-virtualenv"
    "node"
    "ruby"
    "rust"
    "rustup"
    "go"
    "cmake"
    "ninja"
    "llvm"
    "gcc"
    "colima"
    "lima"
    "cloc"
    "ctags"
    "dos2unix"
    "git-filter-repo"
    "git-quick-stats"
    "gnu-sed"
    "marksman"
    "texlab"
    "tree-sitter"
    "telnet"
    "unbound"
    "automake"
    "autoconf"
    "libtool"
    "pkg-config"
    "lazygit"
  )

  # Language servers
  local lsp_packages=(
    "lua-language-server"
    "typescript-language-server"
    "rust-analyzer"
    "gopls"
    "pyright"
  )

  # Code formatters and linters
  local formatter_packages=(
    "prettier"
    "shfmt"
    "stylua"
    "clang-format"
    "astyle"
    "swiftformat"
    "taplo"
    "shellcheck"
    "yamllint"
    "xmlstarlet"
    "perl"
    "perltidy"
    "latexindent"
    "postgresql@14"
    "pgformatter"
    "nasm"
  )

  # Install based on mode
  if [[ "$INSTALL_MODE" == "full" ]]; then
    # Install packages one by one to continue on failures
    info "Installing core packages..."
    for pkg in "${core_packages[@]}"; do
      if brew list --formula "$pkg" &>/dev/null || true; then
        info "✓ $pkg already installed"
      else
        # Apply timeouts and fallbacks for corporate environments
        # Work machines often have proxy/firewall issues that cause hangs
        if [[ "${IS_WORK_MACHINE:-false}" == true ]]; then
          # Try building from source first, then fall back to bottles with timeout
          output=$(timeout 60 brew install --build-from-source "$pkg" 2>&1 || timeout 60 brew install "$pkg" 2>&1)
          exit_code=$?
        else
          output=$(brew install "$pkg" 2>&1)
          exit_code=$?
        fi

        # Provide detailed feedback based on installation results
        # Different exit codes and output patterns indicate specific issues
        if [[ $exit_code -eq 0 ]]; then
          success "✓ $pkg installed successfully"
        elif [[ $exit_code -eq 124 ]]; then
          warning "✗ $pkg installation timed out (likely corporate network restrictions)"
        elif echo "$output" | grep -q "already installed"; then
          info "✓ $pkg already installed"
        elif echo "$output" | grep -q "Rosetta 2\|no bottle available"; then
          warning "✗ $pkg skipped (architecture/bottle compatibility issue)"
        else
          warning "✗ $pkg installation failed"
          # Special handling for critical packages with alternative installation methods
          if [[ "$pkg" == "starship" ]]; then
            info "Homebrew failed for Starship, trying official installer..."
            if curl -sS https://starship.rs/install.sh | sh -s -- -y; then
              success "✓ Starship installed via official installer"
            else
              error "✗ Starship installation failed completely"
            fi
          fi
        fi
      fi
    done

    info "Installing development packages..."
    for pkg in "${dev_packages[@]}"; do
      if brew list --formula "$pkg" &>/dev/null || true; then
        info "✓ $pkg already installed"
      else
        output=$(brew install "$pkg" 2>&1)
        if [[ $? -eq 0 ]]; then
          success "✓ $pkg installed successfully"
        elif echo "$output" | grep -q "already installed"; then
          info "✓ $pkg already installed"
        elif echo "$output" | grep -q "Rosetta 2"; then
          warning "✗ $pkg skipped (architecture mismatch)"
        else
          warning "✗ $pkg installation failed"
        fi
      fi
    done

    info "Installing language servers..."
    for pkg in "${lsp_packages[@]}"; do
      if brew list --formula "$pkg" &>/dev/null || true; then
        info "✓ $pkg already installed"
      else
        output=$(brew install "$pkg" 2>&1)
        if [[ $? -eq 0 ]]; then
          success "✓ $pkg installed successfully"
        elif echo "$output" | grep -q "already installed"; then
          info "✓ $pkg already installed"
        elif echo "$output" | grep -q "Rosetta 2"; then
          warning "✗ $pkg skipped (architecture mismatch)"
        else
          warning "✗ $pkg installation failed"
        fi
      fi
    done

    info "Installing code formatters and linters..."
    for pkg in "${formatter_packages[@]}"; do
      if brew list --formula "$pkg" &>/dev/null || true; then
        info "✓ $pkg already installed"
      else
        output=$(brew install "$pkg" 2>&1)
        if [[ $? -eq 0 ]]; then
          success "✓ $pkg installed successfully"
        elif echo "$output" | grep -q "already installed"; then
          info "✓ $pkg already installed"
        else
          warning "✗ $pkg installation failed"
        fi
      fi
    done

    # Nerd Fonts (check if already installed first)
    info "Installing Nerd Fonts..."
    for font in font-jetbrains-mono-nerd-font font-hack-nerd-font font-ibm-plex-mono; do
      if brew list --cask "$font" &>/dev/null; then
        info "✓ $font already installed"
      elif brew install --cask "$font" 2>/dev/null; then
        success "✓ $font installed successfully"
      else
        warning "✗ $font installation failed"
      fi
    done

    # GUI Applications (check if already installed first)
    info "Installing GUI applications..."
    for app in wezterm raycast amethyst; do # wezterm is Terminal emulator 2
      if brew list --cask "$app" &>/dev/null; then
        info "✓ $app already installed"
      elif brew install --cask "$app" 2>/dev/null; then
        success "✓ $app installed successfully"
      else
        warning "✗ $app installation failed"
      fi
    done

    # Additional tools (from 3-tooling.sh)
    local extra_packages=(
      "cmatrix"
      "cowsay"
      "figlet"
      "htop"
      "neofetch"
      "ranger"
      "ffmpeg"
      "imagemagick"
      "yt-dlp"
      "tesseract"
    )
    info "Installing extra tools..."
    for pkg in "${extra_packages[@]}"; do
      if brew list --formula "$pkg" &>/dev/null || true; then
        info "✓ $pkg already installed"
      elif brew install "$pkg" 2>/dev/null; then
        success "✓ $pkg installed successfully"
      else
        warning "✗ $pkg installation failed"
      fi
    done
  else
    info "Installing core packages only..."
    for pkg in "${core_packages[@]}"; do
      if brew list --formula "$pkg" &>/dev/null || true; then
        info "✓ $pkg already installed"
      elif brew install "$pkg" 2>/dev/null; then
        success "✓ $pkg installed successfully"
      else
        warning "✗ $pkg installation failed"
      fi
    done
  fi

  success "Package installation complete"

  # Ensure Starship is installed (critical for prompt)
  # Skip if SKIP_STARSHIP is set (e.g., in Docker containers)
  if [[ -n "${SKIP_STARSHIP:-}" ]]; then
    info "Skipping Starship installation (SKIP_STARSHIP is set)"
  elif ! command -v starship &>/dev/null; then
    info "Installing Starship via official installer..."
    curl -sS https://starship.rs/install.sh | sh -s -- -y || {
      warning "Starship installation failed, trying alternative method..."
      # Try cargo if available
      if command -v cargo &>/dev/null; then
        cargo install starship --locked || warning "Could not install Starship"
      fi
    }
  else
    success "Starship already installed"
  fi
}

setup_macos() {
  setup_macos_xcode
  setup_homebrew
  install_macos_packages

  # macOS specific settings
  if [[ "$INSTALL_MODE" == "full" ]]; then
    progress "Applying macOS settings..."

    # Keyboard repeat rate
    defaults write NSGlobalDomain KeyRepeat -int 2
    defaults write NSGlobalDomain InitialKeyRepeat -int 15

    # Show hidden files
    defaults write com.apple.finder AppleShowAllFiles -bool true

    # Disable press-and-hold for keys
    defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

    killall Finder || true
    success "macOS settings applied"
  fi
}

# Linux-specific setup functions
# Support multiple distributions with appropriate package managers

install_linux_packages() {
  progress "Installing packages for Linux..."

  # Update package manager
  case "$PKG_MANAGER" in
    apt) sudo apt-get update ;;
    dnf | yum) sudo dnf upgrade -y ;;
    pacman) sudo pacman -Syu --noconfirm ;;
    *) warning "Cannot update unknown package manager" ;;
  esac

  # Core packages (varies by distro)
  local packages=()
  case "$PKG_MANAGER" in
    apt)
      packages=(
        "build-essential"
        "git"
        "curl"
        "wget"
        "tmux"
        "neovim"
        "ripgrep"
        "fd-find"
        "bat"
        "fzf"
        "jq"
        "tree"
        "gnupg"
        "unzip"
        "python3-pip"
        "python3-venv"
        "cargo" # For installing tree-sitter
      )
      ;;
    dnf | yum)
      packages=(
        "gcc"
        "gcc-c++"
        "make"
        "git"
        "curl"
        "wget"
        "tmux"
        "neovim"
        "ripgrep"
        "fd-find"
        "bat"
        "fzf"
        "jq"
        "tree"
        "gnupg2"
        "unzip"
        "python3-pip"
      )
      ;;
    pacman)
      packages=(
        "base-devel"
        "git"
        "curl"
        "wget"
        "tmux"
        "neovim"
        "ripgrep"
        "fd"
        "bat"
        "fzf"
        "jq"
        "tree"
        "gnupg"
        "unzip"
        "python-pip"
      )
      ;;
    *)
      warning "Unknown package manager: $PKG_MANAGER"
      return 1
      ;;
  esac

  # Install packages
  if [[ ${#packages[@]} -gt 0 ]]; then
    info "Installing packages: ${packages[*]}"
    # Install all packages at once, properly handling the command
    case "$PKG_MANAGER" in
      apt)
        sudo apt-get install -y "${packages[@]}" || warning "Some packages failed to install"
        ;;
      dnf | yum)
        sudo dnf install -y "${packages[@]}" || warning "Some packages failed to install"
        ;;
      pacman)
        sudo pacman -S --noconfirm "${packages[@]}" || warning "Some packages failed to install"
        ;;
    esac
  fi

  # Install Starship
  if [[ -z "${SKIP_STARSHIP:-}" ]] && ! command -v starship &>/dev/null; then
    curl -sS https://starship.rs/install.sh | sh -s -- -y
  fi

  # Install lazygit
  if ! command -v lazygit &>/dev/null; then
    info "Installing lazygit..."
    case "$PKG_MANAGER" in
      apt)
        # For Ubuntu/Debian - install from GitHub releases
        LAZYGIT_VERSION=$(curl -sf "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | jq -r '.tag_name' | sed 's/v//')
        if [[ -z "$LAZYGIT_VERSION" || "$LAZYGIT_VERSION" == "null" ]]; then
          warning "Could not fetch lazygit version (GitHub API rate limit?), skipping"
        else
          curl -fLo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
          tar xf lazygit.tar.gz lazygit
          sudo install lazygit /usr/local/bin
          rm -f lazygit lazygit.tar.gz
        fi
        ;;
      dnf | yum)
        # For Fedora/RHEL
        sudo dnf copr enable atim/lazygit -y
        sudo dnf install -y lazygit
        ;;
      pacman)
        # For Arch Linux
        sudo pacman -S --noconfirm lazygit
        ;;
      *)
        warning "Cannot install lazygit for unknown package manager"
        ;;
    esac
  else
    success "lazygit already installed"
  fi

  # Install Terminal Emulators (Linux) - Both Alacritty and WezTerm
  if [[ "$INSTALL_MODE" == "full" ]]; then
    # Install Alacritty
    if ! command -v alacritty &>/dev/null; then
      info "Installing Alacritty..."
      case "$PKG_MANAGER" in
        apt)
          # For Ubuntu/Debian - using cargo for latest version
          if command -v cargo &>/dev/null; then
            sudo apt-get install -y cmake pkg-config libfreetype6-dev libfontconfig1-dev libxcb-xfixes0-dev libxkbcommon-dev python3
            cargo install alacritty || warning "Failed to install Alacritty via cargo"
          else
            # Try snap as fallback
            sudo snap install alacritty --classic 2>/dev/null || warning "Failed to install Alacritty"
          fi
          ;;
        dnf | yum)
          # For Fedora/RHEL
          sudo dnf install -y alacritty || warning "Failed to install Alacritty"
          ;;
        pacman)
          # For Arch Linux
          sudo pacman -S --noconfirm alacritty || warning "Failed to install Alacritty"
          ;;
        *)
          warning "Cannot install Alacritty for unknown package manager"
          ;;
      esac
    else
      success "Alacritty already installed"
    fi

    # Install WezTerm
    if ! command -v wezterm &>/dev/null; then
      info "Installing WezTerm..."
      case "$PKG_MANAGER" in
        apt)
          # For Ubuntu/Debian
          curl -fsSL https://apt.fury.io/wez/gpg.key | sudo gpg --yes --dearmor -o /usr/share/keyrings/wezterm-fury.gpg
          echo 'deb [signed-by=/usr/share/keyrings/wezterm-fury.gpg] https://apt.fury.io/wez/ * *' | sudo tee /etc/apt/sources.list.d/wezterm.list
          sudo apt update
          sudo apt install -y wezterm || warning "Failed to install WezTerm"
          ;;
        dnf | yum)
          # For Fedora/RHEL
          sudo dnf copr enable -y wezfurlong/wezterm-nightly
          sudo dnf install -y wezterm || warning "Failed to install WezTerm"
          ;;
        pacman)
          # For Arch Linux
          sudo pacman -S --noconfirm wezterm || {
            # Try AUR if not in official repos
            if command -v yay &>/dev/null; then
              yay -S --noconfirm wezterm || warning "Failed to install WezTerm"
            else
              warning "WezTerm not in official repos, install from AUR"
            fi
          }
          ;;
        *)
          warning "Cannot install WezTerm for unknown package manager"
          info "Visit https://wezfurlong.org/wezterm/install/linux.html for manual installation"
          ;;
      esac
    else
      success "WezTerm already installed"
    fi
  fi

  # Install Rust
  if ! command -v rustup &>/dev/null && [[ "$INSTALL_MODE" == "full" ]]; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source "$HOME/.cargo/env"
  fi

  # Ensure rustfmt is installed (comes with rustup but make sure it's available)
  if command -v rustup &>/dev/null; then
    rustup component add rustfmt 2>/dev/null || info "rustfmt already installed"
  fi

  # Install tree-sitter CLI via cargo
  if command -v cargo &>/dev/null; then
    if ! command -v tree-sitter &>/dev/null; then
      info "Installing tree-sitter CLI..."
      cargo install tree-sitter-cli || warning "Failed to install tree-sitter CLI"
    else
      success "tree-sitter CLI already installed"
    fi
  else
    warning "Cargo not found, cannot install tree-sitter CLI"
    warning "Install Rust/Cargo and run: cargo install tree-sitter-cli"
  fi

  success "Linux packages installed"
}

setup_linux() {
  install_linux_packages

  # Skip Homebrew on Linux - use native package managers instead
  # Homebrew on Linux is optional and often not needed with good native package managers
  info "Using native package manager for Linux (Homebrew not required)"
}

# Cross-platform setup functions
# Common functionality for shell, languages, and development tools

setup_shell() {
  progress "Setting up Zsh and Zinit..."

  # Install Zsh if needed
  if ! command -v zsh &>/dev/null; then
    if [[ "$OS" == "macos" ]]; then
      brew install zsh
    else
      case "$PKG_MANAGER" in
        apt) sudo apt-get install -y zsh ;;
        dnf | yum) sudo dnf install -y zsh ;;
        pacman) sudo pacman -S --noconfirm zsh ;;
        *) warning "Cannot install zsh with unknown package manager" ;;
      esac
    fi
  fi

  # Set Zsh as default shell
  if [[ "$SHELL" != *"zsh"* ]]; then
    info "Setting Zsh as default shell..."
    if [[ "$OS" == "macos" ]]; then
      sudo dscl . -create /Users/$USER UserShell /usr/local/bin/zsh 2>/dev/null \
        || sudo dscl . -create /Users/$USER UserShell /opt/homebrew/bin/zsh 2>/dev/null \
        || chsh -s $(which zsh)
    else
      chsh -s $(which zsh)
    fi
  fi

  # Install Zinit
  if [[ ! -d "$HOME/.local/share/zinit/zinit.git" ]]; then
    info "Installing Zinit..."
    bash -c "$(curl --fail --show-error --silent --location https://raw.githubusercontent.com/zdharma-continuum/zinit/HEAD/scripts/install.sh)"
  else
    success "Zinit already installed"
  fi
}

setup_python() {
  progress "Setting up Python environment..."

  # Use PyPy on work machines to avoid compilation issues
  # Corporate environments often have restricted build tools or network access
  # PyPy provides a faster alternative that doesn't require compilation
  if [[ "${IS_WORK_MACHINE:-false}" == true ]]; then
    info "Work machine detected - using PyPy to avoid compilation"

    if command -v pypy3 &>/dev/null; then
      info "PyPy3 already installed: $(pypy3 --version)"
      success "Python environment configured (PyPy)"
      return 0
    fi

    # Install PyPy via Homebrew
    if [[ "$OS" == "macos" ]] && command -v brew &>/dev/null; then
      info "Installing PyPy3 via Homebrew..."
      brew install pypy3 || warning "Failed to install PyPy3"

      # Create python3 symlink to pypy3 for compatibility
      if command -v pypy3 &>/dev/null; then
        info "Creating python3 -> pypy3 symlink for compatibility"
        mkdir -p "$HOME/.local/bin"
        ln -sf "$(which pypy3)" "$HOME/.local/bin/python3"
        success "PyPy3 configured for work environment"
        return 0
      fi
    fi

    # Fall back to system Python if PyPy installation fails
    if command -v python3 &>/dev/null; then
      warning "PyPy installation failed, using system Python"
      info "System Python: $(python3 --version)"
      success "Python environment configured (system)"
      return 0
    fi
  fi

  # Personal machine - use regular Python setup
  if [[ "$OS" == "macos" ]]; then
    if command -v pyenv &>/dev/null; then
      # Check if we already have a good Python version installed
      EXISTING_PYTHON=$(pyenv versions 2>/dev/null | grep -E "^[\*[:space:]]*3\.(1[0-9]|[2-9][0-9])" | head -1 | sed 's/^[* ]*//' | awk '{print $1}')
      if [[ -n "$EXISTING_PYTHON" ]]; then
        info "Found existing Python $EXISTING_PYTHON, using it"
        pyenv global "$EXISTING_PYTHON"
        success "Python environment configured"
        return 0
      fi

      # Check system Python version
      if command -v python3 &>/dev/null; then
        SYSTEM_PYTHON_VERSION=$(python3 --version | grep -oE '[0-9]+\.[0-9]+')
        if [[ "${SYSTEM_PYTHON_VERSION%%.*}" -ge 3 ]] && [[ "${SYSTEM_PYTHON_VERSION#*.}" -ge 10 ]]; then
          info "System Python $(python3 --version) is sufficient, using it"
          success "Python environment configured"
          return 0
        fi
      fi

      # Attempt Python installation if needed
      warning "No suitable Python found, will attempt installation"
      info "Press Ctrl+C within 5 seconds to skip Python installation..."
      sleep 5

      # Update pyenv to ensure latest Python versions are available
      # Corporate firewalls may block updates, so continue on failure
      info "Updating pyenv to get latest Python versions..."
      brew update && brew upgrade pyenv 2>/dev/null || true

      # Try to find an available Python 3.13.x version
      AVAILABLE_PYTHON=$(pyenv install --list | grep -E "^\s*3\.13\.[0-9]+$" | tail -1 | xargs)
      if [[ -n "$AVAILABLE_PYTHON" ]]; then
        PYTHON_VERSION="$AVAILABLE_PYTHON"
        info "Found Python $PYTHON_VERSION available"
      else
        # Fall back to latest Python 3.12.x if 3.13 not available
        PYTHON_VERSION=$(pyenv install --list | grep -E "^\s*3\.12\.[0-9]+$" | tail -1 | xargs)
        info "Using Python $PYTHON_VERSION (3.13 not available)"
      fi

      # Check if the version is already installed
      if [[ -n "$PYTHON_VERSION" ]] && ! pyenv versions | grep -q "$PYTHON_VERSION"; then
        info "Installing Python $PYTHON_VERSION (this may take 5-10 minutes)..."
        warning "Python is being compiled from source. This is normal but can be slow."
        info "To speed up future installs, consider using python-build with precompiled binaries"

        # Use verbose mode to show compilation progress and timeout for stuck builds
        # Python compilation can hang on corporate networks or fail due to security restrictions
        if command -v timeout &>/dev/null; then
          # Timeout prevents indefinite hangs during compilation (10 minutes max)
          timeout 600 pyenv install -v "$PYTHON_VERSION" || {
            warning "Python installation timed out or failed"
            info "This can happen due to corporate security or network issues"
            info "Checking for existing Python installations..."

            # Try to use any existing Python 3.10+ version
            EXISTING_PYTHON=$(pyenv versions | grep -E "^[\*[:space:]]*3\.(1[0-9]|[2-9][0-9])" | head -1 | sed 's/^[* ]*//' | awk '{print $1}')
            if [[ -n "$EXISTING_PYTHON" ]]; then
              info "Using existing Python $EXISTING_PYTHON"
              pyenv global "$EXISTING_PYTHON"
              PYTHON_VERSION="$EXISTING_PYTHON"
            elif command -v python3 &>/dev/null; then
              info "Using system Python $(python3 --version)"
              PYTHON_VERSION="system"
            fi
          }
        else
          # No timeout command, run with verbose output
          pyenv install -v "$PYTHON_VERSION" || {
            warning "Failed to install Python $PYTHON_VERSION"
            info "Checking for existing Python installations..."

            # Try to use any existing Python 3.10+ version
            EXISTING_PYTHON=$(pyenv versions | grep -E "^[\*[:space:]]*3\.(1[0-9]|[2-9][0-9])" | head -1 | sed 's/^[* ]*//' | awk '{print $1}')
            if [[ -n "$EXISTING_PYTHON" ]]; then
              info "Using existing Python $EXISTING_PYTHON"
              pyenv global "$EXISTING_PYTHON"
              PYTHON_VERSION="$EXISTING_PYTHON"
            elif command -v python3 &>/dev/null; then
              info "Using system Python $(python3 --version)"
              PYTHON_VERSION="system"
            fi
          }
        fi
      fi

      # Set as global if installation succeeded
      if pyenv versions | grep -q "$PYTHON_VERSION"; then
        pyenv global "$PYTHON_VERSION"
        success "Python $PYTHON_VERSION configured"
      fi
    fi
  fi

  # Install global Python packages
  if command -v pip3 &>/dev/null; then
    # Determine pip install flags based on environment
    # PEP 668 (externally managed) requires --break-system-packages on modern Python
    local pip_flags=""
    if pip3 install --help 2>&1 | grep -q "break-system-packages"; then
      pip_flags="--break-system-packages"
    fi

    # pynvim is ESSENTIAL for Neovim's Python integration
    # Install to system Python that Neovim uses (not --user which may not be in path)
    info "Installing pynvim for Neovim Python integration..."
    if ! pip3 install $pip_flags --upgrade "pynvim>=0.6.0" 2>/dev/null; then
      # Fallback: try with --user flag
      if ! pip3 install --user --upgrade "pynvim>=0.6.0" 2>/dev/null; then
        warning "Failed to install pynvim via pip"
        info "Trying system package manager..."
        if [[ "$OS" == "linux" ]]; then
          case "$PKG_MANAGER" in
            apt) sudo apt-get install -y python3-pynvim 2>/dev/null || true ;;
            dnf | yum) sudo dnf install -y python3-neovim 2>/dev/null || true ;;
            pacman) sudo pacman -S --noconfirm python-pynvim 2>/dev/null || true ;;
            *) true ;;
          esac
        elif [[ "$OS" == "darwin" ]]; then
          # On macOS, pynvim should be installed via pip to the homebrew Python
          warning "pynvim installation failed. Run manually: pip3 install --break-system-packages pynvim"
        fi
      fi
    else
      success "pynvim installed successfully"
    fi

    # Install other Python packages (these are optional, use --user to avoid permission issues)
    for pkg in black ruff mypy ipython yapf autopep8 isort sqlformat cmake-format toml-sort beautysh xmlformatter; do
      pip3 install --user "$pkg" 2>/dev/null || pip3 install $pip_flags "$pkg" 2>/dev/null || {
        # Silent failure for optional packages - they're not critical
        true
      }
    done
  fi

  success "Python environment configured"
}

setup_go_tools() {
  progress "Setting up Go tools and formatters..."

  if command -v go &>/dev/null; then
    info "Installing Go tools..."

    # Install goimports
    go install golang.org/x/tools/cmd/goimports@latest 2>/dev/null || warning "Failed to install goimports"

    # Install keep-sorted
    go install github.com/google/keep-sorted@latest 2>/dev/null || warning "Failed to install keep-sorted"

    # Install asmfmt for assembly formatting
    go install github.com/klauspost/asmfmt/cmd/asmfmt@latest 2>/dev/null || warning "Failed to install asmfmt"

    success "Go tools installed"
  else
    warning "Go not found, skipping Go tools installation"
    info "Install Go and re-run setup to get Go tools"
  fi
}

setup_ruby_tools() {
  progress "Setting up Ruby tools and formatters..."

  if command -v gem &>/dev/null; then
    info "Installing Ruby gems..."

    # Try to install Ruby formatters
    gem install rubocop 2>/dev/null || warning "Failed to install rubocop (may need newer Ruby)"
    gem install rufo 2>/dev/null || warning "Failed to install rufo (may need newer Ruby)"

    success "Ruby tools installed"
  else
    warning "Ruby/gem not found, skipping Ruby tools installation"
  fi
}

setup_latex_tools() {
  progress "Setting up LaTeX tools (latexindent dependencies)..."

  # Check if perl and cpan are available
  if command -v perl &>/dev/null && command -v cpan &>/dev/null; then
    info "Installing Perl modules required for latexindent..."

    # Install required CPAN modules for latexindent
    # These modules are required for latexindent to work properly with fixy
    local cpan_modules=(
      "YAML::Tiny"
      "File::HomeDir"
      "Log::Log4perl"
      "Log::Dispatch::File"
      "Unicode::GCString"
    )

    for module in "${cpan_modules[@]}"; do
      info "Installing $module..."
      # Use yes to auto-answer prompts and redirect output to reduce noise
      yes | sudo cpan install "$module" &>/dev/null 2>&1 && \
        success "✓ $module installed" || \
        warning "✗ $module installation failed (may already be installed)"
    done

    success "LaTeX tools configured"
  else
    warning "Perl or CPAN not found, skipping LaTeX tools installation"
    info "To use latexindent with fixy, install Perl and run:"
    info "  sudo cpan install YAML::Tiny File::HomeDir Log::Log4perl Log::Dispatch::File Unicode::GCString"
  fi
}

setup_node() {
  progress "Setting up Node.js environment..."

  if [[ "$OS" == "macos" ]]; then
    info "Installing Node.js via Homebrew for macOS..."
    if brew list node &>/dev/null || true; then
      info "✓ Node.js already installed"
    elif brew install node; then
      success "✓ Node.js installed successfully"
    else
      warning "✗ Node.js installation failed via Homebrew"
    fi
  else
    # Keep original nvm logic for Linux
    if [[ ! -d "$HOME/.nvm" ]]; then
      info "Installing nvm for Linux..."
      set +u
      curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash || {
        warning "NVM installation had warnings, continuing..."
      }
      set -u
      export NVM_DIR="$HOME/.nvm"
      [[ -s "$NVM_DIR/nvm.sh" ]] && \. "$NVM_DIR/nvm.sh"
    else
      success "NVM already installed"
      export NVM_DIR="$HOME/.nvm"
      [[ -s "$NVM_DIR/nvm.sh" ]] && \. "$NVM_DIR/nvm.sh"
    fi

    if command -v nvm &>/dev/null; then
      info "Installing latest LTS Node.js via nvm..."
      set +u
      nvm install --lts &>/dev/null || warning "Node.js LTS installation via nvm failed"
      nvm use --lts &>/dev/null || warning "Failed to use Node.js LTS via nvm"
      set -u
    else
      warning "nvm command not found, skipping Node.js installation."
    fi
  fi

  # Install global npm packages for Neovim and formatters, regardless of OS
  if command -v npm &>/dev/null; then
    info "Installing global npm packages for Neovim and formatters..."
    npm install -g neovim &>/dev/null || warning "Failed to install neovim npm package"
    npm install -g eslint &>/dev/null || warning "Failed to install eslint"
    npm install -g @fsouza/prettierd &>/dev/null || warning "Failed to install prettierd"
    npm install -g lua-fmt &>/dev/null || warning "Failed to install lua-fmt (lua-format)"
  else
    warning "npm not found, skipping global package installation for Neovim and formatters."
  fi

  success "Node.js environment configured"
}

create_symlinks() {
  progress "Creating dotfile symlinks..."

  # Run the symlink creation script
  if [[ -f "$SCRIPT_DIR/symlinks.sh" ]]; then
    zsh "$SCRIPT_DIR/symlinks.sh"
  else
    error "Symlink script not found"
    return 1
  fi

  success "Symlinks created"
}

setup_neovim() {
  progress "Setting up Neovim..."

  # Install vim-plug
  if [[ ! -f "${XDG_DATA_HOME:-$HOME/.local/share}/nvim/site/autoload/plug.vim" ]]; then
    curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}/nvim/site/autoload/plug.vim" --create-dirs \
      https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  fi

  # Install plugins
  nvim --headless +PlugInstall +qall 2>/dev/null || true
  nvim --headless "+Lazy! sync" +qa 2>/dev/null || true

  success "Neovim configured"
}

setup_tmux() {
  progress "Setting up tmux..."

  # The tmux configuration is minimal and doesn't use plugins
  # Just ensure tmux config is linked
  info "Using minimal tmux configuration (no plugins)"

  # Create tmux config directory if needed
  [[ ! -d "$HOME/.config/tmux" ]] && mkdir -p "$HOME/.config/tmux"

  success "tmux configured"
}

# Main execution flow
# Coordinate setup based on detected system and user preferences

main() {
    # Initialize IS_WORK_MACHINE early to prevent unbound variable errors in strict mode
  # Will be properly detected later by detect_work_environment() function
  IS_WORK_MACHINE=false

  echo "════════════════════════════════════════════════════════════════════"
  echo "       🚀 DOTFILES UNIFIED SETUP"
  echo "════════════════════════════════════════════════════════════════════"
  echo ""

  info "Setup mode: $INSTALL_MODE"
  info "Log file: $LOG_FILE"
  echo ""

  # Detect system
  detect_system

  # Display corporate environment warnings to help users understand potential issues
  # Work environments often have restrictive security policies that affect installation
  if [[ "${IS_WORK_MACHINE:-false}" == true ]]; then
    echo ""
    warning "═══════════════════════════════════════════════════════════════"
    warning "   WORK MACHINE DETECTED: Corporate Environment Settings Active"
    warning "═══════════════════════════════════════════════════════════════"
    info "• Homebrew packages may timeout or fail due to corporate policies"
    info "• Use --skip-brew to skip package installation if it hangs"
    info "• PyPy will be used instead of compiling Python from source"
    info "• Work-specific configurations will be applied"
    echo ""

    # Check for corporate Homebrew configurations that need special handling
    # Some corporate environments force non-standard Homebrew paths
    if [[ -n "${HOMEBREW_CELLAR:-}" ]] && [[ "${HOMEBREW_CELLAR:-}" == "/usr/local/Homebrew/Cellar" ]]; then
      warning "Corporate Homebrew environment detected. Applying workarounds."
    fi
  fi

  # Create necessary directories
  mkdir -p "$HOME/.config" "$HOME/.local/bin" "$HOME/.cache"

  case "$INSTALL_MODE" in
    full)
      info "Running full installation..."

      # OS-specific setup
      if [[ "$OS" == "macos" ]]; then
        setup_macos
      else
        setup_linux
      fi

      # Common setup
      setup_shell
      create_symlinks
      setup_python
      setup_go_tools
      setup_ruby_tools
      setup_latex_tools
      setup_node
      setup_neovim
      setup_tmux

      # Configure Git
      git config --global core.excludesfile '~/.gitignore' || true

      # Install git hooks
      if [[ -f "$DOTFILES_DIR/src/git/install-git-hooks" ]]; then
        zsh "$DOTFILES_DIR/src/git/install-git-hooks"
      fi
      ;;

    core)
      info "Running core installation..."

      # Minimal OS setup
      if [[ "$OS" == "macos" ]]; then
        setup_macos_xcode
        setup_homebrew
        for pkg in git neovim tmux starship ripgrep fd; do
          if brew list --formula "$pkg" &>/dev/null || true; then
            info "✓ $pkg already installed"
          elif brew install "$pkg" 2>/dev/null; then
            success "✓ $pkg installed successfully"
          else
            warning "✗ $pkg installation failed"
          fi
        done
      else
        install_linux_packages
      fi

      setup_shell
      create_symlinks
      ;;

    symlinks)
      info "Creating symlinks only..."
      create_symlinks
      ;;

    *)
      error "Unknown install mode: '$INSTALL_MODE'. Supported modes: full, core, symlinks"
      error "Run '$0 --help' for usage information"
      exit 1
      ;;
  esac

  echo ""
  echo "════════════════════════════════════════════════════════════════════"
  success "✨ Setup complete!"
  echo ""
  echo "Next steps:"
  echo "  1. Restart your terminal or run: source ~/.zshrc"
  echo "  2. Run: nvim to finish plugin installation"
  echo "  3. Check the log file for any warnings: $LOG_FILE"
  echo "════════════════════════════════════════════════════════════════════"
}

# Run main function
main "$@"
