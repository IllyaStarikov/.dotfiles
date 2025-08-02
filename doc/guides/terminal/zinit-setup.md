# Zinit Plugin Manager

> **Modern Zsh plugin manager with turbo mode and performance optimizations**

[Official Documentation](https://github.com/zdharma-continuum/zinit)

## Overview

Zinit replaces Oh My Zsh in our setup for several key advantages:

- **Performance** - 50-90% faster shell startup through turbo mode
- **Flexibility** - Granular plugin loading control
- **Modern** - Active development with latest Zsh features
- **Minimal** - Only loads what you need when you need it

## Our Configuration

### Core Setup

Located in `~/.zshrc`:

```bash
# Zinit installation directory
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# Auto-install if not present
if [[ ! -d "$ZINIT_HOME" ]]; then
    print -P "%F{33}▓▒░ Installing zinit...%f"
    command mkdir -p "$(dirname $ZINIT_HOME)"
    command git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

source "${ZINIT_HOME}/zinit.zsh"
```

### Essential Plugins

**Syntax Highlighting (Turbo Mode):**
```bash
zinit wait lucid for \
    atinit"ZINIT[COMPINIT_OPTS]=-C; zicompinit; zicdreplay" \
    zdharma-continuum/fast-syntax-highlighting
```

**Autosuggestions (Lazy Loading):**
```bash
zinit wait lucid atload"!_zsh_autosuggest_start" for \
    zsh-users/zsh-autosuggestions
```

**Directory Jumping:**
```bash
zinit ice wait"0" lucid
zinit light agkozak/zsh-z
```

**Enhanced Completions:**
```bash
zinit ice wait"0" lucid blockf
zinit light zsh-users/zsh-completions
```

### Performance Features

**Turbo Mode (`wait` ice)**
- Plugins load after prompt appears
- Shell becomes interactive immediately
- Background loading prevents startup delays

**Lazy Loading (`atload` ice)**
- Plugins initialize only when first used
- Reduces memory usage and startup time

**Compilation (`compile` ice)**
- Compiles plugins for faster execution
- Automatic recompilation on updates

## Commands

### Plugin Management

```bash
# List installed plugins
zinit list

# Update all plugins
zinit update

# Update specific plugin
zinit update zdharma-continuum/fast-syntax-highlighting

# Show plugin status
zinit status

# Load/unload plugin
zinit load agkozak/zsh-z
zinit unload agkozak/zsh-z
```

### Advanced Operations

```bash
# Compile all plugins
zinit compile --all

# Create report of loading times  
zinit times

# Stress test installation
zinit stress

# Show plugin information
zinit report zsh-users/zsh-autosuggestions
```

### Completions Management

```bash
# Rebuild completion cache
zinit creinstall

# List completions
zinit clist

# Delete completion
zinit cuninstall _command
```

## Customization

### Adding New Plugins

**Simple plugin:**
```bash
zinit load "user/plugin-name"
```

**With turbo mode:**
```bash
zinit ice wait"1" lucid
zinit load "user/plugin-name"
```

**With conditions:**
```bash
zinit ice wait"1" lucid if"command -v git"
zinit load "user/git-plugin"
```

**Local configuration:**
```bash
zinit ice wait"1" lucid \
    atload"export PLUGIN_VAR=value" \
    atclone"./configure" \
    atpull"./update.sh"
zinit load "user/complex-plugin"
```

### Ice Modifiers

| Ice | Purpose | Example |
|-----|---------|---------|
| `wait"N"` | Delay loading N seconds | `wait"2"` |
| `lucid` | Silent loading | Always use with wait |
| `atload` | Execute after loading | `atload"export VAR=1"` |
| `atinit` | Execute before loading | `atinit"setup()"` |
| `if` | Conditional loading | `if"command -v node"` |
| `blockf` | Block default completions | For completion plugins |
| `compile` | Compile plugin | For faster execution |

### Theme Integration

**Starship prompt (already configured):**
```bash
# Starship is loaded externally
if command -v starship &>/dev/null; then
    eval "$(starship init zsh)"
fi
```

**Custom prompt plugin:**
```bash
zinit ice depth=1
zinit light romkatv/powerlevel10k
```

## Migration from Oh My Zsh

### Plugin Equivalents

| Oh My Zsh | Zinit Equivalent |
|-----------|------------------|
| `git` plugin | `zinit snippet OMZ::plugins/git/git.plugin.zsh` |
| `colored-man-pages` | `zinit snippet OMZ::plugins/colored-man-pages/colored-man-pages.plugin.zsh` |
| Custom theme | `zinit load "theme-author/theme-name"` |

### Snippet Loading

```bash
# Load Oh My Zsh components
zinit snippet OMZ::lib/git.zsh
zinit snippet OMZ::plugins/git/git.plugin.zsh
```

### Configuration Migration

**Old `.zshrc` (Oh My Zsh):**
```bash
plugins=(git colored-man-pages z)
ZSH_THEME="spaceship"
```

**New `.zshrc` (Zinit):**
```bash
zinit snippet OMZ::plugins/git/git.plugin.zsh
zinit snippet OMZ::plugins/colored-man-pages/colored-man-pages.plugin.zsh
zinit load agkozak/zsh-z
# Starship replaces spaceship theme
```

## Performance Comparison

### Startup Time

| Setup | Cold Start | Warm Start |
|-------|------------|------------|
| Oh My Zsh | 800-1200ms | 400-600ms |
| Zinit (basic) | 200-400ms | 100-200ms |
| Zinit (turbo) | 50-150ms | 30-80ms |

### Memory Usage

| Setup | Initial RAM | After Loading |
|-------|-------------|---------------|
| Oh My Zsh | 35MB | 45MB |
| Zinit | 15MB | 25MB |

## Troubleshooting

### Plugin Not Loading

**Check plugin status:**
```bash
zinit status plugin-name
```

**Manual reload:**
```bash
zinit reload plugin-name
```

**Verbose loading:**
```bash
zinit load plugin-name --verbose
```

### Slow Startup

**Profile loading times:**
```bash
zinit times
```

**Check problematic plugins:**
```bash
# Look for plugins without 'wait' ice
zinit list | grep -v "wait"
```

### Completion Issues

**Rebuild completions:**
```bash
rm -rf ~/.zcompdump*
zinit creinstall
exec zsh
```

**Check completion sources:**
```bash
zinit clist
```

### Reset Everything

**Complete Zinit reset:**
```bash
rm -rf ~/.local/share/zinit
rm -rf ~/.zcompdump*
exec zsh  # Will auto-reinstall
```

## Advanced Configurations

### Custom Plugin Development

**Local plugin structure:**
```
~/.local/share/zinit/custom/
└── my-plugin/
    ├── my-plugin.plugin.zsh
    ├── functions/
    │   └── _my_completion
    └── README.md
```

**Load local plugin:**
```bash
zinit load ~/.local/share/zinit/custom/my-plugin
```

### Conditional Loading

**Development tools only in dev projects:**
```bash
zinit ice wait"1" lucid if"[[ -f package.json ]]"
zinit load "lukechilds/zsh-nvm"
```

**Work-specific plugins:**
```bash
if [[ "$PWD" == *"/work/"* ]]; then
    zinit load "work/corporate-plugin"
fi
```

### Binary Programs

**Install programs via Zinit:**
```bash
zinit ice from"gh-r" as"program"
zinit load junegunn/fzf
```

**With renaming:**
```bash
zinit ice from"gh-r" as"program" mv"ripgrep* -> rg"
zinit load BurntSushi/ripgrep
```

## Best Practices

### Performance Tips

1. **Use turbo mode** for all non-essential plugins
2. **Lazy load** expensive operations
3. **Profile regularly** with `zinit times`
4. **Minimize eager loading** - only for critical functionality

### Organization

```bash
# Group related plugins
zinit wait lucid for \
    zsh-users/zsh-autosuggestions \
    zsh-users/zsh-completions \
    zdharma-continuum/fast-syntax-highlighting

# Separate complex configurations
zinit ice wait"1" lucid atload"setup_complex_plugin"
zinit load complex/plugin
```

### Maintenance

```bash
# Regular maintenance script
#!/bin/bash
zinit update --all
zinit compile --all
zinit creinstall  # Rebuild completions
```

---

> **Pro Tip**: Start with our default configuration and gradually add plugins. Use `zinit times` to monitor performance impact before making plugins permanent.