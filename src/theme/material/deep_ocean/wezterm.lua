-- Material Deep Ocean theme for WezTerm
-- Generated from template - do not edit directly

local M = {}

M.colors = {
  -- Basic colors
  foreground = "#a6accd",
  background = "#0f111a",
  cursor_bg = "#a6accd",
  cursor_fg = "#0f111a",
  cursor_border = "#a6accd",
  selection_fg = "#a6accd",
  selection_bg = "#1f2233",

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
    "#464b5d",   -- bright black
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
    background = "#1a1c25",
    active_tab = {
      bg_color = "#0f111a",
      fg_color = "#84ffff",
      intensity = "Bold",
    },
    inactive_tab = {
      bg_color = "#1a1c25",
      fg_color = "#464b5d",
    },
    inactive_tab_hover = {
      bg_color = "#232637",
      fg_color = "#84ffff",
      italic = false,
    },
    new_tab = {
      bg_color = "#1a1c25",
      fg_color = "#84ffff",
    },
    new_tab_hover = {
      bg_color = "#232637",
      fg_color = "#84ffff",
      italic = false,
    },
  },

  -- Scrollbar
  scrollbar_thumb = "#464b5d",

  -- Split lines
  split = "#464b5d",
}

return M
