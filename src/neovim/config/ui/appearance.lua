-- UI and appearance settings

local opt = vim.opt
local g = vim.g

-- Display settings
opt.linebreak = true     -- Default: false (wrap at word boundaries)
opt.formatoptions:remove("t")  -- Don't auto-wrap text

-- GUI font settings with ligature support
if vim.fn.has("gui_running") == 1 or vim.g.neovide then
  opt.guifont = "JetBrainsMono Nerd Font:h18"
  -- Enable ligatures in Neovide
  if vim.g.neovide then
    vim.g.neovide_ligatures = true
  end
end

-- Unicode and encoding
opt.fileencoding = "utf-8"  -- Default: "" (ensure files saved as UTF-8)

-- Ensure terminal supports unicode
if vim.fn.has("multi_byte") == 1 then
  if vim.o.encoding ~= "utf-8" then
    vim.o.encoding = "utf-8"
  end
end

-- Tell Neovim we have a nerd font
g.have_nerd_font = true

-- UI elements
opt.number = true           -- Default: false (show line numbers)
opt.relativenumber = true   -- Default: false (relative line numbers)
opt.signcolumn = "yes"      -- Default: "auto" (always show to avoid shifting)
opt.cursorline = true       -- Default: false (highlight current line)
opt.colorcolumn = "100"     -- Default: "" (visual line length guide)
opt.termguicolors = true    -- Default: false (24-bit RGB colors)
opt.pumheight = 10          -- Default: 0 (limit popup menu height)
opt.splitbelow = true       -- Default: false (new splits below)
opt.splitright = true       -- Default: false (new splits right)
opt.splitkeep = "screen"    -- Default: "cursor" (keep screen position on split)

-- Text display
opt.showbreak = "↪ "        -- Default: "" (visual indicator for wrapped lines)

-- Whitespace visibility
opt.list = true
opt.listchars = {
  tab = "→ ",
  nbsp = "·",
  trail = "·",
  extends = "›",
  precedes = "‹",
  eol = "¬",
}

-- Bracket/parenthesis matching
opt.showmatch = true -- Default: false (highlight matching brackets)
opt.matchtime = 2    -- Default: 5 (faster match display, in tenths of second)

-- Cursor behavior
opt.guicursor = "n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50"
  .. ",a:blinkwait700-blinkoff400-blinkon250"
  .. ",sm:block-blinkwait175-blinkoff150-blinkon175"
