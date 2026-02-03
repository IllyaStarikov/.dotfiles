-- Nord theme for WezTerm
-- Generated from template - do not edit directly

local M = {}

M.colors = {
  -- Basic colors
  foreground = "#d8dee9",
  background = "#2e3440",
  cursor_bg = "#d8dee9",
  cursor_fg = "#2e3440",
  cursor_border = "#d8dee9",
  selection_fg = "#d8dee9",
  selection_bg = "#434c5e",

  -- ANSI colors
  ansi = {
    "#3b4252",   -- black
    "#bf616a",     -- red
    "#a3be8c",   -- green
    "#ebcb8b",  -- yellow
    "#81a1c1",    -- blue
    "#b48ead", -- magenta
    "#88c0d0",    -- cyan
    "#e5e9f0",   -- white
  },

  -- Bright ANSI colors
  brights = {
    "#4c566a",   -- bright black
    "#bf616a",     -- bright red
    "#a3be8c",   -- bright green
    "#ebcb8b",  -- bright yellow
    "#81a1c1",    -- bright blue
    "#b48ead", -- bright magenta
    "#8fbcbb",    -- bright cyan
    "#eceff4",   -- bright white
  },

  -- Tab bar
  tab_bar = {
    background = "#3b4252",
    active_tab = {
      bg_color = "#2e3440",
      fg_color = "#88c0d0",
      intensity = "Bold",
    },
    inactive_tab = {
      bg_color = "#3b4252",
      fg_color = "#616e88",
    },
    inactive_tab_hover = {
      bg_color = "#4c566a",
      fg_color = "#88c0d0",
      italic = false,
    },
    new_tab = {
      bg_color = "#3b4252",
      fg_color = "#88c0d0",
    },
    new_tab_hover = {
      bg_color = "#4c566a",
      fg_color = "#88c0d0",
      italic = false,
    },
  },

  -- Scrollbar
  scrollbar_thumb = "#4c566a",

  -- Split lines
  split = "#4c566a",
}

return M
