# /src - Source Configuration Files

> **The heart of the dotfiles** - All configuration files that get symlinked to their proper locations

This directory contains the actual dotfiles, scripts, and configurations that make up the development environment. Everything here is symlinked to appropriate system locations by the setup scripts.

## 📁 Directory Structure

```
src/
├── alacritty.toml         # Alacritty terminal configuration
├── Brewfile               # macOS package definitions
├── editorconfig           # Universal editor configuration
├── gitleaks.toml          # Secret detection configuration
├── i3_config              # i3 window manager (Linux)
├── ripgreprc              # Ripgrep search configuration
├── tmux.conf              # Tmux terminal multiplexer
├── git/                   # Git configuration and hooks
├── kitty/                 # Kitty terminal emulator
├── language/              # Language-specific configs (7 files)
├── neovim/                # Neovim editor (22 modules + 4 subdirectories)
├── scripts/               # Utility scripts (11 tools)
├── setup/                 # Installation scripts
├── theme/        # Dynamic theme system
├── wezterm/               # WezTerm terminal
└── zsh/                   # Zsh shell configuration
```

## 🔧 Configuration Files

### Terminal Emulators

**alacritty.toml** - GPU-accelerated terminal

- Font: MesloLGS Nerd Font Mono
- Dynamic theme switching via imports
- Custom key bindings
- macOS-specific decorations

**kitty/** - Fast, feature-rich terminal

- GPU rendering
- Ligature support
- Image protocol
- Custom layouts

**wezterm/** - Lua-configurable terminal

- Cross-platform
- Multiplexing support
- GPU acceleration
- Dynamic configuration

### Shell & Multiplexer

**tmux.conf** - Terminal multiplexer

- Prefix: `Ctrl-a` (screen-like)
- Vi-mode navigation
- Smart pane switching
- Status bar with system stats
- Theme integration

**zsh/** - Z shell configuration

- Zinit plugin manager (turbo mode)
- Starship prompt
- 200+ aliases
- Vi mode with visual feedback
- Smart completions

### Development Tools

**neovim/** - Modern text editor

- 500+ plugin references
- LSP for 20+ languages
- AI integration (Avante, CodeCompanion)
- Blink.cmp for ultra-fast completion
- Custom snippets per language

**git/** - Version control

- Global configuration
- 50+ aliases
- Delta for diffs
- GPG signing
- Pre-commit hooks
- Gitleaks integration

### Package Management

**Brewfile** - Homebrew packages

- Core tools: git, tmux, neovim
- Modern CLI: eza, bat, fd, ripgrep
- Development: node, python, rust, go
- Fonts: Nerd Fonts collection

### Language Support

**language/** - Language-specific configurations

- `.clang-format` - C/C++ formatting
- `clangd_config.yaml` - C/C++ LSP
- `latexmkrc` - LaTeX compilation
- `markdownlint.json` - Markdown linting
- `pyproject.toml` - Python project
- `ruff.toml` - Python formatting/linting
- `stylua.toml` - Lua formatting

### Search & Security

**ripgreprc** - Fast search configuration

- Smart case sensitivity
- Hidden file searching
- Custom type definitions
- Ignore patterns

**gitleaks.toml** - Secret detection

- Custom rules for dotfiles
- Allow patterns for false positives
- Pre-commit integration

**editorconfig** - Universal editor settings

- Consistent indentation
- Line endings
- Charset settings
- Works with all editors

## 📂 Key Subdirectories

### /git

Version control configuration and utilities:

- `gitconfig` - User settings and aliases
- `gitignore` - Global ignore patterns
- `gitmessage` - Commit template
- `install-git-hooks` - Hook installer
- `pre-commit-hook` - Quality checks
- `setup-git-signing` - GPG configuration

### /neovim

Modern Neovim configuration:

- `init.lua` - Entry point with path detection
- `core/` - Core modules (options, performance, backup)
- `keymaps/` - Organized key bindings
- `plugins/` - Plugin specifications (lazy.nvim)
- `snippets/` - Language-specific snippets
- `lsp.lua`, `ui.lua`, `utils.lua` - Root-level modules
- Work overrides loaded from private repo

### /scripts

Utility scripts for productivity:

- `fixy` - Universal code formatter (20+ languages)
- `theme` - Quick theme switcher
- `update-dotfiles` - System updater
- `tmux-utils` - Status bar utilities
- `scratchpad` - Temp file editor
- `extract` - Archive extractor
- `fetch-quotes` - Inspiration fetcher

### /setup

Installation and configuration:

- `install.sh` - Main installer (interactive, platform-aware)
- `symlinks.sh` - Dotfile linking
- `update.sh` - System maintenance and updates
- `uninstall.sh` - Clean removal with backup restore

### /theme

Dynamic theme synchronization:

- `switch-theme.sh` - Main switcher
- `validate-themes.sh` - Theme validator
- `tokyonight_day/`, `tokyonight_night/`, `tokyonight_moon/`, `tokyonight_storm/` - Theme configs
- Syncs: Alacritty, tmux, Neovim, WezTerm, Starship
- < 500ms switching time

### /zsh

Shell configuration:

- `aliases.zsh` - Command shortcuts
- `starship.toml` - Prompt configuration
- `zshenv` - Environment variables
- `zshrc` - Main configuration

## 🔗 Symlink Mapping

Files are symlinked from `src/` to system locations:

```bash
# Terminal configs
src/alacritty.toml    → ~/.config/alacritty/alacritty.toml
src/kitty/            → ~/.config/kitty/
src/wezterm/          → ~/.config/wezterm/

# Shell configs
src/zsh/zshrc         → ~/.zshrc
src/zsh/zshenv        → ~/.zshenv
src/tmux.conf         → ~/.tmux.conf

# Editor configs
src/neovim/           → ~/.config/nvim/
src/editorconfig      → ~/.editorconfig

# Git configs
src/git/gitconfig     → ~/.gitconfig
src/git/gitignore     → ~/.gitignore_global

# Language configs
src/language/*        → ~/.config/*/
```

## 💡 Usage Guidelines

### Daily Workflow

```bash
# Edit configurations (always in src/)
nvim ~/.dotfiles/src/neovim/init.lua
nvim ~/.dotfiles/src/zsh/aliases.zsh

# Changes reflect immediately via symlinks
# No re-linking needed
```

### Adding New Dotfiles

1. Create file in `src/` directory
2. Add symlink logic to `setup/symlinks.sh`
3. Run `./setup/symlinks.sh` to create link
4. Test the configuration
5. Commit changes

### Best Practices

- ✅ Always edit files in `src/`, never symlinked versions
- ✅ Test changes immediately after editing
- ✅ Run `./test/runner.zsh --quick` before committing
- ✅ Keep related configs together
- ✅ Document inline with comments
- ✅ No secrets in configs (use env vars)

## 🧪 Testing

Validate configuration changes:

```bash
# Quick sanity check
./test/runner.zsh --quick

# Test specific component
./test/runner.zsh unit/nvim

# Full test suite
./test/runner.zsh --full
```

## 🔒 Security

- Pre-commit hooks scan for secrets
- Gitleaks configuration included
- Private configs in separate submodule
- GPG signing for commits
- No sensitive data in configs

## 📚 Related Documentation

- [Setup Guide](setup/README.md) - Installation instructions
- [Scripts Reference](scripts/README.md) - Utility script docs
- [Neovim Config](neovim/README.md) - Editor setup
- [Theme System](theme/README.md) - Theme switching
- [Git Config](git/README.md) - Version control setup
- [Language Configs](language/README.md) - Language support
- [Main README](../README.md) - Repository overview
