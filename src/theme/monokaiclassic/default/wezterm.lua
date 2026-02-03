-- Monokai Classic theme for WezTerm
-- Generated from template - do not edit directly

local M = {}

M.colors = {
  -- Basic colors
  foreground = "#f8f8f2",
  background = "#272822",
  cursor_bg = "#f8f8f0",
  cursor_fg = "#272822",
  cursor_border = "#f8f8f0",
  selection_fg = "#f8f8f2",
  selection_bg = "#49483e",

  -- ANSI colors
  ansi = {
    "#272822",   -- black
    "#f92672",     -- red
    "#a6e22e",   -- green
    "#e6db74",  -- yellow
    "#66d9ef",    -- blue
    "#ae81ff", -- magenta
    "#a1efe4",    -- cyan
    "#f8f8f2",   -- white
  },

  -- Bright ANSI colors
  brights = {
    "#75715e",   -- bright black
    "#f92672",     -- bright red
    "#a6e22e",   -- bright green
    "#e6db74",  -- bright yellow
    "#66d9ef",    -- bright blue
    "#ae81ff", -- bright magenta
    "#a1efe4",    -- bright cyan
    "#f9f8f5",   -- bright white
  },

  -- Tab bar
  tab_bar = {
    background = "#3c3d37",
    active_tab = {
      bg_color = "#272822",
      fg_color = "#66d9ef",
      intensity = "Bold",
    },
    inactive_tab = {
      bg_color = "#3c3d37",
      fg_color = "#75715e",
    },
    inactive_tab_hover = {
      bg_color = "#64645e",
      fg_color = "#66d9ef",
      italic = false,
    },
    new_tab = {
      bg_color = "#3c3d37",
      fg_color = "#66d9ef",
    },
    new_tab_hover = {
      bg_color = "#64645e",
      fg_color = "#66d9ef",
      italic = false,
    },
  },

  -- Scrollbar
  scrollbar_thumb = "#75715e",

  -- Split lines
  split = "#75715e",
}

return M
