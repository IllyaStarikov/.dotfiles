# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Code Style Preferences

**Line Length**: 100 characters maximum (modern preference over traditional 80 chars)
- All formatters and linters are configured for 100-character line length
- This applies to all languages: Python, C/C++, Lua, JavaScript/TypeScript, Shell, etc.

## Important: README Documentation

**ALWAYS read the README.md file in any directory before performing actions in that directory.** Each directory contains a README that documents:
- Directory purpose and structure
- Configuration details
- Usage patterns
- Integration points
- Best practices specific to that component

When making changes to any directory, **update its README.md** to reflect those changes.

## Repository Overview

This is a comprehensive dotfiles repository serving dual purposes:
1. **Personal configuration management** - Complete development environment with enterprise-level testing
2. **Web publishing** - GitHub Pages site at `dotfiles.starikov.io` showcasing configurations

## Key Commands

### Setup and Installation
```bash
# Unified setup script with different modes
./src/setup/setup.sh           # Full installation (interactive)
./src/setup/setup.sh --core    # Core packages only
./src/setup/setup.sh --symlinks # Just create symlinks

# Platform-specific setup (called by setup.sh)
./src/setup/mac.sh     # macOS setup (Intel/Apple Silicon)
./src/setup/linux.sh   # Linux setup (Ubuntu/Debian/Fedora/Arch)

# Create symlinks for all dotfiles
./src/setup/symlinks.sh

# System maintenance and updates
./src/scripts/update-dotfiles   # Update all packages, plugins, and tools (alias: update)
```

### Testing
```bash
# Main test runner with comprehensive test suite
./test/test            # Run standard test suite
./test/test --quick    # Quick sanity check (< 10s)
./test/test --unit     # Unit tests only (< 5s)
./test/test --functional    # Functional tests (< 30s)
./test/test --integration   # Integration tests (< 60s)
./test/test --performance   # Performance regression tests
./test/test --workflows     # Real-world workflow tests
./test/test --full          # Complete test suite with all tests

# Run specific test files
./test/test unit/nvim/init_test.sh    # Single unit test
./test/test functional/nvim           # All Neovim functional tests
./test/test integration/setup         # Setup integration tests
```

### Linting and Code Quality
```bash
# Universal code formatter with config-based priority queue
./src/scripts/fixy [file]   # Auto-detect language and format

# Shell scripts
shellcheck src/**/*.sh

# Lua files
stylua --check src/neovim/

# Python files
ruff format src/**/*.py
ruff check src/**/*.py
```

### Theme Management
```bash
# Switch themes based on macOS appearance (light/dark mode)
./src/theme-switcher/switch-theme.sh

# Quick theme switching commands (aliases in zsh)
theme           # Auto-detect and switch based on macOS appearance
theme day       # TokyoNight Day (light)
theme night     # TokyoNight Night (dark)
theme moon      # TokyoNight Moon (dark variant)
theme storm     # TokyoNight Storm (dark variant)
```

### Development Workflow
```bash
# Start tmux session with tmuxinator (templates in private repo)
tmuxinator start project
tmuxinator start ai       # AI development session

# Edit configurations
nvim ~/.config/nvim/init.lua

# Utility scripts
scratchpad              # Create temporary file for quick editing
fetch-quotes           # Fetch inspirational quotes
tmux-utils battery     # Check battery status
tmux-utils cpu         # Check CPU usage

# AI-powered local development with Cortex (via pyenv)
cortex                  # Local AI assistant for coding
cortex status          # Check MLX server status
cortex model <model>   # Switch AI model
cortex agent on/off    # Toggle AI agent mode
```

## Repository Statistics

### Actual Metrics (December 2024)
- **500+ plugin references** across 8 Neovim configuration files
- **5 Zsh plugins** via Zinit (not 20+ as documentation may suggest)
- **0 tmux plugins** (pure config, no TPM despite mentions)
- **30+ test files** with 4-level testing infrastructure
- **11 utility scripts** in src/scripts/
- **7 language configs** in src/language/
- **4 TokyoNight theme variants**
- **20+ languages** with LSP support

## High-Level Architecture

### Directory Organization

```
~/.dotfiles/
├── src/                    # Source configurations (actual dotfiles)
│   ├── language/          # Language-specific configurations
│   │   ├── .clang-format  # C/C++ formatter
│   │   ├── clangd_config.yaml # C/C++ language server
│   │   ├── latexmkrc      # LaTeX build configuration
│   │   ├── markdownlint.json # Markdown linter
│   │   ├── pyproject.toml # Python project config
│   │   ├── ruff.toml      # Python linter/formatter
│   │   └── stylua.toml    # Lua formatter
│   ├── neovim/            # Neovim configuration (42 modules)
│   │   ├── config/        # Modular configuration system
│   │   ├── init.lua       # Entry point with path detection
│   │   └── snippets/      # Language-specific snippets
│   ├── setup/             # Installation and setup scripts
│   ├── scripts/           # Utility and maintenance scripts
│   ├── theme-switcher/    # Dynamic theme switching system
│   ├── zsh/               # Zsh configuration with Zinit
│   └── git/               # Git configuration and hooks
├── test/                  # 4-level test infrastructure
├── config/                # Tool configurations (fixy.json)
├── .dotfiles.private/     # Private submodule (work configs)
└── .github/workflows/     # CI/CD pipeline (6 workflows)
```

### Core Architectural Patterns

**1. Symlink Strategy**
- All configurations live in `/src/` and are symlinked to proper locations
- `symlinks.sh` creates all necessary links with backup functionality
- Always edit files in `/src/`, never the symlinked versions

**2. Private Repository Integration**
- `.dotfiles.private/` submodule for work-specific configurations
- Contains: Google/Garmin detection, tmuxinator templates, sensitive settings
- Work overrides loaded conditionally in Neovim and shell configs
- Spell files stored in private repo: `~/.dotfiles/.dotfiles.private/spell/`

**3. Theme System Architecture**
- Atomic switching across all applications (Alacritty, tmux, Neovim, WezTerm, Starship)
- macOS appearance detection via `defaults read -g AppleInterfaceStyle`
- Configuration generation in `~/.config/` directories
- Crash-proof with proper locking mechanisms
- tmux session reloading handled automatically

**4. Testing Infrastructure**
```
Test Levels:
- Unit: Configuration validation (< 5s)
- Functional: Plugin functionality (< 30s)
- Integration: Multi-component (< 60s)
- Performance: Regression tests

Test Categories:
- Configuration validation
- Plugin functionality (Telescope, Gitsigns, Treesitter)
- Performance benchmarks (startup < 300ms, plugin < 500ms)
- Memory leak detection
- Real-world workflows
```

**5. Universal Code Formatter (fixy)**
- Priority-based formatter selection from `/config/fixy.json`
- 20+ language support with automatic fallback
- Parallel processing with CPU core detection
- Normalizations: whitespace, tabs, smart quotes, keep-sorted

**6. CI/CD Pipeline**
- Multi-OS testing (Ubuntu, macOS Intel/Apple Silicon)
- Security scanning with Gitleaks
- Quality checks: ShellCheck, Stylua, Ruff
- Automated dependency updates via Dependabot
- GitHub Pages deployment for web publishing

### Neovim Configuration Architecture

**Module Structure:**
```
config/
├── core/           # Performance tuning, options, globals
├── keymaps/        # Categorized key bindings
├── lsp/            # Language server configurations
├── plugins/        # 80+ plugin specifications
└── ui/             # Theme and interface settings
```

**Key Features:**
- Modern Lua configuration with lazy.nvim
- Work-specific overrides loaded conditionally
- AI integration: Avante, CodeCompanion, local Ollama
- Ultra-fast completion with blink.cmp
- Production-ready auto-formatter with silent operation
- Dynamic path detection for dotfiles or standard location

### Integration Points

**Theme Synchronization:**
- Zsh sources `~/.config/theme-switcher/current-theme.sh`
- Neovim reads `MACOS_THEME` environment variable
- tmux loads `~/.config/tmux/theme.conf`
- Alacritty imports `~/.config/alacritty/theme.toml`

**Performance Standards:**
- Neovim startup: < 300ms
- Plugin loading: < 500ms
- Theme switching: < 500ms
- Memory usage: < 200MB
- Test execution: unit < 5s, functional < 30s, integration < 60s

## Critical Behavioral Notes

**Language Configurations**: All language-specific configs are in `/src/language/`. References in symlinks.sh, fixy, and CI workflows have been updated accordingly.

**Spell Files**: Neovim spell files are configured to load from `~/.dotfiles/.dotfiles.private/spell/` directly via `spellfile` option in `options.lua`. No symlinks needed.

**Testing Before Commits**: Run `./test/test --quick` before committing. For major changes, use `./test/test --full`.

**Code Formatting**: Always use `./src/scripts/fixy` instead of individual formatters. It uses the priority system defined in `/config/fixy.json`.

**Private Repository**: Check for existence of `.dotfiles.private` before accessing work-specific configurations:
```bash
[ -d "$HOME/.dotfiles/.dotfiles.private" ] && echo "Private repo exists"
```

**Theme Changes**: When modifying theme code, test all four TokyoNight variants. The system handles tmux reloading automatically.

**Git Commits**: Pre-commit hooks run Gitleaks for secret detection. The configuration is at `/src/gitleaks.toml`.

**Neovim Debugging**:
```bash
nvim --startuptime /tmp/startup.log   # Profile startup
nvim -V9 /tmp/nvim.log                # Verbose logging
:checkhealth                          # Inside Neovim
:Lazy profile                         # Plugin loading times
```

## Common Fixes and Solutions

### Zsh vim mode recursion error
Fixed by clearing `zle-keymap-select` widget before Starship initialization in `src/zsh/zshrc:181-183`.

### Theme switching issues
- Check lockfile: `/tmp/theme-switch.lock`
- Verify apps are running
- Use force mode: `theme --force dark`

### Formatter not working
- Verify formatter installed: `which <formatter>`
- Check fixy.json config: `/config/fixy.json`
- Test with dry-run: `fixy --dry-run file`

## Script Aliases and Shortcuts

Many scripts have shorter aliases defined in `src/zsh/aliases.zsh`:
- `update` → `update-dotfiles`
- `ff` → fuzzy file finder
- `fg` → fuzzy grep
- `gs` → git status
- `ga` → git add
- `gc` → git commit
- `gp` → git push

## Google Style Guide Reference

The Google style guides are included as a submodule at `/Users/starikov/.dotfiles/styleguide/`. These should be consulted before any code refactoring or commits.

### Style Guide Locations

#### Primary Language Guides
- **Python**: `styleguide/pyguide.md` (100 chars modern preference, 4-space indent)
  - Linter config: `styleguide/pylintrc`
  - Vim config: `styleguide/google_python_style.vim`
- **C++**: `styleguide/cppguide.html` (100 chars modern preference, 2-space indent)
  - Eclipse: `styleguide/eclipse-cpp-google-style.xml`
  - Emacs: `styleguide/google-c-style.el`
- **Shell/Bash**: `styleguide/shellguide.md` (100 chars modern preference, 2-space indent)
- **JavaScript**: `styleguide/jsguide.html` (deprecated, use TypeScript)
- **TypeScript**: `styleguide/tsguide.html` (100 chars modern preference, 2-space indent)
- **Java**: `styleguide/javaguide.html`
  - IntelliJ: `styleguide/intellij-java-google-style.xml`
  - Eclipse: `styleguide/eclipse-java-google-style.xml`
- **Go**: `styleguide/go/guide.md` (no line limit, tabs)
  - Best practices: `styleguide/go/best-practices.md`
  - Decisions: `styleguide/go/decisions.md`

#### Additional Languages
- **HTML/CSS**: `styleguide/htmlcssguide.html`
- **Objective-C**: `styleguide/objcguide.md`
- **R**: `styleguide/Rguide.md`
- **Lisp**: `styleguide/lispguide.xml`
- **Vimscript**: `styleguide/vimscriptguide.xml`
- **XML**: `styleguide/xmlstyle.html`
- **JSON**: `styleguide/jsoncstyleguide.html`
- **C#**: `styleguide/csharp-style.md`

#### Documentation Style
- **Docs**: `styleguide/docguide/style.md`
- **READMEs**: `styleguide/docguide/READMEs.md`
- **Best Practices**: `styleguide/docguide/best_practices.md`

### Configured Style Settings

All formatters and linters in this repository are configured to follow Google style:

#### Python
- Line length: 100 characters (modern preference)
- Indentation: 4 spaces
- Formatter priority: yapf (Google's formatter) → ruff → black
- Import sorting: Google profile via isort
- Config: `src/language/ruff.toml`

#### C/C++
- Line length: 100 characters (modern preference)
- Indentation: 2 spaces
- Base style: Google (via clang-format)
- Config: `src/language/.clang-format`

#### Lua
- Line length: 100 characters (modern preference)
- Indentation: 2 spaces
- Quote style: Double quotes preferred
- Config: `src/language/stylua.toml`

#### Shell Scripts
- Line length: 100 characters (modern preference)
- Indentation: 2 spaces (via shfmt)
- Always use `#!/usr/bin/env zsh` or `#!/bin/bash`

#### JavaScript/TypeScript
- Line length: 100 characters (modern preference)
- Indentation: 2 spaces
- Trailing commas: ES5 style
- Arrow parens: Always
- Config: Prettier in `config/fixy.json`

### Pre-commit Checklist

Before committing code changes:
1. Check the relevant style guide in `styleguide/` directory
2. Run `./src/scripts/fixy` on modified files
3. Run `./test/test --quick` to verify configurations
4. Ensure line lengths comply (100 chars - modern preference for all languages)
5. Verify proper indentation (2 spaces for most, 4 for Python, tabs for Go)
