# UI & Theme Configuration

Dynamic theme system synchronized with macOS appearance, supporting TokyoNight variants and 142 JetBrainsMono ligatures.

## Files

- `appearance.lua` - Display settings
- `theme.lua` - Dynamic theme switching
- `ligatures.lua` - Font ligature support

## Theme System

Automatically switches based on macOS appearance or manual selection:

```bash
theme          # Auto-detect from macOS
theme day      # Light theme
theme moon     # Dark (default)
theme night    # Dark variant
theme storm    # High contrast dark
```

## Visual Settings

- **Line numbers**: Relative + absolute current
- **Color column**: 100 characters
- **Cursor line**: Highlighted
- **Whitespace**: Visible tabs/trailing spaces
- **Font**: JetBrainsMono Nerd Font with ligatures

## Ligature Support

142 programming ligatures including:

- Arrows: `->` `=>` `<-` `<=>`
- Comparison: `==` `!=` `>=` `<=`
- Comments: `//` `/*` `*/`

Terminal must support ligatures (Alacritty, iTerm2, Kitty, WezTerm).

## Theme Files

Configuration reads from `~/.config/theme-switcher/current-theme.sh`:

```bash
export MACOS_THEME="tokyonight_day"
export MACOS_VARIANT="light"
```

## Troubleshooting

**Theme not matching system**: Run `theme` to force sync.

**Ligatures not showing**: Check terminal support and `conceallevel=0`.

**Comments too dark/light**: Theme includes automatic brightness adjustment.

## Performance

- Theme switch: < 500ms
- Config caching prevents repeated file reads
- Lazy colorscheme loading on first use
