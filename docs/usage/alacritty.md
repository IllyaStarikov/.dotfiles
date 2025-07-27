# Alacritty Reference

## Daily Commands
```
WINDOW                TEXT                   NAVIGATION
Cmd+N    New          Cmd+C    Copy         Cmd+F    Search
Cmd+W    Close        Cmd+V    Paste        Cmd+A    Select all
Cmd+Q    Quit         Cmd+X    Cut          Cmd+K    Clear
Cmd+M    Minimize     Cmd++    Font+        Cmd+0    Reset font
Cmd+H    Hide         Cmd+-    Font-        Cmd+Return Fullscreen

VI MODE              MOUSE                   ZOOM
Cmd+Shift+Space Toggle  Click     Select      Cmd++    Increase
v        Visual        Dbl-click Word        Cmd+-    Decrease
y        Copy          Tri-click Line        Cmd+0    Reset
p        Paste         Mid-click Paste       Cmd+Scroll Zoom
```

## Keyboard Shortcuts

### macOS
| Key | Action | Key | Action |
|-----|--------|-----|--------|
| `Cmd+N` | New window | `Cmd+W` | Close |
| `Cmd+T` | New tab | `Cmd+Q` | Quit |
| `Cmd+M` | Minimize | `Cmd+H` | Hide |
| `Cmd+C` | Copy | `Cmd+V` | Paste |
| `Cmd+A` | Select all | `Cmd+X` | Cut |
| `Cmd+Plus` | Font + | `Cmd+Minus` | Font - |
| `Cmd+0` | Font reset | `Cmd+F` | Search |
| `Cmd+K` | Clear buffer | `Cmd+L` | Clear screen |
| `Cmd+Shift+B` | Search backward | `Cmd+Return` | Toggle fullscreen |

### Linux/Windows
| Key | Action | Key | Action |
|-----|--------|-----|--------|
| `Ctrl+Shift+N` | New | `Ctrl+Shift+Q` | Quit |
| `Ctrl+Shift+C` | Copy | `Ctrl+Shift+V` | Paste |
| `Ctrl+Plus` | Font + | `Ctrl+Minus` | Font - |
| `Ctrl+0` | Font reset | `Ctrl+Shift+F` | Search |

### Vi Mode
| Key | Action | Key | Action |
|-----|--------|-----|--------|
| `Cmd+Shift+Space` | Toggle | `v` | Visual |
| `V` | Line select | `Ctrl+v` | Block |
| `y` | Yank | `p` | Paste |
| `/` | Search → | `?` | Search ← |

## Mouse Operations

| Action | Result | Modifier | Effect |
|--------|--------|----------|--------|
| Click | Cursor | Shift+Click | Extend |
| Double-click | Word | Alt+Drag | Block |
| Triple-click | Line | Cmd+Click | Expand selection |
| Quad-click | All | Cmd+Scroll | Zoom |
| Middle-click | Paste selection | Right-click | Expand selection |

## Configuration

### Basic (alacritty.toml)
```toml
import = ["~/.config/alacritty/theme.toml"]
live_config_reload = true

[shell]
program = "/bin/zsh"
args = ["--login"]

[env]
TERM = "xterm-256color"
```

### Window
```toml
[window]
dimensions = { columns = 120, lines = 40 }
padding = { x = 8, y = 8 }
decorations = "Full"  # Full, None, Transparent, Buttonless
opacity = 0.95
```

### Font
```toml
[font]
size = 18.0

[font.normal]
family = "JetBrainsMono Nerd Font"
style = "Regular"

[font.bold]
style = "Bold"

[font.italic]
style = "Italic"
```

### Colors
```toml
[colors.primary]
background = "#282a36"
foreground = "#f8f8f2"

[colors.normal]
black   = "#000000"
red     = "#ff5555"
green   = "#50fa7b"
yellow  = "#f1fa8c"
blue    = "#bd93f9"
magenta = "#ff79c6"
cyan    = "#8be9fd"
white   = "#bfbfbf"
```

## Key Bindings

```toml
[[keyboard.bindings]]
key = "V"
mods = "Command"
action = "Paste"

[[keyboard.bindings]]
key = "Return"
mods = "Command"
action = "ToggleFullscreen"

[[keyboard.bindings]]
key = "Space"
mods = "Shift|Control"
action = "ToggleViMode"
```

## Actions

| Category | Actions |
|----------|---------|
| **Clipboard** | Paste, Copy, ClearSelection |
| **Navigation** | ScrollToTop, ScrollToBottom, ScrollPageUp/Down |
| **Window** | CreateNewWindow, ToggleFullscreen, Minimize, Quit |
| **Font** | IncreaseFontSize, DecreaseFontSize, ResetFontSize |
| **Vi Mode** | ToggleViMode, ClearSelection |
| **Search** | SearchForward, SearchBackward, SearchConfirm |

## Performance

| Setting | Value | Purpose |
|---------|-------|---------|
| `draw_bold_text_with_bright_colors` | true | Bold = bright |
| `save_to_clipboard` | true | Auto copy |
| `history` | 100000 | Scrollback |
| `multiplier` | 3 | Scroll speed |

## Platform-Specific

### macOS
```toml
[window]
decorations = "Buttonless"
option_as_alt = "Both"

[font]
use_thin_strokes = true
```

### Linux
```toml
[window]
gtk_theme_variant = "dark"
class = { instance = "Alacritty", general = "Alacritty" }
```

### Windows
```toml
[shell]
program = "powershell"
# or
program = "cmd"
```

## Troubleshooting

| Issue | Fix |
|-------|-----|
| Font missing | `brew install --cask font-jetbrains-mono-nerd-font` |
| No colors | `export TERM=xterm-256color` |
| Slow | Reduce `history`, disable `opacity` |
| Theme not updating | Check import paths, `touch alacritty.toml` |
| Copy not working | `save_to_clipboard = true` |

## Tips

- Config auto-reloads on save
- Use TOML format (YAML deprecated)
- `alacritty migrate` converts old configs
- `alacritty --print-events` for debugging
- Theme files in `~/.config/alacritty/themes/`