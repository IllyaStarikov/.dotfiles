# Dotfiles


<div align="center">

```
     ██████╗  ██████╗ ████████╗███████╗██╗██╗     ███████╗███████╗
     ██╔══██╗██╔═══██╗╚══██╔══╝██╔════╝██║██║     ██╔════╝██╔════╝
     ██║  ██║██║   ██║   ██║   █████╗  ██║██║     █████╗  ███████╗
     ██║  ██║██║   ██║   ██║   ██╔══╝  ██║██║     ██╔══╝  ╚════██║
     ██████╔╝╚██████╔╝   ██║   ██║     ██║███████╗███████╗███████║
     ╚═════╝  ╚═════╝    ╚═╝   ╚═╝     ╚═╝╚══════╝╚══════╝╚══════╝
```

**A meticulously engineered development environment**

[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Neovim](https://img.shields.io/badge/Neovim-0.9+-57A143.svg?logo=neovim&logoColor=white)](https://neovim.io)
[![Tmux](https://img.shields.io/badge/Tmux-3.3+-1BB91F.svg?logo=tmux&logoColor=white)](https://github.com/tmux/tmux)
[![Shell](https://img.shields.io/badge/Shell-Zsh-4E4E4E.svg?logo=gnu-bash&logoColor=white)](https://www.zsh.org)
[![macOS](https://img.shields.io/badge/macOS-12+-000000.svg?logo=apple&logoColor=white)](https://www.apple.com/macos)
[![Linux](https://img.shields.io/badge/Linux-Compatible-FCC624.svg?logo=linux&logoColor=black)](https://kernel.org)

[**Quick Start**](#-quick-start) • [**Features**](#-features) • [**Documentation**](https://dotfiles.starikov.io) • [**Gallery**](#-gallery)

</div>

---

## 📖 Table of Contents

<details>
<summary><b>Click to expand</b></summary>

- [🎯 Overview](#-overview)
  - [Philosophy](#philosophy)
  - [Performance](#performance)
- [⚡ Quick Start](#-quick-start)
  - [One-Line Install](#one-line-install)
  - [Requirements](#requirements)
- [✨ Features](#-features)
  - [Core Features](#core-features)
  - [Unique Capabilities](#unique-capabilities)
- [📦 What's Included](#-whats-included)
- [🏗️ Architecture](#️-architecture)
  - [Directory Structure](#directory-structure)
  - [Configuration Files](#configuration-files)
- [🛠️ Components](#️-components)
  - [Neovim](#neovim)
  - [Shell](#shell)
  - [Terminal](#terminal)
  - [Development Tools](#development-tools)
  - [Theme System](#theme-system)
- [📚 Documentation](#-documentation)
  - [Installation Guide](#installation-guide)
  - [Configuration](#configuration)
  - [Usage](#usage)
  - [Customization](#customization)
- [🎨 Gallery](#-gallery)
- [⚙️ Advanced](#️-advanced)
  - [Performance Tuning](#performance-tuning)
  - [Troubleshooting](#troubleshooting)
  - [Testing](#testing)
- [🤝 Contributing](#-contributing)
- [📜 License](#-license)
- [🙏 Acknowledgments](#-acknowledgments)

</details>

---

## 🎯 Overview

This repository contains my personal development environment configuration - a carefully crafted collection of dotfiles that transforms a standard Unix system into a powerful, efficient, and beautiful development workstation.

### Philosophy

1. **🚀 Speed is Feature #1** - Every millisecond matters. Configurations are ruthlessly optimized.
2. **⌨️ Keyboard-First** - Mouse usage is minimized. Everything is accessible via keybindings.
3. **🎨 Aesthetics Matter** - A beautiful environment is a productive environment.
4. **🔧 Automation Everything** - If it can be automated, it should be automated.
5. **📝 Document Everything** - Every configuration is documented and discoverable.

### Performance

| Component | Startup Time | Plugins/Extensions | Memory Usage |
|-----------|-------------|-------------------|--------------|
| **Neovim** | ~50ms | 80+ plugins | ~45MB |
| **Zsh** | ~100ms | 20+ plugins | ~15MB |
| **Tmux** | ~20ms | 10+ plugins | ~8MB |
| **Total System** | <200ms | 110+ total | ~70MB |

---

## ⚡ Quick Start

### One-Line Install

```bash
curl -fsSL https://raw.githubusercontent.com/IllyaStarikov/.dotfiles/main/install | bash
```

Or clone and install:

```bash
git clone https://github.com/IllyaStarikov/.dotfiles.git ~/.dotfiles && cd ~/.dotfiles && ./install
```

### Requirements

- **OS**: macOS 12+ / Ubuntu 20.04+ / Arch Linux
- **Shell**: Zsh 5.8+
- **Git**: 2.30+
- **Memory**: 4GB RAM minimum
- **Disk**: 500MB free space

---

## ✨ Features

### Core Features

| Feature | Description |
|---------|------------|
| **🤖 AI Integration** | Built-in Claude, GPT-4, and GitHub Copilot support |
| **🎨 Smart Themes** | Automatic theme switching based on system appearance |
| **🔍 Instant Search** | Telescope + ripgrep for sub-millisecond file search |
| **📝 Language Support** | Pre-configured LSP for 15+ languages |
| **📦 Package Management** | Automated dependency installation and updates |
| **🧪 Test Suite** | Comprehensive testing for all configurations |
| **📊 Performance Monitoring** | Built-in profiling and optimization tools |
| **🔒 Security First** | GPG signing, SSH agent, secure credential storage |

### Unique Capabilities

- **Dynamic Configuration**: Configurations adapt based on system capabilities
- **Work Profiles**: Separate configurations for personal/work environments
- **Session Persistence**: Automatic session save/restore across restarts
- **Smart Aliases**: Context-aware commands that adapt to your project
- **Snippet Engine**: 1000+ snippets with smart expansion
- **Git Workflows**: Advanced git integration with custom workflows

---

## 📦 What's Included

<table>
<tr>
<td width="50%">

### 🎯 Editor & IDE
- **Neovim** - Hyperextensible Vim-based editor
- **VS Code** settings (backup)
- **EditorConfig** - Consistent coding styles
- **Language Servers** - 15+ configured LSPs

### 🐚 Shell & Terminal
- **Zsh** - Advanced shell with Zinit
- **Starship** - Minimal, blazing-fast prompt
- **Alacritty** - GPU-accelerated terminal
- **Tmux** - Terminal multiplexer
- **Kitty** (alternative config)

### 🔧 Development Tools
- **Git** - Advanced configuration
- **Docker** - Container management
- **Kubernetes** - k8s tools and kubectl
- **AWS CLI** - Cloud management
- **GitHub CLI** - gh command tools

</td>
<td width="50%">

### 🎨 Themes & UI
- **TokyoNight** - Multiple variants
- **Dracula** - Dark theme
- **Solarized** - Light/Dark
- **Custom themes** - Personal variants

### 📚 Languages & Frameworks
- **Python** - pyenv, poetry, black
- **JavaScript** - nvm, prettier, eslint
- **Go** - go tools, gopls
- **Rust** - rustup, cargo, clippy
- **Ruby** - rbenv, rubocop

### 🛠️ Utilities
- **ripgrep** - Blazing fast search
- **fd** - Modern find alternative
- **eza** - Modern ls replacement
- **bat** - Syntax-highlighted cat
- **delta** - Beautiful git diffs
- **fzf** - Fuzzy finder

</td>
</tr>
</table>

---

## 🏗️ Architecture

### Directory Structure

```
~/.dotfiles/
│
├── src/                        # 📁 Source configurations
│   ├── neovim/                # 🌙 Neovim configuration
│   │   ├── init.lua           # Entry point
│   │   ├── config/            # Modular configs
│   │   │   ├── autocmds.lua
│   │   │   ├── keymaps.lua
│   │   │   ├── options.lua
│   │   │   ├── plugins.lua
│   │   │   └── lsp/
│   │   └── snippets/          # Custom snippets
│   │
│   ├── zsh/                   # 🐚 Shell configuration
│   │   ├── zshrc              # Main config
│   │   ├── zshenv             # Environment
│   │   ├── aliases.zsh        # Aliases
│   │   ├── functions.zsh      # Functions
│   │   └── starship.toml      # Prompt
│   │
│   ├── git/                   # 🔧 Git configuration
│   │   ├── gitconfig
│   │   ├── gitignore
│   │   └── hooks/
│   │
│   ├── alacritty/             # 🖥️ Terminal configs
│   ├── tmux.conf              # 💻 Tmux config
│   ├── scripts/               # 🛠️ Utility scripts
│   ├── setup/                 # 📦 Install scripts
│   └── theme-switcher/        # 🎨 Theme system
│
├── doc/                       # 📚 Documentation
├── test/                      # 🧪 Test suite
└── template/                  # 🌐 Web generator
```

### Configuration Files

| File | Purpose | Lines | Complexity |
|------|---------|-------|------------|
| `neovim/init.lua` | Neovim entry | ~100 | ⭐⭐ |
| `neovim/config/plugins.lua` | Plugin specs | ~800 | ⭐⭐⭐⭐ |
| `zsh/zshrc` | Shell config | ~300 | ⭐⭐⭐ |
| `tmux.conf` | Tmux config | ~200 | ⭐⭐ |
| `alacritty/alacritty.toml` | Terminal | ~400 | ⭐⭐ |
| `git/gitconfig` | Git config | ~150 | ⭐⭐ |

---

## 🛠️ Components

### Neovim

<details>
<summary><b>Expand for details</b></summary>

#### Features
- **Plugin Manager**: lazy.nvim for fast, lazy-loaded plugins
- **Completion**: blink.cmp - the fastest completion engine
- **File Explorer**: neo-tree.nvim with git integration
- **Fuzzy Finder**: telescope.nvim with 10+ extensions
- **Git Integration**: gitsigns, fugitive, git-conflict
- **AI Assistant**: codecompanion.nvim with multiple providers
- **Debugging**: nvim-dap with language-specific adapters

#### Key Plugins (80+)
- `lazy.nvim` - Plugin manager
- `telescope.nvim` - Fuzzy finder
- `nvim-treesitter` - Syntax highlighting
- `nvim-lspconfig` - LSP configuration
- `blink.cmp` - Completion engine
- `gitsigns.nvim` - Git integration
- `neo-tree.nvim` - File explorer
- `which-key.nvim` - Keybinding hints
- And 70+ more...

#### Performance Optimizations
- Lazy loading for all plugins
- Compiled Lua modules
- Minimal startup sequence
- Async everything

</details>

### Shell

<details>
<summary><b>Expand for details</b></summary>

#### Zsh + Zinit
- **Plugin Manager**: Zinit with turbo mode
- **Prompt**: Starship with custom segments
- **Completions**: 500+ command completions
- **Syntax Highlighting**: Real-time highlighting
- **Auto-suggestions**: Fish-like suggestions
- **Directory jumping**: z, autojump, fasd

#### Custom Functions
- `project` - Smart project navigation
- `extract` - Universal archive extractor
- `backup` - Intelligent backup creation
- `update` - System-wide update command
- `clean` - System cleanup utility

#### Aliases (200+)
- Git shortcuts (50+)
- Docker commands (20+)
- System utilities (30+)
- Navigation helpers (20+)
- Development tools (80+)

</details>

### Terminal

<details>
<summary><b>Expand for details</b></summary>

#### Alacritty
- GPU-accelerated rendering
- Custom keybindings
- Automatic theme switching
- Vi mode
- URL detection and launching

#### Tmux
- **Prefix**: `Ctrl-a`
- **Plugins**: TPM, resurrect, continuum
- **Features**: Session persistence, pane synchronization
- **Custom**: Status bar with system stats

</details>

### Development Tools

<details>
<summary><b>Expand for details</b></summary>

#### Git Configuration
- 50+ aliases for common operations
- GPG/SSH signing
- Delta for beautiful diffs
- Custom hooks and workflows
- GitHub CLI integration

#### Language Support
| Language | LSP | Formatter | Linter | Debugger |
|----------|-----|-----------|--------|----------|
| Python | Pyright | Black | Ruff | debugpy |
| JavaScript | tsserver | Prettier | ESLint | node-debug2 |
| Go | gopls | gofmt | golangci | dlv |
| Rust | rust-analyzer | rustfmt | clippy | lldb |
| C/C++ | clangd | clang-format | clang-tidy | lldb |

</details>

### Theme System

<details>
<summary><b>Expand for details</b></summary>

Intelligent theme switching that synchronizes across:
- Neovim colorscheme
- Alacritty terminal
- Tmux status bar
- Bat syntax highlighter
- Delta diff viewer
- Starship prompt

#### Available Themes
- **TokyoNight** (Night, Storm, Moon, Day)
- **Dracula** (Dark)
- **Solarized** (Light, Dark)
- **Gruvbox** (Light, Dark)
- **Custom** variants

#### Usage
```bash
theme           # Auto-detect system
theme dark      # Force dark mode
theme light     # Force light mode
theme night     # Specific variant
```

</details>

---

## 📚 Documentation

### Installation Guide

<details>
<summary><b>macOS Installation</b></summary>

```bash
# Prerequisites
xcode-select --install

# Quick install
curl -fsSL https://raw.githubusercontent.com/IllyaStarikov/.dotfiles/main/install | bash

# Manual install
git clone https://github.com/IllyaStarikov/.dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./src/setup/mac.sh
```

</details>

<details>
<summary><b>Linux Installation</b></summary>

```bash
# Ubuntu/Debian
sudo apt update && sudo apt install -y git curl
git clone https://github.com/IllyaStarikov/.dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./src/setup/linux.sh

# Arch Linux
sudo pacman -Sy git curl
git clone https://github.com/IllyaStarikov/.dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./src/setup/arch.sh
```

</details>

<details>
<summary><b>Docker Installation</b></summary>

```bash
# Run in Docker
docker run -it ghcr.io/illyastarikov/dotfiles:latest

# Build locally
docker build -t dotfiles https://github.com/IllyaStarikov/.dotfiles.git
docker run -it dotfiles
```

</details>

### Configuration

All configurations support local overrides:

```bash
~/.zshrc.local        # Shell overrides
~/.gitconfig.local    # Git overrides
~/.secrets            # Secret environment variables
```

### Usage

<details>
<summary><b>Daily Workflow</b></summary>

```bash
# Start work session
mux start project

# Navigate projects
z myproject
project frontend

# Git workflow
gs                    # status
ga .                  # add all
gc "feat: add feature" # commit
gp                    # push
gpr                   # create PR

# File operations
ff                    # find files
fg pattern            # grep files
ft                    # find text

# System
update                # update everything
clean                 # cleanup
backup ~/important    # backup directory
```

</details>

<details>
<summary><b>Keybindings</b></summary>

#### Neovim (Leader = Space)
| Key | Action |
|-----|--------|
| `<leader>ff` | Find files |
| `<leader>fg` | Live grep |
| `<leader>fb` | Browse buffers |
| `<leader>ca` | Code actions |
| `<leader>rn` | Rename |
| `gd` | Go to definition |
| `gr` | Find references |
| `K` | Show hover |

#### Tmux (Prefix = Ctrl-a)
| Key | Action |
|-----|--------|
| `<prefix>c` | New window |
| `<prefix>\|` | Split vertical |
| `<prefix>-` | Split horizontal |
| `<prefix>h/j/k/l` | Navigate panes |
| `<prefix>z` | Zoom pane |

</details>

### Customization

<details>
<summary><b>Adding Plugins</b></summary>

#### Neovim Plugin
```lua
-- In ~/.config/nvim/lua/config/plugins.lua
{
  "username/plugin-name",
  event = "VeryLazy",  -- Lazy load
  config = function()
    require("plugin-name").setup({
      -- options
    })
  end,
}
```

#### Zsh Plugin
```bash
# In ~/.zshrc.local
zinit ice wait lucid
zinit load username/plugin-name
```

</details>

---

## 🎨 Gallery

<details>
<summary><b>Click to view screenshots</b></summary>

### Neovim
![Neovim](https://via.placeholder.com/800x450/1a1b26/c0caf5?text=Neovim+IDE)

### Terminal
![Terminal](https://via.placeholder.com/800x450/24283b/a9b1d6?text=Alacritty+%2B+Tmux)

### Git
![Git](https://via.placeholder.com/800x450/1f2335/bb9af7?text=Git+Integration)

</details>

---

## ⚙️ Advanced

### Performance Tuning

<details>
<summary><b>Profiling Tools</b></summary>

```bash
# Profile Neovim startup
nvim --startuptime /tmp/nvim-startup.log

# Profile Zsh startup
zsh -xvs 2>&1 | ts -i "%.s" > /tmp/zsh-profile.log

# Check plugin load times
zinit times         # Zsh plugins
:Lazy profile       # Neovim plugins
```

</details>

### Troubleshooting

<details>
<summary><b>Common Issues</b></summary>

#### Neovim not starting
```bash
# Reset Neovim
rm -rf ~/.local/share/nvim
rm -rf ~/.local/state/nvim
nvim --headless "+Lazy! sync" +qa
```

#### Slow shell startup
```bash
# Disable plugins temporarily
ZINIT_DISABLED=1 zsh

# Check specific plugin
zinit unload plugin-name
```

#### Theme not switching
```bash
# Reset theme system
rm -rf ~/.config/theme-switcher
theme --reset
```

</details>

### Testing

```bash
# Run all tests
./test/test

# Specific tests
./test/test --unit
./test/test --integration
./test/test neovim
```

---

## 🤝 Contributing

Contributions are welcome! Please read [CONTRIBUTING.md](CONTRIBUTING.md) first.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing`)
5. Open a Pull Request

---

## 📜 License

MIT License - see [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

This configuration stands on the shoulders of giants:

- **[Neovim](https://neovim.io)** - The hyperextensible Vim-based text editor
- **[folke](https://github.com/folke)** - For lazy.nvim and amazing plugins
- **[tmux](https://github.com/tmux/tmux)** - Terminal multiplexer
- **[Zsh](https://www.zsh.org)** - The Z shell
- **[Alacritty](https://alacritty.org)** - The fastest terminal emulator

Special thanks to the entire open source community for making these tools possible.

---

<div align="center">

**[⬆ Back to Top](#dotfiles)**

Made with ❤️ and ☕ in San Francisco

[**Website**](https://dotfiles.starikov.io) • [**Documentation**](https://dotfiles.starikov.io/docs) • [**Issues**](https://github.com/IllyaStarikov/.dotfiles/issues)

</div>