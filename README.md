# [dotfiles.starikov.io](https://dotfiles.starikov.io)

<script src="https://dotfiles.starikov.io/template/analytics.js"></script>

> **"The IDE that fits in your head"** - A modern development environment that emphasizes speed, efficiency, and aesthetic minimalism.

<p align="center">
  <img src="template/dotfiles.png" alt="Terminal Screenshot" />
</p>

<p align="center">
  <a href="https://github.com/IllyaStarikov/.dotfiles">
    <img src="https://img.shields.io/github/stars/IllyaStarikov/.dotfiles?style=social" alt="GitHub stars">
  </a>
  <a href="#quick-start">
    <img src="https://img.shields.io/badge/setup-automated-brightgreen" alt="Automated setup">
  </a>
  <a href="https://neovim.io">
    <img src="https://img.shields.io/badge/vim-neovim-green?logo=neovim" alt="Neovim">
  </a>
  <a href="#features">
    <img src="https://img.shields.io/badge/theme-auto--switching-blue" alt="Auto theme">
  </a>
</p>

## Features

### Lightning Fast
- Modern CLI tools that are 10-100x faster than traditional Unix utilities
- Lazy-loaded shell plugins for instant terminal startup
- GPU-accelerated terminal rendering with Alacritty
- Optimized configurations for minimal latency

### AI-Powered Development
- Integrated AI coding assistant (CodeCompanion.nvim)
- Support for Claude, GPT, and GitHub Copilot
- Context-aware code suggestions and explanations
- Automated code reviews and refactoring

### Aesthetic & Functional
- Automatic dark/light theme switching based on system preferences
- Consistent color schemes across all tools
- Beautiful prompt with git integration
- Nerd Font icons throughout the interface

### Developer Productivity
- 200+ shell aliases for common tasks
- Smart directory jumping with `z`
- Fuzzy finding everywhere (files, commands, git branches)
- Persistent tmux sessions that survive reboots
- Integrated debugging with DAP
- LaTeX support with VimTeX
- Menu system for discoverable commands

## The Stack

| Category | Tool | Description |
|----------|------|-------------|
| **Shell** | [Zsh](https://www.zsh.org/) + [Oh My Zsh](https://ohmyz.sh/) | Enhanced shell with 200+ aliases |
| **Terminal** | [Alacritty](https://alacritty.org/) | GPU-accelerated terminal |
| **Editor** | [Neovim](https://neovim.io/) | Hyperextensible Vim-based editor |
| **Multiplexer** | [tmux](https://github.com/tmux/tmux) + [Tmuxinator](https://github.com/tmuxinator/tmuxinator) | Terminal session management |
| **Font** | [FiraCode Nerd Font](https://www.nerdfonts.com/) | Ligatures + icons |
| **Package Manager** | [Homebrew](https://brew.sh/) | macOS package management |
| **Version Control** | [Git](https://git-scm.com/) + [GitHub CLI](https://cli.github.com/) | Enhanced with 50+ aliases |
| **Python** | [pyenv](https://github.com/pyenv/pyenv) | Python version management |
| **File Manager** | [ranger](https://github.com/ranger/ranger) + [Oil.nvim](https://github.com/stevearc/oil.nvim) | Terminal file navigation |

### Modern CLI Replacements

| Traditional | Modern | Improvement |
|-------------|--------|-------------|
| `ls` | [eza](https://github.com/eza-community/eza) | Colors, icons, git status |
| `cat` | [bat](https://github.com/sharkdp/bat) | Syntax highlighting, git integration |
| `find` | [fd](https://github.com/sharkdp/fd) | 5x faster, intuitive syntax |
| `grep` | [ripgrep](https://github.com/BurntSushi/ripgrep) | 10x faster, respects .gitignore |
| `top` | [btop](https://github.com/aristocratos/btop) | Beautiful resource monitor |
| `diff` | [delta](https://github.com/dandavison/delta) | Syntax-highlighted diffs |

## Quick Start

### One-Line Install

```bash
git clone https://github.com/IllyaStarikov/.dotfiles.git ~/.dotfiles && cd ~/.dotfiles && ./src/setup/mac.sh
```

This will:
1. Install Homebrew and essential packages
2. Set up Oh My Zsh with plugins
3. Create all necessary symlinks
4. Configure Neovim with plugins
5. Set up tmux with TPM
6. Install Nerd Fonts

### Manual Setup

```bash
# Clone the repository
git clone https://github.com/IllyaStarikov/.dotfiles.git ~/.dotfiles
cd ~/.dotfiles

# Run setup scripts
./src/setup/mac.sh      # Install dependencies
./src/setup/aliases.sh  # Create symlinks

# Install Neovim plugins (run inside Neovim)
:Lazy sync
```

## Documentation

### [**📚 Complete Usage Guide**](docs/usage/)
Comprehensive documentation for all configurations with daily workflow examples.

### Quick Links
- [**⚡ Neovim Guide**](docs/usage/vim.md) - IDE features, keybindings, AI integration
- [**🐚 Zsh Guide**](docs/usage/zsh.md) - Shell aliases, functions, productivity tips
- [**🖥️ Tmux Guide**](docs/usage/tmux.md) - Session management, keybindings
- [**🔀 Git Guide**](docs/usage/git.md) - Aliases, workflows, emergency commands
- [**🛠️ Tools Guide**](docs/usage/tools.md) - Modern CLI tools reference
- [**🎨 Alacritty Guide**](docs/usage/alacritty.md) - Terminal configuration and shortcuts

## Key Features in Action

### AI-Assisted Coding
```vim
<leader>cc  " Open AI chat
<leader>ca  " AI actions menu
<leader>cr  " Code review (visual mode)
<leader>ce  " Explain code (visual mode)
<leader>cf  " Fix bugs (visual mode)
<leader>co  " Optimize code (visual mode)
```

### Lightning-Fast File Navigation
```bash
z project           # Jump to any project
<leader>ff          # Fuzzy find files in Neovim
fd -e py | fzf      # Find Python files interactively
```

### Git Workflow
```bash
gs                  # Status
gaa                 # Add all
gcmsg "feat: ..."   # Commit with message
gp                  # Push
```

### Persistent Development Sessions
```bash
tmuxinator start myproject  # Launch predefined layout
# ... work all day ...
# Close terminal, reboot, whatever
tmuxinator start myproject  # Back exactly where you left off
```

### Theme Switching
```bash
theme               # Auto-detect system preference
dark                # Force dark mode
light               # Force light mode
# Automatically updates: Alacritty, Neovim, tmux, shell prompt
```

## Screenshots

### Neovim with AI Assistant
![Neovim Setup](template/dotfiles.png)

### Auto Theme Switching
The entire environment switches between light and dark themes automatically based on your system preferences.

## Configuration Files

View the actual configuration files with syntax highlighting:

- [`alacritty.toml`](https://dotfiles.starikov.io/template/alacritty.html) - Terminal configuration
- [`init.lua`](https://dotfiles.starikov.io/template/nvim.html) - Neovim configuration
- [`tmux.conf`](https://dotfiles.starikov.io/template/tmux.html) - Tmux configuration
- [`zshrc`](https://dotfiles.starikov.io/template/zshrc.html) - Shell configuration
- [`gitconfig`](https://dotfiles.starikov.io/template/gitconfig.html) - Git configuration

## Philosophy

1. **⚡ Speed First** - Every millisecond counts
2. **⌨️ Keyboard Driven** - Mouse is optional
3. **🎯 Consistency** - Same keybindings everywhere
4. **🚀 Modern Tools** - Use the best available
5. **🤖 Automation** - Automate repetitive tasks
6. **🧠 Discoverable** - Menus and documentation for everything

## Contributing

Found a bug or have a suggestion? Feel free to:
- Open an [issue](https://github.com/IllyaStarikov/.dotfiles/issues)
- Submit a [pull request](https://github.com/IllyaStarikov/.dotfiles/pulls)
- Star the repository if you find it useful!

## License

MIT License - feel free to use and modify as you like!

---

<p align="center">
  <strong>Happy Coding!</strong><br>
  Made with ❤️ and probably too much ☕
</p>