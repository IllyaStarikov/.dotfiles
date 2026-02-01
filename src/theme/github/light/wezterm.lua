-- GitHub Light theme for WezTerm
-- Generated from template - do not edit directly

local M = {}

M.colors = {
  -- Basic colors
  foreground = "#24292f",
  background = "#ffffff",
  cursor_bg = "#24292f",
  cursor_fg = "#ffffff",
  cursor_border = "#24292f",
  selection_fg = "#24292f",
  selection_bg = "#e1e4e8",

  -- ANSI colors
  ansi = {
    "#24292e",   -- black
    "#d73a49",     -- red
    "#28a745",   -- green
    "#dbab09",  -- yellow
    "#0366d6",    -- blue
    "#5a32a3", -- magenta
    "#0598bc",    -- cyan
    "#6a737d",   -- white
  },

  -- Bright ANSI colors
  brights = {
    "#959da5",   -- bright black
    "#cb2431",     -- bright red
    "#22863a",   -- bright green
    "#b08800",  -- bright yellow
    "#005cc5",    -- bright blue
    "#5a32a3", -- bright magenta
    "#3192aa",    -- bright cyan
    "#d1d5da",   -- bright white
  },

  -- Tab bar
  tab_bar = {
    background = "#eaeaea",
    active_tab = {
      bg_color = "#ffffff",
      fg_color = "#0366d6",
      intensity = "Bold",
    },
    inactive_tab = {
      bg_color = "#eaeaea",
      fg_color = "#959da5",
    },
    inactive_tab_hover = {
      bg_color = "#e1e4e8",
      fg_color = "#0366d6",
      italic = false,
    },
    new_tab = {
      bg_color = "#eaeaea",
      fg_color = "#0366d6",
    },
    new_tab_hover = {
      bg_color = "#e1e4e8",
      fg_color = "#0366d6",
      italic = false,
    },
  },

  -- Scrollbar
  scrollbar_thumb = "#959da5",

  -- Split lines
  split = "#959da5",
}

return M
