# WezTerm Configuration Guide

WezTerm is a powerful, GPU-accelerated terminal emulator with excellent ligature support, tabs, splits, and extensive customization options. This configuration provides a seamless migration from Alacritty with significant enhancements.

## Key Features

### 🎯 Advantages over Alacritty
- **Full ligature support** for JetBrainsMono Nerd Font
- **Native tab support** with Cmd+T, Cmd+W, Cmd+1-9
- **Split panes** with Cmd+D (horizontal), Cmd+Shift+D (vertical)
- **Command palette** with Cmd+Shift+P
- **Clickable URLs** with Cmd+Click
- **Better performance** with WebGPU acceleration
- **Dynamic configuration** reload without restart

### 🎨 Theme Integration
All four TokyoNight variants are fully integrated:
- `theme day` - TokyoNight Day (light)
- `theme night` - TokyoNight Night (dark)
- `theme moon` - TokyoNight Moon (dark variant)
- `theme storm` - TokyoNight Storm (default dark)

## Installation

```bash
# Install WezTerm
brew install --cask wezterm

# Create symlinks (already done if you ran setup.sh)
~/.dotfiles/src/setup/symlinks.sh

# Launch WezTerm
wezterm
```

## Key Bindings

### Core macOS Shortcuts (Matching Alacritty)
| Key | Action |
|-----|--------|
| `Cmd+N` | New window |
| `Cmd+Q` | Quit application |
| `Cmd+Enter` | Toggle fullscreen |
| `Cmd+C` | Copy |
| `Cmd+V` | Paste |
| `Cmd+A` | Select all |
| `Cmd+H` | Hide application |
| `Cmd+M` | Minimize window |

### Font Control
| Key | Action |
|-----|--------|
| `Cmd++` / `Cmd+=` | Increase font size |
| `Cmd+-` | Decrease font size |
| `Cmd+0` | Reset font size |

### Search
| Key | Action |
|-----|--------|
| `Cmd+F` | Search forward |
| `Cmd+Shift+F` | Search backward (case insensitive) |

### Tab Management (NEW - Not in Alacritty!)
| Key | Action |
|-----|--------|
| `Cmd+T` | New tab |
| `Cmd+W` | Close tab |
| `Cmd+Shift+]` | Next tab |
| `Cmd+Shift+[` | Previous tab |
| `Cmd+1` to `Cmd+8` | Switch to tab 1-8 |
| `Cmd+9` | Switch to last tab |

### Split Panes (NEW - Powerful Feature!)
| Key | Action |
|-----|--------|
| `Cmd+D` | Split horizontally |
| `Cmd+Shift+D` | Split vertically |
| `Cmd+Shift+W` | Close current pane |
| `Cmd+Alt+←` | Navigate to left pane |
| `Cmd+Alt+→` | Navigate to right pane |
| `Cmd+Alt+↑` | Navigate to upper pane |
| `Cmd+Alt+↓` | Navigate to lower pane |

### Advanced Features
| Key | Action |
|-----|--------|
| `Cmd+K` | Clear terminal |
| `Cmd+Shift+P` | Command palette |
| `Cmd+Shift+L` | Show debug overlay |
| `Shift+Ctrl+Space` | Enter copy mode (VI mode) |

### tmux Integration
| Key | Action |
|-----|--------|
| `Cmd+Shift+]` | Next tmux window (Ctrl-A n) |
| `Cmd+Shift+[` | Previous tmux window (Ctrl-A p) |

## Copy Mode (VI Navigation)

Enter copy mode with `Shift+Ctrl+Space`, then use VI keybindings:

| Key | Action |
|-----|--------|
| `h/j/k/l` | Move cursor |
| `w/b` | Word forward/backward |
| `0/$` | Start/end of line |
| `g/G` | Top/bottom of scrollback |
| `v` | Visual selection |
| `V` | Line selection |
| `Ctrl+V` | Block selection |
| `y` | Copy and exit |
| `Escape` | Exit copy mode |
| `Ctrl+U/D` | Half page up/down |
| `Ctrl+B/F` | Full page up/down |

## Configuration Files

### Main Configuration
- **Location**: `~/.config/wezterm/wezterm.lua`
- **Source**: `~/.dotfiles/src/wezterm/wezterm.lua`

### Theme Files
- **Dynamic theme**: `~/.config/wezterm/theme.lua` (auto-generated)
- **Theme definitions**: `~/.dotfiles/src/wezterm/themes/`
  - `tokyonight_day.lua`
  - `tokyonight_night.lua`
  - `tokyonight_moon.lua`
  - `tokyonight_storm.lua`

## Features Comparison

| Feature | Alacritty | WezTerm |
|---------|-----------|---------|
| GPU Acceleration | ✅ OpenGL | ✅ WebGPU (better) |
| Ligatures | ❌ | ✅ Full support |
| Tabs | ❌ | ✅ Native |
| Split Panes | ❌ | ✅ Built-in |
| Command Palette | ❌ | ✅ Cmd+Shift+P |
| Clickable URLs | ❌ | ✅ Cmd+Click |
| Config Language | TOML | Lua (more powerful) |
| Hot Reload | ✅ | ✅ |
| Performance | Excellent | Excellent+ |
| Memory Usage | Low | Low-Medium |

## Advanced Features

### Status Bar
WezTerm displays useful information in the status bar:
- Current working directory
- Date and time
- Tab information

### Quick Select Mode
Press `Cmd+Shift+P` and type "Quick Select" to quickly select:
- URLs
- File paths
- Email addresses
- Git hashes
- IP addresses

### Hyperlink Detection
WezTerm automatically detects and makes clickable:
- HTTP/HTTPS URLs
- File paths
- Custom patterns defined in config

### Multiplexing
WezTerm has built-in multiplexing support (like tmux):
- Unix domain sockets for local multiplexing
- SSH domain support for remote sessions

## Customization

### Font Settings
The configuration uses JetBrainsMono Nerd Font with full ligature support:
```lua
config.font = wezterm.font_with_fallback {
  {
    family = 'JetBrainsMono Nerd Font',
    harfbuzz_features = { 'calt=1', 'clig=1', 'liga=1' },
  },
}
```

### Theme Switching
Themes automatically switch with the system:
```bash
# Manual switching
theme day    # Light theme
theme night  # Dark theme
theme moon   # Dark variant
theme storm  # Default dark

# Auto-detect from macOS
theme
```

### Window Appearance
- Clean modern look with `RESIZE` decorations
- 8px padding on all sides
- 120x40 default size
- Native macOS fullscreen support

## Troubleshooting

### Ligatures Not Showing
- Ensure you have JetBrainsMono Nerd Font installed
- Check that you're not using the "Mono" variant
- Restart WezTerm after font changes

### Theme Not Switching
- Run `~/.dotfiles/src/setup/symlinks.sh` to ensure links are correct
- Check `~/.config/wezterm/theme.lua` exists
- Manually run `theme <variant>` to test

### Performance Issues
- WezTerm uses WebGPU by default (best performance)
- Check GPU acceleration: `Cmd+Shift+L` (debug overlay)
- Reduce scrollback if needed (default: 10000 lines)

## Tips and Tricks

1. **Use tabs instead of tmux windows** for better integration
2. **Command palette** (`Cmd+Shift+P`) is incredibly powerful
3. **Split panes** work great with Neovim for side-by-side editing
4. **Copy mode** is more powerful than Alacritty's selection mode
5. **Clickable URLs** save time - just Cmd+Click any URL
6. **Tab titles** can be renamed for better organization
7. **Status bar** shows useful context without cluttering the terminal

## Migration from Alacritty

Your muscle memory is preserved:
- All Alacritty keybindings work the same
- Font and colors are identical
- Window behavior matches
- tmux integration unchanged

New features to explore:
- Try tabs with `Cmd+T`
- Split panes with `Cmd+D`
- Command palette with `Cmd+Shift+P`
- Click URLs with `Cmd+Click`

## Resources

- [WezTerm Documentation](https://wezfurlong.org/wezterm/)
- [Configuration Reference](https://wezfurlong.org/wezterm/config/files.html)
- [Lua API](https://wezfurlong.org/wezterm/config/lua/wezterm/index.html)
- [GitHub Repository](https://github.com/wez/wezterm)