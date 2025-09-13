-- Fix for WezTerm privacy prompts
-- This configuration prevents WezTerm from staying in background and triggering privacy prompts

local wezterm = require 'wezterm'
local config = {}

-- Disable background persistence
config.quit_when_all_windows_are_closed = true  -- Quit when last window closes
config.window_close_confirmation = "NeverPrompt"  -- Don't prompt on close

-- Disable features that might check other apps
config.enable_wayland = false  -- Disable Wayland support if not needed
config.check_for_updates = false  -- Disable update checks
config.automatically_reload_config = false  -- Don't watch config file

-- Disable clipboard integration that might trigger privacy prompts
config.canonicalize_pasted_newlines = "None"

return config