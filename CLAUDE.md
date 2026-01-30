# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Linting Tools

When checking code for errors, always use these tools in order:

**Lua files:**
1. `luac -p <file>` - Syntax validation (catches parse errors only)
2. `stylua --check <file>` - Formatting validation (2-space indent, no tabs)
3. For semantic errors (unused variables, wrong API usage, type mismatches), these CLI tools won't help. Ask the user to check lua_ls diagnostics in Neovim, or test the code by running it.

**Important Lua gotchas CLI tools won't catch:**
- `vim.defer_fn()` returns a libuv timer userdata, stop with `timer:stop(); timer:close()` NOT `vim.fn.timer_stop()`
- `vim.fn.timer_start()` returns a number ID, stop with `vim.fn.timer_stop(id)`
- Unused variables (lua_ls catches these)
- Wrong function signatures
- Overriding vim API functions triggers `duplicate-set-field` - use `---@diagnostic disable-next-line: duplicate-set-field`

**When to suppress vs fix lua_ls errors:**
- **Fix first**: Always try to fix the actual issue before suppressing
  - API changed? Update the code (e.g., which-key v3 no longer uses `setup()`)
  - Deprecated function? Use the replacement
  - Wrong usage? Fix the code
- **Suppress only when**: The code is correct but lua_ls can't verify it
  - Type inference limitations: `(vim.uv or vim.loop).fs_stat` - lua_ls can't infer conditional types
  - Missing/wrong type definitions: Some plugins (conform.nvim, etc.) have incorrect annotations
  - Intentional overrides: `vim.notify = function()` requires `duplicate-set-field`
- **CRITICAL - Always Google/WebSearch first**: Before ANY suppression, you MUST use WebSearch to verify the plugin/API documentation. Every single time. No exceptions. You could be wrong - suppression might hide a real bug or outdated API usage. Search for "<plugin> setup arguments" or "<function> signature" to verify.
- **Always add a comment** explaining why suppression is necessary

**Shell scripts (zsh/bash):**
1. `zsh -n <file>` or `bash -n <file>` - Syntax validation
2. `shellcheck <file>` - Static analysis (note: shellcheck doesn't support zsh, only sh/bash)

**Python files:**
1. `ruff check <file>` - Linting (catches most issues)
2. `ruff format --check <file>` - Formatting

**Always run stylua on Lua files after making changes** - the codebase uses 2-space indentation.

## Code Style Preferences

**Line Length**: 100 characters maximum (modern preference over traditional 80 characters)
- All formatters and linters are configured for 100-character line length
- This applies to all languages: Python, C/C++, Lua, JavaScript/TypeScript, Shell, etc.
- Rationale: Modern monitors support wider lines, improves readability for complex expressions
- Default in most style guides was 80 (terminal width from 1970s hardware)

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
./src/setup/setup.sh           # Full installation (interactive, auto-detects platform)
./src/setup/setup.sh --core    # Core packages only
./src/setup/setup.sh --symlinks # Just create symlinks

# Create symlinks for all dotfiles
./src/setup/symlinks.sh

# System maintenance and updates
./src/scripts/update-dotfiles   # Update all packages, plugins, and tools (alias: update)
```

### Testing
```bash
# Main test runner with comprehensive test suite
./test/runner.zsh            # Run standard test suite
./test/runner.zsh --quick    # Quick sanity check (< 10s)
./test/runner.zsh --unit     # Unit tests only (< 5s)
./test/runner.zsh --functional    # Functional tests (< 30s)
./test/runner.zsh --integration   # Integration tests (< 60s)
./test/runner.zsh --performance   # Performance regression tests
./test/runner.zsh --workflows     # Real-world workflow tests
./test/runner.zsh --full          # Complete test suite with all tests

# Run specific test files
./test/runner.zsh unit/nvim/init_zsh_test.sh    # Single unit test
./test/runner.zsh functional/nvim           # All Neovim functional tests
./test/runner.zsh integration/setup         # Setup integration tests
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
- **80+ Neovim plugins** managed by lazy.nvim (500+ plugin references across config files)
- **5 Zsh plugins** via Zinit (fast-syntax-highlighting, autosuggestions, completions, etc.)
- **0 tmux plugins** (pure configuration, no TPM - simpler and faster)
- **40+ test files** with comprehensive 4-level testing infrastructure
- **14 utility scripts** in src/scripts/ (bugreport, cortex, extract, fixy, etc.)
- **7 language configs** in src/language/ (ruff, stylua, clang-format, etc.)
- **4 TokyoNight theme variants** (day, night, moon, storm)
- **20+ languages** with full LSP support

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
│   ├── neovim/            # Neovim configuration (flat structure)
│   │   ├── init.lua       # Entry point with path detection
│   │   ├── *.lua          # Config modules (plugins, commands, etc.)
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
- Spell files stored in private repo: `~/.dotfiles/.dotfiles.private/config/spell/`

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
- Performance benchmarks (startup ~150ms, plugin < 500ms)
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
src/neovim/
├── core/           # Performance tuning, options, globals
├── keymaps/        # Categorized key bindings
├── lsp/            # Language server configurations
├── plugins/        # 80+ plugin specifications
├── ui/             # Theme and interface settings
├── snippets/       # Language-specific snippets
├── init.lua        # Entry point
├── plugins.lua     # Plugin specifications
└── *.lua           # Other config modules
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
- Neovim startup: ~150ms
- Plugin loading: < 500ms
- Theme switching: < 500ms
- Memory usage: < 200MB
- Test execution: unit < 5s, functional < 30s, integration < 60s

## Critical Behavioral Notes

**Language Configurations**: All language-specific configs are in `/src/language/`. References in symlinks.sh, fixy, and CI workflows have been updated accordingly.

**Spell Files**: Neovim spell files are configured to load from `~/.dotfiles/.dotfiles.private/config/spell/` directly via `spellfile` option in `options.lua`. No symlinks needed.

**Testing Before Commits**: Run `./test/runner.zsh --quick` before committing. For major changes, use `./test/runner.zsh --full`.

**Zsh Library (`src/lib/`)**: Before implementing shell utility functions, check the library first:
```bash
# Available modules (400+ functions):
ls src/lib/*.zsh
# colors.zsh   - Terminal colors, $RED, $GREEN, colorize()
# utils.zsh    - OS detection, command_exists(), file ops, is_macos(), is_linux()
# logging.zsh  - LOG, INFO, WARN, ERROR, DEBUG functions
# die.zsh      - Error handling, assertions, require_command()
# array.zsh    - Array manipulation (60+ functions)
# hash.zsh     - Associative array operations
# json.zsh     - JSON parsing/generation (uses jq)
# yaml.zsh     - YAML parsing/generation
# types.zsh    - Type checking, validation
# math.zsh     - Mathematical operations
# textwrap.zsh - Text formatting, wrapping
# cli.zsh      - Argument parsing
# unit.zsh     - Unit testing assertions
# ssh.zsh      - SSH key management
# callstack.zsh - Stack traces, debugging
# help.zsh     - Help text generation
```

**When writing new shell scripts:**
1. Source the library: `source "${0:A:h}/../lib/init.zsh"` (from src/scripts/)
2. Use library functions instead of reimplementing (e.g., `command_exists` not `command -v`)
3. Add new common utilities to the appropriate library module
4. Colors are exported: `$RED`, `$GREEN`, `$YELLOW`, `$BLUE`, `$CYAN`, `$BOLD`, `$NC`

**CI/Presubmit Checks for Major Refactors**: When doing significant refactoring (moving files, renaming modules, changing plugin configs), always verify CI passes after pushing:
```bash
# Push and watch CI
git push && cd ~/.dotfiles && gh run list --limit 4  # Check workflows started
gh run watch <run-id> --exit-status                   # Watch specific workflow
```

**Known CI-Breaking Patterns** (learned from experience):
- **nvim-treesitter**: Uses `require("nvim-treesitter")` NOT `require("nvim-treesitter.configs")` (deprecated)
- **lazy.nvim `missing = true`**: Causes plugin auto-install which times out in Docker e2e tests (10s limit)
- **LuaSnip jsregexp build**: Native compilation times out in CI Docker containers - keep build step disabled
- **Lua module naming**: Don't name files `debug.lua` - conflicts with Lua's built-in `debug` module
- **File moves/renames**: Update ALL `require()` paths when moving Lua modules

**Code Formatting**: Always use `./src/scripts/fixy` instead of individual formatters. It uses the priority system defined in `/config/fixy.json`.

**Private Repository**: Check for existence of `.dotfiles.private` before accessing work-specific configurations:
```bash
[ -d "$HOME/.dotfiles/.dotfiles.private" ] && echo "Private repo exists"
```

**Theme Changes**: When modifying theme code, test all four TokyoNight variants. The system handles tmux reloading automatically.

**Git Commits**: Pre-commit hooks run Gitleaks for secret detection using Gitleaks default configuration.

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

## Style Guide Reference

The style guides are included as a submodule at `/Users/starikov/.dotfiles/styleguide/`. These should be consulted before any code refactoring or commits. We follow industry-standard style guides for consistency and readability.

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
- Formatter priority: yapf → ruff → black
- Import sorting: isort with profile configured
- Config: `src/language/ruff.toml`
- Style reference: https://google.github.io/styleguide/pyguide.html

#### C/C++
- Line length: 100 characters (modern preference)
- Indentation: 2 spaces
- Base style: Industry standard (via clang-format)
- Config: `src/language/.clang-format`
- Style reference: https://google.github.io/styleguide/cppguide.html

#### Lua
- Line length: 100 characters (modern preference)
- Indentation: 2 spaces
- Quote style: Double quotes preferred
- Config: `src/language/stylua.toml`

#### Shell Scripts
- Line length: 100 characters (modern preference)
- Indentation: 2 spaces (via shfmt)
- Always use `#!/usr/bin/env zsh` or `#!/bin/bash`
- Style reference: https://google.github.io/styleguide/shellguide.html

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
3. Run `./test/runner.zsh --quick` to verify configurations
4. Ensure line lengths comply (100 characters for all languages except Go)
5. Verify proper indentation (2 spaces for most, 4 for Python, tabs for Go)
6. Run `shellcheck` for shell scripts
7. Run `ruff check` for Python files
