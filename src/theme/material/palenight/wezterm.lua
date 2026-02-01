-- Material Palenight theme for WezTerm
-- Generated from template - do not edit directly

local M = {}

M.colors = {
  -- Basic colors
  foreground = "#a6accd",
  background = "#292d3e",
  cursor_bg = "#a6accd",
  cursor_fg = "#292d3e",
  cursor_border = "#a6accd",
  selection_fg = "#a6accd",
  selection_bg = "#676e95",

  -- ANSI colors
  ansi = {
    "#676e95",   -- black
    "#f07178",     -- red
    "#c3e88d",   -- green
    "#ffcb6b",  -- yellow
    "#82aaff",    -- blue
    "#c792ea", -- magenta
    "#89ddff",    -- cyan
    "#ffffff",   -- white
  },

  -- Bright ANSI colors
  brights = {
    "#676e95",   -- bright black
    "#f07178",     -- bright red
    "#c3e88d",   -- bright green
    "#ffcb6b",  -- bright yellow
    "#82aaff",    -- bright blue
    "#c792ea", -- bright magenta
    "#89ddff",    -- bright cyan
    "#ffffff",   -- bright white
  },

  -- Tab bar
  tab_bar = {
    background = "#424655",
    active_tab = {
      bg_color = "#292d3e",
      fg_color = "#c792ea",
      intensity = "Bold",
    },
    inactive_tab = {
      bg_color = "#424655",
      fg_color = "#676e95",
    },
    inactive_tab_hover = {
      bg_color = "#676e95",
      fg_color = "#c792ea",
      italic = false,
    },
    new_tab = {
      bg_color = "#424655",
      fg_color = "#c792ea",
    },
    new_tab_hover = {
      bg_color = "#676e95",
      fg_color = "#c792ea",
      italic = false,
    },
  },

  -- Scrollbar
  scrollbar_thumb = "#676e95",

  -- Split lines
  split = "#676e95",
}

return M
