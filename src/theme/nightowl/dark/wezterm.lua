-- Night Owl Dark theme for WezTerm
-- Generated from template - do not edit directly

local M = {}

M.colors = {
  -- Basic colors
  foreground = "#d6deeb",
  background = "#011627",
  cursor_bg = "#d6deeb",
  cursor_fg = "#011627",
  cursor_border = "#d6deeb",
  selection_fg = "#d6deeb",
  selection_bg = "#1d3b53",

  -- ANSI colors
  ansi = {
    "#575656",   -- black
    "#ef5350",     -- red
    "#22da6e",   -- green
    "#addb67",  -- yellow
    "#82aaff",    -- blue
    "#c792ea", -- magenta
    "#21c7a8",    -- cyan
    "#ffffff",   -- white
  },

  -- Bright ANSI colors
  brights = {
    "#7a8181",   -- bright black
    "#ef5350",     -- bright red
    "#22da6e",   -- bright green
    "#ffeb95",  -- bright yellow
    "#82aaff",    -- bright blue
    "#c792ea", -- bright magenta
    "#7fdbca",    -- bright cyan
    "#ffffff",   -- bright white
  },

  -- Tab bar
  tab_bar = {
    background = "#1f3140",
    active_tab = {
      bg_color = "#011627",
      fg_color = "#82aaff",
      intensity = "Bold",
    },
    inactive_tab = {
      bg_color = "#1f3140",
      fg_color = "#7a8181",
    },
    inactive_tab_hover = {
      bg_color = "#1d3b53",
      fg_color = "#82aaff",
      italic = false,
    },
    new_tab = {
      bg_color = "#1f3140",
      fg_color = "#82aaff",
    },
    new_tab_hover = {
      bg_color = "#1d3b53",
      fg_color = "#82aaff",
      italic = false,
    },
  },

  -- Scrollbar
  scrollbar_thumb = "#7a8181",

  -- Split lines
  split = "#7a8181",
}

return M
