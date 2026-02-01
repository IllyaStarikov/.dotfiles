-- Catppuccin Macchiato theme for WezTerm
-- Generated from template - do not edit directly

local M = {}

M.colors = {
  -- Basic colors
  foreground = "#cad3f5",
  background = "#24273a",
  cursor_bg = "#cad3f5",
  cursor_fg = "#24273a",
  cursor_border = "#cad3f5",
  selection_fg = "#cad3f5",
  selection_bg = "#494d64",

  -- ANSI colors
  ansi = {
    "#494d64",   -- black
    "#ed8796",     -- red
    "#a6da95",   -- green
    "#eed49f",  -- yellow
    "#8aadf4",    -- blue
    "#f5bde6", -- magenta
    "#8bd5ca",    -- cyan
    "#b8c0e0",   -- white
  },

  -- Bright ANSI colors
  brights = {
    "#5b6078",   -- bright black
    "#ed8796",     -- bright red
    "#a6da95",   -- bright green
    "#eed49f",  -- bright yellow
    "#8aadf4",    -- bright blue
    "#f5bde6", -- bright magenta
    "#8bd5ca",    -- bright cyan
    "#a5adcb",   -- bright white
  },

  -- Tab bar
  tab_bar = {
    background = "#3e4051",
    active_tab = {
      bg_color = "#24273a",
      fg_color = "#8aadf4",
      intensity = "Bold",
    },
    inactive_tab = {
      bg_color = "#3e4051",
      fg_color = "#5b6078",
    },
    inactive_tab_hover = {
      bg_color = "#494d64",
      fg_color = "#8aadf4",
      italic = false,
    },
    new_tab = {
      bg_color = "#3e4051",
      fg_color = "#8aadf4",
    },
    new_tab_hover = {
      bg_color = "#494d64",
      fg_color = "#8aadf4",
      italic = false,
    },
  },

  -- Scrollbar
  scrollbar_thumb = "#5b6078",

  -- Split lines
  split = "#5b6078",
}

return M
