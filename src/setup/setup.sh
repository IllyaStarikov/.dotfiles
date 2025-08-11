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

        # Detect architecture
        if [[ $(uname -m) == "arm64" ]]; then
            ARCH="arm64"
            BREW_PREFIX="/opt/homebrew"
            info "Detected Apple Silicon Mac"
        else
            ARCH="x86_64"
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
    brew upgrade
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
        brew install "${core_packages[@]}" "${dev_packages[@]}" "${lsp_packages[@]}" || true

        # Nerd Fonts
        brew install --cask font-jetbrains-mono-nerd-font || true
        brew install --cask font-hack-nerd-font || true
        brew install --cask font-ibm-plex-mono || true
        
        # GUI Applications
        brew install --cask wezterm || true
        brew install --cask raycast || true
        brew install --cask amethyst || true
        brew install --cask docker || true
        
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
        brew install "${extra_packages[@]}" || true
    else
        brew install "${core_packages[@]}" || true
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
    eval "$PKG_UPDATE"

    # Core packages (varies by distro)
    case "$PKG_MANAGER" in
        apt)
            local packages=(
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
            )
            ;;
        dnf|yum)
            local packages=(
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
            local packages=(
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
    esac

    eval "$PKG_INSTALL ${packages[*]}"

    # Install Starship
    if ! command -v starship &>/dev/null; then
        curl -sS https://starship.rs/install.sh | sh -s -- -y
    fi

    # Install Rust
    if ! command -v rustup &>/dev/null && [[ "$INSTALL_MODE" == "full" ]]; then
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
        source "$HOME/.cargo/env"
    fi

    success "Linux packages installed"
}

setup_linux() {
    install_linux_packages

    # Install Homebrew on Linux if requested
    if [[ "$INSTALL_MODE" == "full" ]] && ! command -v brew &>/dev/null; then
        warning "Install Homebrew on Linux? (y/n)"
        read -r response
        if [[ "$response" == "y" ]]; then
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
        fi
    fi
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
            eval "$PKG_INSTALL zsh"
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
            # Install latest Python 3.12
            PYTHON_VERSION="3.12.0"
            if ! pyenv versions | grep -q "$PYTHON_VERSION"; then
                pyenv install "$PYTHON_VERSION"
                pyenv global "$PYTHON_VERSION"
            fi
        fi
    fi

    # Install global Python packages
    if command -v pip3 &>/dev/null; then
        pip3 install --user --upgrade pip
        pip3 install --user pynvim black ruff mypy ipython
    fi
    
    success "Python environment configured"
}

setup_node() {
    progress "Setting up Node.js environment..."

    # Install nvm if not present
    if [[ ! -d "$HOME/.nvm" ]]; then
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
        export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    fi

    # Install latest LTS Node
    if command -v nvm &>/dev/null; then
        nvm install --lts
        nvm use --lts
        npm install -g neovim typescript prettier eslint
    fi

    success "Node.js environment configured"
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
                brew install git neovim tmux starship ripgrep fd
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
