-- Material Darker theme for WezTerm
-- Generated from template - do not edit directly

local M = {}

M.colors = {
  -- Basic colors
  foreground = "#eeffff",
  background = "#212121",
  cursor_bg = "#eeffff",
  cursor_fg = "#212121",
  cursor_border = "#eeffff",
  selection_fg = "#eeffff",
  selection_bg = "#4a4a4a",

  -- ANSI colors
  ansi = {
    "#4a4a4a",   -- black
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
    "#4a4a4a",   -- bright black
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
    background = "#3b3b3b",
    active_tab = {
      bg_color = "#212121",
      fg_color = "#ff5370",
      intensity = "Bold",
    },
    inactive_tab = {
      bg_color = "#3b3b3b",
      fg_color = "#4a4a4a",
    },
    inactive_tab_hover = {
      bg_color = "#4a4a4a",
      fg_color = "#ff5370",
      italic = false,
    },
    new_tab = {
      bg_color = "#3b3b3b",
      fg_color = "#ff5370",
    },
    new_tab_hover = {
      bg_color = "#4a4a4a",
      fg_color = "#ff5370",
      italic = false,
    },
  },

  -- Scrollbar
  scrollbar_thumb = "#4a4a4a",

  -- Split lines
  split = "#4a4a4a",
}

return M
