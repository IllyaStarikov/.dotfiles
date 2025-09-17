# /src/theme-switcher/themes - Theme Configuration Variants

## What's in this directory

This directory contains the four TokyoNight theme variants with pre-generated configuration files for each application. Each theme provides a complete, coordinated color scheme across terminal, tmux, editor, and shell prompt.

### Theme Variants:

```
themes/
├── tokyonight_day/     # Light theme for daytime
│   ├── alacritty.toml  # Terminal colors
│   ├── kitty.conf      # Kitty terminal colors
│   ├── starship.toml   # Shell prompt theme
│   └── tmux.conf       # Tmux status bar colors
├── tokyonight_moon/    # Soft dark theme (default dark)
├── tokyonight_night/   # Standard dark theme
└── tokyonight_storm/   # High contrast dark theme
```

### How to use:

```bash
# Themes are applied automatically by switch-theme.sh
theme           # Auto-detect based on macOS appearance
theme day       # Force light theme
theme night     # Force dark night variant
theme moon      # Force dark moon variant (default)
theme storm     # Force dark storm variant

# Manual application (not recommended)
cp themes/tokyonight_day/alacritty.toml ~/.config/alacritty/theme.toml
```

## Why this directory exists

Pre-generated theme files enable atomic, instant theme switching across all applications. Rather than dynamically generating colors (slow, error-prone), we store validated, tested configurations that can be copied instantly.

### Benefits of pre-generated themes:

- **Atomic updates** - All apps switch simultaneously
- **No computation** - Simple file copy, < 50ms
- **Offline capable** - No network or tools needed
- **Version controlled** - Track color changes
- **Validated colors** - Tested for readability

## Theme Specifications

### TokyoNight Day (Light)

```toml
# Optimized for bright environments
[colors.primary]
background = '#e1e2e7'  # Light gray background
foreground = '#3760bf'  # Dark blue text

# High contrast for readability
[colors.normal]
black = '#b4b5b9'       # Softer than pure black
blue = '#2e7de9'        # Vibrant but not harsh
```

**Use cases:**

- Bright office lighting
- Outdoor coding
- Reducing eye strain in daylight
- Presentations and screensharing

### TokyoNight Moon (Dark - Default)

```toml
# Balanced dark theme
[colors.primary]
background = '#222436'  # Deep blue-gray
foreground = '#c8d3f5'  # Soft blue-white

# Muted colors for long sessions
[colors.normal]
blue = '#82aaff'        # Soft blue
green = '#c3e88d'       # Gentle green
```

**Use cases:**

- Evening coding sessions
- Moderate ambient lighting
- Extended coding periods
- Default dark preference

### TokyoNight Night (Dark - Standard)

```toml
# Traditional dark theme
[colors.primary]
background = '#1a1b26'  # Deep navy
foreground = '#c0caf5'  # Light purple-white

# Classic terminal colors
[colors.normal]
blue = '#7aa2f7'        # Classic blue
green = '#9ece6a'       # Terminal green
```

**Use cases:**

- Traditional terminal aesthetic
- Low light environments
- Classic dark theme preference

### TokyoNight Storm (Dark - High Contrast)

```toml
# Maximum contrast dark theme
[colors.primary]
background = '#24283b'  # Lighter dark
foreground = '#c0caf5'  # Bright text

# Enhanced visibility
[colors.normal]
blue = '#7aa2f7'        # Brighter blue
red = '#f7768e'         # More vivid red
```

**Use cases:**

- Poor quality displays
- Accessibility needs
- Quick code reviews
- High ambient light with dark preference

## Application Configurations

### Alacritty (`alacritty.toml`)

```toml
# Terminal emulator colors
[colors.primary]     # Main background/foreground
[colors.normal]      # 16 base colors
[colors.bright]      # Bright variants
[colors.indexed]     # 256 color palette
```

### Tmux (`tmux.conf`)

```bash
# Status bar and pane borders
set -g status-style "bg=#color,fg=#color"
set -g pane-border-style "fg=#color"
set -g message-style "bg=#color,fg=#color"
```

### Starship (`starship.toml`)

```toml
# Shell prompt colors
[palettes.colors]
background = '#color'
foreground = '#color'
cyan = '#color'
green = '#color'
```

### Kitty (`kitty.conf`)

```conf
# Kitty terminal colors
foreground #color
background #color
color0 #black
color1 #red
# ... all 16 colors
```

## Lessons Learned

### What NOT to Do

#### ❌ Don't generate colors dynamically

**Problem**: Lua script took 200ms per theme switch
**Solution**: Pre-generate all configs

```bash
# BAD: Generate on switch
lua generate_colors.lua "$theme" > ~/.config/alacritty/theme.toml

# GOOD: Copy pre-generated
cp "themes/$theme/alacritty.toml" ~/.config/alacritty/theme.toml
```

#### ❌ Don't use symbolic links for themes

**Problem**: Some apps don't follow symlinks, cache issues
**Solution**: Copy actual files

```bash
# BAD: Symlink to theme
ln -sf "themes/$theme/tmux.conf" ~/.config/tmux/theme.conf

# GOOD: Copy file
cp "themes/$theme/tmux.conf" ~/.config/tmux/theme.conf
```

#### ❌ Don't forget color accessibility

**Problem**: Low contrast colors hard to read
**Solution**: Test contrast ratios

```bash
# Minimum WCAG AA compliance
# Normal text: 4.5:1 contrast ratio
# Large text: 3:1 contrast ratio
```

#### ❌ Don't mix color formats

**Problem**: RGB vs Hex caused inconsistencies
**Solution**: Use hex everywhere

```toml
# BAD: Mixed formats
color = "rgb(46, 125, 233)"
other = "#2e7de9"

# GOOD: Consistent hex
color = "#2e7de9"
other = "#2e7de9"
```

### Theme Development Issues

1. **Alacritty caching** - Force reload with Cmd+Q and restart
2. **Tmux not updating** - Need `tmux source-file` after copy
3. **Color bleeding** - Terminal app overrides some colors
4. **Starship caching** - Clear with `starship cache clear`

### Failed Approaches

- **HSL color generation** - Colors looked different across apps
- **Base16 themes** - Limited to 16 colors, not enough
- **Dynamic tinting** - Inconsistent results across terminals
- **Solarized base** - Users found it too low contrast

### Color Psychology Insights

```yaml
Day (Light):
  - Blue foreground: Maintains focus
  - Gray background: Reduces glare
  - Muted colors: Prevent distraction

Moon (Soft Dark):
  - Blue tint: Calming for long sessions
  - Soft contrast: Reduces eye fatigue
  - Warm accents: Comfortable feel

Night (Standard):
  - Navy background: Classic terminal
  - Purple tint: Modern aesthetic
  - Balanced colors: Familiar comfort

Storm (High Contrast):
  - Lighter background: More contrast
  - Vivid colors: Quick scanning
  - Sharp edges: Maximum clarity
```

## Creating New Themes

To add a new theme variant:

1. **Create theme directory**

   ```bash
   mkdir themes/new_theme
   ```

2. **Generate color files**

   ```bash
   # Create configs for each app
   touch themes/new_theme/{alacritty.toml,tmux.conf,starship.toml,kitty.conf}
   ```

3. **Define color palette**

   ```toml
   # Base colors needed:
   background, foreground
   black, red, green, yellow
   blue, magenta, cyan, white
   # Plus bright variants
   ```

4. **Test readability**

   ```bash
   # Apply theme and verify
   ./switch-theme.sh new_theme
   # Check all text is readable
   ```

5. **Update switch script**
   ```bash
   # Add to switch-theme.sh
   "new_theme") copy_theme_files "new_theme" ;;
   ```

## Theme File Validation

### Verify colors are correct:

```bash
# Check all colors are valid hex
grep -E '#[0-9a-fA-F]{6}' themes/*/alacritty.toml

# Ensure no missing colors
for theme in themes/*/; do
    echo "Checking $theme"
    grep -c "color[0-9]" "$theme/kitty.conf"  # Should be 16
done
```

### Test theme switching:

```bash
# Time theme switch
time theme day
# Should be < 500ms

# Verify files copied
diff themes/tokyonight_day/alacritty.toml ~/.config/alacritty/theme.toml
```

## Related Documentation

- [Theme Switcher](../README.md) - Main switching logic
- [Switch Script](../switch-theme.sh) - Implementation
- [UI Config](../../neovim/config/ui/README.md) - Neovim integration
- [TokyoNight Upstream](https://github.com/folke/tokyonight.nvim)
