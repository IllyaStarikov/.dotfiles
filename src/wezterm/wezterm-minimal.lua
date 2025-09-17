-- Absolute minimal WezTerm config for debugging
local wezterm = require("wezterm")
local config = wezterm.config_builder and wezterm.config_builder() or {}

-- Just the basics
config.font = wezterm.font("JetBrainsMono Nerd Font")
config.font_size = 18.0

-- Disable everything that could cause issues
config.front_end = "Software" -- Most compatible renderer
config.enable_tab_bar = false
config.harfbuzz_features = {} -- No font features
config.automatically_reload_config = false
config.check_for_updates = false

return config
