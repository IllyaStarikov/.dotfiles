#!/usr/bin/env bash
set -euo pipefail

# Linux-specific setup script
# This script is called from setup.sh after OS detection

# Import helper functions and variables from parent
source "$(dirname "$0")/setup-helpers.sh"

# Install system dependencies based on package manager
install_linux_dependencies() {
    info "Installing system dependencies for Linux..."
    
    case "$PKG_MANAGER" in
        apt)
            # Update package list
            sudo apt-get update
            
            # Essential build tools and libraries
            $PKG_INSTALL \
                build-essential \
                curl \
                wget \
                git \
                zsh \
                tmux \
                neovim \
                python3 \
                python3-pip \
                python3-venv \
                ruby \
                ruby-dev \
                nodejs \
                npm \
                cargo \
                golang \
                fzf \
                ripgrep \
                fd-find \
                bat \
                htop \
                jq \
                tree \
                xclip \
                xsel \
                fontconfig \
                unzip \
                cmake \
                pkg-config \
                libssl-dev \
                libreadline-dev \
                libbz2-dev \
                libsqlite3-dev \
                libncurses5-dev \
                libncursesw5-dev \
                libffi-dev \
                liblzma-dev \
                libxml2-dev \
                libxmlsec1-dev \
                llvm \
                tk-dev \
                lzma \
                lzma-dev
                
            # Create symlink for fd (Ubuntu/Debian call it fdfind)
            if command -v fdfind &> /dev/null && ! command -v fd &> /dev/null; then
                sudo ln -sf $(which fdfind) /usr/local/bin/fd
            fi
            ;;
            
        dnf|yum)
            # Fedora/RHEL/CentOS packages
            $PKG_INSTALL \
                gcc \
                gcc-c++ \
                make \
                curl \
                wget \
                git \
                zsh \
                tmux \
                neovim \
                python3 \
                python3-pip \
                python3-devel \
                ruby \
                ruby-devel \
                nodejs \
                npm \
                cargo \
                golang \
                fzf \
                ripgrep \
                fd-find \
                bat \
                htop \
                jq \
                tree \
                xclip \
                xsel \
                fontconfig \
                unzip \
                cmake \
                openssl-devel \
                readline-devel \
                bzip2-devel \
                sqlite-devel \
                ncurses-devel \
                libffi-devel \
                xz-devel \
                libxml2-devel \
                libxmlsec1-devel \
                llvm \
                tk-devel
            ;;
            
        pacman)
            # Arch Linux packages
            $PKG_INSTALL \
                base-devel \
                curl \
                wget \
                git \
                zsh \
                tmux \
                neovim \
                python \
                python-pip \
                ruby \
                nodejs \
                npm \
                rust \
                go \
                fzf \
                ripgrep \
                fd \
                bat \
                htop \
                jq \
                tree \
                xclip \
                xsel \
                fontconfig \
                unzip \
                cmake \
                openssl \
                readline \
                bzip2 \
                sqlite \
                ncurses \
                libffi \
                xz \
                libxml2 \
                libxmlsec \
                llvm \
                tk
            ;;
            
        zypper)
            # openSUSE packages
            $PKG_INSTALL \
                gcc \
                gcc-c++ \
                make \
                curl \
                wget \
                git \
                zsh \
                tmux \
                neovim \
                python3 \
                python3-pip \
                python3-devel \
                ruby \
                ruby-devel \
                nodejs \
                npm \
                cargo \
                go \
                fzf \
                ripgrep \
                fd \
                bat \
                htop \
                jq \
                tree \
                xclip \
                xsel \
                fontconfig \
                unzip \
                cmake \
                libopenssl-devel \
                readline-devel \
                libbz2-devel \
                sqlite3-devel \
                ncurses-devel \
                libffi-devel \
                xz-devel \
                libxml2-devel \
                libxmlsec1-devel \
                llvm \
                tk-devel
            ;;
    esac
    
    success "System dependencies installed"
}

# Install additional tools not in package managers
install_additional_tools() {
    info "Installing additional tools..."
    
    # Install eza (better ls) - works on all Linux distros
    if ! command -v eza &> /dev/null; then
        info "Installing eza..."
        cargo install eza
    fi
    
    # Install starship prompt
    if ! command -v starship &> /dev/null; then
        info "Installing starship..."
        curl -sS https://starship.rs/install.sh | sh -s -- -y
    fi
    
    # Install lazygit
    if ! command -v lazygit &> /dev/null; then
        info "Installing lazygit..."
        LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
        curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
        tar xf lazygit.tar.gz lazygit
        sudo install lazygit /usr/local/bin
        rm lazygit lazygit.tar.gz
    fi
    
    # Install delta (better git diff)
    if ! command -v delta &> /dev/null; then
        info "Installing delta..."
        cargo install git-delta
    fi
    
    # Install bottom (better htop)
    if ! command -v btm &> /dev/null; then
        info "Installing bottom..."
        cargo install bottom
    fi
    
    # Install dust (better du)
    if ! command -v dust &> /dev/null; then
        info "Installing dust..."
        cargo install du-dust
    fi
    
    # Install procs (better ps)
    if ! command -v procs &> /dev/null; then
        info "Installing procs..."
        cargo install procs
    fi
    
    # Install zoxide (better cd)
    if ! command -v zoxide &> /dev/null; then
        info "Installing zoxide..."
        cargo install zoxide
    fi
    
    success "Additional tools installed"
}

# Install fonts for Linux
install_linux_fonts() {
    info "Installing Nerd Fonts..."
    
    # Create fonts directory
    mkdir -p ~/.local/share/fonts
    
    # Install JetBrains Mono Nerd Font
    if ! fc-list | grep -q "JetBrainsMono Nerd Font"; then
        info "Installing JetBrains Mono Nerd Font..."
        wget -q https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/JetBrainsMono.zip
        unzip -q JetBrainsMono.zip -d ~/.local/share/fonts/
        rm JetBrainsMono.zip
    fi
    
    # Install Hack Nerd Font
    if ! fc-list | grep -q "Hack Nerd Font"; then
        info "Installing Hack Nerd Font..."
        wget -q https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/Hack.zip
        unzip -q Hack.zip -d ~/.local/share/fonts/
        rm Hack.zip
    fi
    
    # Install FiraCode Nerd Font
    if ! fc-list | grep -q "FiraCode Nerd Font"; then
        info "Installing FiraCode Nerd Font..."
        wget -q https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/FiraCode.zip
        unzip -q FiraCode.zip -d ~/.local/share/fonts/
        rm FiraCode.zip
    fi
    
    # Update font cache
    fc-cache -fv ~/.local/share/fonts
    
    success "Fonts installed"
}

# Install pyenv for Python version management
install_pyenv() {
    if ! command -v pyenv &> /dev/null; then
        info "Installing pyenv..."
        curl https://pyenv.run | bash
        
        # Add pyenv to path for current session
        export PATH="$HOME/.pyenv/bin:$PATH"
        eval "$(pyenv init -)"
        eval "$(pyenv virtualenv-init -)"
    fi
    success "pyenv installed"
}

# Configure Linux-specific settings
configure_linux() {
    info "Configuring Linux-specific settings..."
    
    # Set Zsh as default shell if not already
    if [[ "$SHELL" != *"zsh"* ]]; then
        info "Setting Zsh as default shell..."
        chsh -s $(which zsh)
    fi
    
    # Create necessary directories
    mkdir -p ~/.config/{nvim,alacritty,fontconfig}
    mkdir -p ~/.local/share/nvim/site/autoload
    mkdir -p ~/.cache/nvim
    
    # Configure font rendering (better font smoothing)
    cat > ~/.config/fontconfig/fonts.conf << 'EOF'
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>
  <match target="font">
    <edit mode="assign" name="hinting">
      <bool>true</bool>
    </edit>
    <edit mode="assign" name="hintstyle">
      <const>hintslight</const>
    </edit>
    <edit mode="assign" name="antialias">
      <bool>true</bool>
    </edit>
    <edit mode="assign" name="rgba">
      <const>rgb</const>
    </edit>
    <edit mode="assign" name="lcdfilter">
      <const>lcddefault</const>
    </edit>
  </match>
</fontconfig>
EOF
    
    success "Linux configuration complete"
}

# Main Linux setup
main() {
    info "Starting Linux setup..."
    
    # Install dependencies
    install_linux_dependencies
    
    # Install additional tools
    install_additional_tools
    
    # Install fonts
    install_linux_fonts
    
    # Install pyenv
    install_pyenv
    
    # Configure Linux-specific settings
    configure_linux
    
    success "Linux setup complete!"
}

# Run main function
main "$@"