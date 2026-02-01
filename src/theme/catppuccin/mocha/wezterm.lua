-- Catppuccin Mocha theme for WezTerm
-- Generated from template - do not edit directly

local M = {}

M.colors = {
  -- Basic colors
  foreground = "#cdd6f4",
  background = "#1e1e2e",
  cursor_bg = "#cdd6f4",
  cursor_fg = "#1e1e2e",
  cursor_border = "#cdd6f4",
  selection_fg = "#cdd6f4",
  selection_bg = "#45475a",

  -- ANSI colors
  ansi = {
    "#45475a",   -- black
    "#f38ba8",     -- red
    "#a6e3a1",   -- green
    "#f9e2af",  -- yellow
    "#89b4fa",    -- blue
    "#f5c2e7", -- magenta
    "#94e2d5",    -- cyan
    "#bac2de",   -- white
  },

  -- Bright ANSI colors
  brights = {
    "#585b70",   -- bright black
    "#f38ba8",     -- bright red
    "#a6e3a1",   -- bright green
    "#f9e2af",  -- bright yellow
    "#89b4fa",    -- bright blue
    "#f5c2e7", -- bright magenta
    "#94e2d5",    -- bright cyan
    "#a6adc8",   -- bright white
  },

  -- Tab bar
  tab_bar = {
    background = "#393947",
    active_tab = {
      bg_color = "#1e1e2e",
      fg_color = "#89b4fa",
      intensity = "Bold",
    },
    inactive_tab = {
      bg_color = "#393947",
      fg_color = "#585b70",
    },
    inactive_tab_hover = {
      bg_color = "#45475a",
      fg_color = "#89b4fa",
      italic = false,
    },
    new_tab = {
      bg_color = "#393947",
      fg_color = "#89b4fa",
    },
    new_tab_hover = {
      bg_color = "#45475a",
      fg_color = "#89b4fa",
      italic = false,
    },
  },

  -- Scrollbar
  scrollbar_thumb = "#585b70",

  -- Split lines
  split = "#585b70",
}

return M
