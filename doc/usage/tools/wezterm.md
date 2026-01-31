# WezTerm Reference

> **GPU-accelerated terminal emulator with Lua configuration**

## Quick Start

```bash
# Launch WezTerm
wezterm

# With specific config
wezterm --config-file ~/.config/wezterm/wezterm.lua

# Start new instance
wezterm start

# Connect to existing
wezterm connect unix
```

## Features

- **GPU rendering** - Metal/DirectX/OpenGL acceleration
- **Multiplexing** - Built-in splits and tabs (no tmux needed)
- **Ligatures** - Full programming font support
- **Dynamic config** - Hot-reload Lua configuration
- **Image support** - Inline image protocol
- **SSH integration** - Built-in SSH client with multiplexing

## Configuration

### File Location

```
~/.config/wezterm/
├── wezterm.lua           # Main configuration
├── wezterm-minimal.lua   # Fallback config
├── theme.lua             # Dynamic theme loader
└── themes/               # TokyoNight variants
    ├── tokyonight-moon.lua
    ├── tokyonight-night.lua
    ├── tokyonight-storm.lua
    └── tokyonight-day.lua
```

### Key Settings

```lua
local config = wezterm.config_builder()

-- Font configuration
config.font = wezterm.font("MesloLGS Nerd Font Mono")
config.font_size = 13.0

-- Window settings
config.window_background_opacity = 0.95
config.window_decorations = "RESIZE"
config.window_padding = {
  left = 10,
  right = 10,
  top = 10,
  bottom = 10,
}

-- Tab bar
config.hide_tab_bar_if_only_one_tab = true
config.tab_bar_at_bottom = false

-- Colors
config.color_scheme = "tokyonight_moon"

return config
```

## Keyboard Shortcuts

### Window Management

| Key           | Action            |
| ------------- | ----------------- |
| `Cmd+N`       | New window        |
| `Cmd+W`       | Close pane        |
| `Cmd+Shift+W` | Close window      |
| `Cmd+Return`  | Toggle fullscreen |
| `Cmd+M`       | Minimize          |

### Tab Management

| Key           | Action             |
| ------------- | ------------------ |
| `Cmd+T`       | New tab            |
| `Cmd+[`       | Previous tab       |
| `Cmd+]`       | Next tab           |
| `Cmd+1-9`     | Go to tab 1-9      |
| `Cmd+Shift+T` | Show tab navigator |

### Pane Management

| Key           | Action         |
| ------------- | -------------- |
| `Cmd+D`       | Split right    |
| `Cmd+Shift+D` | Split down     |
| `Cmd+H`       | Navigate left  |
| `Cmd+J`       | Navigate down  |
| `Cmd+K`       | Navigate up    |
| `Cmd+L`       | Navigate right |

### Text Operations

| Key     | Action       |
| ------- | ------------ |
| `Cmd+C` | Copy         |
| `Cmd+V` | Paste        |
| `Cmd+F` | Search       |
| `Cmd+K` | Clear screen |

### Font Size

| Key         | Action        |
| ----------- | ------------- |
| `Cmd+Plus`  | Increase font |
| `Cmd+Minus` | Decrease font |
| `Cmd+0`     | Reset font    |

## Custom Keybindings

### Configuration Format

```lua
config.keys = {
  -- Split panes
  {
    key = "d",
    mods = "CMD",
    action = wezterm.action.SplitHorizontal { domain = "CurrentPaneDomain" },
  },
  {
    key = "d",
    mods = "CMD|SHIFT",
    action = wezterm.action.SplitVertical { domain = "CurrentPaneDomain" },
  },

  -- Navigate panes (vim-style)
  {
    key = "h",
    mods = "CMD",
    action = wezterm.action.ActivatePaneDirection("Left"),
  },
  {
    key = "l",
    mods = "CMD",
    action = wezterm.action.ActivatePaneDirection("Right"),
  },

  -- Quick commands
  {
    key = "g",
    mods = "CMD",
    action = wezterm.action.SendString("lazygit\n"),
  },
}
```

## Multiplexing

WezTerm has built-in multiplexing, making tmux optional:

### Pane Operations

```lua
-- Split current pane
wezterm.action.SplitHorizontal { domain = "CurrentPaneDomain" }
wezterm.action.SplitVertical { domain = "CurrentPaneDomain" }

-- Navigate between panes
wezterm.action.ActivatePaneDirection("Left")
wezterm.action.ActivatePaneDirection("Right")
wezterm.action.ActivatePaneDirection("Up")
wezterm.action.ActivatePaneDirection("Down")

-- Resize panes
wezterm.action.AdjustPaneSize { "Left", 5 }
wezterm.action.AdjustPaneSize { "Right", 5 }
```

### Workspace Management

```lua
-- Create named workspace
wezterm.action.SwitchToWorkspace { name = "coding" }

-- Switch workspaces
wezterm.action.SwitchWorkspaceRelative(1)
wezterm.action.SwitchWorkspaceRelative(-1)
```

## Theme Integration

### Automatic Theme Switching

Our setup syncs with macOS appearance:

```lua
-- In wezterm.lua
local theme = require("theme")
config.colors = theme.colors
```

```bash
# Manual theme switch
theme         # Auto-detect
theme dark    # Force dark
theme light   # Force light
```

### Custom Colors

```lua
config.colors = {
  foreground = "#c0caf5",
  background = "#1a1b26",
  cursor_bg = "#c0caf5",
  cursor_fg = "#1a1b26",

  ansi = {
    "#15161e", "#f7768e", "#9ece6a", "#e0af68",
    "#7aa2f7", "#bb9af7", "#7dcfff", "#a9b1d6",
  },
  bright = {
    "#414868", "#f7768e", "#9ece6a", "#e0af68",
    "#7aa2f7", "#bb9af7", "#7dcfff", "#c0caf5",
  },
}
```

## Performance

### GPU Acceleration

WezTerm uses GPU by default:

- Metal on macOS
- DirectX on Windows
- OpenGL on Linux

### Optimizations

```lua
-- Reduce animations for speed
config.animation_fps = 1
config.cursor_blink_rate = 0

-- Limit scrollback for memory
config.scrollback_lines = 10000

-- Disable unused features
config.enable_scroll_bar = false
```

## SSH Integration

### Built-in SSH Client

```lua
-- SSH domains
config.ssh_domains = {
  {
    name = "server",
    remote_address = "user@server.com",
    username = "user",
  },
}
```

```bash
# Connect via WezTerm
wezterm connect server
```

## Troubleshooting

### Common Issues

| Issue              | Solution                                        |
| ------------------ | ----------------------------------------------- |
| Config errors      | Use `wezterm --config-file wezterm-minimal.lua` |
| Font not rendering | Install Nerd Font variant                       |
| Slow performance   | Disable transparency, check GPU                 |
| Theme not updating | Ensure theme.lua exists                         |

### Debug Mode

```bash
# Check configuration
wezterm show-keys

# Verbose logging
WEZTERM_LOG=debug wezterm

# Test configuration
wezterm --config-file ~/.config/wezterm/wezterm.lua
```

### Reset Configuration

```bash
# Backup current config
mv ~/.config/wezterm ~/.config/wezterm.bak

# Use minimal config
cp ~/.dotfiles/src/wezterm/wezterm-minimal.lua ~/.config/wezterm/wezterm.lua
```

## Quick Reference

```bash
# Launch
wezterm              # Default
wezterm start        # New instance
wezterm connect      # Attach to running

# Shortcuts
Cmd+T      New tab
Cmd+D      Split right
Cmd+Shift+D Split down
Cmd+H/J/K/L Navigate panes
Cmd+[/]    Prev/Next tab
Cmd+K      Clear
Cmd+F      Search
Cmd++/-    Font size
```

---

<p align="center">
  <a href="../README.md">← Back to Tools</a>
</p>
