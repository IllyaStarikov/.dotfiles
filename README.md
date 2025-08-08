# Dotfiles

A comprehensive development environment configuration for macOS and Linux, featuring Neovim, tmux, Zsh, and modern CLI tools.

## Overview

This repository contains my personal dotfiles and system configuration. It provides a complete, reproducible development environment with an emphasis on:

- **Editor efficiency** - Highly optimized Neovim configuration with LSP support
- **Terminal productivity** - Zsh with custom functions, tmux for session management
- **Modern tooling** - Rust-based CLI replacements for better performance
- **Automation** - Automatic theme switching, smart aliases, and helper scripts

## Installation

### Quick Start (macOS)

```bash
git clone https://github.com/IllyaStarikov/.dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./src/setup/setup.sh
```

### Manual Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/IllyaStarikov/.dotfiles.git ~/.dotfiles
   ```

2. Run the setup script for your system:
   ```bash
   # macOS
   ./src/setup/setup.sh
   
   # Linux
   ./src/setup/setup.sh --linux
   ```

3. Create symlinks:
   ```bash
   ./src/setup/symlinks.sh
   ```

## Components

### Neovim

- **Framework**: Lazy.nvim for plugin management
- **Completion**: Blink.cmp with LSP integration
- **Languages**: Configured LSP for Python, JavaScript/TypeScript, Go, Rust, C/C++, Lua
- **AI Integration**: CodeCompanion.nvim for Claude/GPT assistance
- **File Navigation**: Telescope with ripgrep backend
- **Git Integration**: Gitsigns, fugitive, and git-conflict
- **Startup Time**: ~50ms with 80+ plugins

Key files:
- `src/neovim/init.lua` - Main configuration entry point
- `src/neovim/config/` - Modular configuration files
- `src/neovim/snippets/` - Custom snippets for various languages

### Terminal

#### Alacritty
- GPU-accelerated terminal emulator
- Custom keybindings for tmux integration
- Automatic theme switching based on system appearance

#### Tmux
- Custom prefix key (Ctrl-a)
- Vi-mode navigation
- Session management with tmuxinator
- Status bar with system monitoring

#### Zsh
- **Plugin Manager**: Zinit for fast loading
- **Prompt**: Starship with custom configuration
- **Completions**: Fast, context-aware completions
- **Aliases**: Extensive git aliases and shortcuts

### CLI Tools

Modern replacements for common Unix tools:

| Traditional | Modern | Purpose |
|------------|---------|---------|
| `find` | `fd` | File search |
| `grep` | `ripgrep` (`rg`) | Text search |
| `ls` | `eza` | Directory listing |
| `cat` | `bat` | File viewing |
| `diff` | `delta` | Diff viewing |
| `ps` | `procs` | Process viewing |
| `top` | `btop` | System monitoring |

### Theme System

Automatic theme switching that syncs across all applications:

- Detects macOS appearance (light/dark mode)
- Updates Alacritty, Neovim, tmux, and bat colors
- Themes: TokyoNight (variants: night, storm, moon, day)

Usage:
```bash
# Automatic switching based on system
theme

# Manual switching
theme dark
theme light
```

## Directory Structure

```
~/.dotfiles/
├── src/
│   ├── neovim/          # Neovim configuration
│   ├── alacritty/       # Terminal configuration
│   ├── git/             # Git configuration and hooks
│   ├── scripts/         # Utility scripts
│   ├── setup/           # Installation scripts
│   ├── spell/           # Custom dictionary
│   ├── theme-switcher/  # Theme management
│   ├── tmuxinator/      # Tmux session templates
│   ├── zsh/             # Shell configuration
│   └── *.conf/rc        # Other config files
├── doc/                 # Documentation
├── test/                # Test suite
└── template/            # Web documentation templates
```

## Key Features

### Development Workflow

- **LSP Support**: Auto-completion, diagnostics, and code actions for multiple languages
- **Snippet System**: 1000+ snippets across languages with smart expansion
- **Git Integration**: Inline git blame, conflict resolution, and GitHub CLI
- **Testing**: Test runners integrated for Python, JavaScript, and more

### Productivity Tools

- **File Navigation**: Fuzzy finding with Telescope and fzf
- **Session Management**: Tmuxinator templates for project layouts
- **Task Running**: AsyncRun for background compilation and testing
- **Note Taking**: Markdown support with live preview

### Performance Optimizations

- Lazy loading of plugins for fast startup
- Compiled Lua modules for Neovim
- Minimal shell prompt with async git status
- Efficient file operations with Rust-based tools

## Customization

### Local Configuration

Create local overrides that won't be tracked by git:

- `~/.config/nvim/lua/local.lua` - Neovim local settings
- `~/.zshrc.local` - Shell local configuration
- `~/.gitconfig.local` - Git local settings

### Work Profiles

The configuration supports work-specific settings:

```lua
-- In ~/.config/nvim/lua/local.lua
return {
  work = {
    profile = "company-name",
    lsp_servers = { "custom_lsp" },
    snippets_path = "~/work/snippets"
  }
}
```

## Documentation

Detailed documentation is available in the `doc/` directory:

- [Setup Guide](doc/setup/README.md) - Installation and configuration
- [Usage Guide](doc/usage/README.md) - Daily usage and workflows
- [Keybindings](doc/usage/keybindings/README.md) - Complete keybinding reference
- [Troubleshooting](doc/troubleshooting/README.md) - Common issues and solutions

## Testing

The repository includes a comprehensive test suite:

```bash
# Run all tests
./test/test

# Run specific test category
./test/test --unit
./test/test --integration
```

## Requirements

### System Requirements

- **OS**: macOS 12+ or Linux (Ubuntu 20.04+, Fedora 35+, Arch)
- **Neovim**: 0.9.0 or higher
- **Git**: 2.30 or higher
- **Python**: 3.8+ (for Python development)
- **Node.js**: 16+ (for JavaScript development)

### Dependencies

Core dependencies are installed automatically by the setup script:

- Homebrew (macOS) or system package manager (Linux)
- Neovim and dependencies
- Terminal tools (tmux, ripgrep, fd, etc.)
- Language servers and formatters
- Fonts (Nerd Fonts for icons)

## Contributing

While this is a personal configuration, suggestions and improvements are welcome:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## License

MIT License - See [LICENSE](LICENSE) file for details.

## Acknowledgments

This configuration builds upon the work of many excellent projects in the open source community. Special thanks to the maintainers of Neovim, tmux, and all the plugins and tools that make this setup possible.

---

For questions or issues, please open an issue on [GitHub](https://github.com/IllyaStarikov/.dotfiles/issues).