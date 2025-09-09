# 🚀 Dotfiles

<div align="center">

```
     ██████╗  ██████╗ ████████╗███████╗██╗██╗     ███████╗███████╗
     ██╔══██╗██╔═══██╗╚══██╔══╝██╔════╝██║██║     ██╔════╝██╔════╝
     ██║  ██║██║   ██║   ██║   █████╗  ██║██║     █████╗  ███████╗
     ██║  ██║██║   ██║   ██║   ██╔══╝  ██║██║     ██╔══╝  ╚════██║
     ██████╔╝╚██████╔╝   ██║   ██║     ██║███████╗███████╗███████║
     ╚═════╝  ╚═════╝    ╚═╝   ╚═╝     ╚═╝╚══════╝╚══════╝╚══════╝
```

**A meticulously engineered development environment that just works™**

[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Neovim](https://img.shields.io/badge/Neovim-0.10+-57A143.svg?logo=neovim&logoColor=white)](https://neovim.io)
[![Tmux](https://img.shields.io/badge/Tmux-3.3+-1BB91F.svg?logo=tmux&logoColor=white)](https://github.com/tmux/tmux)
[![Shell](https://img.shields.io/badge/Shell-Zsh-4E4E4E.svg?logo=gnu-bash&logoColor=white)](https://www.zsh.org)
[![Tests](https://img.shields.io/badge/Tests-30+-success.svg)](test/)
[![CI](https://img.shields.io/badge/CI-GitHub_Actions-2088FF.svg?logo=github-actions&logoColor=white)](.github/workflows)

[**⚡ Quick Start**](#-quick-start) • [**✨ Features**](#-features) • [**📖 Documentation**](https://dotfiles.starikov.io) • [**🧪 Testing**](#-testing)

</div>

---

## 🎯 What Is This?

My personal development environment - a battle-tested, performance-obsessed configuration that transforms any Unix system into a productivity powerhouse. This isn't just a collection of dotfiles; it's a complete development ecosystem with enterprise-grade testing, AI integration, and sub-second everything.

### 🏆 Key Achievements
- **< 50ms** Neovim startup with 500+ plugin references
- **< 100ms** Zsh initialization with smart lazy loading
- **< 500ms** Complete theme switching across all applications
- **30+ test files** ensuring everything works perfectly
- **20+ languages** with full LSP, formatting, and debugging support
- **100% keyboard-driven** workflow with discoverable keybindings

---

## ⚡ Quick Start

### One-Command Installation

```bash
# For the brave (inspects system and installs everything)
curl -fsSL https://raw.githubusercontent.com/IllyaStarikov/.dotfiles/main/src/setup/setup.sh | bash

# For the cautious (clone first, inspect, then install)
git clone https://github.com/IllyaStarikov/.dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./src/setup/setup.sh        # Interactive installation
./src/setup/setup.sh --dry-run  # Preview changes without installing
```

### System Requirements

- **macOS** 12+ (Intel or Apple Silicon) / **Linux** (Ubuntu 20.04+, Arch, Fedora)
- **Zsh** 5.8+ (installed automatically if missing)
- **Git** 2.30+ (for proper delta integration)
- **4GB RAM** minimum (8GB recommended for full AI features)
- **500MB** disk space

---

## ✨ Features

### 🤖 AI-Powered Development
- **Local AI** via Ollama with llama3.1:70b model
- **CodeCompanion** integration for chat, inline edits, and agents
- **GitHub Copilot** support with automatic suggestions
- **Claude/GPT-4** ready configurations

### 🎨 Intelligent Theme System
- **Automatic switching** based on macOS appearance
- **4 TokyoNight variants** (Day, Night, Moon, Storm)
- **Synchronized** across Neovim, Alacritty, WezTerm, tmux, and Starship
- **< 500ms** switching time with zero flicker

### 🚀 Performance-First Design
- **Lazy loading** for all plugins and scripts
- **Compiled Lua** modules for Neovim
- **Parallel execution** wherever possible
- **Smart caching** for expensive operations

### 🔧 Modern CLI Toolchain
| Traditional | Replacement | Improvement |
|-------------|-------------|-------------|
| `ls` | `eza` | Icons, git status, tree view |
| `cat` | `bat` | Syntax highlighting, git integration |
| `find` | `fd` | 5-10x faster, intuitive syntax |
| `grep` | `ripgrep` | 10-50x faster, respects .gitignore |
| `cd` | `zoxide` | Frecency-based jumping |
| `diff` | `delta` | Side-by-side, syntax highlighted |

### 📝 Language Support (20+)
Full LSP, formatting, linting, and debugging for:
- **Systems**: C/C++, Rust, Go, Zig
- **Scripting**: Python, Ruby, Perl, Lua, Shell/Bash
- **Web**: TypeScript, JavaScript, HTML, CSS, Vue, React
- **Data**: SQL, JSON, YAML, TOML, XML
- **Docs**: Markdown, LaTeX
- **Mobile**: Swift, Kotlin

### 🧪 Enterprise-Grade Testing
```bash
./test/test           # Standard test suite (< 30s)
./test/test --quick   # Sanity check (< 10s)
./test/test --unit    # Unit tests only (< 5s)
./test/test --full    # Everything including performance tests
```

---

## 📦 What's Included

### Core Components
- **[Neovim](src/neovim/)** - 500+ plugin references organized in 8 modules
- **[Zsh](src/zsh/)** - Zinit-powered with turbo mode for instant startup
- **[Tmux](src/tmux/)** - Minimal config with custom status line
- **[Git](src/git/)** - 50+ aliases, delta integration, GPG signing
- **[Alacritty](src/alacritty/)** - GPU-accelerated terminal
- **[WezTerm](src/wezterm/)** - Alternative terminal with Lua config
- **[Starship](src/zsh/starship.toml)** - Minimal, fast, customizable prompt

### Utility Scripts
- **[`fixy`](src/scripts/fixy)** - Universal formatter supporting 20+ languages
- **[`theme`](src/scripts/theme)** - Instant theme switching
- **[`update`](src/scripts/update)** - Update everything with one command
- **[`scratchpad`](src/scripts/scratchpad)** - Quick temporary file editing
- **[`extract`](src/scripts/extract)** - Extract any archive format

### Development Tools
All installed via [Brewfile](src/Brewfile):
- **Modern CLI**: `bat`, `delta`, `eza`, `fd`, `fzf`, `ripgrep`, `zoxide`
- **Dev Tools**: `gh`, `lazygit`, `jq`, `hyperfine`, `glow`
- **Languages**: `fnm`, `pyenv`, `rustup`, `go`
- **LSPs**: `gopls`, `lua-language-server`, `typescript-language-server`

---

## 🏗️ Architecture

```
~/.dotfiles/
├── src/                    # All source configurations
│   ├── neovim/            # Neovim (500+ plugins, 42 modules)
│   │   ├── init.lua       # Entry point with smart path detection
│   │   ├── config/        # Core, UI, keymaps, autocmds
│   │   └── plugins/       # AI, completion, git, languages, etc.
│   ├── zsh/               # Shell configuration
│   ├── theme-switcher/    # Cross-app theme synchronization
│   ├── scripts/           # Utility scripts (11 tools)
│   ├── setup/             # Platform-specific installers
│   ├── language/          # Language-specific configs
│   └── git/               # Git config with hooks
├── test/                  # 30+ test files
│   ├── unit/             # Configuration validation
│   ├── functional/       # Feature testing
│   ├── integration/      # Multi-component tests
│   └── performance/      # Regression benchmarks
├── config/               # Tool configurations
│   └── fixy.json        # 631-line formatter config
└── .github/workflows/    # 6 CI/CD pipelines
```

### Key Design Principles

1. **Everything is a symlink** - Source files live in `src/`, symlinked to proper locations
2. **Lazy by default** - Nothing loads until needed
3. **Test everything** - Every configuration has tests
4. **Document inline** - Self-documenting code with examples
5. **Fail gracefully** - Works even if dependencies are missing

---

## 🧪 Testing

Our test suite ensures everything works perfectly:

```bash
# Quick sanity check (< 10s)
./test/test --quick

# Run specific test category
./test/test unit/nvim
./test/test functional/themes

# Full test suite with performance benchmarks
./test/test --full

# Test in Docker
docker run -it ghcr.io/illyastarikov/dotfiles:test
```

### Test Coverage
- ✅ All shell scripts pass ShellCheck
- ✅ All Lua files pass Stylua
- ✅ All Python files pass Ruff
- ✅ Neovim starts in < 300ms
- ✅ Themes switch in < 500ms
- ✅ No memory leaks detected

---

## 🎯 Daily Workflow

```bash
# Start your day
theme              # Auto-detect and set theme
update             # Update all tools and plugins

# Navigate efficiently  
z project          # Jump to frecent directory
ff                 # Fuzzy find files
fg "pattern"       # Grep with preview

# Code with AI
# <leader>cc - Open AI chat
# <leader>ca - Get code actions
# :AI fix this     # Direct AI commands

# Git workflow
gs                 # Status with delta
ga .              # Stage changes
gc "message"      # Commit with conventional format
gp                # Push with automatic upstream
gpr               # Create pull request via gh

# Format anything
fixy file.py      # Auto-detect and format
fixy --all *.js   # Format with normalizations
```

---

## 🎨 Keybindings

### Neovim (Leader = `Space`)
| Key | Action | Key | Action |
|-----|--------|-----|--------|
| `<leader>ff` | Find files | `<leader>ca` | Code actions |
| `<leader>fg` | Live grep | `<leader>rn` | Rename symbol |
| `<leader>fb` | Browse buffers | `gd` | Go to definition |
| `<leader>e` | File explorer | `K` | Show documentation |

### Tmux (Prefix = `Ctrl-a`)
| Key | Action | Key | Action |
|-----|--------|-----|--------|
| `<prefix>c` | New window | `<prefix>z` | Zoom pane |
| `<prefix>\|` | Split vertical | `<prefix>s` | Choose session |
| `<prefix>-` | Split horizontal | `<prefix>r` | Reload config |

---

## 🚦 CI/CD

Every push triggers comprehensive checks:

1. **Testing** - Multi-OS (Ubuntu, macOS Intel/ARM)
2. **Linting** - ShellCheck, Stylua, Ruff
3. **Security** - Gitleaks secret scanning
4. **Performance** - Startup time regression tests
5. **Deployment** - GitHub Pages documentation

---

## 📚 Documentation

- **[Setup Guide](src/setup/README.md)** - Detailed installation instructions
- **[Script Reference](src/scripts/README.md)** - All utility scripts explained
- **[Theme System](src/theme-switcher/README.md)** - How theme switching works
- **[Test Guide](test/TEST_GUIDE.md)** - Writing and running tests
- **[CLAUDE.md](CLAUDE.md)** - AI assistant instructions

---

## 🤝 Contributing

Contributions welcome! This repository follows:
- [Conventional Commits](https://www.conventionalcommits.org/)
- [Google Style Guides](styleguide/)
- Comprehensive testing for all changes

```bash
# Setup development environment
git clone https://github.com/IllyaStarikov/.dotfiles.git
cd .dotfiles
./src/setup/setup.sh --dev

# Run tests before committing
./test/test --quick
./src/scripts/fixy --check

# Create feature branch
git checkout -b feature/amazing-feature
```

---

## 📜 License

MIT License - see [LICENSE](LICENSE) for details.

---

## 🙏 Acknowledgments

Standing on the shoulders of giants:

- [Neovim](https://neovim.io) - The future of vim
- [folke](https://github.com/folke) - lazy.nvim and incredible plugins
- [Zinit](https://github.com/zdharma-continuum/zinit) - Fastest Zsh plugin manager
- [TokyoNight](https://github.com/folke/tokyonight.nvim) - Beautiful theme family

---

<div align="center">

**[⬆ Back to Top](#-dotfiles)**

Made with ❤️ and excessive attention to detail

[**Website**](https://dotfiles.starikov.io) • [**Issues**](https://github.com/IllyaStarikov/.dotfiles/issues) • [**Discussions**](https://github.com/IllyaStarikov/.dotfiles/discussions)

</div>