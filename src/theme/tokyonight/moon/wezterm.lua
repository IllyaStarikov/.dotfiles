-- Tokyo Night Moon theme for WezTerm
-- Generated from template - do not edit directly

local M = {}

M.colors = {
  -- Basic colors
  foreground = "#c8d3f5",
  background = "#222436",
  cursor_bg = "#c8d3f5",
  cursor_fg = "#222436",
  cursor_border = "#c8d3f5",
  selection_fg = "#c8d3f5",
  selection_bg = "#3b4261",

  -- ANSI colors
  ansi = {
    "#1b1d2b",   -- black
    "#ff757f",     -- red
    "#c3e88d",   -- green
    "#ffc777",  -- yellow
    "#82aaff",    -- blue
    "#c099ff", -- magenta
    "#86e1fc",    -- cyan
    "#828bb8",   -- white
  },

  -- Bright ANSI colors
  brights = {
    "#444a73",   -- bright black
    "#ff8d94",     -- bright red
    "#c7fb6d",   -- bright green
    "#ffd8ab",  -- bright yellow
    "#9ab8ff",    -- bright blue
    "#caabff", -- bright magenta
    "#b2ebff",    -- bright cyan
    "#c8d3f5",   -- bright white
  },

  -- Tab bar
  tab_bar = {
    background = "#3c3e4e",
    active_tab = {
      bg_color = "#222436",
      fg_color = "#82aaff",
      intensity = "Bold",
    },
    inactive_tab = {
      bg_color = "#3c3e4e",
      fg_color = "#444a73",
    },
    inactive_tab_hover = {
      bg_color = "#3b4261",
      fg_color = "#82aaff",
      italic = false,
    },
    new_tab = {
      bg_color = "#3c3e4e",
      fg_color = "#82aaff",
    },
    new_tab_hover = {
      bg_color = "#3b4261",
      fg_color = "#82aaff",
      italic = false,
    },
  },

  -- Scrollbar
  scrollbar_thumb = "#444a73",

  -- Split lines
  split = "#444a73",
}

return M
