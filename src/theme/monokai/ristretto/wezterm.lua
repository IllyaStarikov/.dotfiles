-- Monokai Pro Ristretto theme for WezTerm
-- Generated from template - do not edit directly

local M = {}

M.colors = {
  -- Basic colors
  foreground = "#fff1f3",
  background = "#2c2525",
  cursor_bg = "#fff1f3",
  cursor_fg = "#2c2525",
  cursor_border = "#fff1f3",
  selection_fg = "#fff1f3",
  selection_bg = "#72696a",

  -- ANSI colors
  ansi = {
    "#72696a",   -- black
    "#fd6883",     -- red
    "#adda78",   -- green
    "#f9cc6c",  -- yellow
    "#85dacc",    -- blue
    "#a8a9eb", -- magenta
    "#85dacc",    -- cyan
    "#fff1f3",   -- white
  },

  -- Bright ANSI colors
  brights = {
    "#918787",   -- bright black
    "#fd6883",     -- bright red
    "#adda78",   -- bright green
    "#f9cc6c",  -- bright yellow
    "#85dacc",    -- bright blue
    "#a8a9eb", -- bright magenta
    "#85dacc",    -- bright cyan
    "#fff1f3",   -- bright white
  },

  -- Tab bar
  tab_bar = {
    background = "#453f3f",
    active_tab = {
      bg_color = "#2c2525",
      fg_color = "#f38d70",
      intensity = "Bold",
    },
    inactive_tab = {
      bg_color = "#453f3f",
      fg_color = "#918787",
    },
    inactive_tab_hover = {
      bg_color = "#72696a",
      fg_color = "#f38d70",
      italic = false,
    },
    new_tab = {
      bg_color = "#453f3f",
      fg_color = "#f38d70",
    },
    new_tab_hover = {
      bg_color = "#72696a",
      fg_color = "#f38d70",
      italic = false,
    },
  },

  -- Scrollbar
  scrollbar_thumb = "#918787",

  -- Split lines
  split = "#918787",
}

return M
