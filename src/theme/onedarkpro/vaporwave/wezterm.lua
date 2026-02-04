-- One Dark Pro Vaporwave theme for WezTerm
-- Generated from template - do not edit directly

local M = {}

M.colors = {
  -- Basic colors
  foreground = "#b4b7cf",
  background = "#222435",
  cursor_bg = "#b4b7cf",
  cursor_fg = "#222435",
  cursor_border = "#b4b7cf",
  selection_fg = "#b4b7cf",
  selection_bg = "#585b89",

  -- ANSI colors
  ansi = {
    "#585b89",   -- black
    "#e16765",     -- red
    "#75be78",   -- green
    "#eaa041",  -- yellow
    "#25abe4",    -- blue
    "#c678dd", -- magenta
    "#46a3af",    -- cyan
    "#b4b7cf",   -- white
  },

  -- Bright ANSI colors
  brights = {
    "#7679a7",   -- bright black
    "#e16765",     -- bright red
    "#75be78",   -- bright green
    "#eae852",  -- bright yellow
    "#25abe4",    -- bright blue
    "#c678dd", -- bright magenta
    "#46a3af",    -- bright cyan
    "#b4b7cf",   -- bright white
  },

  -- Tab bar
  tab_bar = {
    background = "#2a2c44",
    active_tab = {
      bg_color = "#222435",
      fg_color = "#25abe4",
      intensity = "Bold",
    },
    inactive_tab = {
      bg_color = "#2a2c44",
      fg_color = "#7679a7",
    },
    inactive_tab_hover = {
      bg_color = "#585b89",
      fg_color = "#25abe4",
      italic = false,
    },
    new_tab = {
      bg_color = "#2a2c44",
      fg_color = "#25abe4",
    },
    new_tab_hover = {
      bg_color = "#585b89",
      fg_color = "#25abe4",
      italic = false,
    },
  },

  -- Scrollbar
  scrollbar_thumb = "#7679a7",

  -- Split lines
  split = "#7679a7",
}

return M
