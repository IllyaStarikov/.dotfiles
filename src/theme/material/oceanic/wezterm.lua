-- Material Oceanic theme for WezTerm
-- Generated from template - do not edit directly

local M = {}

M.colors = {
  -- Basic colors
  foreground = "#8f93a2",
  background = "#0f111a",
  cursor_bg = "#8f93a2",
  cursor_fg = "#0f111a",
  cursor_border = "#8f93a2",
  selection_fg = "#8f93a2",
  selection_bg = "#464b5d",

  -- ANSI colors
  ansi = {
    "#464b5d",   -- black
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
    "#464b5d",   -- bright black
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
    background = "#2b2d35",
    active_tab = {
      bg_color = "#0f111a",
      fg_color = "#82aaff",
      intensity = "Bold",
    },
    inactive_tab = {
      bg_color = "#2b2d35",
      fg_color = "#464b5d",
    },
    inactive_tab_hover = {
      bg_color = "#464b5d",
      fg_color = "#82aaff",
      italic = false,
    },
    new_tab = {
      bg_color = "#2b2d35",
      fg_color = "#82aaff",
    },
    new_tab_hover = {
      bg_color = "#464b5d",
      fg_color = "#82aaff",
      italic = false,
    },
  },

  -- Scrollbar
  scrollbar_thumb = "#464b5d",

  -- Split lines
  split = "#464b5d",
}

return M
