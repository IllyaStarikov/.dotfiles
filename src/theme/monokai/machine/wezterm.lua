-- Monokai Pro Machine theme for WezTerm
-- Generated from template - do not edit directly

local M = {}

M.colors = {
  -- Basic colors
  foreground = "#f2fffc",
  background = "#273136",
  cursor_bg = "#f2fffc",
  cursor_fg = "#273136",
  cursor_border = "#f2fffc",
  selection_fg = "#f2fffc",
  selection_bg = "#6b7678",

  -- ANSI colors
  ansi = {
    "#6b7678",   -- black
    "#ff6d7e",     -- red
    "#a2e57b",   -- green
    "#ffed72",  -- yellow
    "#7cd5f1",    -- blue
    "#baa0f8", -- magenta
    "#7cd5f1",    -- cyan
    "#f2fffc",   -- white
  },

  -- Bright ANSI colors
  brights = {
    "#8a9496",   -- bright black
    "#ff6d7e",     -- bright red
    "#a2e57b",   -- bright green
    "#ffed72",  -- bright yellow
    "#7cd5f1",    -- bright blue
    "#baa0f8", -- bright magenta
    "#7cd5f1",    -- bright cyan
    "#f2fffc",   -- bright white
  },

  -- Tab bar
  tab_bar = {
    background = "#40494e",
    active_tab = {
      bg_color = "#273136",
      fg_color = "#7cd5f1",
      intensity = "Bold",
    },
    inactive_tab = {
      bg_color = "#40494e",
      fg_color = "#8a9496",
    },
    inactive_tab_hover = {
      bg_color = "#6b7678",
      fg_color = "#7cd5f1",
      italic = false,
    },
    new_tab = {
      bg_color = "#40494e",
      fg_color = "#7cd5f1",
    },
    new_tab_hover = {
      bg_color = "#6b7678",
      fg_color = "#7cd5f1",
      italic = false,
    },
  },

  -- Scrollbar
  scrollbar_thumb = "#8a9496",

  -- Split lines
  split = "#8a9496",
}

return M
