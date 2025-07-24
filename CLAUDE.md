# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a comprehensive dotfiles repository that serves dual purposes:
1. **Personal configuration management** - Complete development environment setup
2. **Web publishing** - GitHub Pages site at `dotfiles.starikov.io` showcasing configurations

## Key Commands

### Setup and Installation
```bash
# Initial macOS setup (installs Homebrew, Oh My Zsh, packages, fonts)
./src/setup/mac.sh

# Create symlinks for all dotfiles
./src/setup/aliases.sh

# System maintenance and updates
./src/scripts/update
```

### Theme Management
```bash
# Switch themes based on macOS appearance (light/dark mode)
./src/theme-switcher/switch-theme.sh

# Quick alias for theme switching
theme
```

### Development Workflow
```bash
# Start tmux session with tmuxinator
tmuxinator start project

# Launch Alacritty terminal
alacritty

# Edit configurations
nvim ~/.vimrc
```

## Architecture Overview

### Core Components

**Configuration Management** (`/src/`):
- All dotfiles are stored in `/src/` and symlinked to home directory
- Configurations include: Alacritty, Neovim, Zsh, tmux, Git, LaTeX
- Uses Oh My Zsh with Spaceship theme and various productivity plugins

**Automated Theme Switching**:
- `switch-theme.sh` detects macOS appearance settings via `defaults read -g AppleInterfaceStyle`
- Automatically updates color schemes for: Alacritty (Dracula/Solarized), tmux, and exports `MACOS_THEME` variable
- Integrated with Vim configuration for automatic light/dark mode switching
- Theme configurations are generated in `~/.config/` directories

**Web Publishing System**:
- HTML templates in `/template/` directory mirror each configuration file
- Served via GitHub Pages with custom domain and Google Analytics
- README.md acts as main index page linking to all configurations

### Development Environment Stack

- **Shell**: Zsh + Oh My Zsh + Spaceship theme
- **Terminal**: Alacritty with custom keybindings and theme integration  
- **Editor**: Neovim with Vim-Plug package manager
- **Multiplexer**: tmux with TPM, custom prefix (C-a), vim-like bindings
- **Session Management**: Tmuxinator with predefined project layouts
- **Package Management**: Homebrew for macOS packages
- **Version Control**: Git with global ignore patterns
- **Python**: pyenv for version management
- **LaTeX**: MiKTeX with custom latexmkrc build configuration

### Key Integration Points

**Theme System Integration**:
- Zsh sources `~/.config/theme-switcher/current-theme.sh` for `MACOS_THEME` variable
- Vim detects theme via same mechanism and switches between Dracula (dark) and default (light)
- tmux loads `~/.config/tmux/theme.conf` which is dynamically generated
- Alacritty imports `~/.config/alacritty/theme.toml` for color schemes

**Unified Keybindings**:
- Vim mode enabled in both zsh and tmux
- Consistent navigation patterns across terminal, editor, and multiplexer
- Custom tmux prefix (C-a) with vim-like visual selection

**Automation Pipeline**:
- `update` script maintains all system packages and plugins
- Automated symlink creation via `aliases.sh`
- Theme switching handles tmux session reloading automatically

## File Structure Logic

- **`/src/`** - Source configurations (the actual dotfiles)
- **`/src/setup/`** - Installation and setup scripts  
- **`/src/scripts/`** - Maintenance and utility scripts
- **`/src/theme-switcher/`** - Dynamic theme switching system
- **`/src/tmuxinator/`** - tmux session templates
- **`/template/`** - HTML templates for web publishing
- **`/.claude/`** - Claude Code configuration and permissions

## Important Behavioral Notes

**Theme Switching**: When modifying theme-related code, always test both light and dark modes. The system detects changes to macOS appearance settings and updates multiple applications simultaneously.

**Symlink Management**: Configuration files in `/src/` are symlinked to their proper locations. Always edit files in `/src/` directory, not the symlinked versions.

**Web Publishing**: Any changes to configuration files should consider the corresponding HTML template in `/template/` directory for web presentation.

**tmux Integration**: Theme changes require tmux session reloading. The theme switcher handles this automatically by sourcing configs and refreshing all clients.