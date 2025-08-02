# Linux Setup Guide

This guide covers Linux-specific installation details and troubleshooting.

## Supported Distributions

The setup has been tested on:
- **Ubuntu** 20.04, 22.04, 24.04
- **Fedora** 35, 36, 37, 38
- **Arch Linux** (rolling)
- **openSUSE** Leap 15.4+, Tumbleweed
- **Debian** 11, 12
- **Linux Mint** 21+
- **Pop!_OS** 22.04+

## Prerequisites

### System Requirements
- 64-bit x86_64 or ARM64 architecture
- 4GB RAM minimum (8GB recommended)
- 5GB free disk space
- Active internet connection

### Required Packages
These will be installed automatically, but you can pre-install them:
```bash
# Debian/Ubuntu
sudo apt update
sudo apt install git curl wget build-essential

# Fedora
sudo dnf install git curl wget gcc-c++ make

# Arch
sudo pacman -S git curl wget base-devel

# openSUSE
sudo zypper install git curl wget gcc-c++ make
```

## Installation

### Quick Install
```bash
git clone https://github.com/IllyaStarikov/.dotfiles.git ~/.dotfiles && \
cd ~/.dotfiles && \
./src/setup/setup.sh
```

### Desktop Environment Support

The theme switcher supports:
- **GNOME** - Full integration with system theme
- **KDE Plasma** - Color scheme synchronization
- **XFCE** - Window manager theme switching
- **Other DEs** - Falls back to time-based switching

### Package Managers

The setup automatically detects and uses:
- **APT** (Debian/Ubuntu)
- **DNF** (Fedora)
- **YUM** (RHEL/CentOS)
- **Pacman** (Arch)
- **Zypper** (openSUSE)
- **Flatpak** (if installed)
- **Snap** (if installed)

## Post-Installation

### Font Configuration

Fonts are installed to `~/.local/share/fonts`. If they don't appear:
```bash
# Rebuild font cache
fc-cache -fv

# Verify installation
fc-list | grep "JetBrains"
```

### Clipboard Integration

For clipboard support in tmux/Neovim:
```bash
# Debian/Ubuntu
sudo apt install xclip xsel

# Fedora
sudo dnf install xclip xsel

# Arch
sudo pacman -S xclip xsel
```

### Theme Switching

The theme switcher integrates with your desktop environment:
```bash
# Switch theme manually
theme light
theme dark

# Auto-detect from system
theme auto
```

For GNOME users:
```bash
# Ensure gsettings is available
which gsettings || sudo apt install libglib2.0-bin
```

### Shell Configuration

The setup uses Zsh with Zinit. To make Zsh your default shell:
```bash
# Check if Zsh is installed
which zsh

# Make it default
chsh -s $(which zsh)

# Log out and back in for changes to take effect
```

## Troubleshooting

### Common Issues

#### "Command not found" after installation
```bash
# Reload your shell configuration
source ~/.zshrc

# Or start a new shell
exec zsh
```

#### Fonts not displaying correctly
```bash
# Install fontconfig if missing
sudo apt install fontconfig  # Debian/Ubuntu
sudo dnf install fontconfig  # Fedora

# Rebuild cache
fc-cache -fv

# Restart your terminal
```

#### Theme not switching
```bash
# Check if theme files exist
ls ~/.config/alacritty/theme.toml
ls ~/.config/tmux/theme.conf

# Run theme switcher manually
~/.dotfiles/src/theme-switcher/switch-theme-universal.sh auto
```

#### Neovim plugins not installing
```bash
# Install plugin dependencies
nvim --headless +"Lazy! sync" +qa

# Check for errors
nvim +checkhealth
```

### WSL-Specific Setup

For Windows Subsystem for Linux users:

#### Clipboard Integration
```bash
# The setup automatically detects WSL
# Clipboard commands will use clip.exe
```

#### Font Installation
Install JetBrainsMono Nerd Font in Windows:
1. Download from [Nerd Fonts](https://www.nerdfonts.com/)
2. Install in Windows (not WSL)
3. Configure your terminal to use the font

#### Performance Tips
```bash
# Store projects in WSL filesystem (not /mnt/c)
cd ~
mkdir projects

# Disable Windows PATH inheritance (optional)
echo '[interop]' | sudo tee -a /etc/wsl.conf
echo 'appendWindowsPath = false' | sudo tee -a /etc/wsl.conf
```

## Customization

### Local Overrides
Create `~/.zshrc.local` for machine-specific settings:
```bash
# Example: Add custom paths
export PATH="$HOME/custom/bin:$PATH"

# Example: Distribution-specific aliases
if [[ -f /etc/debian_version ]]; then
    alias update='sudo apt update && sudo apt upgrade'
fi
```

### Platform Detection
The setup exports these variables for your scripts:
```bash
echo $OS_TYPE    # "linux"
echo $IS_WSL     # "1" if on WSL, unset otherwise
echo $DISTRO     # "ubuntu", "fedora", "arch", etc.
```

## Uninstallation

To remove the dotfiles:
```bash
# Remove symlinks
rm -f ~/.zshrc ~/.tmux.conf ~/.config/nvim ~/.config/alacritty

# Remove the repository
rm -rf ~/.dotfiles

# Restore default shell (optional)
chsh -s /bin/bash

# Remove installed packages (optional)
# Review before running - this removes many useful tools!
cat ~/.dotfiles/doc/setup/packages-to-remove.txt
```