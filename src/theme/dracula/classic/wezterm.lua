-- Dracula Classic theme for WezTerm
-- Generated from template - do not edit directly

local M = {}

M.colors = {
  -- Basic colors
  foreground = "#f8f8f2",
  background = "#282a36",
  cursor_bg = "#f8f8f2",
  cursor_fg = "#282a36",
  cursor_border = "#f8f8f2",
  selection_fg = "#f8f8f2",
  selection_bg = "#44475a",

  -- ANSI colors
  ansi = {
    "#21222c",   -- black
    "#ff5555",     -- red
    "#50fa7b",   -- green
    "#f1fa8c",  -- yellow
    "#bd93f9",    -- blue
    "#ff79c6", -- magenta
    "#8be9fd",    -- cyan
    "#f8f8f2",   -- white
  },

  -- Bright ANSI colors
  brights = {
    "#6272a4",   -- bright black
    "#ff6e6e",     -- bright red
    "#69ff94",   -- bright green
    "#ffffa5",  -- bright yellow
    "#d6acff",    -- bright blue
    "#ff92df", -- bright magenta
    "#a4ffff",    -- bright cyan
    "#ffffff",   -- bright white
  },

  -- Tab bar
  tab_bar = {
    background = "#41434e",
    active_tab = {
      bg_color = "#282a36",
      fg_color = "#bd93f9",
      intensity = "Bold",
    },
    inactive_tab = {
      bg_color = "#41434e",
      fg_color = "#6272a4",
    },
    inactive_tab_hover = {
      bg_color = "#44475a",
      fg_color = "#bd93f9",
      italic = false,
    },
    new_tab = {
      bg_color = "#41434e",
      fg_color = "#bd93f9",
    },
    new_tab_hover = {
      bg_color = "#44475a",
      fg_color = "#bd93f9",
      italic = false,
    },
  },

  -- Scrollbar
  scrollbar_thumb = "#6272a4",

  -- Split lines
  split = "#6272a4",
}

return M
