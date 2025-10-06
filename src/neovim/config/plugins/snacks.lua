--
-- config/snacks.lua
-- HIGH-PERFORMANCE snacks.nvim configuration
-- Comprehensive productivity and quality-of-life features
--

local M = {}

function M.setup()
	-- Enable Snacks.nvim with file explorer support
	local ok, snacks = pcall(require, "snacks")
	if not ok then
		vim.notify("Failed to load snacks.nvim", vim.log.levels.WARN)
		return
	end

	snacks.setup({
		-- Core modules
		bigfile = { enabled = true },

		-- Picker configuration with vim.ui overrides
		picker = {
			enabled = true,
		},

		explorer = {
			enabled = true,
			replace_netrw = true, -- Replace netrw with Snacks explorer
		},

		-- Dashboard configuration with proper setup
		dashboard = {
			enabled = true,
			width = 64, -- Increased width to accommodate ASCII art
			preset = {
				header = [[
███╗   ███╗██╗   ██╗████████╗██╗███╗   ██╗██╗   ██╗
████╗ ████║██║   ██║╚══██╔══╝██║████╗  ██║╚██╗ ██╔╝
██╔████╔██║██║   ██║   ██║   ██║██╔██╗ ██║ ╚████╔╝
██║╚██╔╝██║██║   ██║   ██║   ██║██║╚██╗██║  ╚██╔╝
██║ ╚═╝ ██║╚██████╔╝   ██║   ██║██║ ╚████║   ██║
╚═╝     ╚═╝ ╚═════╝    ╚═╝   ╚═╝╚═╝  ╚═══╝   ╚═╝   ]],
			},
			sections = {
				{ section = "header" },
				{
					section = "keys",
					gap = 1,
					padding = 1,
					keys = {
						-- Use telescope for all file operations to avoid picker conflicts
						{
							icon = " ",
							key = "f",
							desc = "Find File",
							action = ":Telescope find_files",
						},
						{
							icon = " ",
							key = "r",
							desc = "Recent Files",
							action = ":Telescope oldfiles",
						},
						{
							icon = " ",
							key = "g",
							desc = "Find Text",
							action = ":Telescope live_grep",
						},
						{
							icon = " ",
							key = "b",
							desc = "Buffers",
							action = ":Telescope buffers",
						},
						{
							icon = " ",
							key = "c",
							desc = "Config",
							action = function()
								require("telescope.builtin").find_files({
									cwd = vim.fn.stdpath("config"),
								})
							end,
						},
						{
							icon = " ",
							key = ".",
							desc = "Browse Files",
							action = function()
								local ok, snacks = pcall(require, "snacks")
								if ok and snacks then
									snacks.explorer()
								else
									vim.notify("Snacks not loaded", vim.log.levels.WARN)
								end
							end,
						},
						{ icon = " ", key = "q", desc = "Quit", action = ":confirm qa" },
					},
				},
				{ section = "startup" },
			},
		},

		-- Enable only safe modules that don't use picker
		indent = { enabled = true },
		scroll = { enabled = false }, -- Disabled for instant scrolling
		notifier = { enabled = true },
		words = { enabled = true },
		terminal = { enabled = true },
		toggle = { enabled = true },

		-- Input with vim.ui.input override
		input = {
			enabled = true,
		},

		git = { enabled = true },
		rename = { enabled = true },
		bufdelete = { enabled = true },
		scratch = { enabled = true },
		lazygit = { enabled = false }, -- Disable until lazygit is installed
	})

	-- Set up vim.ui overrides after setup (dressing.nvim is now disabled)
	-- Set directly to Snacks modules (required for healthcheck to pass)
	vim.ui.select = snacks.picker.select
	-- Snacks.input is a callable that returns the input handler
	vim.ui.input = require("snacks").input
end

return M
