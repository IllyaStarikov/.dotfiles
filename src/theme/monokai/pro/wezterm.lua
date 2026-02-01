-- Monokai Pro Pro theme for WezTerm
-- Generated from template - do not edit directly

local M = {}

M.colors = {
  -- Basic colors
  foreground = "#fcfcfa",
  background = "#2d2a2e",
  cursor_bg = "#fcfcfa",
  cursor_fg = "#2d2a2e",
  cursor_border = "#fcfcfa",
  selection_fg = "#fcfcfa",
  selection_bg = "#403e41",

  -- ANSI colors
  ansi = {
    "#403e41",   -- black
    "#ff6188",     -- red
    "#a9dc76",   -- green
    "#ffd866",  -- yellow
    "#78dce8",    -- blue
    "#ab9df2", -- magenta
    "#78dce8",    -- cyan
    "#fcfcfa",   -- white
  },

  -- Bright ANSI colors
  brights = {
    "#727072",   -- bright black
    "#ff6188",     -- bright red
    "#a9dc76",   -- bright green
    "#ffd866",  -- bright yellow
    "#78dce8",    -- bright blue
    "#ab9df2", -- bright magenta
    "#78dce8",    -- bright cyan
    "#fcfcfa",   -- bright white
  },

  -- Tab bar
  tab_bar = {
    background = "#464347",
    active_tab = {
      bg_color = "#2d2a2e",
      fg_color = "#ffd866",
      intensity = "Bold",
    },
    inactive_tab = {
      bg_color = "#464347",
      fg_color = "#727072",
    },
    inactive_tab_hover = {
      bg_color = "#403e41",
      fg_color = "#ffd866",
      italic = false,
    },
    new_tab = {
      bg_color = "#464347",
      fg_color = "#ffd866",
    },
    new_tab_hover = {
      bg_color = "#403e41",
      fg_color = "#ffd866",
      italic = false,
    },
  },

  -- Scrollbar
  scrollbar_thumb = "#727072",

  -- Split lines
  split = "#727072",
}

return M
