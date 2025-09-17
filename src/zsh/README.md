# Zsh Shell Configuration

Fast, modern shell setup with < 200ms startup time using Zinit and Starship.

## Files

- `zshrc` - Main configuration with plugins
- `zshenv` - Environment variables
- `aliases.zsh` - 200+ command aliases
- `starship.toml` - Prompt configuration

## Key Features

- **< 200ms startup** with Zinit turbo mode
- **5 essential plugins** (syntax highlighting, autosuggestions, completions)
- **Vi mode** with visual feedback
- **Smart completions** with caching
- **Starship prompt** with git integration

## Plugin Management

```zsh
# Zinit with turbo mode (loads after prompt)
zinit wait lucid for \
    zdharma-continuum/fast-syntax-highlighting \
    zsh-users/zsh-autosuggestions \
    zsh-users/zsh-completions
```

## Common Aliases

```zsh
# Navigation
alias ..="cd .."
alias ls="eza --icons"

# Git
alias gs="git status"
alias gc="git commit"
alias gp="git push"

# Development
alias v="nvim"
alias py="python3"
```

## Performance Tips

- Use `zinit wait` for deferred loading
- Profile with `time zsh -i -c exit`
- Clear widget conflicts before Starship init
- Compile completion cache with `zicompinit`

## Lessons Learned

### Vi Mode Recursion Fix

Both Starship and vi-mode define `zle-keymap-select` causing infinite recursion.

```zsh
# Fix at zshrc:181-183
if (( ${+widgets[zle-keymap-select]} )); then
    zle -D zle-keymap-select 2>/dev/null
fi
```

### Why Not Oh-My-Zsh

- Adds 500ms+ to startup
- Bloated with unused features
- Zinit is 10x faster with turbo mode

### Failed Approaches

- **Prezto** - Still 300ms+ startup
- **Antigen** - No parallel loading
- **Powerline** - Python-based, very slow
- **zcompile** - Negligible improvement

## Troubleshooting

**Slow startup**: Use `zinit wait` for plugins

**Completions broken**: Run `rm -rf ~/.zcompdump* && exec zsh`

**Path duplicates**: Add `typeset -U path` to zshenv

**Debug**: `zsh -x -i -c exit 2>&1 | head -50`
