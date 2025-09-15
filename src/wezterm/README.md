# WezTerm Configuration

GPU-accelerated terminal emulator with Lua configuration and built-in multiplexing.

## Features
- **GPU rendering** - Metal/DirectX/OpenGL acceleration
- **Multiplexing** - Built-in splits and tabs
- **Ligatures** - Full programming font support
- **Dynamic config** - Hot-reload Lua configuration
- **Image support** - Inline image protocol

## Files
```
wezterm.lua           # Main configuration
wezterm-minimal.lua   # Fallback config
theme.lua            # Dynamic theme loader
themes/              # TokyoNight variants
```

## Configuration

### Font & Appearance
```lua
config.font = wezterm.font("MesloLGS Nerd Font Mono")
config.font_size = 13.0
config.window_background_opacity = 0.95
config.window_padding = { left = 10, right = 10 }
```

### Theme
Auto-loads from `~/.config/wezterm/theme.lua`
Synced with system theme switcher

## Key Bindings

| Key | Action |
|-----|--------|
| `Cmd+T` | New tab |
| `Cmd+N` | New window |
| `Cmd+D` | Split pane right |
| `Cmd+Shift+D` | Split pane down |
| `Cmd+[/]` | Previous/Next tab |
| `Cmd+H/J/K/L` | Navigate panes |

## Performance
- Hardware acceleration
- Efficient Rust core
- Smart rendering
- Low latency input

## Integration
- Works with theme switcher
- tmux-like keybindings
- SSH multiplexing
- URL highlighting

## Troubleshooting

**Config errors**: Check with `wezterm --config-file wezterm-minimal.lua`

**Performance issues**: Disable transparency, check GPU drivers

**Theme not updating**: Ensure theme.lua exists at `~/.config/wezterm/`