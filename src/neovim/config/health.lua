--
-- config/health.lua
-- Health check for Neovim configuration
--

local M = {}

-- Check if a module can be loaded
local function check_module(name)
	local ok, _ = pcall(require, name)
	return ok
end

-- Check if a command exists
local function check_command(cmd)
	return vim.fn.executable(cmd) == 1
end

function M.check()
	vim.health.start("Dotfiles Configuration")

	-- Check core modules
	vim.health.info("Checking core modules...")
	local core_modules = {
		"config.utils",
		"config.error-handler",
		"config.core",
		"config.ui",
		"config.keymaps",
		"config.autocmds",
		"config.plugins",
		"config.commands",
	}

	local all_core_ok = true
	for _, module in ipairs(core_modules) do
		if check_module(module) then
			vim.health.ok(module .. " loaded successfully")
		else
			vim.health.error(module .. " failed to load")
			all_core_ok = false
		end
	end

	if all_core_ok then
		vim.health.ok("All core modules loaded successfully")
	end

	-- Check external dependencies
	vim.health.info("Checking external dependencies...")
	local dependencies = {
		{ cmd = "git", required = true },
		{ cmd = "rg", required = true, name = "ripgrep" },
		{ cmd = "fd", required = false },
		{ cmd = "node", required = false },
		{ cmd = "npm", required = false },
		{ cmd = "python3", required = false },
		{ cmd = "pip3", required = false },
	}

	for _, dep in ipairs(dependencies) do
		local name = dep.name or dep.cmd
		if check_command(dep.cmd) then
			vim.health.ok(name .. " found")
		elseif dep.required then
			vim.health.error(name .. " not found (required)")
		else
			vim.health.warn(name .. " not found (optional)")
		end
	end

	-- Check plugin manager
	vim.health.info("Checking plugin manager...")
	local lazy_ok = check_module("lazy")
	if lazy_ok then
		vim.health.ok("lazy.nvim is installed")

		-- Check for common plugin issues
		local lazy = require("lazy")
		local stats = lazy.stats()
		if stats.count > 0 then
			vim.health.ok(string.format("Loaded %d plugins", stats.count))
		else
			vim.health.warn("No plugins loaded")
		end
	else
		vim.health.error("lazy.nvim not found")
	end

	-- Check LSP setup
	vim.health.info("Checking LSP configuration...")
	if check_module("lspconfig") then
		vim.health.ok("nvim-lspconfig is available")

		-- Check for active LSP clients
		local clients = vim.lsp.get_clients()
		if #clients > 0 then
			vim.health.ok(string.format("%d LSP client(s) active", #clients))
			for _, client in ipairs(clients) do
				vim.health.info("  - " .. client.name)
			end
		else
			vim.health.info("No active LSP clients")
		end
	else
		vim.health.warn("nvim-lspconfig not available")
	end

	-- Check completion
	vim.health.info("Checking completion setup...")
	if check_module("blink.cmp") then
		vim.health.ok("blink.cmp is available")
	elseif check_module("cmp") then
		vim.health.ok("nvim-cmp is available")
	else
		vim.health.warn("No completion plugin found")
	end

	-- Check critical keymaps
	vim.health.info("Checking critical keymaps...")
	local keymaps_to_check = {
		{ mode = "n", lhs = "<leader>", desc = "Leader key" },
		{ mode = "n", lhs = "<C-p>", desc = "File finder" },
		{ mode = "n", lhs = "<leader>T", desc = "Aerial toggle" },
	}

	for _, keymap in ipairs(keymaps_to_check) do
		local mapping = vim.fn.maparg(keymap.lhs, keymap.mode)
		if mapping ~= "" then
			vim.health.ok(keymap.desc .. " is mapped")
		else
			vim.health.warn(keymap.desc .. " is not mapped")
		end
	end

	-- Check work profile
	vim.health.info("Checking work profile...")
	local work = require("config.work")
	if work.is_work_env() then
		local profile = work.get_profile()
		vim.health.ok("Work profile active: " .. (profile.profile or "unknown"))
	else
		vim.health.info("No work profile active")
	end

	-- Check for startup errors
	local error_file = vim.fn.stdpath("state") .. "/startup_errors.log"
	if vim.fn.filereadable(error_file) == 1 then
		vim.health.warn("Startup errors detected. Run :ErrorLog to view")
	else
		vim.health.ok("No startup errors logged")
	end
end

-- Create health check command
vim.api.nvim_create_user_command("CheckHealth", function()
	vim.cmd("checkhealth config.health")
end, { desc = "Run configuration health check" })

return M
