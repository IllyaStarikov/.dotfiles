-- Ayu Light theme for WezTerm
-- Generated from template - do not edit directly

local M = {}

M.colors = {
  -- Basic colors
  foreground = "#575f66",
  background = "#fafafa",
  cursor_bg = "#575f66",
  cursor_fg = "#fafafa",
  cursor_border = "#575f66",
  selection_fg = "#575f66",
  selection_bg = "#d9d9d9",

  -- ANSI colors
  ansi = {
    "#55606d",   -- black
    "#f51818",     -- red
    "#86b300",   -- green
    "#f29718",  -- yellow
    "#36a3d9",    -- blue
    "#a37acc", -- magenta
    "#4cbf99",    -- cyan
    "#ffffff",   -- white
  },

  -- Bright ANSI colors
  brights = {
    "#707a8c",   -- bright black
    "#f51818",     -- bright red
    "#86b300",   -- bright green
    "#f29718",  -- bright yellow
    "#36a3d9",    -- bright blue
    "#a37acc", -- bright magenta
    "#4cbf99",    -- bright cyan
    "#ffffff",   -- bright white
  },

  -- Tab bar
  tab_bar = {
    background = "#e6e6e6",
    active_tab = {
      bg_color = "#fafafa",
      fg_color = "#36a3d9",
      intensity = "Bold",
    },
    inactive_tab = {
      bg_color = "#e6e6e6",
      fg_color = "#707a8c",
    },
    inactive_tab_hover = {
      bg_color = "#d9d9d9",
      fg_color = "#36a3d9",
      italic = false,
    },
    new_tab = {
      bg_color = "#e6e6e6",
      fg_color = "#36a3d9",
    },
    new_tab_hover = {
      bg_color = "#d9d9d9",
      fg_color = "#36a3d9",
      italic = false,
    },
  },

  -- Scrollbar
  scrollbar_thumb = "#707a8c",

  -- Split lines
  split = "#707a8c",
}

return M
