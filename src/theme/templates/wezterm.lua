-- {{THEME_NAME}} theme for WezTerm
-- Generated from template - do not edit directly

local M = {}

M.colors = {
  -- Basic colors
  foreground = "{{fg}}",
  background = "{{bg}}",
  cursor_bg = "{{cursor}}",
  cursor_fg = "{{bg}}",
  cursor_border = "{{cursor}}",
  selection_fg = "{{fg}}",
  selection_bg = "{{selection_bg}}",

  -- ANSI colors
  ansi = {
    "{{black}}",   -- black
    "{{red}}",     -- red
    "{{green}}",   -- green
    "{{yellow}}",  -- yellow
    "{{blue}}",    -- blue
    "{{magenta}}", -- magenta
    "{{cyan}}",    -- cyan
    "{{white}}",   -- white
  },

  -- Bright ANSI colors
  brights = {
    "{{bright_black}}",   -- bright black
    "{{bright_red}}",     -- bright red
    "{{bright_green}}",   -- bright green
    "{{bright_yellow}}",  -- bright yellow
    "{{bright_blue}}",    -- bright blue
    "{{bright_magenta}}", -- bright magenta
    "{{bright_cyan}}",    -- bright cyan
    "{{bright_white}}",   -- bright white
  },

  -- Tab bar
  tab_bar = {
    background = "{{surface}}",
    active_tab = {
      bg_color = "{{bg}}",
      fg_color = "{{accent}}",
      intensity = "Bold",
    },
    inactive_tab = {
      bg_color = "{{surface}}",
      fg_color = "{{muted}}",
    },
    inactive_tab_hover = {
      bg_color = "{{border}}",
      fg_color = "{{accent}}",
      italic = false,
    },
    new_tab = {
      bg_color = "{{surface}}",
      fg_color = "{{accent}}",
    },
    new_tab_hover = {
      bg_color = "{{border}}",
      fg_color = "{{accent}}",
      italic = false,
    },
  },

  -- Scrollbar
  scrollbar_thumb = "{{bright_black}}",

  -- Split lines
  split = "{{bright_black}}",
}

return M
