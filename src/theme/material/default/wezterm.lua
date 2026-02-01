-- Material Default theme for WezTerm
-- Generated from template - do not edit directly

local M = {}

M.colors = {
  -- Basic colors
  foreground = "#eeffff",
  background = "#263238",
  cursor_bg = "#eeffff",
  cursor_fg = "#263238",
  cursor_border = "#eeffff",
  selection_fg = "#eeffff",
  selection_bg = "#546e7a",

  -- ANSI colors
  ansi = {
    "#546e7a",   -- black
    "#ff5370",     -- red
    "#c3e88d",   -- green
    "#ffcb6b",  -- yellow
    "#82aaff",    -- blue
    "#c792ea", -- magenta
    "#89ddff",    -- cyan
    "#ffffff",   -- white
  },

  -- Bright ANSI colors
  brights = {
    "#546e7a",   -- bright black
    "#ff5370",     -- bright red
    "#c3e88d",   -- bright green
    "#ffcb6b",  -- bright yellow
    "#82aaff",    -- bright blue
    "#c792ea", -- bright magenta
    "#89ddff",    -- bright cyan
    "#ffffff",   -- bright white
  },

  -- Tab bar
  tab_bar = {
    background = "#404a4f",
    active_tab = {
      bg_color = "#263238",
      fg_color = "#80cbc4",
      intensity = "Bold",
    },
    inactive_tab = {
      bg_color = "#404a4f",
      fg_color = "#546e7a",
    },
    inactive_tab_hover = {
      bg_color = "#546e7a",
      fg_color = "#80cbc4",
      italic = false,
    },
    new_tab = {
      bg_color = "#404a4f",
      fg_color = "#80cbc4",
    },
    new_tab_hover = {
      bg_color = "#546e7a",
      fg_color = "#80cbc4",
      italic = false,
    },
  },

  -- Scrollbar
  scrollbar_thumb = "#546e7a",

  -- Split lines
  split = "#546e7a",
}

return M
