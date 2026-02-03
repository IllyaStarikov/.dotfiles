-- Iceberg Light theme for WezTerm
-- Generated from template - do not edit directly

local M = {}

M.colors = {
  -- Basic colors
  foreground = "#33374c",
  background = "#e8e9ec",
  cursor_bg = "#33374c",
  cursor_fg = "#e8e9ec",
  cursor_border = "#33374c",
  selection_fg = "#33374c",
  selection_bg = "#c9cdd7",

  -- ANSI colors
  ansi = {
    "#dcdfe7",   -- black
    "#cc517a",     -- red
    "#668e3d",   -- green
    "#c57339",  -- yellow
    "#2d539e",    -- blue
    "#7759b4", -- magenta
    "#3f83a6",    -- cyan
    "#33374c",   -- white
  },

  -- Bright ANSI colors
  brights = {
    "#8389a3",   -- bright black
    "#cc3768",     -- bright red
    "#598030",   -- bright green
    "#b6662d",  -- bright yellow
    "#22478e",    -- bright blue
    "#6845ad", -- bright magenta
    "#327698",    -- bright cyan
    "#262a3f",   -- bright white
  },

  -- Tab bar
  tab_bar = {
    background = "#dcdfe7",
    active_tab = {
      bg_color = "#e8e9ec",
      fg_color = "#2d539e",
      intensity = "Bold",
    },
    inactive_tab = {
      bg_color = "#dcdfe7",
      fg_color = "#8389a3",
    },
    inactive_tab_hover = {
      bg_color = "#b8bcc7",
      fg_color = "#2d539e",
      italic = false,
    },
    new_tab = {
      bg_color = "#dcdfe7",
      fg_color = "#2d539e",
    },
    new_tab_hover = {
      bg_color = "#b8bcc7",
      fg_color = "#2d539e",
      italic = false,
    },
  },

  -- Scrollbar
  scrollbar_thumb = "#8389a3",

  -- Split lines
  split = "#8389a3",
}

return M
