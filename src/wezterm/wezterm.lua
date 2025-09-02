-- ════════════════════════════════════════════════════════════════════════════════════════════════════════════
-- 🚀 WEZTERM CONFIGURATION - Production-Ready Terminal Emulator
-- ════════════════════════════════════════════════════════════════════════════════════════════════════════════
-- Matching Alacritty configuration with WezTerm's advanced features
-- Optimized for speed, modern workflows, and seamless integration with Neovim, tmux, and Zsh
-- ════════════════════════════════════════════════════════════════════════════════════════════════════════════

local wezterm = require 'wezterm'
local config = wezterm.config_builder()

-- ────────────────────────────────────────────────────────────────────────────────────────────────────────────
-- 🖋️ FONT CONFIGURATION - JetBrainsMono with full ligature and variant support
-- ────────────────────────────────────────────────────────────────────────────────────────────────────────────

-- Primary font with extensive fallbacks for math and Unicode coverage
config.font = wezterm.font_with_fallback({
  {
    family = 'JetBrainsMono Nerd Font',
    weight = 'Regular',
    stretch = 'Normal',
    style = 'Normal',
  },
  'JetBrains Mono',  -- Fallback to non-Nerd Font version
  'Symbols Nerd Font Mono',  -- Extra symbol coverage
  'DejaVu Sans Mono',  -- Excellent math symbol coverage
  'Cambria Math',  -- Windows math font (if available)
  'STIX Two Math',  -- Professional math font
  'Latin Modern Math',  -- LaTeX-style math font
  'Noto Sans Math',  -- Google's math font
  'Noto Sans Symbols',  -- Additional symbols
  'Noto Sans Symbols 2',  -- More symbols
  'Apple Symbols',  -- macOS system symbols
  'Apple Color Emoji',  -- Emoji support
})

config.font_size = 18.0  -- Matching Alacritty
config.line_height = 1.0
config.cell_width = 1.0

-- Comprehensive font rules for all text styles
config.font_rules = {
  -- Regular text (base style) with math fallbacks
  {
    intensity = 'Normal',
    italic = false,
    font = wezterm.font_with_fallback({
      { family = 'JetBrainsMono Nerd Font', weight = 'Regular' },
      'JetBrains Mono',
      'DejaVu Sans Mono',
      'STIX Two Math',
      'Noto Sans Math',
      'Apple Symbols',
    }),
  },
  
  -- Bold text
  {
    intensity = 'Bold',
    italic = false,
    font = wezterm.font_with_fallback({
      { family = 'JetBrainsMono Nerd Font', weight = 'Bold' },
      'JetBrains Mono',
    }),
  },
  
  -- Italic text
  {
    intensity = 'Normal',
    italic = true,
    font = wezterm.font_with_fallback({
      { family = 'JetBrainsMono Nerd Font', style = 'Italic' },
      'JetBrains Mono',
    }),
  },
  
  -- Bold italic text
  {
    intensity = 'Bold',
    italic = true,
    font = wezterm.font_with_fallback({
      { family = 'JetBrainsMono Nerd Font', weight = 'Bold', style = 'Italic' },
      'JetBrains Mono',
    }),
  },
  
  -- Half-bright/dim text (often used in terminal apps)
  {
    intensity = 'Half',
    italic = false,
    font = wezterm.font_with_fallback({
      { family = 'JetBrainsMono Nerd Font', weight = 'Light' },
      'JetBrains Mono',
    }),
  },
  
  -- Half-bright italic
  {
    intensity = 'Half',
    italic = true,
    font = wezterm.font_with_fallback({
      { family = 'JetBrainsMono Nerd Font', weight = 'Light', style = 'Italic' },
      'JetBrains Mono',
    }),
  },
}

-- Enable ALL ligature features for JetBrainsMono
-- JetBrainsMono supports 142 code ligatures
config.harfbuzz_features = {
  'calt=1',  -- Contextual alternates (main ligature feature)
  'clig=1',  -- Contextual ligatures
  'liga=1',  -- Standard ligatures
  'dlig=1',  -- Discretionary ligatures
  'ss01=1',  -- Stylistic set 01 (alternative style)
  'ss02=1',  -- Stylistic set 02 (alternative style)
  'ss03=1',  -- Stylistic set 03 (alternative style)
  'ss04=1',  -- Stylistic set 04 (alternative style)
  'ss05=1',  -- Stylistic set 05 (alternative style)
  'ss06=1',  -- Stylistic set 06 (alternative style)
  'ss07=1',  -- Stylistic set 07 (alternative style)
  'ss19=1',  -- Stylistic set 19 (slashed zero)
  'ss20=1',  -- Stylistic set 20 (graphical control characters)
  'zero=1',  -- Slashed zero
  'onum=1',  -- Oldstyle numbers
}

-- Additional font configuration for better math rendering
config.allow_square_glyphs_to_overflow_width = 'Always'  -- Better for math symbols
config.custom_block_glyphs = true  -- Better box drawing characters
config.anti_alias_custom_block_glyphs = true
config.treat_east_asian_ambiguous_width_as_wide = false
config.unicode_version = 15  -- Use latest Unicode standard
config.warn_about_missing_glyphs = false  -- Don't warn about missing math glyphs

-- ────────────────────────────────────────────────────────────────────────────────────────────────────────────
-- 🎨 COLOR SCHEME - Dynamic TokyoNight theme loading with error handling
-- ────────────────────────────────────────────────────────────────────────────────────────────────────────────

-- Load the dynamic theme configuration with better error handling
local function load_theme_safe()
  local home = os.getenv("HOME")
  local theme_path = home .. "/.config/wezterm/theme.lua"
  
  -- Use pcall to safely load the theme
  local theme_ok, theme_result = pcall(function()
    local f = loadfile(theme_path)
    if f then
      return f()
    end
    return nil
  end)
  
  if theme_ok and theme_result and theme_result.colors then
    return theme_result
  end
  
  -- Return nil if theme loading fails
  return nil
end

local theme = load_theme_safe()
if theme and theme.colors then
  config.colors = theme.colors
  config.bold_brightens_ansi_colors = true
else
  -- Fallback to built-in theme if custom theme fails
  config.color_scheme = 'tokyonight_storm'
  config.bold_brightens_ansi_colors = true
end

-- ────────────────────────────────────────────────────────────────────────────────────────────────────────────
-- 🖼️ WINDOW CONFIGURATION
-- ────────────────────────────────────────────────────────────────────────────────────────────────────────────

config.initial_cols = 120
config.initial_rows = 40
config.window_decorations = "RESIZE"  -- Clean look like Alacritty
config.window_padding = {
  left = 8,
  right = 8,
  top = 8,
  bottom = 8,
}
config.window_close_confirmation = 'NeverPrompt'
config.window_background_opacity = 1.0
config.macos_window_background_blur = 0

-- Disable native fullscreen to prevent hangs
config.native_macos_fullscreen_mode = false

-- ────────────────────────────────────────────────────────────────────────────────────────────────────────────
-- 📜 SCROLLING & HISTORY
-- ────────────────────────────────────────────────────────────────────────────────────────────────────────────

config.scrollback_lines = 10000
config.enable_scroll_bar = false

-- ────────────────────────────────────────────────────────────────────────────────────────────────────────────
-- 🖱️ MOUSE CONFIGURATION
-- ────────────────────────────────────────────────────────────────────────────────────────────────────────────

config.mouse_wheel_scrolls_tabs = false
config.hide_mouse_cursor_when_typing = true

-- Simplified mouse bindings to prevent event conflicts
config.mouse_bindings = {
  -- Paste with middle click
  {
    event = { Down = { streak = 1, button = 'Middle' } },
    action = wezterm.action.PasteFrom 'PrimarySelection',
  },
  -- CMD+Click to open links (simplified)
  {
    event = { Up = { streak = 1, button = 'Left' } },
    mods = 'CMD',
    action = wezterm.action.OpenLinkAtMouseCursor,
  },
}

-- ────────────────────────────────────────────────────────────────────────────────────────────────────────────
-- 🔲 CURSOR CONFIGURATION
-- ────────────────────────────────────────────────────────────────────────────────────────────────────────────

config.default_cursor_style = 'BlinkingBlock'
config.cursor_blink_rate = 700
config.cursor_blink_ease_in = 'Constant'
config.cursor_blink_ease_out = 'Constant'

-- ────────────────────────────────────────────────────────────────────────────────────────────────────────────
-- 🎵 BELL CONFIGURATION
-- ────────────────────────────────────────────────────────────────────────────────────────────────────────────

config.audible_bell = 'Disabled'
config.visual_bell = {
  fade_in_function = 'EaseIn',
  fade_in_duration_ms = 100,
  fade_out_function = 'EaseOut',
  fade_out_duration_ms = 100,
}

-- ────────────────────────────────────────────────────────────────────────────────────────────────────────────
-- ⚙️ PERFORMANCE & RENDERING
-- ────────────────────────────────────────────────────────────────────────────────────────────────────────────

config.front_end = "WebGpu"  -- Best performance on modern hardware
config.webgpu_power_preference = "HighPerformance"
config.max_fps = 120
config.animation_fps = 60
config.enable_wayland = false  -- macOS doesn't use Wayland

-- ────────────────────────────────────────────────────────────────────────────────────────────────────────────
-- 📑 TAB BAR CONFIGURATION
-- ────────────────────────────────────────────────────────────────────────────────────────────────────────────

config.enable_tab_bar = true
config.use_fancy_tab_bar = false
config.hide_tab_bar_if_only_one_tab = true
config.tab_bar_at_bottom = false
config.show_tab_index_in_tab_bar = true
config.show_new_tab_button_in_tab_bar = false

-- ────────────────────────────────────────────────────────────────────────────────────────────────────────────
-- 🌍 ENVIRONMENT VARIABLES
-- ────────────────────────────────────────────────────────────────────────────────────────────────────────────

config.set_environment_variables = {
  TERM_PROGRAM = 'WezTerm',
  TERM = 'wezterm',
  COLORTERM = 'truecolor',
  LANG = 'en_US.UTF-8',
  LC_ALL = 'en_US.UTF-8',
  LC_CTYPE = 'en_US.UTF-8',
}

-- ────────────────────────────────────────────────────────────────────────────────────────────────────────────
-- ⌨️ KEY BINDINGS - Matching Alacritty + WezTerm extras
-- ────────────────────────────────────────────────────────────────────────────────────────────────────────────

config.keys = {
  -- Core macOS shortcuts
  { key = 'n', mods = 'CMD', action = wezterm.action.SpawnWindow },
  { key = 'q', mods = 'CMD', action = wezterm.action.QuitApplication },
  { key = 'Enter', mods = 'CMD', action = wezterm.action.ToggleFullScreen },
  
  -- Clipboard
  { key = 'c', mods = 'CMD', action = wezterm.action.CopyTo 'Clipboard' },
  { key = 'v', mods = 'CMD', action = wezterm.action.PasteFrom 'Clipboard' },
  { key = 'a', mods = 'CMD', action = wezterm.action.SelectTextAtMouseCursor 'Line' },
  
  -- Window management
  { key = 'h', mods = 'CMD', action = wezterm.action.HideApplication },
  { key = 'm', mods = 'CMD', action = wezterm.action.Hide },
  
  -- Font size control
  { key = '+', mods = 'CMD', action = wezterm.action.IncreaseFontSize },
  { key = '=', mods = 'CMD', action = wezterm.action.IncreaseFontSize },
  { key = '-', mods = 'CMD', action = wezterm.action.DecreaseFontSize },
  { key = '0', mods = 'CMD', action = wezterm.action.ResetFontSize },
  
  -- Search
  { key = 'f', mods = 'CMD', action = wezterm.action.Search { CaseSensitiveString = '' } },
  
  -- Tab management with proper confirmation
  { key = 't', mods = 'CMD', action = wezterm.action.SpawnTab 'CurrentPaneDomain' },
  { key = 'w', mods = 'CMD', action = wezterm.action.CloseCurrentTab { confirm = false } },
  { key = '[', mods = 'CMD', action = wezterm.action.ActivateTabRelative(-1) },
  { key = ']', mods = 'CMD', action = wezterm.action.ActivateTabRelative(1) },
  
  -- Quick tab switching
  { key = '1', mods = 'CMD', action = wezterm.action.ActivateTab(0) },
  { key = '2', mods = 'CMD', action = wezterm.action.ActivateTab(1) },
  { key = '3', mods = 'CMD', action = wezterm.action.ActivateTab(2) },
  { key = '4', mods = 'CMD', action = wezterm.action.ActivateTab(3) },
  { key = '5', mods = 'CMD', action = wezterm.action.ActivateTab(4) },
  { key = '6', mods = 'CMD', action = wezterm.action.ActivateTab(5) },
  { key = '7', mods = 'CMD', action = wezterm.action.ActivateTab(6) },
  { key = '8', mods = 'CMD', action = wezterm.action.ActivateTab(7) },
  { key = '9', mods = 'CMD', action = wezterm.action.ActivateTab(-1) },
  
  -- Pane management (WezTerm splits)
  { key = 'd', mods = 'CMD', action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' } },
  { key = 'd', mods = 'CMD|SHIFT', action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' } },
  { key = 'x', mods = 'CMD', action = wezterm.action.CloseCurrentPane { confirm = false } },
  
  -- Pane navigation (vim-style)
  { key = 'h', mods = 'CMD|ALT', action = wezterm.action.ActivatePaneDirection 'Left' },
  { key = 'l', mods = 'CMD|ALT', action = wezterm.action.ActivatePaneDirection 'Right' },
  { key = 'k', mods = 'CMD|ALT', action = wezterm.action.ActivatePaneDirection 'Up' },
  { key = 'j', mods = 'CMD|ALT', action = wezterm.action.ActivatePaneDirection 'Down' },
  
  -- Pane resizing
  { key = 'H', mods = 'CMD|SHIFT', action = wezterm.action.AdjustPaneSize { 'Left', 5 } },
  { key = 'L', mods = 'CMD|SHIFT', action = wezterm.action.AdjustPaneSize { 'Right', 5 } },
  { key = 'K', mods = 'CMD|SHIFT', action = wezterm.action.AdjustPaneSize { 'Up', 5 } },
  { key = 'J', mods = 'CMD|SHIFT', action = wezterm.action.AdjustPaneSize { 'Down', 5 } },
  
  -- Clear terminal (Cmd+K like Alacritty)
  { key = 'k', mods = 'CMD', action = wezterm.action.SendString '\x0c' },
  
  -- tmux integration (pass through for tmux windows)
  { key = ']', mods = 'CMD|SHIFT', action = wezterm.action.SendString '\x01n' },  -- Ctrl-A n
  { key = '[', mods = 'CMD|SHIFT', action = wezterm.action.SendString '\x01p' },  -- Ctrl-A p
  
  -- Copy mode (better than tmux)
  { key = 'Space', mods = 'CTRL|SHIFT', action = wezterm.action.ActivateCopyMode },
  
  -- Command palette
  { key = 'p', mods = 'CMD|SHIFT', action = wezterm.action.ActivateCommandPalette },
}

-- ────────────────────────────────────────────────────────────────────────────────────────────────────────────
-- 🎯 HYPERLINK RULES
-- ────────────────────────────────────────────────────────────────────────────────────────────────────────────

config.hyperlink_rules = wezterm.default_hyperlink_rules()

-- ────────────────────────────────────────────────────────────────────────────────────────────────────────────
-- 📋 SELECTION
-- ────────────────────────────────────────────────────────────────────────────────────────────────────────────

config.selection_word_boundary = " \t\n{}[]()\"'`,;:"

-- ────────────────────────────────────────────────────────────────────────────────────────────────────────────
-- 🔧 MISC SETTINGS
-- ────────────────────────────────────────────────────────────────────────────────────────────────────────────

config.automatically_reload_config = true
config.check_for_updates = false  -- Managed by Homebrew
config.use_ime = true
config.enable_kitty_keyboard = false
config.send_composed_key_when_left_alt_is_pressed = false
config.send_composed_key_when_right_alt_is_pressed = false

return config