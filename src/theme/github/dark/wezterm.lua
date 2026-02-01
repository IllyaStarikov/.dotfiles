-- GitHub Dark theme for WezTerm
-- Generated from template - do not edit directly

local M = {}

M.colors = {
  -- Basic colors
  foreground = "#d1d5da",
  background = "#24292e",
  cursor_bg = "#d1d5da",
  cursor_fg = "#24292e",
  cursor_border = "#d1d5da",
  selection_fg = "#d1d5da",
  selection_bg = "#444d56",

  -- ANSI colors
  ansi = {
    "#586069",   -- black
    "#ea4a5a",     -- red
    "#34d058",   -- green
    "#ffea7f",  -- yellow
    "#2188ff",    -- blue
    "#b392f0", -- magenta
    "#39c5cf",    -- cyan
    "#d1d5da",   -- white
  },

  -- Bright ANSI colors
  brights = {
    "#959da5",   -- bright black
    "#f97583",     -- bright red
    "#85e89d",   -- bright green
    "#ffea7f",  -- bright yellow
    "#79b8ff",    -- bright blue
    "#b392f0", -- bright magenta
    "#56d4dd",    -- bright cyan
    "#fafbfc",   -- bright white
  },

  -- Tab bar
  tab_bar = {
    background = "#3e4247",
    active_tab = {
      bg_color = "#24292e",
      fg_color = "#2188ff",
      intensity = "Bold",
    },
    inactive_tab = {
      bg_color = "#3e4247",
      fg_color = "#959da5",
    },
    inactive_tab_hover = {
      bg_color = "#444d56",
      fg_color = "#2188ff",
      italic = false,
    },
    new_tab = {
      bg_color = "#3e4247",
      fg_color = "#2188ff",
    },
    new_tab_hover = {
      bg_color = "#444d56",
      fg_color = "#2188ff",
      italic = false,
    },
  },

  -- Scrollbar
  scrollbar_thumb = "#959da5",

  -- Split lines
  split = "#959da5",
}

return M
