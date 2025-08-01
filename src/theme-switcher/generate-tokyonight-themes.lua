#!/usr/bin/env lua

-- Add Tokyo Night path
package.path = package.path .. ";/Users/starikov/.dotfiles/tokyonight.nvim/lua/?.lua"

-- Function to create Alacritty theme content
local function create_alacritty_theme(variant, colors)
  local terminal = {
    black = colors.terminal_black or colors.bg_dark,
    red = colors.red,
    green = colors.green,
    yellow = colors.yellow,
    blue = colors.blue,
    magenta = colors.magenta or colors.purple,
    cyan = colors.cyan,
    white = colors.fg,
    black_bright = colors.dark3,
    red_bright = colors.red1,
    green_bright = colors.green1,
    yellow_bright = colors.orange,
    blue_bright = colors.blue1,
    magenta_bright = colors.magenta2 or colors.magenta,
    cyan_bright = colors.blue5,
    white_bright = colors.fg_dark,
  }
  
  local content = "# TokyoNight Alacritty Colors\n"
  content = content .. "# Variant: " .. variant .. "\n\n"
  
  content = content .. "[colors.primary]\n"
  content = content .. "background = '" .. colors.bg .. "'\n"
  content = content .. "foreground = '" .. colors.fg .. "'\n\n"
  
  content = content .. "[colors.normal]\n"
  content = content .. "black = '" .. terminal.black .. "'\n"
  content = content .. "red = '" .. terminal.red .. "'\n"
  content = content .. "green = '" .. terminal.green .. "'\n"
  content = content .. "yellow = '" .. terminal.yellow .. "'\n"
  content = content .. "blue = '" .. terminal.blue .. "'\n"
  content = content .. "magenta = '" .. terminal.magenta .. "'\n"
  content = content .. "cyan = '" .. terminal.cyan .. "'\n"
  content = content .. "white = '" .. terminal.white .. "'\n\n"
  
  content = content .. "[colors.bright]\n"
  content = content .. "black = '" .. terminal.black_bright .. "'\n"
  content = content .. "red = '" .. terminal.red_bright .. "'\n"
  content = content .. "green = '" .. terminal.green_bright .. "'\n"
  content = content .. "yellow = '" .. terminal.yellow_bright .. "'\n"
  content = content .. "blue = '" .. terminal.blue_bright .. "'\n"
  content = content .. "magenta = '" .. terminal.magenta_bright .. "'\n"
  content = content .. "cyan = '" .. terminal.cyan_bright .. "'\n"
  content = content .. "white = '" .. terminal.white_bright .. "'\n\n"
  
  content = content .. "[[colors.indexed_colors]]\n"
  content = content .. "index = 16\n"
  content = content .. "color = '" .. colors.orange .. "'\n\n"
  
  content = content .. "[[colors.indexed_colors]]\n"
  content = content .. "index = 17\n"
  content = content .. "color = '" .. colors.red1 .. "'\n"
  
  return content
end

-- Generate themes
local variants = {"storm", "moon", "night", "day"}

for _, variant in ipairs(variants) do
  print("Generating theme for: " .. variant)
  
  -- Validate variant name (alphanumeric only for safety)
  if not variant:match("^[%w_%-]+$") then
    print("Error: Invalid variant name '" .. variant .. "'. Skipping for security.")
    goto continue
  end
  
  -- Load colors
  local colors
  if variant == "day" then
    -- Day needs special handling
    local util = require("tokyonight.util")
    colors = vim.deepcopy(require("tokyonight.colors.storm"))
    util.invert(colors)
    colors.bg_dark = util.blend(colors.bg, 0.9, colors.fg)
    colors.bg_dark1 = util.blend(colors.bg_dark, 0.9, colors.fg)
  else
    colors = require("tokyonight.colors." .. variant)
  end
  
  -- Create theme
  local theme_content = create_alacritty_theme(variant, colors)
  
  -- Write file
  local output_dir = "/Users/starikov/.dotfiles/src/theme-switcher/themes/tokyonight_" .. variant .. "/alacritty"
  -- Use safer command with proper escaping
  os.execute("mkdir -p '" .. output_dir:gsub("'", "'\"'\"'") .. "'")
  
  local file = io.open(output_dir .. "/theme.toml", "w")
  if file then
    file:write(theme_content)
    file:close()
    print("Created: " .. output_dir .. "/theme.toml")
  else
    print("Error creating file for " .. variant)
  end
  
  ::continue::
end

print("Done!")