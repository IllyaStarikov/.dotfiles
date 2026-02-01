-- Tokyo Night Day theme for WezTerm
-- Generated from template - do not edit directly

local M = {}

M.colors = {
  -- Basic colors
  foreground = "#3760bf",
  background = "#e1e2e7",
  cursor_bg = "#3760bf",
  cursor_fg = "#e1e2e7",
  cursor_border = "#3760bf",
  selection_fg = "#3760bf",
  selection_bg = "#b7c1e3",

  -- ANSI colors
  ansi = {
    "#b4b5b9",   -- black
    "#f52a65",     -- red
    "#587539",   -- green
    "#8c6c3e",  -- yellow
    "#2e7de9",    -- blue
    "#9854f1", -- magenta
    "#007197",    -- cyan
    "#6172b0",   -- white
  },

  -- Bright ANSI colors
  brights = {
    "#a1a6c5",   -- bright black
    "#ff4774",     -- bright red
    "#5c8524",   -- bright green
    "#a27629",  -- bright yellow
    "#358aff",    -- bright blue
    "#a463ff", -- bright magenta
    "#007ea8",    -- bright cyan
    "#3760bf",   -- bright white
  },

  -- Tab bar
  tab_bar = {
    background = "#cfcfd4",
    active_tab = {
      bg_color = "#e1e2e7",
      fg_color = "#2e7de9",
      intensity = "Bold",
    },
    inactive_tab = {
      bg_color = "#cfcfd4",
      fg_color = "#a1a6c5",
    },
    inactive_tab_hover = {
      bg_color = "#b7c1e3",
      fg_color = "#2e7de9",
      italic = false,
    },
    new_tab = {
      bg_color = "#cfcfd4",
      fg_color = "#2e7de9",
    },
    new_tab_hover = {
      bg_color = "#b7c1e3",
      fg_color = "#2e7de9",
      italic = false,
    },
  },

  -- Scrollbar
  scrollbar_thumb = "#a1a6c5",

  -- Split lines
  split = "#a1a6c5",
}

return M
