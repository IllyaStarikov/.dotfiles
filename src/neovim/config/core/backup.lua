-- Backup, swap, and undo settings

local opt = vim.opt
local fn = vim.fn

-- Backup settings
opt.writebackup = false -- Default: true (disable for cleaner saves)
opt.swapfile = false -- Default: true (disable to avoid clutter)

-- Persistent undo
opt.undofile = true -- Default: false (enable persistent undo)
opt.undolevels = 50000 -- Default: 1000 (more undo history)
opt.undoreload = 50000 -- Default: 10000 (reload more lines)
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
