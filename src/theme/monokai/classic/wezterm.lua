-- Monokai Pro Classic theme for WezTerm
-- Generated from template - do not edit directly

local M = {}

M.colors = {
  -- Basic colors
  foreground = "#f8f8f2",
  background = "#272822",
  cursor_bg = "#f8f8f2",
  cursor_fg = "#272822",
  cursor_border = "#f8f8f2",
  selection_fg = "#f8f8f2",
  selection_bg = "#75715e",

  -- ANSI colors
  ansi = {
    "#75715e",   -- black
    "#f92672",     -- red
    "#a6e22e",   -- green
    "#f4bf75",  -- yellow
    "#66d9ef",    -- blue
    "#ae81ff", -- magenta
    "#a1efe4",    -- cyan
    "#f9f8f5",   -- white
  },

  -- Bright ANSI colors
  brights = {
    "#908e82",   -- bright black
    "#f92672",     -- bright red
    "#a6e22e",   -- bright green
    "#f4bf75",  -- bright yellow
    "#66d9ef",    -- bright blue
    "#ae81ff", -- bright magenta
    "#a1efe4",    -- bright cyan
    "#f9f8f5",   -- bright white
  },

  -- Tab bar
  tab_bar = {
    background = "#40413c",
    active_tab = {
      bg_color = "#272822",
      fg_color = "#f92672",
      intensity = "Bold",
    },
    inactive_tab = {
      bg_color = "#40413c",
      fg_color = "#908e82",
    },
    inactive_tab_hover = {
      bg_color = "#75715e",
      fg_color = "#f92672",
      italic = false,
    },
    new_tab = {
      bg_color = "#40413c",
      fg_color = "#f92672",
    },
    new_tab_hover = {
      bg_color = "#75715e",
      fg_color = "#f92672",
      italic = false,
    },
  },

  -- Scrollbar
  scrollbar_thumb = "#908e82",

  -- Split lines
  split = "#908e82",
}

return M
