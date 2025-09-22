-- Optimized blink.cmp configuration
-- Based on best practices for performance and functionality

return {
	-- Enable blink.cmp
	enabled = function()
		return true
	end,
	-- Configure snippet preset for LuaSnip
	snippets = { preset = "luasnip" },
	-- Keymap preset with custom Tab handling
	keymap = {
		preset = "default",
		["<C-Space>"] = { "show", "show_documentation", "hide_documentation" },
		["<C-e>"] = { "hide", "fallback" },
		["<Tab>"] = { "accept", "fallback" },
		["<S-Tab>"] = { "snippet_backward", "fallback" },
		["<CR>"] = { "accept", "fallback" },
		["<C-p>"] = { "select_prev", "fallback" },
		["<C-n>"] = { "select_next", "fallback" },
		["<Up>"] = { "select_prev", "fallback" },
		["<Down>"] = { "select_next", "fallback" },
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
			show_in_snippet = true,
			show_on_accept_on_trigger_character = true,
			prefetch_on_insert = true, -- Enable prefetch
			show_on_blocked_trigger_characters = {}, -- Don't block any characters
			show_on_x_blocked_trigger_characters = {}, -- Don't block any characters
		},

		-- List configuration
		list = {
			max_items = 200,
			selection = {
				preselect = true, -- Preselect first item
				auto_insert = true, -- Auto-insert on selection
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
			max_height = 10,
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

	-- Source configuration with performance optimizations
	sources = {
		-- Minimum keyword length to trigger completion
		min_keyword_length = 0,

		-- Default sources for all filetypes
		default = { "lsp", "path", "snippets", "buffer" },

		-- Per-filetype source configuration
		-- Commented out to test if this is causing Python LSP issues
		-- per_filetype = {
		--   lua = { inherit_defaults = true, 'lsp', 'path', 'buffer' },
		--   python = { inherit_defaults = true, 'lsp', 'path', 'snippets', 'buffer' },
		--   cpp = { inherit_defaults = true, 'lsp', 'path', 'snippets' },
		--   c = { inherit_defaults = true, 'lsp', 'path', 'snippets' },
		--   markdown = { inherit_defaults = true, 'lsp', 'path', 'buffer', 'snippets' },
		--   tex = { inherit_defaults = true, 'lsp', 'path', 'buffer' },
		-- },

		-- Provider-specific settings
		providers = {
			lsp = {
				name = "LSP",
				module = "blink.cmp.sources.lsp",
				enabled = true,
				async = true, -- Keep async for performance
				timeout_ms = 5000, -- Increase timeout for LSP requests
				score_offset = 0, -- Boost score for LSP items
				min_keyword_length = 0, -- Show completions immediately after dot
				should_show_items = true,
				fallbacks = {}, -- No fallbacks for LSP
				opts = {
					-- Specific options for LSP source
				},
			},
			buffer = {
				name = "Buffer",
				module = "blink.cmp.sources.buffer",
				enabled = true,
				max_items = 5, -- Limit buffer completions for performance
				score_offset = -3, -- Lower priority than LSP
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
				name = "Path",
				module = "blink.cmp.sources.path",
				enabled = true,
				async = false, -- Path completion is fast enough to be sync
				score_offset = 3,
				opts = {
					trailing_slash = true,
					label_trailing_slash = true,
					show_hidden_files_by_default = false,
				},
			},
		},
	},
}
