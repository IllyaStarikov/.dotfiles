-- GitHub Dark Tritanopia theme for WezTerm
-- Generated from template - do not edit directly

local M = {}

M.colors = {
  -- Basic colors
  foreground = "#c9d1d9",
  background = "#0d1117",
  cursor_bg = "#c9d1d9",
  cursor_fg = "#0d1117",
  cursor_border = "#c9d1d9",
  selection_fg = "#c9d1d9",
  selection_bg = "#30363d",

  -- ANSI colors
  ansi = {
    "#484f58",   -- black
    "#ff7b72",     -- red
    "#58a6ff",   -- green
    "#d29922",  -- yellow
    "#58a6ff",    -- blue
    "#bc8cff", -- magenta
    "#39c5cf",    -- cyan
    "#b1bac4",   -- white
  },

  -- Bright ANSI colors
  brights = {
    "#6e7681",   -- bright black
    "#ffa198",     -- bright red
    "#79c0ff",   -- bright green
    "#e3b341",  -- bright yellow
    "#79c0ff",    -- bright blue
    "#d2a8ff", -- bright magenta
    "#56d4dd",    -- bright cyan
    "#ffffff",   -- bright white
  },

  -- Tab bar
  tab_bar = {
    background = "#161b22",
    active_tab = {
      bg_color = "#0d1117",
      fg_color = "#58a6ff",
      intensity = "Bold",
    },
    inactive_tab = {
      bg_color = "#161b22",
      fg_color = "#8b949e",
    },
    inactive_tab_hover = {
      bg_color = "#30363d",
      fg_color = "#58a6ff",
      italic = false,
    },
    new_tab = {
      bg_color = "#161b22",
      fg_color = "#58a6ff",
    },
    new_tab_hover = {
      bg_color = "#30363d",
      fg_color = "#58a6ff",
      italic = false,
    },
  },

  -- Scrollbar
  scrollbar_thumb = "#6e7681",

  -- Split lines
  split = "#6e7681",
}

return M
