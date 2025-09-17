# Alacritty Reference

> **GPU-accelerated terminal emulator**

## Quick Start

```bash
# Launch Alacritty
alacritty

# With specific config
alacritty --config-file ~/.config/alacritty/custom.toml

# With command
alacritty -e zsh
alacritty -e tmux new -s work

# With title
alacritty -t "Development"
```

## Configuration

### File Location

```
~/.config/alacritty/
├── alacritty.toml      # Main config
├── theme.toml          # Dynamic theme (generated)
└── themes/             # Theme files
    ├── tokyo-night-moon.toml
    └── tokyo-night-day.toml
```

### Key Settings

```toml
# Font configuration
[font]
size = 14.0

[font.normal]
family = "JetBrainsMono Nerd Font"
style = "Regular"

# Window settings
[window]
decorations = "buttonless"
dynamic_title = true
opacity = 0.95

[window.padding]
x = 10
y = 10

# Scrolling
[scrolling]
history = 10000
multiplier = 3
```

## Keyboard Shortcuts

### Window Management

| Key     | Action         | macOS |
| ------- | -------------- | ----- |
| `Cmd+N` | New window     | ✓     |
| `Cmd+W` | Close window   | ✓     |
| `Cmd+M` | Minimize       | ✓     |
| `Cmd+Q` | Quit Alacritty | ✓     |

### Tab Management

| Key             | Action        |
| --------------- | ------------- |
| `Cmd+T`         | New tab       |
| `Cmd+Tab`       | Next tab      |
| `Cmd+Shift+Tab` | Previous tab  |
| `Cmd+1-9`       | Go to tab 1-9 |

### Text Operations

| Key     | Action       |
| ------- | ------------ |
| `Cmd+C` | Copy         |
| `Cmd+V` | Paste        |
| `Cmd+A` | Select all   |
| `Cmd+F` | Search       |
| `Cmd+K` | Clear screen |

### Font Size

| Key         | Action        |
| ----------- | ------------- |
| `Cmd+Plus`  | Increase font |
| `Cmd+Minus` | Decrease font |
| `Cmd+0`     | Reset font    |

### Scrolling

| Key            | Action           |
| -------------- | ---------------- |
| `Shift+PgUp`   | Scroll up        |
| `Shift+PgDown` | Scroll down      |
| `Cmd+Home`     | Scroll to top    |
| `Cmd+End`      | Scroll to bottom |

## Custom Keybindings

### Configuration Format

```toml
[[keyboard.bindings]]
key = "N"
mods = "Command"
action = "CreateNewWindow"

[[keyboard.bindings]]
key = "K"
mods = "Command"
chars = "\x0c"  # Clear screen

[[keyboard.bindings]]
key = "Return"
mods = "Command"
action = "ToggleFullscreen"
```

### Common Customizations

```toml
# tmux integration
[[keyboard.bindings]]
key = "T"
mods = "Command"
chars = "\x01\x63"  # C-a c (new tmux window)

# Quick commands
[[keyboard.bindings]]
key = "G"
mods = "Command"
chars = "lazygit\n"

# Vi mode toggle
[[keyboard.bindings]]
key = "Space"
mods = "Shift|Control"
action = "ToggleViMode"
```

## Mouse Configuration

### Mouse Settings

```toml
[mouse]
hide_when_typing = true

# Selection
[selection]
save_to_clipboard = true
semantic_escape_chars = ",│`|:\"' ()[]{}<>\t"
```

### Mouse Actions

| Action       | Result                  |
| ------------ | ----------------------- |
| Click        | Position cursor         |
| Double-click | Select word             |
| Triple-click | Select line             |
| Click+Drag   | Select text             |
| Right-click  | Paste (if no selection) |

## Color Schemes

### Theme Structure

```toml
# ~/.config/alacritty/theme.toml
[colors.primary]
background = '#1a1b26'
foreground = '#c0caf5'

[colors.cursor]
text = '#1a1b26'
cursor = '#c0caf5'

[colors.normal]
black = '#15161e'
red = '#f7768e'
green = '#9ece6a'
yellow = '#e0af68'
blue = '#7aa2f7'
magenta = '#bb9af7'
cyan = '#7dcfff'
white = '#a9b1d6'

[colors.bright]
black = '#414868'
red = '#f7768e'
green = '#9ece6a'
yellow = '#e0af68'
blue = '#7aa2f7'
magenta = '#bb9af7'
cyan = '#7dcfff'
white = '#c0caf5'
```

### Theme Integration

Our setup automatically switches themes based on macOS appearance:

```bash
# Manual theme switch
theme         # Auto-detect
theme dark    # Force dark
theme light   # Force light
```

## Performance

### GPU Acceleration

```toml
# Ensure GPU rendering
# Alacritty uses GPU by default

# Debug rendering
alacritty --print-events
```

### Optimizations

1. **Scrollback**: Limited to 10,000 lines
2. **Font**: Use patched Nerd Fonts
3. **Opacity**: Slight transparency (0.95)
4. **Decorations**: Buttonless for macOS

## Integration

### With tmux

```toml
# Auto-start tmux
[shell]
program = "/bin/zsh"
args = ["-l", "-c", "tmux attach || tmux"]
```

### With Shell

```bash
# In .zshrc
if [[ "$TERM" == "alacritty" ]]; then
  # Alacritty-specific settings
  export COLORTERM=truecolor
fi
```

### With Neovim

```lua
-- In Neovim config
if vim.env.TERM == "alacritty" then
  vim.opt.termguicolors = true
end
```

## Advanced Features

### Vi Mode

| Key                | Action              |
| ------------------ | ------------------- |
| `Ctrl+Shift+Space` | Toggle vi mode      |
| `v`                | Visual selection    |
| `y`                | Copy selection      |
| `/`                | Search forward      |
| `?`                | Search backward     |
| `n/N`              | Next/Previous match |

### URL Handling

```toml
[hints]
enabled = [
  {
    regex = "(ipfs:|ipns:|magnet:|mailto:|gemini:|gopher:|https:|http:|news:|file:|git:|ssh:|ftp:)[^\u0000-\u001F\u007F-\u009F<>\"\\s{-}\\^⟨⟩`]+"
    command = "open"
    post_processing = true
    mouse.enabled = true
  }
]
```

### Search Mode

| Key           | Action        |
| ------------- | ------------- |
| `Cmd+F`       | Enter search  |
| `Enter`       | Find next     |
| `Shift+Enter` | Find previous |
| `Escape`      | Exit search   |

## Troubleshooting

### Common Issues

| Issue              | Solution                        |
| ------------------ | ------------------------------- |
| Font not rendering | Install Nerd Font variant       |
| Colors look wrong  | Check `$TERM` and termguicolors |
| Slow performance   | Check GPU acceleration          |
| tmux issues        | Set `TERM=xterm-256color`       |

### Debug Mode

```bash
# Verbose output
alacritty -vvv

# Configuration validation
alacritty --config-file alacritty.toml check

# Print events
alacritty --print-events
```

### Reset Configuration

```bash
# Backup current config
mv ~/.config/alacritty ~/.config/alacritty.bak

# Use defaults
alacritty

# Or minimal config
echo "[window]\nopacity = 0.95" > ~/.config/alacritty/alacritty.toml
```

## Tips and Tricks

### Productivity

1. **Quick fullscreen**: `Cmd+Return`
2. **Clear screen**: `Cmd+K`
3. **Font size**: `Cmd+/-` for quick adjustment
4. **URL hints**: `Cmd+Shift+U` to open URLs

### Customization

1. **Opacity**: Adjust for readability
2. **Padding**: Add space for aesthetics
3. **Font**: Use ligature-enabled fonts
4. **Cursor**: Customize style and blink

### Integration

1. **tmux**: Auto-attach on launch
2. **Theme**: Syncs with system
3. **Shell**: Full zsh integration
4. **Copy**: Automatic clipboard

## Quick Reference

```bash
# Launch
alacritty              # Default
alacritty -e tmux      # With tmux
alacritty -t "Dev"     # With title

# Shortcuts
Cmd+N      New window
Cmd+T      New tab
Cmd+K      Clear
Cmd+F      Search
Cmd++/-    Font size

# Vi mode
Ctrl+Shift+Space  Toggle
v                 Select
y                 Copy
/                 Search
```

---

<p align="center">
  <a href="../README.md">← Back to Tools</a>
</p>
