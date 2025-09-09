# 🐚 Zsh Configuration

Modern, fast, and feature-rich Zsh configuration powered by Zinit. Optimized for development workflows with smart completions, syntax highlighting, and a comprehensive alias system.

## ✨ Features

### ⚡ Performance First
- **Zinit plugin manager**: Modern, fast plugin loading with turbo mode
- **Minimal startup time**: < 200ms shell initialization
- **Smart loading**: Plugins load only when needed
- **Optimized history**: 10,000 commands with deduplication

### 🎯 Developer Experience  
- **Intelligent completions**: Context-aware command completion
- **Syntax highlighting**: Real-time command validation
- **Smart suggestions**: History-based autosuggestions
- **Vi mode**: Efficient modal editing
- **Directory navigation**: Enhanced cd with z-jump

### 🎨 Visual Enhancement
- **Starship prompt**: Consistent, informative, and fast
- **Git integration**: Repository status in prompt
- **Theme awareness**: Syncs with system appearance
- **Color scheme**: Consistent with terminal themes

## 📁 File Structure

```
src/zsh/
├── zshrc              # Main configuration file
├── zshenv             # Environment variables
├── aliases.zsh        # Comprehensive alias definitions  
├── starship.toml      # Starship prompt configuration
└── README.md          # This documentation
```

## 🔧 Core Configuration Files

### zshrc - Main Configuration

The heart of the Zsh setup with modern plugin management.

**Key Features:**
- **Zinit integration**: Auto-installing plugin manager
- **Essential options**: History, completion, navigation settings
- **Performance optimization**: Turbo mode for plugins
- **Environment setup**: Path management, tool integration
- **Key bindings**: Vi mode with smart navigation

**Core Options:**
```zsh
setopt AUTO_CD              # cd by typing directory name
setopt INTERACTIVE_COMMENTS # Allow comments in interactive mode
setopt HIST_IGNORE_DUPS     # Don't record duplicate commands
setopt SHARE_HISTORY        # Share history between sessions
setopt CORRECT              # Command correction
setopt GLOB_DOTS            # Include dotfiles in globbing
```

### zshenv - Environment Variables

Global environment setup loaded for all shell types.

**Configuration:**
- **Path management**: Dotfiles, homebrew, development tools
- **Tool integration**: Python, Node.js, Rust toolchains
- **XDG compliance**: Proper config directory structure
- **Performance variables**: Optimizations for common tools

### aliases.zsh - Alias Definitions

Comprehensive alias system with 200+ shortcuts for common tasks.

**Categories:**
- **Editor shortcuts**: nvim, VS Code integration
- **File management**: Enhanced ls with eza, tree navigation
- **Git operations**: Streamlined git workflows  
- **System utilities**: Process management, network tools
- **Development tools**: Language-specific shortcuts
- **Navigation**: Quick directory jumping

### starship.toml - Prompt Configuration

Modern cross-shell prompt with rich information display.

**Features:**
- **Git status**: Branch, changes, remote tracking
- **Language versions**: Python, Node.js, Rust, Go
- **Directory info**: Current path with home abbreviation
- **Execution time**: Command duration for slow operations
- **Exit codes**: Visual indication of command success/failure

## 🚀 Plugin Ecosystem

### Essential Plugins (Zinit)

**Syntax Highlighting:**
```zsh
# Fast syntax highlighting with turbo mode
zinit wait lucid for \
    atinit"ZINIT[COMPINIT_OPTS]=-C; zicompinit; zicdreplay" \
    zdharma-continuum/fast-syntax-highlighting
```

**Autosuggestions:**
```zsh
# History-based command suggestions
zinit wait lucid atload"!_zsh_autosuggest_start" for \
    zsh-users/zsh-autosuggestions
```

**Smart Navigation:**
```zsh
# Enhanced directory jumping
zinit ice wait"0" lucid
zinit light agkozak/zsh-z
```

**Completions:**
```zsh
# Additional completion definitions
zinit ice wait"0" lucid blockf
zinit light zsh-users/zsh-completions
```

**Git Integration:**
```zsh
# Git aliases and functions
zinit snippet OMZ::lib/git.zsh
zinit wait lucid for \
    OMZ::plugins/git/git.plugin.zsh
```

## 🎯 Alias Categories

### File Management (eza-powered)

Modern file listing with icons, git status, and smart grouping:

```bash
# Basic listing
l          # Long listing with all details
ls         # Simple listing with directories first
lt         # Tree view (2 levels)
tree       # Full tree view

# Tree navigation
l1         # Tree view (1 level)
l2         # Tree view (2 levels)  
l3         # Tree view (3 levels)

# Icon variants
lsi        # Simple listing with icons
lli        # Long listing with icons
lai        # All files with icons
```

### Git Workflow

Streamlined git operations:

```bash
# Status and info
gs         # git status
gl         # git log (pretty)
gd         # git diff
gb         # git branch

# Common operations  
ga         # git add
gc         # git commit
gp         # git push
gpl        # git pull

# Advanced workflows
gco        # git checkout
gcm        # git checkout main
gf         # git fetch
gr         # git rebase
```

### Development Tools

Language and tool shortcuts:

```bash
# Editors
vi         # nvim
edit       # nvim
code       # VS Code (platform-aware)

# Python
py         # python3
pip        # pip3
venv       # python -m venv

# Node.js
npm        # npm with progress
yarn       # yarn package manager
node       # node.js

# Rust
cargo      # Rust package manager
rustc      # Rust compiler
```

### System Utilities

Enhanced system commands:

```bash
# Process management
ps         # Enhanced process list
top        # System monitor
kill       # Safe process termination

# Network
ping       # Network connectivity test
curl       # HTTP client
wget       # File downloader

# File operations
cp         # Safe copy with progress
mv         # Safe move with prompts
rm         # Safe removal (trash integration)
```

### Quick Navigation

Efficient directory and file access:

```bash
# Directory shortcuts
..         # cd ..
...        # cd ../..
....       # cd ../../..

# Quick access
h          # cd ~
d          # cd ~/Downloads
doc        # cd ~/Documents
desk       # cd ~/Desktop

# Development directories
dot        # cd ~/.dotfiles
config     # cd ~/.config
```

## 🎨 Starship Prompt

### Configuration Highlights

**Git Integration:**
- Branch name with clean/dirty indicators
- Ahead/behind tracking with remote
- Stash count when present
- Repository status symbols

**Language Support:**
- Python version (via pyenv/venv)
- Node.js version (via nvm)
- Rust version (via rustup)
- Go version detection

**System Information:**
- Current directory (abbreviated)
- Command execution time (>2s)
- Exit code display (on error)
- User@hostname (SSH sessions)

**Visual Elements:**
- Consistent color scheme with theme system
- Unicode symbols for clean appearance
- Contextual information display
- Minimal but informative design

### Prompt Format

```bash
# Example prompt appearance
~/dev/project main* ⇡1 🐍3.11.0 ⚡ 1.2s
❯ command here
```

## 🔧 Environment Management

### Path Configuration

Intelligent PATH management with precedence:

```zsh
# Development tools (highest priority)
$HOME/.dotfiles/src/scripts
$HOME/.local/bin

# Language managers
$HOME/.cargo/bin          # Rust
$HOME/.pyenv/bin         # Python (macOS)
$HOME/.nvm/bin           # Node.js

# System tools
/opt/homebrew/bin        # Homebrew (Apple Silicon)
/usr/local/bin          # Homebrew (Intel)
/usr/bin                # System
```

### Tool Integration

**Homebrew:**
```zsh
# Conditional loading based on platform
[[ -x "/opt/homebrew/bin/brew" ]] && eval "$(/opt/homebrew/bin/brew shellenv)"
```

**FZF:**
```zsh
# Enhanced fuzzy finding with fd
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'
```

**Editor:**
```zsh
export EDITOR=nvim
export VISUAL=nvim
```

## ⚡ Performance Optimizations

### Zinit Turbo Mode

Plugins load asynchronously for faster startup:

```zsh
# Wait for prompt, then load
zinit wait lucid for \
    plugin-name

# Load immediately after compinit
zinit wait"0" lucid for \
    plugin-name
```

### Completion System

Optimized completion loading:

```zsh
# Skip global compinit for performance
skip_global_compinit=1

# Initialize once with zinit
atinit"ZINIT[COMPINIT_OPTS]=-C; zicompinit; zicdreplay"
```

### History Management

Efficient history with smart deduplication:

```zsh
HISTFILE="$HOME/.zsh_history"
HISTSIZE=10000
SAVEHIST=10000

setopt HIST_IGNORE_DUPS     # No consecutive duplicates
setopt SHARE_HISTORY        # Share between sessions
setopt HIST_REDUCE_BLANKS   # Clean up whitespace
```

## 🔧 Customization

### Adding Aliases

**Method 1: Direct in aliases.zsh**
```zsh
# Add to src/zsh/aliases.zsh
alias myalias="command here"
```

**Method 2: Work-specific aliases**
```zsh
# In private dotfiles (if available)
~/.dotfiles/.dotfiles.private/zsh/work-aliases.zsh
```

### Plugin Management

**Adding new plugins:**
```zsh
# In zshrc
zinit wait lucid for \
    user/plugin-name
```

**Removing plugins:**
```zsh
# Comment out in zshrc, then
zinit delete user/plugin-name
```

### Theme Integration

Shell configuration syncs with theme system:

```zsh
# Load current theme environment
if [[ -f ~/.config/theme-switcher/current-theme.sh ]]; then
    source ~/.config/theme-switcher/current-theme.sh
fi
```

## 🧪 Testing & Validation

### Shell Startup Performance

```bash
# Measure startup time
time zsh -c exit

# Profile plugin loading
zinit times

# Debug slow components
zprof  # Add to zshrc for profiling
```

### Alias Validation

```bash
# Test alias functionality
alias | grep myalias

# Check command resolution
type mycommand

# Validate PATH
echo $PATH | tr ':' '\n'
```

### Plugin Health

```bash
# Check plugin status
zinit status

# Update all plugins
zinit update

# Clean unused plugins
zinit clean
```

## 🔧 Troubleshooting

### Common Issues

**Slow startup:**
```bash
# Profile startup
zprof
zinit times

# Check for problematic plugins
zinit times | sort -n
```

**Completions not working:**
```bash
# Rebuild completion cache
rm ~/.zcompdump*
exec zsh

# Debug completion system
echo $fpath
```

**Aliases not loading:**
```bash
# Check alias file source
grep aliases ~/.zshrc

# Manually source aliases
source ~/.dotfiles/src/zsh/aliases.zsh
```

**Plugin errors:**
```bash
# Check zinit status
zinit status

# Reinstall problematic plugin
zinit delete user/plugin
zinit load user/plugin
```

### Performance Issues

**High memory usage:**
```bash
# Check loaded plugins
zinit list

# Disable unnecessary plugins
# Comment out in zshrc
```

**Slow command execution:**
```bash
# Check for problematic aliases
time mycommand

# Profile specific operations
zprof myfunction
```

## 🎯 Advanced Features

### Work Environment Integration

Support for work-specific configurations:

```zsh
# Load work aliases if available
[[ -f ~/.dotfiles/.dotfiles.private/zsh/work.zsh ]] && \
    source ~/.dotfiles/.dotfiles.private/zsh/work.zsh
```

### Conditional Loading

Platform and context-aware configuration:

```zsh
# macOS specific
if [[ "$OSTYPE" == darwin* ]]; then
    # macOS-specific aliases and functions
fi

# SSH session detection
if [[ -n "$SSH_CLIENT" ]]; then
    # SSH-specific prompt and behavior
fi
```

### Extended Functionality

**Directory Bookmarks:**
```zsh
# Quick directory bookmarks
alias mark='pwd > ~/.zsh_bookmark'
alias jump='cd "$(cat ~/.zsh_bookmark)"'
```

**Smart Command History:**
```zsh
# History search with fzf
bindkey '^R' fzf-history-widget
```

## 🚀 Future Enhancements

### Planned Features
- **Fuzzy completion**: Enhanced tab completion with fzf
- **Command correction**: Smart typo correction
- **Session management**: Named shell sessions
- **Remote sync**: Synchronized history across machines

### Integration Roadmap
- **AI assistance**: Shell command suggestions
- **Cloud storage**: Config backup and sync
- **Team sharing**: Collaborative alias management
- **Analytics**: Command usage insights

---

**Plugin Manager**: Zinit (modern, fast) • **Startup Time**: < 200ms • **Aliases**: 200+ shortcuts
**Features**: Syntax highlighting • Autosuggestions • Smart completions • Vi mode

*Streamlined Zsh configuration for maximum developer productivity.*