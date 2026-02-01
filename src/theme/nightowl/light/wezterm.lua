-- Night Owl Light theme for WezTerm
-- Generated from template - do not edit directly

local M = {}

M.colors = {
  -- Basic colors
  foreground = "#403f53",
  background = "#fbfbfb",
  cursor_bg = "#403f53",
  cursor_fg = "#fbfbfb",
  cursor_border = "#403f53",
  selection_fg = "#403f53",
  selection_bg = "#e0e0e0",

  -- ANSI colors
  ansi = {
    "#90a7b2",   -- black
    "#de3d3b",     -- red
    "#08916a",   -- green
    "#e0af02",  -- yellow
    "#288ed7",    -- blue
    "#d6438a", -- magenta
    "#2aa298",    -- cyan
    "#ffffff",   -- white
  },

  -- Bright ANSI colors
  brights = {
    "#7a8181",   -- bright black
    "#de3d3b",     -- bright red
    "#08916a",   -- bright green
    "#daaa01",  -- bright yellow
    "#288ed7",    -- bright blue
    "#d6438a", -- bright magenta
    "#2aa298",    -- bright cyan
    "#ffffff",   -- bright white
  },

  -- Tab bar
  tab_bar = {
    background = "#e6e6e6",
    active_tab = {
      bg_color = "#fbfbfb",
      fg_color = "#4876d6",
      intensity = "Bold",
    },
    inactive_tab = {
      bg_color = "#e6e6e6",
      fg_color = "#7a8181",
    },
    inactive_tab_hover = {
      bg_color = "#e0e0e0",
      fg_color = "#4876d6",
      italic = false,
    },
    new_tab = {
      bg_color = "#e6e6e6",
      fg_color = "#4876d6",
    },
    new_tab_hover = {
      bg_color = "#e0e0e0",
      fg_color = "#4876d6",
      italic = false,
    },
  },

  -- Scrollbar
  scrollbar_thumb = "#7a8181",

  -- Split lines
  split = "#7a8181",
}

return M
