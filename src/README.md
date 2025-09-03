# src/

Source configuration files for the dotfiles repository - the actual dotfiles that get symlinked to their proper locations.

## Overview

This directory contains all the configuration files, scripts, and settings that make up the dotfiles system. Files here are symlinked to their appropriate locations in the home directory and ~/.config/ by the setup scripts.

## Directory Structure

```
src/
├── Brewfile                # Homebrew package definitions
├── alacritty.toml         # Alacritty terminal configuration
├── brain/                 # Local AI assistant system
├── editorconfig          # Editor configuration (multi-language)
├── git/                   # Git configuration and hooks
├── gitleaks.toml         # Secret detection configuration
├── i3_config             # i3 window manager config (Linux)
├── language/             # Language-specific configurations
│   ├── .clang-format     # C/C++ code formatter
│   ├── clangd_config.yaml # C/C++ language server
│   ├── latexmkrc         # LaTeX build configuration
│   ├── markdownlint.json # Markdown linter rules
│   ├── pyproject.toml    # Python project configuration
│   ├── ruff.toml         # Python linter/formatter
│   └── stylua.toml       # Lua code formatter
├── neovim/               # Neovim configuration (Lua)
├── ripgreprc             # Ripgrep search configuration
├── scripts/              # Utility and maintenance scripts
├── setup/                # Installation and setup scripts
├── theme-switcher/       # Dynamic theme switching system
├── tmux.conf            # Tmux configuration
├── zsh/                 # Zsh shell configuration
└── zshrc                # Zsh entry point
```

## Core Configuration Files

### Terminal & Shell

**alacritty.toml**: Alacritty terminal emulator configuration

- Font settings (MesloLGS Nerd Font)
- Color scheme (dynamically switched)
- Key bindings
- Window decorations

**zshrc** & **zsh/**: Zsh shell configuration

- Plugin management with Zinit
- Starship prompt
- 200+ aliases
- Vi mode
- Completions

**tmux.conf**: Terminal multiplexer configuration

- Custom prefix (Ctrl-a)
- Vim-like navigation
- Theme integration
- Plugin management with TPM

### Development Tools

**neovim/**: Complete Neovim configuration

- Modern Lua configuration
- Lazy.nvim plugin manager
- LSP, completion, snippets
- AI integration (Avante, CodeCompanion)
- Custom keybindings

**git/**: Version control configuration

- Global gitconfig
- Ignore patterns
- Commit message template
- Pre-commit hooks
- GPG signing setup

**Brewfile**: macOS package management

- Development tools
- CLI utilities
- Applications
- Fonts

### Language-Specific

All language-specific configurations are now organized in the `language/` directory:

**language/pyproject.toml**: Python project settings

- Package metadata
- Dependency specifications
- Tool configurations

**language/ruff.toml**: Python linting and formatting

- Style rules
- Ignore patterns
- Line length settings

**language/clangd_config.yaml**: C/C++ development

- Compiler flags
- Include paths
- Diagnostics settings

**language/latexmkrc**: LaTeX compilation

- PDF generation settings
- Continuous compilation
- Viewer configuration

### Search & Security

**ripgreprc**: Fast text search configuration

- Default search options
- File type definitions
- Ignore patterns

**gitleaks.toml**: Secret detection

- Detection rules
- Allow patterns
- Custom patterns

## Subdirectories

### brain/

Local AI assistant system using MLX on Apple Silicon.

- Model management
- Server daemon
- API gateway
- Integration with editors

### git/

Version control configurations and utilities:

- **gitconfig**: User settings, aliases, tools
- **gitignore**: Global ignore patterns
- **gitmessage**: Commit message template
- **install-git-hooks**: Hook installation script
- **pre-commit-hook**: Code quality checks
- **setup-git-signing**: GPG configuration

### neovim/

Modern Neovim configuration with 40+ Lua modules:

- **init.lua**: Entry point
- **config/**: Core configuration modules
  - **fixy.lua**: Production-ready silent auto-formatter (see below)
  - **autocmds.lua**: Auto-commands with notification filtering
  - **lsp.lua**: Language server configurations
  - **keymaps.lua**: Custom key bindings
- **snippets/**: Language-specific snippets
- **spell/**: Custom dictionaries
- **plugin/**: Plugin configurations

#### Fixy Auto-Formatter (Production-Ready)

The `config/fixy.lua` module provides sophisticated silent auto-formatting:

**Features:**
- ✅ **Silent Operation**: Formats on save without "file reloaded" notifications
- ✅ **Multi-layer Notification Suppression**: Handles vim.notify, Snacks.nvim, noice.nvim
- ✅ **Cursor Preservation**: Maintains position during async formatting
- ✅ **Robust Error Handling**: Timeout protection, buffer validation, race condition prevention
- ✅ **Debug Mode**: Optional logging to `/tmp/fixy.log`
- ✅ **State Management**: Global and buffer-local flags prevent concurrent formatting

**Commands:**
- `:Fixy` - Format current file
- `:FixyAuto` - Toggle auto-format
- `:FixyAutoOn/Off` - Enable/disable
- `:FixyStatus` - Show status
- `:FixyDebug` - Toggle debug mode

### scripts/

Utility scripts for daily workflows:

- **common.sh**: Shared functions
- **extract**: Archive extraction
- **fetch-quotes**: Inspirational quotes
- **format**: Universal code formatter
- **scratchpad**: Temporary file creation
- **theme**: Theme switching
- **tmux-utils**: Status bar utilities
- **update-dotfiles**: System updater

### setup/

Installation and configuration scripts:

- **setup.sh**: Main setup script
- **symlinks.sh**: Dotfile linking
- **README.md**: Setup documentation

### spell/

Spell checking dictionaries:

- Custom word lists
- Technical terms
- Personal additions

### theme-switcher/

Dynamic theme switching system:

- **switch-theme.sh**: Main switcher
- **themes/**: Theme configurations
- **validate-themes.sh**: Theme validator

Supports TokyoNight variants:

- Day (light)
- Night (dark)
- Moon (dark variant)
- Storm (dark variant)

### zsh/

Zsh shell components:

- **aliases.zsh**: Command aliases
- **starship.toml**: Prompt configuration
- **zshenv**: Environment variables
- **zshrc**: Main Zsh config

## Symlinking Strategy

Files are symlinked from src/ to their proper locations:

```
src/alacritty.toml      → ~/.config/alacritty/alacritty.toml
src/tmux.conf          → ~/.tmux.conf
src/zshrc              → ~/.zshrc
src/neovim/            → ~/.config/nvim/
src/git/gitconfig      → ~/.gitconfig
src/git/gitignore      → ~/.gitignore_global
```

The `setup/symlinks.sh` script handles all symlinking automatically.

## File Organization Principles

### Configuration Placement

1. **Modern locations preferred**: Use ~/.config/ when possible
2. **Legacy support**: Maintain ~/.file for tools that require it
3. **Modularity**: Split large configs into logical modules

### Naming Conventions

- **Lowercase with underscores**: For scripts and directories
- **Standard names**: Use tool's expected config name
- **Extensions**: Include for clarity (.toml, .yaml, .lua)

### Structure Guidelines

1. **Group by tool**: Keep related configs together
2. **Separate concerns**: Scripts, configs, data in different dirs
3. **Document inline**: Include comments in configs

## Usage Patterns

### Daily Use

Most interactions happen through symlinked files:

```bash
# Edit Neovim config
nvim ~/.config/nvim/init.lua

# Modify shell aliases
nvim ~/.zshrc

# Update git config
nvim ~/.gitconfig
```

### Maintenance

Always edit files in src/ directory:

```bash
# Edit source file
nvim ~/.dotfiles/src/alacritty.toml

# Changes immediately reflected via symlink
# No need to re-link
```

### Adding New Dotfiles

1. Create file in appropriate src/ location
2. Add symlink logic to `setup/symlinks.sh`
3. Run symlink script to create link
4. Commit both file and script changes

## Integration Points

### With Setup System

- `setup/setup.sh`: Installs dependencies
- `setup/symlinks.sh`: Creates all symlinks
- Platform-specific setup scripts

### With Theme System

- Theme switcher updates multiple configs
- Configs read theme variables
- Atomic switching prevents inconsistencies

### With Update System

- `scripts/update-dotfiles`: Updates all components
- Package managers: Homebrew, pip, gem, npm
- Plugin managers: Neovim, tmux, Zsh

## Best Practices

### File Editing

1. **Always edit in src/**: Never edit symlinked versions
2. **Test changes**: Reload configs after editing
3. **Version control**: Commit changes promptly

### Organization

1. **Logical grouping**: Related files stay together
2. **Clear naming**: Self-documenting filenames
3. **Documentation**: README in each major directory

### Compatibility

1. **Cross-platform**: Consider macOS and Linux
2. **Version checks**: Handle missing features gracefully
3. **Fallbacks**: Provide defaults for missing tools

## Security Considerations

- No secrets in configs (use env vars)
- Git hooks prevent accidental commits
- Gitleaks configuration for scanning
- Private configs in separate private repo

## Testing

Test configuration changes:

```bash
# Run quick tests
~/.dotfiles/test/test --quick

# Validate specific component
~/.dotfiles/test/test neovim

# Full test suite
~/.dotfiles/test/test --full
```

## Backup

Critical files to backup:

- Custom configurations
- Personal scripts
- Spell dictionaries
- Snippet definitions

```bash
# Backup src directory
tar -czf dotfiles-src-backup.tar.gz ~/.dotfiles/src/
```

## See Also

- Setup Guide: [setup/README.md](setup/README.md)
- Scripts Documentation: [scripts/README.md](scripts/README.md)
- Neovim Configuration: [neovim/README.md](neovim/README.md)
- Theme System: [theme-switcher/README.md](theme-switcher/README.md)
- Main README: `~/.dotfiles/README.md`
