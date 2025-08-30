-- ════════════════════════════════════════════════════════════════════════════════════════════════════════════
-- 🚀 WEZTERM CONFIGURATION - Production-Ready Terminal Emulator
-- ════════════════════════════════════════════════════════════════════════════════════════════════════════════
-- Matching Alacritty configuration with WezTerm's advanced features
-- Optimized for speed, modern workflows, and seamless integration with Neovim, tmux, and Zsh
-- ════════════════════════════════════════════════════════════════════════════════════════════════════════════

local wezterm = require 'wezterm'
local config = wezterm.config_builder()

-- ────────────────────────────────────────────────────────────────────────────────────────────────────────────
-- 🖋️ FONT CONFIGURATION - JetBrainsMono with ligatures (matching Alacritty)
-- ────────────────────────────────────────────────────────────────────────────────────────────────────────────

config.font = wezterm.font('JetBrainsMono Nerd Font', { weight = 'Regular' })
config.font_size = 18.0  -- Matching Alacritty
config.line_height = 1.0
config.cell_width = 1.0

-- Bold font
config.font_rules = {
  {
    intensity = 'Bold',
    italic = false,
    font = wezterm.font('JetBrainsMono Nerd Font', { weight = 'Bold' }),
  },
  {
    intensity = 'Normal',
    italic = true,
    font = wezterm.font('JetBrainsMono Nerd Font', { style = 'Italic' }),
  },
  {
    intensity = 'Bold',
    italic = true,
    font = wezterm.font('JetBrainsMono Nerd Font', { weight = 'Bold', style = 'Italic' }),
  },
}

-- Enable ligatures (PopClip was the issue, not ligatures)
config.harfbuzz_features = { 'calt=1', 'clig=1', 'liga=1' }

-- ────────────────────────────────────────────────────────────────────────────────────────────────────────────
-- 🎨 COLOR SCHEME - Dynamic TokyoNight theme loading
-- ────────────────────────────────────────────────────────────────────────────────────────────────────────────

-- Load the dynamic theme configuration
local home = os.getenv("HOME")
local theme_path = home .. "/.config/wezterm/theme.lua"
local theme_ok, theme = pcall(dofile, theme_path)

if theme_ok and theme then
  -- Apply the colors from the theme
  config.colors = theme.colors
  config.bold_brightens_ansi_colors = true
else
  -- Fallback to default theme if theme file doesn't exist
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

-- Mouse bindings matching Alacritty
config.mouse_bindings = {
  -- Paste with middle click
  {
    event = { Down = { streak = 1, button = 'Middle' } },
    action = wezterm.action.PasteFrom 'PrimarySelection',
  },
  -- Right click to extend selection
  {
    event = { Down = { streak = 1, button = 'Right' } },
    action = wezterm.action.ExtendSelectionToMouseCursor 'Word',
  },
  -- CMD+Click to open links
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
  { key = 'b', mods = 'CMD|SHIFT', action = wezterm.action.Search { CaseSensitiveString = '' } },
  
  -- Tab management (WezTerm native tabs, better than tmux for this)
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