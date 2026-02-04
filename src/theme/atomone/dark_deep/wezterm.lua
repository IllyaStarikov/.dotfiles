-- OneDark Deep theme for WezTerm
-- Generated from template - do not edit directly

local M = {}

M.colors = {
  -- Basic colors
  foreground = "#93a4c3",
  background = "#1a212e",
  cursor_bg = "#93a4c3",
  cursor_fg = "#1a212e",
  cursor_border = "#93a4c3",
  selection_fg = "#93a4c3",
  selection_bg = "#283347",

  -- ANSI colors
  ansi = {
    "#0c0e15",   -- black
    "#f65866",     -- red
    "#8bcd5b",   -- green
    "#efbd5d",  -- yellow
    "#41a7fc",    -- blue
    "#c75ae8", -- magenta
    "#34bfd0",    -- cyan
    "#93a4c3",   -- white
  },

  -- Bright ANSI colors
  brights = {
    "#455574",   -- bright black
    "#f65866",     -- bright red
    "#8bcd5b",   -- bright green
    "#efbd5d",  -- bright yellow
    "#41a7fc",    -- bright blue
    "#c75ae8", -- bright magenta
    "#34bfd0",    -- bright cyan
    "#93a4c3",   -- bright white
  },

  -- Tab bar
  tab_bar = {
    background = "#21283b",
    active_tab = {
      bg_color = "#1a212e",
      fg_color = "#41a7fc",
      intensity = "Bold",
    },
    inactive_tab = {
      bg_color = "#21283b",
      fg_color = "#455574",
    },
    inactive_tab_hover = {
      bg_color = "#455574",
      fg_color = "#41a7fc",
      italic = false,
    },
    new_tab = {
      bg_color = "#21283b",
      fg_color = "#41a7fc",
    },
    new_tab_hover = {
      bg_color = "#455574",
      fg_color = "#41a7fc",
      italic = false,
    },
  },

  -- Scrollbar
  scrollbar_thumb = "#455574",

  -- Split lines
  split = "#455574",
}

return M
