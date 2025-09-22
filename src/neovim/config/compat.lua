--
-- config/compat.lua
-- Compatibility layer for older Neovim versions
--

local M = {}

-- Check if we're running Neovim 0.7+
M.has_nvim_07 = vim.fn.has("nvim-0.7") == 1

-- Safe wrapper for nvim_create_autocmd (requires 0.7+)
M.create_autocmd = function(event, opts)
	if vim.api.nvim_create_autocmd then
		return vim.api.nvim_create_autocmd(event, opts)
	elseif vim.cmd then
		-- Fallback for older versions - create a basic autocmd
		local group = opts.group and ("augroup " .. opts.group) or ""
		local pattern = opts.pattern and table.concat(opts.pattern, ",") or "*"
		local cmd = string.format("autocmd %s %s %s", event, pattern, opts.command or "")

		if group ~= "" then
			vim.cmd(group)
			vim.cmd("autocmd!")
		end

		if opts.command then
			vim.cmd(cmd)
		elseif opts.callback then
			-- Can't easily support callbacks in old versions, skip
			return nil
		end

		if group ~= "" then
			vim.cmd("augroup END")
		end
	end
	return nil
end

-- Safe wrapper for nvim_create_augroup (requires 0.7+)
M.create_augroup = function(name, opts)
	if vim.api.nvim_create_augroup then
		return vim.api.nvim_create_augroup(name, opts)
	else
		-- Fallback for older versions
		vim.cmd("augroup " .. name)
		if opts and opts.clear then
			vim.cmd("autocmd!")
		end
		vim.cmd("augroup END")
		return name
	end
end

-- Safe wrapper for nvim_create_user_command (requires 0.7+)
M.create_user_command = function(name, command, opts)
	if vim.api.nvim_create_user_command then
		return vim.api.nvim_create_user_command(name, command, opts)
	else
		-- Fallback for older versions
		local cmd_string = "command"
		if opts then
			if opts.nargs then
				cmd_string = cmd_string .. " -nargs=" .. opts.nargs
			end
			if opts.bang then
				cmd_string = cmd_string .. " -bang"
			end
			if opts.range then
				cmd_string = cmd_string .. " -range"
			end
		end
		cmd_string = cmd_string .. " " .. name

		if type(command) == "string" then
			cmd_string = cmd_string .. " " .. command
		else
			-- Can't easily support function commands in old versions
			return
		end

		vim.cmd(cmd_string)
	end
end

-- Safe wrapper for nvim_exec2 (requires 0.9+)
M.exec2 = function(cmd, opts)
	if vim.api.nvim_exec2 then
		return vim.api.nvim_exec2(cmd, opts)
	elseif vim.api.nvim_exec then
		-- Fallback for 0.7-0.8
		local output = vim.api.nvim_exec(cmd, opts and opts.output or false)
		return { output = output or "" }
	else
		-- Fallback for older versions
		vim.cmd(cmd)
		return { output = "" }
	end
end

return M
