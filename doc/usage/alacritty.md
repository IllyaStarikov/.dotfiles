# Alacritty Commands

## Daily Commands

```bash
WINDOW                 TEXT                   NAVIGATION
Cmd+N    New window   Cmd+C    Copy         Cmd+F    Search
Cmd+W    Close        Cmd+V    Paste        Cmd+K    Clear buffer
Cmd+Q    Quit         Cmd+A    Select all   Shift+PgUp  Scroll up
Cmd+M    Minimize     Cmd+X    Cut          Shift+PgDn  Scroll down
Cmd+H    Hide         Cmd+L    Clear screen Cmd+Home    Top

FONT SIZE              FULLSCREEN            SEARCH
Cmd++    Increase      Cmd+Return Toggle     Cmd+F       Find
Cmd+-    Decrease                            Cmd+G       Find next
Cmd+0    Reset                               Cmd+Shift+G Find prev
                                            Esc         Cancel search
```

## Keyboard Shortcuts

### macOS Bindings

| Key | Action | Key | Action |
|-----|--------|-----|--------|
| `Cmd+N` | New window | `Cmd+W` | Close window |
| `Cmd+Q` | Quit Alacritty | `Cmd+M` | Minimize |
| `Cmd+H` | Hide Alacritty | `Cmd+Return` | Toggle fullscreen |
| `Cmd+K` | Clear buffer | `Cmd+L` | Clear screen |

### Text Operations

| Key | Action | Key | Action |
|-----|--------|-----|--------|
| `Cmd+C` | Copy selection | `Cmd+V` | Paste |
| `Cmd+A` | Select all | `Cmd+X` | Cut |
| `Cmd+F` | Search forward | `Cmd+Shift+B` | Search backward |

### Font Control

| Key | Action | Notes |
|-----|--------|-------|
| `Cmd+Plus` | Increase font size | Also `Cmd+=` |
| `Cmd+Minus` | Decrease font size | Also `Cmd+-` |
| `Cmd+0` | Reset font size | Back to config default |

### Scrolling

| Key | Action | Alternative |
|-----|--------|-------------|
| `Shift+PageUp` | Scroll up | Mouse wheel up |
| `Shift+PageDown` | Scroll down | Mouse wheel down |
| `Cmd+Home` | Scroll to top | - |
| `Cmd+End` | Scroll to bottom | - |

## Mouse Operations

### Selection Modes

| Action | Result | Modifier |
|--------|--------|----------|
| Click | Position cursor | - |
| Double-click | Select word | - |
| Triple-click | Select line | - |
| Quad-click | Select all | - |
| Click & drag | Select text | - |
| Right-click | Extend selection | - |

### Modifiers

| Combo | Effect |
|-------|--------|
| `Shift+Click` | Extend selection to click point |
| `Cmd+Click` | Open URL under cursor |
| `Option+Click` | Block selection mode |
| `Middle-click` | Paste selection (if configured) |

## Configuration

### File Structure (TOML)
```toml
# ~/.alacritty.toml
[general]
import = ["~/.config/alacritty/theme.toml"]
live_config_reload = true

[window]
dimensions = { columns = 120, lines = 40 }
padding = { x = 8, y = 8 }
opacity = 0.99
decorations = "full"

[font]
size = 18.0
builtin_box_drawing = true

[font.normal]
family = "Lilex Nerd Font"
style = "Regular"
```

### Font Configuration
```toml
[font]
size = 18.0
builtin_box_drawing = true  # Better box drawing

[font.normal]
family = "Lilex Nerd Font"
style = "Regular"

[font.bold]
family = "Lilex Nerd Font"
style = "Bold"

[font.italic]  
family = "Lilex Nerd Font"
style = "Italic"

[font.offset]
x = 0
y = 1    # Slight vertical adjustment

[font.glyph_offset]
x = 0
y = 0
```

## Theme Integration

### Automatic Theme Switching

```bash
# Dark mode: Dracula theme
# Light mode: Solarized Light theme

# Theme files location:
~/.config/alacritty/theme.toml  # Current theme (auto-generated)
~/.config/alacritty/themes/     # Theme collection
```

### Manual Theme Control
```bash
theme        # Auto-detect and switch
dark         # Force dark mode
light        # Force light mode
```

### Theme File Structure
```toml
# ~/.config/alacritty/theme.toml
[colors.primary]
background = "#282a36"  # Dracula background
foreground = "#f8f8f2"  # Dracula foreground

[colors.normal]
black   = "#000000"
red     = "#ff5555"
green   = "#50fa7b"
yellow  = "#f1fa8c"
blue    = "#bd93f9"
magenta = "#ff79c6"
cyan    = "#8be9fd"
white   = "#bfbfbf"

[colors.bright]
# Bright variants...
```

## Performance Tuning

### Optimized Settings
```toml
[scrolling]
history = 100000        # Massive scrollback for logs
multiplier = 3          # 3x faster scroll speed

[selection]
save_to_clipboard = true              # Auto-copy on select
semantic_escape_chars = ",│`|:\"' ()[]{}<>\t"

[cursor]
style = { shape = "Block", blinking = "On" }
vi_mode_style = { shape = "Block", blinking = "Off" }
blink_interval = 750    # Milliseconds
blink_timeout = 15      # Stop after 15 seconds

[bell]
animation = "EaseOutExpo"
duration = 100          # Brief visual bell  
color = "0x88c0d0"      # Nord-inspired blue
command = "None"        # No audio bell

[mouse]
hide_when_typing = true  # Clean typing experience
```

## Advanced Features

### Custom Key Bindings
```toml
# Core macOS shortcuts configured
[[keyboard.bindings]]
action = "SpawnNewInstance"
key = "N"
mods = "Command"

[[keyboard.bindings]]
action = "SearchForward"
key = "F"
mods = "Command"

[[keyboard.bindings]]
action = "SearchBackward"  
key = "B"
mods = "Command|Shift"

# Font size control
[[keyboard.bindings]]
action = "IncreaseFontSize"
key = "Plus"
mods = "Command"

# Mouse bindings
[[mouse.bindings]]
mouse = "Middle"
action = "PasteSelection"

[[mouse.bindings]]
mouse = "Right"
action = "ExpandSelection"
```

### Environment Variables
```toml
[env]
TERM = "alacritty"      # Better than xterm-256color
COLORTERM = "truecolor"
LANG = "en_US.UTF-8"
LC_ALL = "en_US.UTF-8"
LC_CTYPE = "en_US.UTF-8"
```

### Shell Integration
```toml
[shell]
program = "/bin/zsh"
args = ["--login"]      # Login shell for proper PATH
```

### Window Options
```toml
[window]
decorations = "full"              # Window decorations
dynamic_title = true              # Update window title
resize_increments = true          # Resize by cell
option_as_alt = "Both"           # macOS Alt key behavior
decorations_theme_variant = "None" # Follow system theme

[window.class]
instance = "Alacritty"
general = "Alacritty"
```

## 🐛 Debug Mode

### Enable Debug Logging
```toml
[debug]
render_timer = false      # Show FPS counter
persistent_logging = false
log_level = "Warn"       # Options: Trace, Debug, Info, Warn, Error
print_events = false     # Log all input events
```

### Debug Commands
```bash
# Check events
alacritty --print-events

# Validate config
alacritty --check-config

# Show config path
alacritty --show-config-path
```

## Changes in v0.13+

### Removed Features
- **Vi Mode**: Removed in v0.13.0+ (use tmux/screen for this)
- **Hints Mode**: URL hints removed (use Cmd+Click instead)
- **Search**: Built-in search removed (use tmux search)

### Migration Guide
```bash
# Old Vi mode users:
# Use tmux copy mode (C-a [) instead

# Old hints mode users:
# Cmd+Click on URLs to open

# Old search users:
# Use tmux search (C-a /) or terminal app search
```

## Platform-Specific

### macOS
```toml
[window]
decorations = "full"     # Or "transparent", "buttonless"
option_as_alt = "Both"   # Use Option as Alt

# For better font rendering
[font]
use_thin_strokes = true  # If you prefer thinner fonts
```

### Linux
```toml
[window]
decorations = "full"
gtk_theme_variant = "dark"  # Force GTK dark theme

# Wayland specific
[window]
decorations = "none"  # If using tiling WM
```

## Integration Tips

### With tmux
```bash
# Alacritty + tmux is the perfect combo
# Alacritty handles GPU rendering
# tmux handles sessions, splits, copy mode

# In ~/.tmux.conf:
set -g default-terminal "alacritty"
set -ga terminal-overrides ",alacritty:Tc"
```

### With Neovim
```vim
" In init.lua or init.vim
if $TERM == "alacritty"
  set termguicolors  " True color support
endif
```

### Shell Prompt
```bash
# Fast prompt rendering
# Alacritty works best with:
# - Starship
# - Powerlevel10k
# - Spaceship (current)
```

## Troubleshooting

### Common Issues

| Problem | Solution |
|---------|----------|
| Font not found | Install JetBrains Mono: `brew install --cask font-jetbrains-mono` |
| No ligatures | Use "JetBrains Mono" not "JetBrainsMono Nerd Font" for ligatures |
| Slow performance | Disable transparency: `opacity = 1.0` |
| Theme not updating | Run `theme` command to regenerate |
| Colors look wrong | Check `TERM=alacritty` is set |

### Config Validation
```bash
# Check for errors
alacritty --check-config

# Common fixes:
# - Use TOML format (YAML deprecated)
# - Check indentation
# - Validate key names
# - Ensure paths exist
```

### Performance Issues
```toml
# Reduce these for better performance:
[scrolling]
history = 10000  # Smaller buffer

[window]
opacity = 1.0    # No transparency

[font]
size = 16.0      # Smaller font
```

## Pro Tips

### Productivity Tips

1. Use with tmux - Alacritty for rendering, tmux for features
2. Large scrollback - Set history to 100k for logs
3. Semantic selection - Double-click respects word boundaries
4. URL clicking - Cmd+Click to open links
5. Live reload - Config changes apply instantly

### Workflow Integration

```bash
# Quick terminal from anywhere
# Add to macOS shortcuts: Cmd+Space -> "Alacritty"
# Or use Alfred/Raycast hotkey
```

### Best Practices

1. One window per project - Use tmux for splits
2. Consistent font size - Match your editor
3. Theme automation - Let it follow system
4. GPU monitoring - Check Activity Monitor if slow
5. Regular updates - `brew upgrade alacritty`

