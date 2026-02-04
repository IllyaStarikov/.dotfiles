-- GitHub Dark Default theme for WezTerm
-- Generated from template - do not edit directly

local M = {}

M.colors = {
  -- Basic colors
  foreground = "#e6edf3",
  background = "#0d1117",
  cursor_bg = "#e6edf3",
  cursor_fg = "#0d1117",
  cursor_border = "#e6edf3",
  selection_fg = "#e6edf3",
  selection_bg = "#30363d",

  -- ANSI colors
  ansi = {
    "#484f58",   -- black
    "#ff7b72",     -- red
    "#3fb950",   -- green
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
    "#56d364",   -- bright green
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
      fg_color = "#2f81f7",
      intensity = "Bold",
    },
    inactive_tab = {
      bg_color = "#161b22",
      fg_color = "#7d8590",
    },
    inactive_tab_hover = {
      bg_color = "#30363d",
      fg_color = "#2f81f7",
      italic = false,
    },
    new_tab = {
      bg_color = "#161b22",
      fg_color = "#2f81f7",
    },
    new_tab_hover = {
      bg_color = "#30363d",
      fg_color = "#2f81f7",
      italic = false,
    },
  },

  -- Scrollbar
  scrollbar_thumb = "#6e7681",

  -- Split lines
  split = "#6e7681",
}

return M
