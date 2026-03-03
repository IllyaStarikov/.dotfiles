# WezTerm Configuration

GPU-accelerated terminal emulator with Lua configuration and built-in multiplexing.

## Features

- **GPU rendering** - WebGpu (Metal) acceleration at 120 FPS
- **Multiplexing** - Built-in splits and tabs
- **Ligatures** - Full JetBrainsMono programming font support (142 ligatures)
- **Dynamic config** - Hot-reload Lua configuration with theme file watching
- **Image support** - Inline image protocol

## Files

```
wezterm.lua           # Main configuration
wezterm-minimal.lua   # Fallback config for debugging (Software renderer, no plugins)
```

## Configuration

### Font & Appearance

```lua
config.font = wezterm.font_with_fallback({
  { family = "JetBrainsMono Nerd Font", weight = "Regular" },
  "JetBrains Mono",
  "Symbols Nerd Font Mono",
  -- ... math/unicode fallbacks
})
config.font_size = 18.0
config.window_padding = { left = 8, right = 8, top = 8, bottom = 8 }
```

### Theme

Auto-loads from `~/.config/wezterm/theme.lua` (copied by `switch-theme.sh`).
Falls back to built-in `tokyonight_storm` if theme file is missing or broken.
Synced with system theme switcher.

## Key Bindings

| Key               | Action             |
| ------------------ | ------------------ |
| `Cmd+T`            | New tab            |
| `Cmd+N`            | New window         |
| `Cmd+D`            | Split pane right   |
| `Cmd+Shift+D`      | Split pane down    |
| `Cmd+X`            | Close pane         |
| `Cmd+[/]`          | Previous/Next tab  |
| `Cmd+Alt+H/J/K/L`  | Navigate panes     |
| `Cmd+Shift+H/J/K/L`| Resize panes       |
| `Cmd+K`            | Clear terminal     |
| `Cmd+Shift+S`      | Quick Select       |
| `Cmd+Shift+P`      | Command palette    |
| `Cmd+E`            | Tab navigator      |

## Performance

- WebGpu (Metal) front end at 120 FPS
- 50,000 line scrollback
- Efficient Rust core
- Low latency input

## Integration

- Works with theme switcher (`switch-theme.sh`)
- tmux pass-through keybindings (`Cmd+Shift+[/]`)
- URL highlighting with `Cmd+Click`
- Quick Select for git hashes, IPs, file paths

## Troubleshooting

**Config errors**: Check with `wezterm --config-file wezterm-minimal.lua`

**Performance issues**: Minimal config uses Software renderer for debugging

**Theme not updating**: Ensure `~/.config/wezterm/theme.lua` exists (run `theme` command)
