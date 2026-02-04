-- Material Oceanic theme for WezTerm
-- Generated from template - do not edit directly

local M = {}

M.colors = {
  -- Basic colors
  foreground = "#b0bec5",
  background = "#25363b",
  cursor_bg = "#b0bec5",
  cursor_fg = "#25363b",
  cursor_border = "#b0bec5",
  selection_fg = "#b0bec5",
  selection_bg = "#395b65",

  -- ANSI colors
  ansi = {
    "#000000",   -- black
    "#dc6068",     -- red
    "#abcf76",   -- green
    "#e6b455",  -- yellow
    "#6e98eb",    -- blue
    "#b480d6", -- magenta
    "#71c6e7",    -- cyan
    "#eeffff",   -- white
  },

  -- Bright ANSI colors
  brights = {
    "#546e7a",   -- bright black
    "#f07178",     -- bright red
    "#c3e88d",   -- bright green
    "#ffcb6b",  -- bright yellow
    "#82aaff",    -- bright blue
    "#c792ea", -- bright magenta
    "#89ddff",    -- bright cyan
    "#eeffff",   -- bright white
  },

  -- Tab bar
  tab_bar = {
    background = "#314549",
    active_tab = {
      bg_color = "#25363b",
      fg_color = "#11bba3",
      intensity = "Bold",
    },
    inactive_tab = {
      bg_color = "#314549",
      fg_color = "#546e7a",
    },
    inactive_tab_hover = {
      bg_color = "#355058",
      fg_color = "#11bba3",
      italic = false,
    },
    new_tab = {
      bg_color = "#314549",
      fg_color = "#11bba3",
    },
    new_tab_hover = {
      bg_color = "#355058",
      fg_color = "#11bba3",
      italic = false,
    },
  },

  -- Scrollbar
  scrollbar_thumb = "#546e7a",

  -- Split lines
  split = "#546e7a",
}

return M
