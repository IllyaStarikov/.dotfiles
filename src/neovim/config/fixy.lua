-- Fixy formatter integration for Neovim
-- Provides async formatting with the fixy script
-- Production-ready with comprehensive error handling and notification suppression

local M = {}

-- Configuration
local config = {
	enabled = false, -- Auto-format disabled by default (must be explicitly enabled)
	cmd = vim.fn.expand("~/.dotfiles/src/scripts/fixy"),
	timeout = 5000, -- 5 seconds timeout
	notifications = false, -- Disable notifications for silent operation
	notify_on_error = true, -- Still notify on errors
	debug = false, -- Enable debug logging to /tmp/fixy.log
}

-- Debug logging helper
local function debug_log(msg)
	if config.debug then
		local file = io.open("/tmp/fixy.log", "a")
		if file then
			file:write(os.date("%Y-%m-%d %H:%M:%S") .. " - " .. msg .. "\n")
			file:close()
		end
	end
end

-- Check if fixy command exists
local function fixy_exists()
	return vim.fn.executable(config.cmd) == 1
end

-- Format the current buffer with fixy
function M.format_buffer()
	-- Validate environment first
	if not fixy_exists() then
		if config.notify_on_error then
			vim.notify("Fixy not found at: " .. config.cmd, vim.log.levels.ERROR)
		end
		return
	end

	-- Don't format if another format is already in progress on this buffer
	local bufnr = vim.api.nvim_get_current_buf()
	if vim.b[bufnr]._fixy_formatting then
		debug_log("Format already in progress for buffer " .. bufnr)
		return
	end

	local filepath = vim.fn.expand("%:p")
	if filepath == "" then
		if config.notify_on_error then
			vim.notify("No file to format", vim.log.levels.WARN)
		end
		return
	end

	-- Validate buffer and window state
	if not vim.api.nvim_buf_is_valid(bufnr) then
		debug_log("Invalid buffer " .. bufnr)
		return
	end

	local winnr = vim.api.nvim_get_current_win()
	if not vim.api.nvim_win_is_valid(winnr) then
		debug_log("Invalid window " .. winnr)
		return
	end

	-- Set the global flag IMMEDIATELY before any operations
	vim.g._fixy_formatting = true
	-- Also set a buffer-local flag for extra safety
	vim.b[bufnr]._fixy_formatting = true

	debug_log("Starting format for buffer " .. bufnr .. " file: " .. filepath)

	-- Store original notification state for restoration
	local notification_state = {
		original_notify = vim.notify,
		snacks_state = nil,
		noice_state = nil,
	}

	-- Disable Snacks.nvim notifications
	local snacks_ok, snacks = pcall(require, "snacks")
	if snacks_ok and snacks then
		notification_state.snacks_state = {
			notifier_enabled = false,
			notify_func = nil,
			notifier_notify_func = nil,
		}

		-- Save and disable notifier config
		if snacks.config and snacks.config.notifier then
			notification_state.snacks_state.notifier_enabled = snacks.config.notifier.enabled
			snacks.config.notifier.enabled = false
		end

		-- Save and disable notify function
		if snacks.notify then
			notification_state.snacks_state.notify_func = snacks.notify
			snacks.notify = function() end
		end

		-- Save and disable notifier module
		if snacks.notifier and snacks.notifier.notify then
			notification_state.snacks_state.notifier_notify_func = snacks.notifier.notify
			snacks.notifier.notify = function() end
		end
	end

	-- Also handle noice.nvim if present
	local noice_ok, noice = pcall(require, "noice")
	if noice_ok and noice then
		notification_state.noice_state = {
			enabled = vim.g.noice_enabled,
		}
		vim.g.noice_enabled = false
	end

	-- Replace vim.notify to suppress ALL notifications
	vim.notify = function(msg, level)
		-- Complete silence during formatting
		-- Log suppressed notifications for debugging
		if config.debug and msg then
			debug_log("Suppressed notification: " .. tostring(msg))
		end
	end

	-- Track the latest cursor position in case user continues typing
	local latest_cursor = vim.api.nvim_win_get_cursor(winnr)
	local latest_view = vim.fn.winsaveview()

	-- Set up a one-time autocmd to capture cursor position right before formatting applies
	local cursor_track_group = vim.api.nvim_create_augroup("FixyCursorTrack" .. bufnr, { clear = true })
	vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI", "TextChanged", "TextChangedI" }, {
		group = cursor_track_group,
		buffer = bufnr,
		callback = function()
			-- Update latest cursor position as user types/moves
			if vim.api.nvim_get_current_buf() == bufnr then
				latest_cursor = vim.api.nvim_win_get_cursor(0)
				latest_view = vim.fn.winsaveview()
			end
		end,
	})

	-- Function to restore notification state
	local function restore_notifications()
		-- Restore vim.notify
		vim.notify = notification_state.original_notify

		-- Restore Snacks.nvim
		if notification_state.snacks_state then
			local snacks_ok, snacks = pcall(require, "snacks")
			if snacks_ok and snacks then
				if notification_state.snacks_state.notify_func then
					snacks.notify = notification_state.snacks_state.notify_func
				end
				if snacks.notifier and notification_state.snacks_state.notifier_notify_func then
					snacks.notifier.notify = notification_state.snacks_state.notifier_notify_func
				end
				if snacks.config and snacks.config.notifier then
					snacks.config.notifier.enabled = notification_state.snacks_state.notifier_enabled
				end
			end
		end

		-- Restore noice.nvim
		if notification_state.noice_state then
			vim.g.noice_enabled = notification_state.noice_state.enabled
		end

		debug_log("Notifications restored")
	end

	-- Function to cleanup formatting state
	local function cleanup_formatting_state()
		vim.g._fixy_formatting = nil
		if vim.api.nvim_buf_is_valid(bufnr) then
			vim.b[bufnr]._fixy_formatting = nil
		end
		debug_log("Formatting state cleaned up for buffer " .. bufnr)
	end

	-- Run fixy asynchronously with timeout protection
	local job_id = nil
	local timeout_timer = nil

	-- Set up timeout handler (vim.defer_fn returns a timer handle)
	timeout_timer = vim.defer_fn(function()
		if job_id and job_id > 0 then
			vim.fn.jobstop(job_id)
			debug_log("Format job timed out for buffer " .. bufnr)
			cleanup_formatting_state()
			restore_notifications()
			if config.notify_on_error then
				notification_state.original_notify("Fixy formatting timed out", vim.log.levels.WARN)
			end
		end
	end, config.timeout)

	job_id = vim.fn.jobstart({ config.cmd, filepath }, {
		on_exit = function(_, exit_code, _)
			-- Cancel timeout timer (no need to stop defer_fn timers, they auto-cleanup)
			timeout_timer = nil

			vim.schedule(function()
				-- Clear cursor tracking autocmd safely
				pcall(vim.api.nvim_del_augroup_by_id, cursor_track_group)

				if exit_code == 0 then
					-- Only proceed if buffer is still valid
					if not vim.api.nvim_buf_is_valid(bufnr) then
						return
					end

					-- Read the formatted content
					local ok, formatted_lines = pcall(vim.fn.readfile, filepath)
					if not ok then
						return
					end

					-- Get current content
					local current_lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

					-- Check if content actually changed
					local content_changed = false
					if #formatted_lines ~= #current_lines then
						content_changed = true
					else
						for i, line in ipairs(formatted_lines) do
							if line ~= current_lines[i] then
								content_changed = true
								break
							end
						end
					end

					if content_changed then
						-- Get the absolute latest cursor position right before we update
						if vim.api.nvim_win_is_valid(winnr) and vim.api.nvim_get_current_buf() == bufnr then
							latest_cursor = vim.api.nvim_win_get_cursor(winnr)
							latest_view = vim.fn.winsaveview()
						end

						-- Mark globally and buffer-locally that fixy is formatting to prevent notifications
						vim.g._fixy_formatting = true
						vim.b[bufnr]._fixy_formatting = true

						-- No need to disable autocommands, the global flag will handle it

						-- Perform buffer operations
						vim.api.nvim_buf_call(bufnr, function()
							-- Save current undo state
							local undolevels = vim.bo.undolevels
							vim.bo.undolevels = -1

							-- Make buffer modifiable
							local modifiable = vim.bo.modifiable
							vim.bo.modifiable = true

							-- Update buffer lines directly
							vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, formatted_lines)

							-- Clear modified flag
							vim.bo.modified = false

							-- Restore undo levels
							vim.bo.undolevels = undolevels

							-- Restore modifiable state
							vim.bo.modifiable = modifiable
						end)

						-- Restore cursor to the LATEST position
						if vim.api.nvim_win_is_valid(winnr) and vim.api.nvim_win_get_buf(winnr) == bufnr then
							vim.api.nvim_win_call(winnr, function()
								-- Ensure cursor line is within bounds after formatting
								local line_count = vim.api.nvim_buf_line_count(bufnr)
								if latest_cursor[1] > line_count then
									latest_cursor[1] = line_count
								end

								pcall(vim.fn.winrestview, latest_view)
								pcall(vim.api.nvim_win_set_cursor, winnr, latest_cursor)
							end)
						end

						-- Clear formatting flags and restore notify after a delay
						vim.defer_fn(function()
							cleanup_formatting_state()
							restore_notifications()
						end, 500) -- Increased delay to 500ms for safety
					end

					if config.notifications and content_changed then
						-- Use original_notify if we want to show success
						notification_state.original_notify("Formatted with fixy", vim.log.levels.INFO)
					end
				else
					debug_log("Fixy formatting failed with exit code: " .. exit_code)
					if config.notify_on_error then
						notification_state.original_notify(
							"Fixy formatting failed (exit code: " .. exit_code .. ")",
							vim.log.levels.ERROR
						)
					end
					-- Clear formatting flags on error too
					vim.defer_fn(function()
						cleanup_formatting_state()
						restore_notifications()
					end, 100)
				end
			end)
		end,
		on_stderr = function(_, data, _)
			if data and #data > 0 and data[1] ~= "" then
				vim.schedule(function()
					local error_msg = table.concat(data, "\n")
					debug_log("Fixy stderr: " .. error_msg)
					if config.notify_on_error then
						notification_state.original_notify("Fixy error: " .. error_msg, vim.log.levels.ERROR)
					end
				end)
			end
		end,
	})

	if job_id <= 0 then
		debug_log("Failed to start fixy job")
		if config.notify_on_error then
			notification_state.original_notify("Failed to start fixy", vim.log.levels.ERROR)
		end
		-- Clear flags and restore notify if job failed to start
		cleanup_formatting_state()
		restore_notifications()

		-- Timeout timer auto-cleans up, just clear reference
		timeout_timer = nil
	else
		debug_log("Fixy job started with ID: " .. job_id)
	end
end

-- Format on save if auto-format is enabled
function M.format_on_save()
	if config.enabled then
		M.format_buffer()
	end
end

-- Toggle auto-formatting
function M.toggle_auto()
	config.enabled = not config.enabled
	local status = config.enabled and "enabled" or "disabled"
	-- Always show toggle notifications (user action)
	vim.notify("Fixy auto-format " .. status, vim.log.levels.INFO)
end

-- Enable auto-formatting
function M.enable_auto()
	config.enabled = true
	-- Always show enable notifications (user action)
	vim.notify("Fixy auto-format enabled", vim.log.levels.INFO)
end

-- Disable auto-formatting
function M.disable_auto()
	config.enabled = false
	-- Always show disable notifications (user action)
	vim.notify("Fixy auto-format disabled", vim.log.levels.INFO)
end

-- Get current status
function M.status()
	return config.enabled
end

-- Get debug status
function M.debug_status()
	return config.debug
end

-- Toggle debug mode
function M.toggle_debug()
	config.debug = not config.debug
	local status = config.debug and "enabled" or "disabled"
	vim.notify("Fixy debug mode " .. status .. (config.debug and " (logs to /tmp/fixy.log)" or ""), vim.log.levels.INFO)
end

-- Setup function to initialize fixy integration
function M.setup(opts)
	opts = opts or {}

	-- Merge user config
	config = vim.tbl_deep_extend("force", config, opts)

	-- Validate configuration
	if config.timeout < 1000 then
		config.timeout = 1000 -- Minimum 1 second timeout
	elseif config.timeout > 60000 then
		config.timeout = 60000 -- Maximum 60 seconds timeout
	end

	-- Create commands
	vim.api.nvim_create_user_command("Fixy", function()
		M.format_buffer()
	end, { desc = "Format current file with fixy" })

	vim.api.nvim_create_user_command("FixyAuto", function()
		M.toggle_auto()
	end, { desc = "Toggle fixy auto-format on save" })

	vim.api.nvim_create_user_command("FixyAutoOn", function()
		M.enable_auto()
	end, { desc = "Enable fixy auto-format on save" })

	vim.api.nvim_create_user_command("FixyAutoOff", function()
		M.disable_auto()
	end, { desc = "Disable fixy auto-format on save" })

	vim.api.nvim_create_user_command("FixyStatus", function()
		local status = config.enabled and "enabled" or "disabled"
		local debug = config.debug and " (debug mode on)" or ""
		vim.notify("Fixy auto-format is " .. status .. debug, vim.log.levels.INFO)
	end, { desc = "Show fixy auto-format status" })

	vim.api.nvim_create_user_command("FixyDebug", function()
		M.toggle_debug()
	end, { desc = "Toggle fixy debug mode" })

	-- Set up autocommand for format on save
	local augroup = vim.api.nvim_create_augroup("FixyAutoFormat", { clear = true })

	vim.api.nvim_create_autocmd("BufWritePost", {
		group = augroup,
		pattern = "*",
		callback = function()
			-- Skip certain file types and special buffers
			local ft = vim.bo.filetype
			local buftype = vim.bo.buftype

			-- Skip special buffers
			if buftype ~= "" then
				return
			end

			-- Skip certain filetypes (you can customize this list)
			local skip_filetypes = {
				"gitcommit",
				"gitrebase",
				"svn",
				"hgcommit",
				"oil",
				"TelescopePrompt",
				"TelescopeResults",
				"dashboard",
				"alpha",
				"NvimTree",
				"neo-tree",
			}

			for _, skip_ft in ipairs(skip_filetypes) do
				if ft == skip_ft then
					return
				end
			end

			-- Format the file
			M.format_on_save()
		end,
		desc = "Auto-format with fixy on save",
	})

	-- Optionally set up keybinding
	vim.keymap.set("n", "<leader>cf", M.format_buffer, { desc = "Format with fixy" })
end

-- Auto-initialize on module load
M.setup()

return M
