# Dotfiles Usage Documentation

> **Complete reference guides for a modern development environment** - Everything you need to master this configuration.

## Quick Command Reference

<details>
<summary><strong>Click to expand the essential commands cheatsheet</strong></summary>

```bash
# FILE NAVIGATION        GIT WORKFLOW           SYSTEM
v file      # Edit      gs        # Status     update   # Update all
z project   # Jump dir  gaa       # Add all    theme    # Switch theme
fzf         # Find file gcmsg     # Commit     reload   # Reload shell
ll          # List all  gp        # Push       c        # Clear
cd -        # Go back   gl        # Pull       q        # Exit

# TMUX                   NEOVIM                 SEARCH
tmux a      # Attach    :w        # Save       rg text  # Grep files
C-a c       # New win   <leader>ff # Find      fd name  # Find files
C-a |       # V-split   <leader>gg # LazyGit   ag text  # Alt grep
C-a d       # Detach    <leader>cc # AI Chat   /pattern # In vim
C-a [       # Copy mode gd        # Go to def  *        # Word search
```
</details>

## Complete Guides

Each guide is optimized for daily reference with quick-access commands at the top.

### [🚀 Daily Workflow](workflow.md)
**Your Day-to-Day Development Guide**
- **Morning to Evening**: Complete workflow patterns
- Project navigation and file operations
- AI-assisted development workflows
- Git workflows from feature to deployment
- Terminal multiplexing strategies
- Speed shortcuts and pro tips
- Emergency recovery commands

### [⚡ Neovim](vim.md) 
**The Hyperextensible Editor**
- **Quick Start**: Daily command cheatsheet
- AI-powered coding with CodeCompanion
- LSP with intelligent code completion
- DAP debugging support
- LaTeX environment with VimTeX
- Automatic theme switching
- Menu system for discoverable commands

<details>
<summary>Popular Neovim Commands</summary>

```vim
<leader>ff  " Find files      <leader>cc  " AI chat
<leader>fg  " Grep text       <leader>la  " Code actions
<leader>gg  " Open LazyGit    gd         " Go to definition
<leader>ca  " AI actions      K          " Show docs
```
</details>

### [🐚 Zsh + Oh My Zsh](zsh.md)
**The Power User's Shell**
- **Quick Start**: Essential aliases grid
- 200+ productivity aliases
- Modern CLI tool replacements
- Smart directory navigation
- Vi-mode with enhanced bindings
- Fuzzy completion everywhere
- Architecture-specific commands (Apple Silicon)

<details>
<summary>Popular Shell Aliases</summary>

```bash
gs    # git status       ll    # eza long list
gaa   # git add all      la    # list all
gcmsg # git commit msg   lt    # tree view
gp    # git push         z     # jump to dir
gl    # git pull         ..    # go up
```
</details>

### [🖥️ Tmux](tmux.md)
**Terminal Multiplexer Supreme**
- **Quick Start**: Session workflow examples
- Persistent sessions across reboots
- Intuitive window/pane management
- Vi-style copy mode with clipboard
- Seamless navigation with vim
- Powerful plugin ecosystem
- Automatic theme switching

<details>
<summary>Essential Tmux Keys</summary>

```bash
C-a c     # New window      C-a |    # Vertical split
C-a n/p   # Next/prev       C-a -    # Horizontal split
C-a d     # Detach          C-a z    # Zoom pane
C-a s     # Sessions        C-a [    # Copy mode
```
</details>

### [🎨 Alacritty](alacritty.md)
**GPU-Accelerated Terminal**
- **Quick Start**: Keyboard shortcuts
- Automatic theme integration
- Blazing fast GPU rendering
- Vi mode support
- Platform optimizations
- Pixel-perfect FiraCode Nerd Font
- Mouse and keyboard driven

### [🔀 Git](git.md)
**Version Control Mastery**
- **Quick Start**: Emergency commands
- 50+ time-saving aliases
- Common workflow patterns
- Conflict resolution guide
- Advanced operations
- Recovery procedures
- Commit type shortcuts
- GitHub CLI integration

<details>
<summary>Git Power Aliases</summary>

```bash
grhh   # reset --hard HEAD    grbi   # rebase interactive
gsta   # stash                gstp   # stash pop
gco    # checkout             gcb    # checkout -b
gfa    # fetch --all          gpsup  # push set upstream
```
</details>

### [🛠️ Tools](tools.md)
**Modern CLI Arsenal**
- **Quick Start**: Tool comparison table
- Homebrew management
- Modern replacements guide
- Network utilities
- System monitoring
- Theme switcher details
- delta, ranger, pyenv guides
- Performance benchmarks

## Power User Workflows

### Daily Startup Routine
```bash
# 1. Open terminal (Alacritty starts instantly)
# 2. Attach to yesterday's session
tmux a                    # Resume exactly where you left off

# 3. Update your tools
update                    # Updates everything automatically

# 4. Check project status
z myproject && gs         # Jump to project and git status
```

### Feature Development Flow
```bash
# 1. Create feature branch
gco -b feature/awesome    # New branch

# 2. Open editor with AI assist
v .                       # Open Neovim
<leader>cc                # Start AI chat for guidance

# 3. Make changes with confidence
<leader>ca                # AI suggests improvements
<leader>lf                # Format code
<leader>lt                # Run tests

# 4. Commit and push
gaa && gcmsg "feat: add awesome feature" && gp
```

### Code Exploration
```bash
# Find any file instantly
fd -e py | fzf            # Find Python files
rg "TODO" --type py       # Find TODOs in Python

# In Neovim
<leader>fg                # Grep across project
<leader>fs                # Search symbols
gd                        # Jump to definition
gr                        # Find references
```

### Theme Switching
```bash
# Automatic (detects system preference)
theme

# Manual override
dark                      # Force dark mode
light                     # Force light mode

# Affects: Alacritty, Neovim, tmux, shell prompt
```

## Architecture Overview

### Integration Points
```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│  Alacritty  │────▶│     Zsh     │────▶│    Tmux     │
│   (GPU)     │     │  (200+ cmd) │     │  (Sessions) │
└─────────────┘     └─────────────┘     └─────────────┘
        │                    │                    │
        └────────────────────┴────────────────────┘
                             │
                    ┌────────┴────────┐
                    │     Neovim      │
                    │  (AI + LSP)     │
                    │   + Plugins     │
                    └─────────────────┘
                             │
                    ┌────────┴────────┐
                    │  Modern Tools   │
                    │ eza, bat, rg... │
                    └─────────────────┘
```

### Performance Optimizations
- **Lazy Loading**: Shell plugins load on-demand
- **GPU Rendering**: Alacritty uses GPU for 60+ FPS
- **Smart Caching**: Tools cache results intelligently
- **Async Operations**: Non-blocking UI everywhere

## Customization Guide

### Quick Config Access
```bash
zshconfig    # Edit ~/.zshrc
vimconfig    # Edit ~/.config/nvim/init.lua
tmuxconfig   # Edit ~/.tmux.conf
gitconfig    # Edit ~/.gitconfig
```

### Key Files

| Config | Location | Purpose |
|--------|----------|---------|
| Shell | `~/.zshrc` | Aliases, functions, plugins |
| Editor | `~/.config/nvim/` | Complete Neovim setup |
| Terminal | `~/.config/alacritty/` | Terminal appearance |
| Multiplexer | `~/.tmux.conf` | Tmux behavior |
| Version Control | `~/.gitconfig` | Git settings |

## Troubleshooting

### Quick Fixes

| Problem | Solution |
|---------|----------|
| Icons broken | `brew install --cask font-fira-code-nerd-font` |
| Command not found | `which command` or `brew install tool` |
| Theme not updating | Run `theme` manually |
| Slow startup | Check `zsh -xvf` for bottlenecks |
| Neovim issues | `:checkhealth` for diagnostics |

### Getting Help
- **In Neovim**: `:help keyword` or `K` on any function
- **In Shell**: `man command` or `tldr command`
- **In Tmux**: `C-a ?` for key bindings
- **Anywhere**: Most tools support `--help`

## Learning Path

### Week 1: Foundation
1. Master basic vim motions (`h`, `j`, `k`, `l`)
2. Learn tmux session management
3. Use core git aliases (`gs`, `gaa`, `gcmsg`, `gp`)

### Week 2: Efficiency
1. Learn vim text objects (`ciw`, `da{`, `yi"`)
2. Use fuzzy finding (`fzf`, `<leader>ff`)
3. Master directory jumping (`z`)

### Week 3: Advanced
1. Explore AI assistance in Neovim
2. Create tmuxinator templates
3. Customize your workflow

### Week 4: Mastery
1. Write custom functions
2. Create your own aliases
3. Contribute improvements back!

---

## Quick Setup

### Prerequisites
- macOS (Apple Silicon or Intel)
- Internet connection
- Terminal access

### One-Line Install
```bash
git clone https://github.com/IllyaStarikov/.dotfiles.git ~/.dotfiles && cd ~/.dotfiles && ./src/setup/mac.sh
```

## Support & Community

- **Issues**: [GitHub Issues](https://github.com/IllyaStarikov/.dotfiles/issues)
- **Discussions**: [GitHub Discussions](https://github.com/IllyaStarikov/.dotfiles/discussions)
- **Website**: [dotfiles.starikov.io](https://dotfiles.starikov.io)

---

<p align="center">
  <strong>Welcome to a faster way of working!</strong><br>
  <em>Remember: The best tool is the one you master.</em>
</p>

<p align="center">
  <a href="https://github.com/IllyaStarikov/.dotfiles">← Back to Repository</a> •
  <a href="https://dotfiles.starikov.io">Visit Website →</a>
</p>