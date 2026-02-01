-- Ayu Mirage theme for WezTerm
-- Generated from template - do not edit directly

local M = {}

M.colors = {
  -- Basic colors
  foreground = "#cbccc6",
  background = "#1f2430",
  cursor_bg = "#cbccc6",
  cursor_fg = "#1f2430",
  cursor_border = "#cbccc6",
  selection_fg = "#cbccc6",
  selection_bg = "#707a8c",

  -- ANSI colors
  ansi = {
    "#707a8c",   -- black
    "#f28779",     -- red
    "#bbd684",   -- green
    "#ffd580",  -- yellow
    "#73d0ff",    -- blue
    "#d4bfff", -- magenta
    "#95e6cb",    -- cyan
    "#ffffff",   -- white
  },

  -- Bright ANSI colors
  brights = {
    "#8a919d",   -- bright black
    "#f28779",     -- bright red
    "#bbd684",   -- bright green
    "#ffd580",  -- bright yellow
    "#73d0ff",    -- bright blue
    "#d4bfff", -- bright magenta
    "#95e6cb",    -- bright cyan
    "#ffffff",   -- bright white
  },

  -- Tab bar
  tab_bar = {
    background = "#393e48",
    active_tab = {
      bg_color = "#1f2430",
      fg_color = "#73d0ff",
      intensity = "Bold",
    },
    inactive_tab = {
      bg_color = "#393e48",
      fg_color = "#8a919d",
    },
    inactive_tab_hover = {
      bg_color = "#707a8c",
      fg_color = "#73d0ff",
      italic = false,
    },
    new_tab = {
      bg_color = "#393e48",
      fg_color = "#73d0ff",
    },
    new_tab_hover = {
      bg_color = "#707a8c",
      fg_color = "#73d0ff",
      italic = false,
    },
  },

  -- Scrollbar
  scrollbar_thumb = "#8a919d",

  -- Split lines
  split = "#8a919d",
}

return M
