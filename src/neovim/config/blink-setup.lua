-- Optimized blink.cmp configuration
-- Based on best practices for performance and functionality

return {
	-- Keymap preset with custom Tab handling
	keymap = {
		preset = "default",
		["<Tab>"] = {
			-- If completion menu is visible, accept the selected item
			function(cmp)
				if cmp.snippet_active() then
					return cmp.accept()
				else
					return cmp.select_and_accept()
				end
			end,
			-- Otherwise, try snippet expansion/jump
			"snippet_forward",
			-- Finally, fallback to default Tab behavior
			"fallback",
		},
		["<S-Tab>"] = { "snippet_backward", "fallback" },
	},

	-- Appearance settings
	appearance = {
		use_nvim_cmp_as_default = true, -- Use nvim-cmp highlights as fallback
		nerd_font_variant = "mono", -- Use mono variant for consistent width
	},

	-- Completion behavior configuration
	completion = {
		-- Keyword matching settings
		keyword = {
			range = "prefix", -- More efficient than 'full'
		},

		-- Trigger settings for when to show completions
		trigger = {
			show_on_keyword = true,
			show_on_trigger_character = true,
			show_on_insert_on_trigger_character = true,
			prefetch_on_insert = false, -- Disable for better performance
		},

		-- List configuration
		list = {
			max_items = 500, -- Default: 200
			selection = {
				preselect = true, -- Preselect first item
				auto_insert = false, -- Don't auto-insert on selection
			},
		},

		-- Accept behavior
		accept = {
			create_undo_point = true,
			auto_brackets = {
				enabled = true,
				default_brackets = { "(", ")" },
			},
		},

		-- Menu appearance
		menu = {
			max_height = 20, -- Default: 10
			draw = {
				columns = {
					{ "kind_icon" },
					{ "label", "label_description", gap = 1 },
				},
			},
		},

		-- Documentation window
		documentation = {
			auto_show = true,
			auto_show_delay_ms = 500,
			treesitter_highlighting = true,
		},
	},

	-- Source configuration with performance optimizations
	sources = {
		-- Default sources for all filetypes
		default = { "lsp", "path", "snippets", "buffer" },

		-- Per-filetype source configuration
		per_filetype = {
			lua = { "lsp", "path", "buffer" },
			python = { "lsp", "path", "snippets", "buffer" },
			cpp = { "lsp", "path", "snippets" },
			c = { "lsp", "path", "snippets" },
			markdown = { "lsp", "path", "buffer", "snippets" },
			tex = { "lsp", "path", "buffer" },
		},

		-- Provider-specific settings
		providers = {
			lsp = {
				async = true, -- Non-blocking LSP requests
				timeout_ms = 5000, -- Default: 2000
			},
			buffer = {
				max_items = 20, -- Default: 5
				opts = {
					-- Only search visible buffers
					get_bufnrs = function()
						return vim.iter(vim.api.nvim_list_wins())
							:map(function(win)
								return vim.api.nvim_win_get_buf(win)
							end)
							:filter(function(buf)
								return vim.bo[buf].buftype ~= "nofile"
							end)
							:totable()
					end,
				},
			},
			path = {
				async = false, -- Path completion is fast enough to be sync
			},
			snippets = {
				max_items = 30, -- Default: 10
				opts = {
					friendly_snippets = true,
					search_paths = { vim.fn.stdpath("config") .. "/snippets" },
					global_snippets = { "all" },
				},
			},
		},
	},

	-- Fuzzy matching configuration
	fuzzy = {
		implementation = "prefer_rust_with_warning", -- Use Rust for 6x performance
		use_frecency = true, -- Prioritize frequently used items
		use_proximity = true, -- Boost nearby matches
		sorts = { "score", "sort_text" },
	},

	-- Signature help
	signature = {
		enabled = true,
		window = {
			border = "rounded",
		},
	},
}
