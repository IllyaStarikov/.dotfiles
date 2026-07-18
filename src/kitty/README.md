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
```

Nerd Font icons via `symbol_map` ranges (ligatures from regular font + icons from Nerd Font).

### Appearance

```conf
window_padding_width 8
macos_option_as_alt yes
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

## Clipboard

- `Cmd+C` / `Cmd+V` copy and paste
- Mouse selections copy straight to the system clipboard
  (`copy_on_select clipboard` — parity with Alacritty's `save_to_clipboard`
  and WezTerm's default selection behavior)

## Integration

- Works with theme switcher
- Supports tmux integration
- Full Unicode and emoji
- Clickable URLs

## Performance

- 50,000 line scrollback
- Shared memory for images
- GPU-accelerated scrolling
- Minimal input lag

## Troubleshooting

**Ligatures not working**: Ensure font supports ligatures

**Slow performance**: Check GPU drivers, disable transparency

**Theme not updating**: Run `theme` command to sync
