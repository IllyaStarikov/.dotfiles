# Setup Guide

Quick installation guide for macOS and Linux.

## Quick Install

```bash
git clone https://github.com/IllyaStarikov/.dotfiles.git ~/.dotfiles
cd ~/.dotfiles && ./src/setup/setup.sh
```

## Prerequisites

**macOS**: 10.15+, Admin privileges, 2GB bandwidth
**Linux**: Ubuntu 20.04+/Fedora 35+/Arch, Admin privileges, 1.5GB bandwidth

## What Gets Installed

- Package managers (Homebrew on macOS)
- Modern CLI tools (ripgrep, fd, fzf, eza)
- Development tools (Neovim, tmux, Git)
- Nerd Fonts with ligatures
- Shell enhancements (Zsh + Zinit + Starship)
- All dotfile symlinks

## Post-Installation

### Neovim Setup

```bash
nvim                # Plugins auto-install
:checkhealth        # Verify installation
:Mason              # Install language servers
```

### tmux Setup

```bash
tmux
# Press Ctrl-a + I to install plugins
```

### Theme Configuration

```bash
theme               # Auto-detect from macOS
theme day           # Light theme
theme night         # Dark theme
```

## Customization

Personal configs go in:

- `~/.config/nvim/after/` - Neovim overrides
- `~/.zshrc.local` - Shell customizations
- `~/.gitconfig.local` - Git settings

## Troubleshooting

**Neovim issues**: Run `:checkhealth` for diagnostics

**Shell not loading**: Ensure Zsh is default: `chsh -s $(which zsh)`

**Fonts missing**: Restart terminal after installation

**Permission errors**: Don't use sudo, let scripts handle permissions

## Updating

```bash
cd ~/.dotfiles
git pull
./src/setup/setup.sh --symlinks  # Update links only
```
