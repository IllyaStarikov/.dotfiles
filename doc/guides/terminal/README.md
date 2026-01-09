# Terminal Configuration Guides

> **Comprehensive terminal emulator and shell configuration**

## Terminal Emulators

This setup supports multiple GPU-accelerated terminal emulators:

| Terminal | Best For | Config Location |
|----------|----------|-----------------|
| [Alacritty](../../usage/tools/alacritty.md) | Simplicity, cross-platform | `~/.config/alacritty/` |
| [WezTerm](../../usage/tools/wezterm.md) | Built-in multiplexing, Lua config | `~/.config/wezterm/` |
| [Kitty](../../usage/tools/kitty.md) | Image support, remote control | `~/.config/kitty/` |

## Available Guides

### Theme System

- **[Theme System Guide](theme-system.md)** - How automatic theme switching works across all applications

### Shell Configuration

- **[Zinit Setup Guide](zinit-setup.md)** - Fast Zsh plugin manager configuration

## Common Configuration

### Theme Integration

All terminals automatically sync with macOS appearance:

```bash
# Manual theme switch
theme         # Auto-detect from system
theme dark    # Force dark mode
theme light   # Force light mode
theme moon    # TokyoNight Moon variant
theme storm   # TokyoNight Storm variant
```

Theme files are generated in each terminal's config directory:
- Alacritty: `~/.config/alacritty/theme.toml`
- WezTerm: `~/.config/wezterm/theme.lua`
- Kitty: `~/.config/kitty/theme.conf`
- tmux: `~/.config/tmux/theme.conf`

### Font Configuration

All terminals use Nerd Fonts for consistent icons:

| Terminal | Font Setting |
|----------|--------------|
| Alacritty | `font.normal.family = "JetBrainsMono Nerd Font"` |
| WezTerm | `config.font = wezterm.font("MesloLGS Nerd Font Mono")` |
| Kitty | `font_family JetBrains Mono` |

**Recommended fonts:**
- JetBrains Mono Nerd Font
- MesloLGS Nerd Font Mono
- Fira Code Nerd Font

### Performance Settings

Common optimizations across terminals:

```
GPU acceleration      Enabled (Metal/OpenGL)
Scrollback lines      10,000
Background opacity    0.95
Font ligatures        Enabled
```

### Common Keybindings

Consistent keybindings across all terminals:

| Action | macOS Key |
|--------|-----------|
| New tab | `Cmd+T` |
| Close tab | `Cmd+W` |
| New window | `Cmd+N` |
| Split vertical | `Cmd+D` |
| Split horizontal | `Cmd+Shift+D` |
| Previous tab | `Cmd+[` |
| Next tab | `Cmd+]` |
| Font size up | `Cmd++` |
| Font size down | `Cmd+-` |
| Fullscreen | `Cmd+Return` |

## Shell Integration

### Zsh Configuration

The shell detects the terminal and configures accordingly:

```bash
# In .zshrc
case "$TERM_PROGRAM" in
  Alacritty) export COLORTERM=truecolor ;;
  WezTerm)   export COLORTERM=truecolor ;;
  *) ;;
esac

case "$TERM" in
  xterm-kitty) alias icat="kitty +kitten icat" ;;
  *) ;;
esac
```

### tmux Integration

All terminals work seamlessly with tmux:

```bash
# Auto-attach to tmux
if [[ -z "$TMUX" ]]; then
  tmux attach || tmux new -s main
fi
```

## Troubleshooting

### Common Issues

| Issue | Solution |
|-------|----------|
| Colors wrong | Check `$TERM` and `$COLORTERM` variables |
| Icons missing | Install Nerd Font variant |
| Slow rendering | Check GPU acceleration settings |
| Theme not updating | Run `theme` command to force sync |

### Debug Commands

```bash
# Check terminal info
echo $TERM
echo $TERM_PROGRAM
echo $COLORTERM

# Check font rendering
echo -e "\ue0b0 \ue0b2 \uf113 \uf1d3"

# Check true color support
awk 'BEGIN{
  for (i=0; i<256; i++) {
    printf "\033[38;5;%dm%3d\033[0m ", i, i
    if ((i+1)%16==0) print ""
  }
}'
```

## Choosing a Terminal

### Alacritty

**Pros:**
- Simple TOML configuration
- Cross-platform (macOS, Linux, Windows)
- Minimal and fast

**Cons:**
- No built-in tabs/splits (use tmux)
- No image support

**Best for:** Users who prefer tmux for multiplexing

### WezTerm

**Pros:**
- Built-in multiplexing (tabs, splits)
- Lua configuration (powerful)
- SSH integration
- Image support

**Cons:**
- Larger binary
- More complex configuration

**Best for:** Users who want tmux features built into the terminal

### Kitty

**Pros:**
- Excellent image support (`icat`)
- Remote control API
- Fast and GPU-accelerated
- Built-in multiplexing

**Cons:**
- Linux/macOS only
- Configuration syntax unique to Kitty

**Best for:** Users who need inline images or remote scripting

---

<p align="center">
  <a href="../README.md">← Back to Guides</a>
</p>
