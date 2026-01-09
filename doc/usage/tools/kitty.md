# Kitty Reference

> **GPU-accelerated terminal emulator with ligatures and image support**

## Quick Start

```bash
# Launch Kitty
kitty

# With specific config
kitty --config ~/.config/kitty/kitty.conf

# With command
kitty -e zsh
kitty -e tmux new -s work

# New OS window
kitty --single-instance
```

## Features

- **GPU rendering** - OpenGL acceleration
- **Ligatures** - Full programming font support
- **Images** - Native image protocol (icat)
- **Fast** - Threaded rendering, low latency
- **Tabs/Layouts** - Multiple sessions and layouts
- **Remote control** - Scriptable via `kitty @`

## Configuration

### File Location

```
~/.config/kitty/
├── kitty.conf          # Main configuration
├── theme.conf          # Dynamic theme (generated)
└── themes/             # Theme files
```

### Key Settings

```conf
# Font configuration
font_family      JetBrains Mono
bold_font        auto
italic_font      auto
font_size        14.0
disable_ligatures never

# Window settings
background_opacity 0.95
window_padding_width 10
macos_titlebar_color background
macos_option_as_alt yes

# Tab bar
tab_bar_edge bottom
tab_bar_style powerline
tab_powerline_style slanted

# Scrollback
scrollback_lines 10000

# Bell
enable_audio_bell no
visual_bell_duration 0.0
```

## Keyboard Shortcuts

### Window Management

| Key           | Action           |
|---------------|------------------|
| `Cmd+N`       | New OS window    |
| `Cmd+W`       | Close window     |
| `Cmd+Return`  | Toggle fullscreen|
| `Cmd+M`       | Minimize         |

### Tab Management

| Key              | Action            |
|------------------|-------------------|
| `Cmd+T`          | New tab           |
| `Cmd+[`          | Previous tab      |
| `Cmd+]`          | Next tab          |
| `Cmd+1-9`        | Go to tab 1-9     |
| `Cmd+Shift+Left` | Move tab left     |
| `Cmd+Shift+Right`| Move tab right    |

### Window Splits

| Key           | Action            |
|---------------|-------------------|
| `Cmd+D`       | Split vertical    |
| `Cmd+Shift+D` | Split horizontal  |
| `Cmd+[`       | Previous window   |
| `Cmd+]`       | Next window       |

### Text Operations

| Key     | Action       |
|---------|--------------|
| `Cmd+C` | Copy         |
| `Cmd+V` | Paste        |
| `Cmd+F` | Search       |
| `Cmd+K` | Clear screen |

### Font Size

| Key          | Action        |
|--------------|---------------|
| `Cmd+Plus`   | Increase font |
| `Cmd+Minus`  | Decrease font |
| `Cmd+0`      | Reset font    |

### Scrolling

| Key         | Action           |
|-------------|------------------|
| `Cmd+Up`    | Scroll line up   |
| `Cmd+Down`  | Scroll line down |
| `Cmd+PgUp`  | Scroll page up   |
| `Cmd+PgDown`| Scroll page down |
| `Cmd+Home`  | Scroll to top    |
| `Cmd+End`   | Scroll to bottom |

## Custom Keybindings

### Configuration Format

```conf
# Split windows
map cmd+d launch --location=vsplit --cwd=current
map cmd+shift+d launch --location=hsplit --cwd=current

# Navigate windows
map cmd+h neighboring_window left
map cmd+j neighboring_window down
map cmd+k neighboring_window up
map cmd+l neighboring_window right

# Quick commands
map cmd+g send_text all lazygit\n

# Resize windows
map cmd+left resize_window narrower
map cmd+right resize_window wider
map cmd+up resize_window taller
map cmd+down resize_window shorter
```

## Layouts

Kitty supports multiple window layouts:

```conf
# Available layouts
enabled_layouts tall:bias=50, fat:bias=50, stack, grid, splits

# Cycle layouts
map cmd+l next_layout
```

### Layout Types

| Layout  | Description                    |
|---------|--------------------------------|
| `tall`  | One main + stack on side       |
| `fat`   | One main + stack on bottom     |
| `grid`  | Windows in grid                |
| `splits`| Manual splits                  |
| `stack` | Single window (tabs-like)      |

## Theme Integration

### Automatic Theme Switching

Our setup syncs with macOS appearance:

```conf
# Include dynamic theme
include theme.conf
```

```bash
# Manual theme switch
theme         # Auto-detect
theme dark    # Force dark
theme light   # Force light
```

### Custom Colors

```conf
# Tokyo Night Moon theme
foreground #c0caf5
background #1a1b26
selection_foreground #c0caf5
selection_background #33467c
cursor #c0caf5
cursor_text_color #1a1b26

# Normal colors
color0 #15161e
color1 #f7768e
color2 #9ece6a
color3 #e0af68
color4 #7aa2f7
color5 #bb9af7
color6 #7dcfff
color7 #a9b1d6

# Bright colors
color8  #414868
color9  #f7768e
color10 #9ece6a
color11 #e0af68
color12 #7aa2f7
color13 #bb9af7
color14 #7dcfff
color15 #c0caf5
```

## Image Support

### Display Images

```bash
# Using icat (built-in)
kitty +kitten icat image.png

# With options
kitty +kitten icat --align left --scale-up image.png

# In scripts
icat() {
  kitty +kitten icat "$@"
}
```

### Image Protocols

Kitty supports:
- Native kitty graphics protocol
- iTerm2 inline images
- Sixel graphics

## Remote Control

### Enable Remote Control

```conf
# In kitty.conf
allow_remote_control yes
listen_on unix:/tmp/kitty
```

### Usage

```bash
# Send command to kitty
kitty @ send-text "ls -la\n"

# Change colors
kitty @ set-colors foreground=#ffffff

# Create new window
kitty @ launch --type=tab

# Focus window
kitty @ focus-window --match title:vim
```

## Performance

### Optimizations

```conf
# Reduce CPU usage
repaint_delay 10
input_delay 3
sync_to_monitor yes

# Memory management
scrollback_lines 10000
scrollback_pager_history_size 0

# Disable animations
cursor_blink_interval 0
```

### GPU Settings

```conf
# Force GPU
# Kitty uses OpenGL by default

# Check GPU info
kitty --debug-gl
```

## Troubleshooting

### Common Issues

| Issue              | Solution                        |
|--------------------|---------------------------------|
| Ligatures missing  | Ensure font supports ligatures  |
| Slow performance   | Check GPU, disable transparency |
| Theme not updating | Run `theme` command             |
| Keys not working   | Check `kitty --debug-keyboard`  |

### Debug Mode

```bash
# Check configuration
kitty --debug-config

# Keyboard debugging
kitty --debug-keyboard

# OpenGL debugging
kitty --debug-gl

# Full debug
kitty --debug-rendering
```

### Reset Configuration

```bash
# Backup current config
mv ~/.config/kitty ~/.config/kitty.bak

# Generate default config
kitty --debug-config > ~/.config/kitty/kitty.conf
```

## Integration

### With tmux

```conf
# Pass-through for tmux
map cmd+t send_text all \x01c
map cmd+w send_text all \x01x
```

### With Shell

```bash
# In .zshrc
if [[ "$TERM" == "xterm-kitty" ]]; then
  alias icat="kitty +kitten icat"
  alias ssh="kitty +kitten ssh"
fi
```

### With Neovim

```lua
-- In Neovim config
if vim.env.TERM == "xterm-kitty" then
  vim.opt.termguicolors = true
end
```

## Quick Reference

```bash
# Launch
kitty              # Default
kitty -e tmux      # With tmux
kitty --single-instance  # Reuse

# Shortcuts
Cmd+T      New tab
Cmd+D      Split vertical
Cmd+Shift+D Split horizontal
Cmd+[/]    Prev/Next tab
Cmd+K      Clear
Cmd+F      Search
Cmd++/-    Font size

# Images
icat image.png
kitty +kitten icat --scale-up image.png

# Remote control
kitty @ send-text "command\n"
kitty @ launch --type=tab
```

---

<p align="center">
  <a href="../README.md">← Back to Tools</a>
</p>
