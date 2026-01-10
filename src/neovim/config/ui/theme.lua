--
-- config/theme.lua
-- Dynamic theme system with macOS integration
--
-- Features:
-- • Automatic theme switching based on macOS Dark/Light mode
-- • Support for Tokyo Night (primary) and GitHub (backup) themes
-- • Intelligent comment color adaptation for readability
-- • Real-time theme reloading when system appearance changes
-- • Fallback handling for missing theme configurations
--

-- =============================================================================
-- THEME CONFIGURATION FUNCTION
-- =============================================================================

--- Main theme setup function that reads macOS appearance and applies appropriate themes
--- @return nil
local function setup_theme()
	local config_file = vim.fn.expand("~/.config/theme-switcher/current-theme.sh")

	if vim.fn.filereadable(config_file) == 1 then
		-- Source the theme config and get environment variables
		local theme_cmd = "source " .. config_file .. " && echo $MACOS_THEME"
		local variant_cmd = "source " .. config_file .. " && echo $MACOS_VARIANT"
		-- MACOS_VARIANT is the single source of truth for light/dark

		local theme = vim.fn.system(theme_cmd):gsub("\n", "")
		local variant = vim.fn.system(variant_cmd):gsub("\n", "")

		-- Handle legacy format where theme is just "light" or "dark"
		if theme == "light" then
			theme = "tokyonight_day"
			variant = "light"
		elseif theme == "dark" then
			theme = "tokyonight_moon"
			variant = "dark"
		end

		-- Set background based on variant
		if variant == "dark" then
			vim.opt.background = "dark"
		else
			vim.opt.background = "light"
		end

		-- Apply colorscheme based on current theme
		if theme == "tokyonight_moon" then
			vim.opt.background = "dark"
			local ok, tokyonight = pcall(require, "tokyonight")
			if ok then
				tokyonight.setup({
					style = "moon",
					transparent = false,
					styles = {
						comments = { italic = true },
						keywords = { italic = true },
					},
				})
			end
			pcall(function() vim.cmd("colorscheme tokyonight-moon") end)
		-- vim.g.airline_theme = 'base16'
		elseif theme == "tokyonight_storm" then
			vim.opt.background = "dark"
			local ok, tokyonight = pcall(require, "tokyonight")
			if ok then
				tokyonight.setup({
					style = "storm",
					transparent = false,
					styles = {
						comments = { italic = true },
						keywords = { italic = true },
					},
				})
			end
			pcall(function() vim.cmd("colorscheme tokyonight-storm") end)
		-- vim.g.airline_theme = 'base16'
		elseif theme == "tokyonight_night" then
			vim.opt.background = "dark"
			-- Ensure Tokyo Night plugin is configured before loading
			local ok, tokyonight = pcall(require, "tokyonight")
			if ok then
				tokyonight.setup({
					style = "night",
					transparent = false,
					styles = {
						comments = { italic = true },
						keywords = { italic = true },
					},
				})
			end
			-- Set the style global for compatibility
			vim.g.tokyonight_style = "night"
			-- Try to load the colorscheme with error handling
			local status_ok = pcall(function() vim.cmd("colorscheme tokyonight-night") end)
			if not status_ok then
				-- Fallback to basic tokyonight command
				vim.cmd("colorscheme tokyonight")
			end
		-- vim.g.airline_theme = 'base16'
		elseif theme == "tokyonight_day" then
			vim.opt.background = "light"
			local ok, tokyonight = pcall(require, "tokyonight")
			if ok then
				tokyonight.setup({
					style = "day",
					transparent = false,
					styles = {
						comments = { italic = true },
						keywords = { italic = true },
					},
				})
			end
			pcall(function() vim.cmd("colorscheme tokyonight-day") end)
		-- vim.g.airline_theme = 'base16'
		else
			-- Default fallback to Tokyo Night Moon
			vim.opt.background = "dark"
			local ok, tokyonight = pcall(require, "tokyonight")
			if ok then
				tokyonight.setup({
					style = "moon",
					transparent = false,
					styles = {
						comments = { italic = true },
						keywords = { italic = true },
					},
				})
			end
			pcall(function() vim.cmd("colorscheme tokyonight-moon") end)
		end
	else
		-- Default to dark theme if config file doesn't exist
		vim.opt.background = "dark"
		local ok, tokyonight = pcall(require, "tokyonight")
		if ok then
			tokyonight.setup({
				style = "moon",
				transparent = false,
				styles = {
					comments = { italic = true },
					keywords = { italic = true },
				},
			})
		end
		vim.cmd("colorscheme tokyonight-moon")
		-- vim.g.airline_theme = 'base16'
	end

	-- Apply intelligent syntax highlighting optimizations
	vim.schedule(function()
		local current_bg = vim.o.background

		-- Smart comment colors based on background
		if current_bg == "dark" then
			-- Dark background: lighter, more visible comment colors
			vim.cmd("highlight Comment guifg=#6272A4 ctermfg=61 cterm=italic gui=italic")
			vim.cmd("highlight CommentDoc guifg=#7289DA ctermfg=68 cterm=italic gui=italic")
		else
			-- Light background: darker, high-contrast comment colors
			vim.cmd("highlight Comment guifg=#5C6370 ctermfg=59 cterm=italic gui=italic")
			vim.cmd("highlight CommentDoc guifg=#4078C0 ctermfg=32 cterm=italic gui=italic")
		end

		-- Light theme syntax optimizations for better readability
		if current_bg == "light" then
			vim.cmd("highlight String guifg=#032F62 ctermfg=28") -- Dark blue strings
			vim.cmd("highlight Number guifg=#0451A5 ctermfg=26") -- Blue numbers
			vim.cmd("highlight Constant guifg=#0451A5 ctermfg=26") -- Blue constants
			vim.cmd("highlight PreProc guifg=#AF00DB ctermfg=129") -- Purple preprocessor
			vim.cmd("highlight Type guifg=#0451A5 ctermfg=26") -- Blue types
			vim.cmd("highlight Special guifg=#FF6600 ctermfg=202") -- Orange special chars
		end

		-- Theme changes are automatically applied by mini.statusline
	end)
end

-- =============================================================================
-- INITIALIZATION AND AUTO-RELOAD
-- =============================================================================

-- Apply theme configuration on startup
setup_theme()

-- Auto-reload theme when the config file changes
vim.api.nvim_create_autocmd("BufWritePost", {
	pattern = vim.fn.expand("~/.config/theme-switcher/current-theme.sh"),
	callback = setup_theme,
	group = vim.api.nvim_create_augroup("ThemeReload", { clear = true }),
})

-- =============================================================================
-- USER COMMANDS
-- =============================================================================

-- Convenient commands for manual theme management
vim.api.nvim_create_user_command("ReloadTheme", setup_theme, {
	desc = "Reload the current theme and adjust colors",
})

vim.api.nvim_create_user_command("FixComments", function()
	local current_bg = vim.o.background

	if current_bg == "dark" then
		vim.cmd("highlight Comment guifg=#6272A4 ctermfg=61 cterm=italic gui=italic")
		vim.cmd("highlight CommentDoc guifg=#7289DA ctermfg=68 cterm=italic gui=italic")
	-- Dark theme comment colors applied
	else
		vim.cmd("highlight Comment guifg=#5C6370 ctermfg=59 cterm=italic gui=italic")
		vim.cmd("highlight CommentDoc guifg=#4078C0 ctermfg=32 cterm=italic gui=italic")
		-- Light theme comment colors applied
	end
end, {
	desc = "Fix comment colors for current background",
})

-- Command to force Tokyo Night theme reload
vim.api.nvim_create_user_command("TokyoNight", function(args)
	local style = args.args ~= "" and args.args or "moon"
	vim.opt.background = style == "day" and "light" or "dark"

	local ok, tokyonight = pcall(require, "tokyonight")
	if ok then
		tokyonight.setup({
			style = style,
			transparent = false,
			styles = {
				comments = { italic = true },
				keywords = { italic = true },
			},
		})
		vim.g.tokyonight_style = style
		vim.cmd("colorscheme tokyonight-" .. style)
	-- Tokyo Night theme loaded
	else
		vim.notify("Tokyo Night plugin not found", vim.log.levels.WARN)
	end
end, {
	nargs = "?",
	complete = function()
		return { "night", "moon", "storm", "day" }
	end,
	desc = "Load Tokyo Night theme variant (night, moon, storm, day)",
})
