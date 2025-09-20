# Kitty Terminal Configuration

GPU-accelerated terminal emulator with ligatures and image support.

## Features

- **GPU rendering** - OpenGL acceleration
- **Ligatures** - Full programming font support
- **Images** - Native image protocol
- **Fast** - Threaded rendering, low latency
- **Tabs** - Multiple sessions and layouts

## Configuration

### Font

```conf
font_family JetBrains Mono
font_size 18.0
disable_ligatures never
```

### Appearance

```conf
background_opacity 0.95
window_padding_width 10
macos_titlebar_color background
```

### Theme

Synced with system via `~/.config/kitty/theme.conf`

## Key Bindings

| Key              | Action            |
| ---------------- | ----------------- |
| `Cmd+T`          | New tab           |
| `Cmd+N`          | New window        |
| `Cmd+D`          | Split vertical    |
| `Cmd+Shift+D`    | Split horizontal  |
| `Cmd+[/]`        | Previous/Next tab |
| `Cmd+Plus/Minus` | Font size         |

## Integration

- Works with theme switcher
- Supports tmux integration
- Full Unicode and emoji
- Clickable URLs

## Performance

- 10,000 line scrollback
- Shared memory for images
- GPU-accelerated scrolling
- Minimal input lag

## Troubleshooting

**Ligatures not working**: Ensure font supports ligatures

**Slow performance**: Check GPU drivers, disable transparency

**Theme not updating**: Run `theme` command to sync
