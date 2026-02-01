-- One Dark Pro Classic theme for WezTerm
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
    "#e06c75",     -- red
    "#98c379",   -- green
    "#e5c07b",  -- yellow
    "#61afef",    -- blue
    "#c678dd", -- magenta
    "#56b6c2",    -- cyan
    "#abb2bf",   -- white
  },

  -- Bright ANSI colors
  brights = {
    "#5c6370",   -- bright black
    "#e06c75",     -- bright red
    "#98c379",   -- bright green
    "#e5c07b",  -- bright yellow
    "#61afef",    -- bright blue
    "#c678dd", -- bright magenta
    "#56b6c2",    -- bright cyan
    "#abb2bf",   -- bright white
  },

  -- Tab bar
  tab_bar = {
    background = "#41454c",
    active_tab = {
      bg_color = "#282c34",
      fg_color = "#61afef",
      intensity = "Bold",
    },
    inactive_tab = {
      bg_color = "#41454c",
      fg_color = "#5c6370",
    },
    inactive_tab_hover = {
      bg_color = "#3e4451",
      fg_color = "#61afef",
      italic = false,
    },
    new_tab = {
      bg_color = "#41454c",
      fg_color = "#61afef",
    },
    new_tab_hover = {
      bg_color = "#3e4451",
      fg_color = "#61afef",
      italic = false,
    },
  },

  -- Scrollbar
  scrollbar_thumb = "#5c6370",

  -- Split lines
  split = "#5c6370",
}

return M
