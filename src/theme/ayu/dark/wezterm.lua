-- Ayu Dark theme for WezTerm
-- Generated from template - do not edit directly

local M = {}

M.colors = {
  -- Basic colors
  foreground = "#bfbdb6",
  background = "#0d1017",
  cursor_bg = "#bfbdb6",
  cursor_fg = "#0d1017",
  cursor_border = "#bfbdb6",
  selection_fg = "#bfbdb6",
  selection_bg = "#3e4451",

  -- ANSI colors
  ansi = {
    "#3e4451",   -- black
    "#f07178",     -- red
    "#aad94c",   -- green
    "#ffb454",  -- yellow
    "#39bae6",    -- blue
    "#d2a6ff", -- magenta
    "#95e6cb",    -- cyan
    "#e6e1cf",   -- white
  },

  -- Bright ANSI colors
  brights = {
    "#4d5566",   -- bright black
    "#f07178",     -- bright red
    "#aad94c",   -- bright green
    "#ffb454",  -- bright yellow
    "#39bae6",    -- bright blue
    "#d2a6ff", -- bright magenta
    "#95e6cb",    -- bright cyan
    "#e6e1cf",   -- bright white
  },

  -- Tab bar
  tab_bar = {
    background = "#2a2c32",
    active_tab = {
      bg_color = "#0d1017",
      fg_color = "#39bae6",
      intensity = "Bold",
    },
    inactive_tab = {
      bg_color = "#2a2c32",
      fg_color = "#4d5566",
    },
    inactive_tab_hover = {
      bg_color = "#3e4451",
      fg_color = "#39bae6",
      italic = false,
    },
    new_tab = {
      bg_color = "#2a2c32",
      fg_color = "#39bae6",
    },
    new_tab_hover = {
      bg_color = "#3e4451",
      fg_color = "#39bae6",
      italic = false,
    },
  },

  -- Scrollbar
  scrollbar_thumb = "#4d5566",

  -- Split lines
  split = "#4d5566",
}

return M
