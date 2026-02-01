-- One Dark Pro Vivid theme for WezTerm
-- Generated from template - do not edit directly

local M = {}

M.colors = {
  -- Basic colors
  foreground = "#abb2bf",
  background = "#282c34",
  cursor_bg = "#abb2bf",
  cursor_fg = "#282c34",
  cursor_border = "#abb2bf",
  selection_fg = "#abb2bf",
  selection_bg = "#3e4451",

  -- ANSI colors
  ansi = {
    "#3e4451",   -- black
    "#ef596f",     -- red
    "#89ca78",   -- green
    "#e5c07b",  -- yellow
    "#52adf2",    -- blue
    "#d55fde", -- magenta
    "#2bbac5",    -- cyan
    "#abb2bf",   -- white
  },

  -- Bright ANSI colors
  brights = {
    "#5c6370",   -- bright black
    "#ef596f",     -- bright red
    "#89ca78",   -- bright green
    "#e5c07b",  -- bright yellow
    "#52adf2",    -- bright blue
    "#d55fde", -- bright magenta
    "#2bbac5",    -- bright cyan
    "#abb2bf",   -- bright white
  },

  -- Tab bar
  tab_bar = {
    background = "#41454c",
    active_tab = {
      bg_color = "#282c34",
      fg_color = "#52adf2",
      intensity = "Bold",
    },
    inactive_tab = {
      bg_color = "#41454c",
      fg_color = "#5c6370",
    },
    inactive_tab_hover = {
      bg_color = "#3e4451",
      fg_color = "#52adf2",
      italic = false,
    },
    new_tab = {
      bg_color = "#41454c",
      fg_color = "#52adf2",
    },
    new_tab_hover = {
      bg_color = "#3e4451",
      fg_color = "#52adf2",
      italic = false,
    },
  },

  -- Scrollbar
  scrollbar_thumb = "#5c6370",

  -- Split lines
  split = "#5c6370",
}

return M
