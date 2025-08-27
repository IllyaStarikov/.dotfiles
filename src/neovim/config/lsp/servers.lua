--------------------------------------------------------------------------------
-- config/lsp/servers.lua - Language Server Protocol configuration
--
-- DESCRIPTION:
--   Configures LSP servers for various programming languages. Integrates with
--   blink.cmp for completion and Mason for server management. Supports work-
--   specific overrides for Google and Garmin environments.
--
-- SERVERS:
--   Python:     pyright
--   C/C++:      clangd
--   Lua:        lua_ls
--   JavaScript: ts_ls
--   Rust:       rust_analyzer
--   Go:         gopls
--   LaTeX:      texlab
--   And more...
--
-- FEATURES:
--   - Automatic server installation via Mason
--   - Work-specific override support
--   - Blink.cmp completion integration
--   - Consistent keybindings across servers
--   - Format on save for supported languages
--
-- USAGE:
--   Called automatically from plugins configuration:
--   require("config.lsp.servers").setup()
--
-- KEYBINDINGS (when LSP attached):
--   gd         - Go to definition
--   gr         - Find references
--   K          - Hover documentation
--   <F2>       - Rename symbol
--   <F4>       - Code actions
--   gl         - Show diagnostics
--
-- WORK OVERRIDES:
--   Google machines: Uses CiderLSP instead of standard servers
--   Garmin machines: Uses clangd with Whitesmiths style
--------------------------------------------------------------------------------

-- LSP Setup with blink.cmp integration
-- Returns: nil (modifies global LSP configuration)
local function setup_lsp()
	-- Check for private work-specific LSP overrides
	-- The override file handles machine detection and routing to company configs
	local override_path = vim.fn.expand("~/.dotfiles/.dotfiles.private/lsp-override.lua")
	if vim.fn.filereadable(override_path) == 1 then
		local override = dofile(override_path)
		if override and override.setup then
			local result = override.setup()
			-- If override returns true, it means a work config is handling everything
			if result == true then
				return -- Exit early, work config handles all LSP setup
			end
		end
	end

	local lspconfig = require("lspconfig")
	
	-- 1. Setup Mason for LSP management (skip if work override is active)
	if not vim.g.work_lsp_override then
		require("mason").setup({
			ui = {
				border = "rounded",
				icons = {
					package_installed = "✓",
					package_pending = "➜",
					package_uninstalled = "✗",
				},
			},
		})

		require("mason-lspconfig").setup({
			-- Ensure these servers are installed
			ensure_installed = {
				"pyright", -- Python
				"clangd", -- C/C++
				"lua_ls", -- Lua
				"marksman", -- Markdown
				"texlab", -- LaTeX
				"ts_ls", -- TypeScript/JavaScript
				"rust_analyzer", -- Rust
				"gopls", -- Go
				"dockerls", -- Docker
				"yamlls", -- YAML
				"jsonls", -- JSON
			},
			automatic_installation = true,
			-- Disable automatic server setup to prevent duplicates
			automatic_enable = false,
			handlers = nil,
		})
	end

	-- 2. LSP server configurations
	-- lspconfig already required above

	-- Configure diagnostics with virtual text (inline error messages)
	-- The signs configuration is now done directly in vim.diagnostic.config
	vim.diagnostic.config({
		virtual_text = {
			source = "always",  -- Show source in diagnostic virtual text
			prefix = "●",       -- Icon to show before the diagnostic
			spacing = 4,        -- Spacing between code and virtual text
		},
		signs = {
			text = {
				[vim.diagnostic.severity.ERROR] = " ",
				[vim.diagnostic.severity.WARN] = " ",
				[vim.diagnostic.severity.HINT] = "󰌵 ",
				[vim.diagnostic.severity.INFO] = " ",
			},
		},
		underline = true,       -- Underline diagnostic locations
		update_in_insert = false, -- Don't update diagnostics in insert mode
		severity_sort = true,   -- Sort diagnostics by severity
		float = {
			border = "rounded",
			source = "always",
			header = "",
			prefix = "",
		},
	})

	-- Capabilities for blink.cmp integration
	local capabilities = vim.lsp.protocol.make_client_capabilities()

	-- Get blink.cmp capabilities using the correct API
	local blink_ok, blink = pcall(require, "blink.cmp")
	if blink_ok then
		capabilities = blink.get_lsp_capabilities()
	end

	-- Simple on_attach function for LSP keybindings
	local on_attach = function(client, bufnr)
		-- Disable semantic tokens for clangd (performance)
		if client.name == "clangd" then
			client.server_capabilities.semanticTokensProvider = nil
		end

		local buf = vim.lsp.buf -- alias for convenience
		local map = function(mode, lhs, rhs, desc)
			if desc then
				desc = "[LSP] " .. desc
			end
			vim.keymap.set(mode, lhs, rhs, {
				buffer = bufnr,
				silent = true,
				noremap = true,
				desc = desc,
			})
		end

		-- Keybindings for LSP features:
		map("n", "gd", buf.definition, "Go to definition")
		map("n", "gD", buf.declaration, "Go to declaration")
		map("n", "gi", buf.implementation, "Go to implementation")
		map("n", "gr", buf.references, "Find references")
		map("n", "K", buf.hover, "Hover documentation")
		map("n", "<F2>", buf.rename, "Rename symbol")
		map("n", "<F4>", buf.code_action, "Code actions")
		map("n", "gl", vim.diagnostic.open_float, "Show diagnostics") -- Show diagnostics in floating window
		map("n", "[d", vim.diagnostic.goto_prev, "Prev diagnostic")
		map("n", "]d", vim.diagnostic.goto_next, "Next diagnostic")
	end

	-- Enable language servers only if they exist
	local servers = {
		pyright = {
			settings = {
				python = {
					analysis = {
						autoSearchPaths = true,
						useLibraryCodeForTypes = true,
						diagnosticMode = "workspace",
						typeCheckingMode = "basic",
						-- Add completion-specific settings
						autoImportCompletions = true,
						completeFunctionParens = true,
					},
				},
			},
		},
		clangd = {
			-- Minimal configuration for clangd
			cmd = {
				"clangd",
				"--background-index",
				"--completion-style=detailed",
				"--header-insertion=iwyu",
				"--clang-tidy=false", -- Disable clang-tidy for better performance
			},
			filetypes = { "c", "cpp", "objc", "objcpp", "cuda", "proto" },
			-- Add root directory detection to prevent multiple instances
			root_dir = function(fname)
				local root = lspconfig.util.root_pattern(
					".clangd",
					".clang-tidy",
					".clang-format",
					"compile_commands.json",
					"compile_flags.txt",
					"configure.ac",
					".git"
				)(fname)
				-- If no root found, use the file's directory
				return root or lspconfig.util.path.dirname(fname)
			end,
			single_file_support = true,
		},
		marksman = {},
		texlab = {},
		lua_ls = {
			settings = {
				Lua = {
					diagnostics = { globals = { "vim" } },
					workspace = {
						library = vim.api.nvim_list_runtime_paths(),
						checkThirdParty = false,
					},
					telemetry = { enable = false },
				},
			},
		},
		ts_ls = {
			settings = {
				typescript = {
					inlayHints = {
						includeInlayParameterNameHints = "all",
						includeInlayParameterNameHintsWhenArgumentMatchesName = false,
						includeInlayFunctionParameterTypeHints = true,
						includeInlayVariableTypeHints = true,
						includeInlayPropertyDeclarationTypeHints = true,
						includeInlayFunctionLikeReturnTypeHints = true,
						includeInlayEnumMemberValueHints = true,
					},
				},
			},
		},
		rust_analyzer = {
			settings = {
				["rust-analyzer"] = {
					checkOnSave = {
						command = "clippy",
					},
				},
			},
		},
		gopls = {
			settings = {
				gopls = {
					analyses = {
						unusedparams = true,
					},
					staticcheck = true,
				},
			},
		},
		dockerls = {
			settings = {
				docker = {
					languageserver = {
						formatter = {
							ignoreMultilineInstructions = true,
						},
					},
				},
			},
		},
		yamlls = {
			settings = {
				yaml = {
					schemas = {
						["https://json.schemastore.org/github-workflow.json"] = "/.github/workflows/*",
						["https://raw.githubusercontent.com/compose-spec/compose-spec/master/schema/compose-spec.json"] = "docker-compose*.yml",
					},
					format = {
						enable = true,
					},
				},
			},
		},
		jsonls = {
			settings = {
				json = {
					validate = { enable = true },
					format = { enable = true },
				},
			},
		},
	}

	-- Setup all configured servers (skip if work override is active)
	if not vim.g.work_lsp_override then
		for server, config in pairs(servers) do
			-- Setup the server
			config.capabilities = capabilities
			config.on_attach = on_attach

			-- Use pcall to handle servers that might not be installed
			local ok, err = pcall(function()
				lspconfig[server].setup(config)
			end)
		end
	end

	-- For clangd, we need to manually start it to avoid duplicates
	-- Only register this if we're not on a work machine (work machines handle their own LSP)
	if not vim.g.work_lsp_override then
		vim.api.nvim_create_autocmd("FileType", {
			pattern = { "c", "cpp", "objc", "objcpp", "cuda", "proto" },
			callback = function()
				-- Check if clangd is already running for this buffer
				local clients = vim.lsp.get_clients({ bufnr = 0, name = "clangd" })
				if #clients == 0 then
					-- No clangd running, start it
					vim.cmd("LspStart clangd")
				end
			end,
			desc = "Manually start clangd to prevent duplicates",
		})
	end

	-- Note: We're manually configuring servers above, so we don't need
	-- mason-lspconfig handlers which could cause duplicate setup
end

-- Export module
local M = {}

-- Export setup function
M.setup = setup_lsp

-- Don't setup LSP immediately - let init.lua handle it after plugins are loaded
-- setup_lsp()

return M

