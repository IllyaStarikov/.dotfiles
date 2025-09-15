-- Backup, swap, and undo settings

local opt = vim.opt
local fn = vim.fn

-- Disable backup files
opt.backup = false
opt.writebackup = false
opt.swapfile = false

-- Persistent undo
opt.undofile = true
opt.undolevels = 10000
opt.undodir = fn.stdpath("data") .. "/undo"

-- Ensure required directories exist
local data_dir = fn.stdpath("data")
local config_dir = fn.stdpath("config")
local required_dirs = {
  data_dir .. "/undo",
  data_dir .. "/backup",
  data_dir .. "/swap",
  data_dir .. "/sessions",
  config_dir .. "/spell",
}

for _, dir in ipairs(required_dirs) do
  if fn.isdirectory(dir) == 0 then
    fn.mkdir(dir, "p")
  end
end
