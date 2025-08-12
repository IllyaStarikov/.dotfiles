#!/usr/bin/env bash
# ════════════════════════════════════════════════════════════════════════════════════════════════════════════
# 🚀 UNIFIED DOTFILES SETUP - All-in-One Installation Script
# ════════════════════════════════════════════════════════════════════════════════════════════════════════════
# Single entry point for complete development environment setup
# Supports: macOS (Intel/Apple Silicon), Linux (Ubuntu/Debian/Fedora/Arch)
# ════════════════════════════════════════════════════════════════════════════════════════════════════════════

set -euo pipefail
IFS=$'\n\t'

# ────────────────────────────────────────────────────────────────────────────────────────────────────────────
# 🎨 CONFIGURATION
# ────────────────────────────────────────────────────────────────────────────────────────────────────────────

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"
readonly LOG_FILE="$HOME/.dotfiles-setup-$(date +%Y%m%d_%H%M%S).log"

# Color codes
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly MAGENTA='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly NC='\033[0m'

# Installation modes
INSTALL_MODE="${1:-full}"  # full, core, symlinks
VERBOSE="${VERBOSE:-false}"

# ────────────────────────────────────────────────────────────────────────────────────────────────────────────
# 📝 LOGGING
# ────────────────────────────────────────────────────────────────────────────────────────────────────────────

log() {
    local level="$1"
    shift
    local timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    local message="${timestamp} $level $*"
    echo -e "$message"
    echo -e "$message" | sed 's/\x1b\[[0-9;]*m//g' >> "$LOG_FILE"
}

info() { log "${BLUE}[INFO]${NC}" "$@"; }
success() { log "${GREEN}[✓]${NC}" "$@"; }
warning() { log "${YELLOW}[⚠]${NC}" "$@"; }
error() { log "${RED}[✗]${NC}" "$@" >&2; }
progress() { log "${CYAN}[➜]${NC}" "$@"; }

# ────────────────────────────────────────────────────────────────────────────────────────────────────────────
# 🔍 SYSTEM DETECTION
# ────────────────────────────────────────────────────────────────────────────────────────────────────────────

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
            info "Detected $ARCH Mac with Homebrew at $BREW_PREFIX"
        elif [[ "$ARCH" == "arm64" ]]; then
            BREW_PREFIX="/opt/homebrew"
            info "Detected Apple Silicon Mac"
        else
            BREW_PREFIX="/usr/local"
            info "Detected Intel Mac"
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
        if command -v apt-get &> /dev/null; then
            PKG_MANAGER="apt"
            PKG_INSTALL="sudo apt-get install -y"
            PKG_UPDATE="sudo apt-get update"
        elif command -v dnf &> /dev/null; then
            PKG_MANAGER="dnf"
            PKG_INSTALL="sudo dnf install -y"
            PKG_UPDATE="sudo dnf upgrade -y"
        elif command -v pacman &> /dev/null; then
            PKG_MANAGER="pacman"
            PKG_INSTALL="sudo pacman -S --noconfirm"
            PKG_UPDATE="sudo pacman -Syu --noconfirm"
        else
            error "Unsupported package manager"
            exit 1
        fi
    else
        error "Unsupported operating system: $OSTYPE"
        exit 1
    fi

    success "System: $OS_NAME ($ARCH)"
}

# ────────────────────────────────────────────────────────────────────────────────────────────────────────────
# 🍎 MACOS SETUP
# ────────────────────────────────────────────────────────────────────────────────────────────────────────────

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
            echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$HOME/.zprofile"
            eval "$(/opt/homebrew/bin/brew shellenv)"
        else
            echo 'eval "$(/usr/local/bin/brew shellenv)"' >> "$HOME/.zprofile"
            eval "$(/usr/local/bin/brew shellenv)"
        fi
    else
        success "Homebrew already installed"
    fi

    # Update Homebrew
    brew update
    # Check if Homebrew architecture matches system architecture
    local brew_arch=$(file "$(which brew)" | grep -o 'arm64\|x86_64' | head -1)
    if [[ "$brew_arch" != "$ARCH" ]]; then
        warning "Architecture mismatch: System is $ARCH but Homebrew is $brew_arch"
        warning "Skipping brew upgrade to avoid architecture conflicts"
        info "Consider reinstalling Homebrew for $ARCH architecture"
    else
        info "Upgrading Homebrew packages for $ARCH architecture..."
        brew upgrade || warning "Some packages failed to upgrade"
    fi
}

install_macos_packages() {
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
        "alacritty"
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
        "nvm"
        "node"
        "ruby"
        "rust"
        "rustup"
        "go"
        "cmake"
        "ninja"
        "llvm"
        "gcc"
        "docker"
        "docker-compose"
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
    )

    # Language servers
    local lsp_packages=(
        "lua-language-server"
        "typescript-language-server"
        "rust-analyzer"
        "gopls"
        "pyright"
    )

    # Install based on mode
    if [[ "$INSTALL_MODE" == "full" ]]; then
        # Install packages one by one to continue on failures
        info "Installing core packages..."
        for pkg in "${core_packages[@]}"; do
            if brew list --formula "$pkg" &>/dev/null; then
                info "✓ $pkg already installed"
            elif brew install "$pkg" 2>/dev/null; then
                success "✓ $pkg installed successfully"
            else
                warning "✗ $pkg installation failed"
            fi
        done
        
        info "Installing development packages..."
        for pkg in "${dev_packages[@]}"; do
            if brew list --formula "$pkg" &>/dev/null; then
                info "✓ $pkg already installed"
            elif brew install "$pkg" 2>/dev/null; then
                success "✓ $pkg installed successfully"
            else
                warning "✗ $pkg installation failed"
            fi
        done
        
        info "Installing language servers..."
        for pkg in "${lsp_packages[@]}"; do
            if brew list --formula "$pkg" &>/dev/null; then
                info "✓ $pkg already installed"
            elif brew install "$pkg" 2>/dev/null; then
                success "✓ $pkg installed successfully"
            else
                warning "✗ $pkg installation failed"
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
        for app in wezterm raycast amethyst docker; do
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
            "neofetch"
            "ffmpeg"
            "imagemagick"
            "yt-dlp"
            "tesseract"
        )
        info "Installing extra tools..."
        for pkg in "${extra_packages[@]}"; do
            if brew list --formula "$pkg" &>/dev/null; then
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
            if brew list --formula "$pkg" &>/dev/null; then
                info "✓ $pkg already installed"
            elif brew install "$pkg" 2>/dev/null; then
                success "✓ $pkg installed successfully"
            else
                warning "✗ $pkg installation failed"
            fi
        done
    fi

    success "Package installation complete"
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

# ────────────────────────────────────────────────────────────────────────────────────────────────────────────
# 🐧 LINUX SETUP
# ────────────────────────────────────────────────────────────────────────────────────────────────────────────

install_linux_packages() {
    progress "Installing packages for Linux..."

    # Update package manager
    case "$PKG_MANAGER" in
        apt) sudo apt-get update ;;
        dnf|yum) sudo dnf upgrade -y ;;
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
                "cargo"  # For installing tree-sitter
            )
            ;;
        dnf|yum)
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
            dnf|yum)
                sudo dnf install -y "${packages[@]}" || warning "Some packages failed to install"
                ;;
            pacman)
                sudo pacman -S --noconfirm "${packages[@]}" || warning "Some packages failed to install"
                ;;
        esac
    fi

    # Install Starship
    if ! command -v starship &>/dev/null; then
        curl -sS https://starship.rs/install.sh | sh -s -- -y
    fi

    # Install Rust
    if ! command -v rustup &>/dev/null && [[ "$INSTALL_MODE" == "full" ]]; then
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
        source "$HOME/.cargo/env"
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

# ────────────────────────────────────────────────────────────────────────────────────────────────────────────
# 🔧 COMMON SETUP
# ────────────────────────────────────────────────────────────────────────────────────────────────────────────

setup_shell() {
    progress "Setting up Zsh and Zinit..."

    # Install Zsh if needed
    if ! command -v zsh &>/dev/null; then
        if [[ "$OS" == "macos" ]]; then
            brew install zsh
        else
            case "$PKG_MANAGER" in
                apt) sudo apt-get install -y zsh ;;
                dnf|yum) sudo dnf install -y zsh ;;
                pacman) sudo pacman -S --noconfirm zsh ;;
                *) warning "Cannot install zsh with unknown package manager" ;;
            esac
        fi
    fi

    # Set Zsh as default shell
    if [[ "$SHELL" != *"zsh"* ]]; then
        info "Setting Zsh as default shell..."
        if [[ "$OS" == "macos" ]]; then
            sudo dscl . -create /Users/$USER UserShell /usr/local/bin/zsh 2>/dev/null || \
            sudo dscl . -create /Users/$USER UserShell /opt/homebrew/bin/zsh 2>/dev/null || \
            chsh -s $(which zsh)
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

    if [[ "$OS" == "macos" ]]; then
        if command -v pyenv &>/dev/null; then
            # First update pyenv to get latest Python versions
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
                info "Installing Python $PYTHON_VERSION..."
                pyenv install "$PYTHON_VERSION" || warning "Failed to install Python $PYTHON_VERSION"
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
        # Try to install Python packages, but don't fail if externally managed
        pip3 install --user --upgrade pip 2>/dev/null || {
            warning "pip upgrade failed (may be externally managed)"
            info "Consider using pipx or virtual environments for Python packages"
        }
        
        # Try to install essential packages, continue on failure
        for pkg in pynvim black ruff mypy ipython; do
            pip3 install --user "$pkg" 2>/dev/null || {
                info "Could not install $pkg with pip, trying system package manager..."
                if [[ "$OS" == "linux" ]]; then
                    case "$PKG_MANAGER" in
                        apt) sudo apt-get install -y "python3-$pkg" 2>/dev/null || true ;;
                        dnf|yum) sudo dnf install -y "python3-$pkg" 2>/dev/null || true ;;
                        *) true ;;
                    esac
                fi
            }
        done
    fi
    
    success "Python environment configured"
}

setup_node() {
    progress "Setting up Node.js environment..."

    # Install nvm if not present
    if [[ ! -d "$HOME/.nvm" ]]; then
        info "Installing nvm..."
        # Temporarily disable strict mode for nvm installation
        set +u
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash || {
            warning "NVM installation had warnings, continuing..."
        }
        set -u
        
        # Load nvm for current session
        export NVM_DIR="$HOME/.nvm"
        if [[ -s "$NVM_DIR/nvm.sh" ]]; then
            # Disable strict mode while sourcing nvm
            set +u
            source "$NVM_DIR/nvm.sh"
            set -u
        fi
    else
        success "NVM already installed"
        export NVM_DIR="$HOME/.nvm"
        if [[ -s "$NVM_DIR/nvm.sh" ]]; then
            set +u
            source "$NVM_DIR/nvm.sh"
            set -u
        fi
    fi

    # Install latest LTS Node if nvm is available
    if command -v nvm &>/dev/null; then
        info "Installing latest LTS Node.js..."
        set +u  # Disable strict mode for nvm commands
        nvm install --lts 2>/dev/null || warning "Node installation had issues"
        nvm use --lts 2>/dev/null || warning "Could not switch to LTS Node"
        
        # Install global npm packages
        if command -v npm &>/dev/null; then
            info "Installing global npm packages..."
            npm install -g neovim typescript prettier eslint 2>/dev/null || warning "Some npm packages failed to install"
        fi
        set -u  # Re-enable strict mode
        
        success "Node.js environment configured"
    else
        warning "NVM not available, skipping Node.js setup"
    fi
}

create_symlinks() {
    progress "Creating dotfile symlinks..."

    # Run the symlink creation script
    if [[ -f "$SCRIPT_DIR/symlinks.sh" ]]; then
        bash "$SCRIPT_DIR/symlinks.sh"
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

    # Install TPM (Tmux Plugin Manager)
    if [[ ! -d "$HOME/.tmux/plugins/tpm" ]]; then
        info "Installing Tmux Plugin Manager..."
        git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
    else
        success "TPM already installed"
    fi

    # Install tmux plugins
    if [[ -f "$HOME/.tmux/plugins/tpm/bin/install_plugins" ]]; then
        "$HOME/.tmux/plugins/tpm/bin/install_plugins" || true
    fi

    success "tmux configured"
}

# ────────────────────────────────────────────────────────────────────────────────────────────────────────────
# 🎯 MAIN EXECUTION
# ────────────────────────────────────────────────────────────────────────────────────────────────────────────

main() {
    echo "════════════════════════════════════════════════════════════════════"
    echo "       🚀 DOTFILES UNIFIED SETUP"
    echo "════════════════════════════════════════════════════════════════════"
    echo ""

    info "Setup mode: $INSTALL_MODE"
    info "Log file: $LOG_FILE"
    echo ""

    # Detect system
    detect_system

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
            setup_node
            setup_neovim
            setup_tmux

            # Configure Git
            git config --global core.excludesfile '~/.gitignore' || true
            
            # Install git hooks
            if [[ -f "$DOTFILES_DIR/git/install-git-hooks" ]]; then
                bash "$DOTFILES_DIR/git/install-git-hooks"
            fi
            ;;

        core)
            info "Running core installation..."

            # Minimal OS setup
            if [[ "$OS" == "macos" ]]; then
                setup_macos_xcode
                setup_homebrew
                for pkg in git neovim tmux starship ripgrep fd; do
                    if brew list --formula "$pkg" &>/dev/null; then
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
            error "Unknown install mode: $INSTALL_MODE"
            echo "Usage: $0 [full|core|symlinks]"
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
