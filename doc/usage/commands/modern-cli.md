# Modern CLI Tools Reference

> **Enhanced replacements for traditional Unix commands**

## Overview

Modern CLI tools provide significant improvements over traditional Unix utilities:

- **Better performance** - Often 10-100x faster
- **Better UX** - Intuitive syntax, colored output, progress bars
- **Better defaults** - Sensible out-of-the-box behavior
- **Git awareness** - Understanding of version control context

## Tool Replacements

### File Operations

| Traditional | Modern                                               | Benefits                                         |
| ----------- | ---------------------------------------------------- | ------------------------------------------------ |
| `ls`        | **[eza](https://eza.rocks/)**                        | Git integration, tree view, icons                |
| `cat`       | **[bat](https://github.com/sharkdp/bat)**            | Syntax highlighting, line numbers, git changes   |
| `find`      | **[fd](https://github.com/sharkdp/fd)**              | Intuitive syntax, respect `.gitignore`, faster   |
| `grep`      | **[ripgrep](https://github.com/BurntSushi/ripgrep)** | 10-100x faster, respects `.gitignore`, better UX |
| `sed`       | **[sd](https://github.com/chmln/sd)**                | Intuitive find/replace syntax                    |
| `diff`      | **[delta](https://github.com/dandavison/delta)**     | Syntax highlighting, side-by-side view           |

### System Monitoring

| Traditional | Modern                                        | Benefits                              |
| ----------- | --------------------------------------------- | ------------------------------------- |
| `top`       | **[htop](https://htop.dev/)**                 | Interactive process viewer, tree view |
| `ps`        | **[procs](https://github.com/dalance/procs)** | Better formatting, tree view          |
| `df`        | **[duf](https://github.com/muesli/duf)**      | Better formatting, device filtering   |
| `du`        | **[dust](https://github.com/bootandy/dust)**  | Intuitive tree view, faster           |

### Network Tools

| Traditional | Modern                                    | Benefits                                 |
| ----------- | ----------------------------------------- | ---------------------------------------- |
| `ping`      | **[gping](https://github.com/orf/gping)** | Graph visualization                      |
| `dig`       | **[dog](https://github.com/ogham/dog)**   | Colorful output, better UX               |
| `curl`      | **[xh](https://github.com/ducaale/xh)**   | HTTPie-compatible, faster, single binary |

## Configuration

### eza (Enhanced ls)

```bash
# Aliases in .zshrc
alias l='eza --group-directories-first --time-style=relative --git --icons --all --header --long'
alias ls='eza --group-directories-first'
alias ll='eza -l --git --time-style=relative'
alias la='eza -a'
alias lt='eza --tree'
```

### bat (Better cat)

```bash
# Environment
export BAT_THEME="tokyonight_storm"  # or "tokyonight_day" for light

# Aliases
alias cat='bat'
alias less='bat --paging=always'
```

### ripgrep (Fast grep)

```bash
# Config at ~/.config/ripgrep/config
--smart-case
--colors=match:fg:red
--colors=line:fg:yellow
```

### fd (Friendly find)

```bash
# Aliases
alias find='fd'
ff() { fd "$@" | fzf }
```

### delta (Git diff)

```gitconfig
# In .gitconfig
[core]
    pager = delta

[delta]
    navigate = true
    light = false
    side-by-side = true
```

## Usage Examples

### Finding Files

```bash
# Traditional
find . -name "*.py" -type f

# Modern
fd -e py

# With preview
fd -e py | fzf --preview 'bat {}'
```

### Searching Text

```bash
# Traditional
grep -r "TODO" . --include="*.js"

# Modern
rg "TODO" -t js

# With context
rg "TODO" -C 2
```

### Viewing Files

```bash
# Traditional
cat file.py

# Modern with highlighting
bat file.py

# With line numbers
bat -n file.py
```

### Listing Files

```bash
# Traditional
ls -la

# Modern with git status
ll

# Tree view
lt --level=2
```

### System Info

```bash
# Traditional
df -h

# Modern
duf

# Just local disks
duf --only local
```

## Performance Comparison

### ripgrep vs grep

```bash
# Test: Search Linux kernel source
time grep -r "TODO" linux/
# 18.5s

time rg "TODO" linux/
# 0.5s (37x faster!)
```

### fd vs find

```bash
# Test: Find all Python files
time find . -name "*.py" -type f
# 4.2s

time fd -e py
# 0.3s (14x faster!)
```

## Integration Tips

### With fzf

```bash
# Interactive file search
alias ff='fd | fzf --preview "bat {}"'

# Interactive grep
fif() {
  rg "$1" | fzf --preview 'bat {1} --highlight-line {2}'
}
```

### With tmux

```bash
# Use bat for tmux copy mode
set -g @plugin 'laktak/extrakto'
set -g @extrakto_clip_tool 'pbcopy'
```

### With Git

```bash
# Better git log
alias gl='git log --graph --pretty=format:"%C(auto)%h%d %s %C(black)%C(bold)%cr" | delta'

# Interactive branch selection
fco() {
  git branch -a | fzf | xargs git checkout
}
```

## Installation

```bash
# macOS with Homebrew
brew install eza bat fd ripgrep sd delta htop duf dust procs gping dog xh fzf

# Configuration
mkdir -p ~/.config/ripgrep
echo "--smart-case" > ~/.config/ripgrep/config
```

## Customization

### Color Themes

Most tools respect terminal colors or have theme support:

```bash
# Dark mode
export BAT_THEME="tokyonight_storm"
export EZA_COLORS="di=34:ln=35:ex=31"

# Light mode
export BAT_THEME="tokyonight_day"
export EZA_COLORS="di=94:ln=95:ex=91"
```

### Shell Integration

Add to your `.zshrc`:

```bash
# Modern CLI replacements
[ -x "$(command -v eza)" ] && alias ls='eza'
[ -x "$(command -v bat)" ] && alias cat='bat'
[ -x "$(command -v fd)" ] && alias find='fd'
[ -x "$(command -v rg)" ] && alias grep='rg'
[ -x "$(command -v sd)" ] && alias sed='sd'
[ -x "$(command -v htop)" ] && alias top='htop'
[ -x "$(command -v duf)" ] && alias df='duf'
```

---

<p align="center">
  <a href="../README.md">← Back to Commands</a>
</p>
