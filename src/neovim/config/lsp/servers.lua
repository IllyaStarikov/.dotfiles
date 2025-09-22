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
	-- Try to use debug logging if available
	local debug = nil
	pcall(function()
		debug = require("config.debug")
	end)

	-- Check for private work-specific LSP overrides
	-- The override file handles machine detection and routing to company configs
	local override_path = vim.fn.expand("~/.dotfiles/.dotfiles.private/lsp-override.lua")
	if vim.fn.filereadable(override_path) == 1 then
		if debug then
			debug.info("LSP", "Found LSP override at: " .. override_path)
		end

		-- Use pcall to handle any errors in the override file
		local ok, override = pcall(dofile, override_path)
		if ok and override and override.setup then
			if debug then
				debug.info("LSP", "Attempting work-specific LSP setup")
			end

			local setup_ok, result = pcall(override.setup)
			if setup_ok then
				-- If override returns true, it means a work config is handling everything
				if result == true then
					if debug then
						debug.info("LSP", "Work-specific LSP configuration active")
					end
					return -- Exit early, work config handles all LSP setup
				end
			else
				-- Log error if debug mode is enabled
				local err_msg = "LSP override error: " .. tostring(result)
				if debug then
					debug.error("LSP", err_msg)
				elseif vim.env.NVIM_DEBUG or vim.env.NVIM_DEBUG_WORK then
					vim.notify(err_msg, vim.log.levels.WARN)
				end
			end
		elseif not ok then
			if debug then
				debug.error("LSP", "Failed to load override: " .. tostring(override))
			end
		end
	else
		if debug then
			debug.debug("LSP", "No LSP override found, using standard configuration")
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
			-- Note: sourcekit (Swift) must be installed via Xcode, not Mason
			-- Note: solargraph (Ruby) may fail if system Ruby is too old
			ensure_installed = {
				-- keep-sorted start
				"bashls", -- Bash/Shell
				"clangd", -- C/C++
				"cmake", -- CMake
				"cssls", -- CSS
				"dockerls", -- Docker
				"emmet_ls", -- Emmet for HTML/CSS
				"gopls", -- Go
				"html", -- HTML
				"jsonls", -- JSON
				"lemminx", -- XML
				"lua_ls", -- Lua
				"marksman", -- Markdown
				"perlnavigator", -- Perl
				"pyright", -- Python
				"rust_analyzer", -- Rust
				-- "solargraph", -- Ruby (commented out - install via gem install solargraph instead)
				-- sourcekit removed - not available in Mason, configured separately below
				"sqlls", -- SQL
				"taplo", -- TOML
				"texlab", -- LaTeX
				"ts_ls", -- TypeScript/JavaScript
				"yamlls", -- YAML
				"zls", -- Zig (can be used for assembly)
				-- keep-sorted end
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
	-- Only configure once to prevent duplicates
	if not vim.g.diagnostics_configured then
		vim.g.diagnostics_configured = true

		-- First, disable virtual text to prevent default display
		vim.diagnostic.config({
			virtual_text = false,
			signs = {
				text = {
					[vim.diagnostic.severity.ERROR] = " ",
					[vim.diagnostic.severity.WARN] = " ",
					[vim.diagnostic.severity.HINT] = "󰌵 ",
					[vim.diagnostic.severity.INFO] = " ",
				},
			},
			underline = true, -- Underline diagnostic locations
			update_in_insert = false, -- Don't update diagnostics in insert mode
			severity_sort = true, -- Sort diagnostics by severity
			float = {
				border = "rounded",
				source = "always",
				header = "",
				prefix = "",
			},
		})

		-- Create a namespace for our custom virtual text
		local ns = vim.api.nvim_create_namespace("custom_diagnostic_vtext")

		-- Custom handler that shows only one diagnostic per line
		local function show_diagnostic_virtual_text()
			-- Clear previous virtual text
			for _, buf in ipairs(vim.api.nvim_list_bufs()) do
				if vim.api.nvim_buf_is_loaded(buf) then
					vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
				end
			end

			-- Get diagnostics for current buffer
			local bufnr = vim.api.nvim_get_current_buf()
			local diagnostics = vim.diagnostic.get(bufnr)

			-- Group diagnostics by line
			local line_diagnostics = {}
			for _, diagnostic in ipairs(diagnostics) do
				local line = diagnostic.lnum
				if not line_diagnostics[line] or diagnostic.severity < line_diagnostics[line].severity then
					line_diagnostics[line] = diagnostic
				end
			end

			-- Display virtual text for the most severe diagnostic on each line
			for line, diagnostic in pairs(line_diagnostics) do
				local msg = diagnostic.message
				-- Truncate long messages
				if #msg > 80 then
					msg = msg:sub(1, 77) .. "..."
				end

				-- Add virtual text with extra spacing
				pcall(vim.api.nvim_buf_set_extmark, bufnr, ns, line, 0, {
					virt_text = {
						{
							"  ● " .. msg,
							"DiagnosticVirtualText" .. vim.diagnostic.severity[diagnostic.severity],
						},
					},
					virt_text_pos = "eol",
					hl_mode = "combine",
				})
			end
		end

		-- Set up autocommand to update virtual text
		vim.api.nvim_create_autocmd("DiagnosticChanged", {
			callback = function()
				show_diagnostic_virtual_text()
			end,
		})

		-- Also update on buffer enter/win enter
		vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter" }, {
			callback = function()
				show_diagnostic_virtual_text()
			end,
		})
	end

	-- Capabilities for blink.cmp integration
	local capabilities = vim.lsp.protocol.make_client_capabilities()

	-- Enhance capabilities with blink.cmp if available
	local blink_ok, blink = pcall(require, "blink.cmp")
	if blink_ok then
		capabilities = blink.get_lsp_capabilities()
	end

	-- Simple on_attach function for LSP keybindings
	local on_attach = function(client, bufnr)
		-- Disable semantic tokens for servers that don't properly support it
		-- This prevents errors when switching buffers with bufferline
		if client.name == "clangd" or client.name == "pyright" or client.name == "marksman" then
			client.server_capabilities.semanticTokensProvider = nil
		end

		-- Configure inlay hints if supported
		if vim.lsp.inlay_hint and client.supports_method("textDocument/inlayHint") then
			pcall(function()
				-- Disable inlay hints by default
				-- Parameters: enable(boolean, filter_table)
				vim.lsp.inlay_hint.enable(false, { bufnr = bufnr })
			end)
		end

		-- Enable document highlight on cursor hold
		if client.server_capabilities.documentHighlightProvider then
			local group = vim.api.nvim_create_augroup("lsp_document_highlight", { clear = false })
			vim.api.nvim_clear_autocmds({ buffer = bufnr, group = group })

			vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
				buffer = bufnr,
				group = group,
				callback = function()
					-- Wrap in pcall to handle servers that might temporarily not support the method
					local ok, _ = pcall(vim.lsp.buf.document_highlight)
					if not ok then
						-- Silently ignore errors - server might be busy or temporarily unavailable
						return
					end
				end,
			})

			vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
				buffer = bufnr,
				group = group,
				callback = vim.lsp.buf.clear_references,
			})
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
					schemas = {
						["https://json.schemastore.org/package.json"] = "package.json",
						["https://json.schemastore.org/tsconfig.json"] = "tsconfig*.json",
						["https://json.schemastore.org/eslintrc.json"] = ".eslintrc*",
					},
				},
			},
		},
		html = {
			settings = {
				html = {
					format = {
						enable = true,
						wrapLineLength = 100,
						unformatted = "wbr",
					},
					validate = {
						scripts = true,
						styles = true,
					},
				},
			},
		},
		cssls = {
			settings = {
				css = {
					validate = true,
					lint = {
						unknownAtRules = "ignore",
					},
				},
				scss = {
					validate = true,
					lint = {
						unknownAtRules = "ignore",
					},
				},
				less = {
					validate = true,
					lint = {
						unknownAtRules = "ignore",
					},
				},
			},
		},
		emmet_ls = {
			filetypes = {
				"html",
				"css",
				"scss",
				"javascript",
				"javascriptreact",
				"typescript",
				"typescriptreact",
				"haml",
				"xml",
				"xsl",
				"pug",
				"slim",
				"sass",
				"less",
			},
		},
		lemminx = {}, -- XML
		cmake = {
			settings = {
				cmake = {
					configProvider = {
						enableSnippets = true,
					},
				},
			},
		},
		bashls = {
			filetypes = { "sh", "bash", "zsh" },
		},
		zls = {}, -- Zig/Assembly
		solargraph = {
			-- Try to use system solargraph if available (via rbenv/rvm)
			cmd = function()
				-- Check for rbenv shim first
				local rbenv_shim = vim.fn.expand("~/.rbenv/shims/solargraph")
				if vim.fn.executable(rbenv_shim) == 1 then
					return { rbenv_shim, "stdio" }
				end
				-- Check for rvm shim
				local rvm_shim = vim.fn.expand("~/.rvm/shims/solargraph")
				if vim.fn.executable(rvm_shim) == 1 then
					return { rvm_shim, "stdio" }
				end
				-- Check for system solargraph
				if vim.fn.executable("solargraph") == 1 then
					return { "solargraph", "stdio" }
				end
				-- Fall back to Mason's installation if available
				return { "solargraph", "stdio" }
			end,
			settings = {
				solargraph = {
					diagnostics = true,
					formatting = true,
				},
			},
		},
		taplo = {}, -- TOML
		perlnavigator = {
			settings = {
				perlnavigator = {
					perlPath = "perl",
					enableWarnings = true,
				},
			},
		},
		sqlls = {
			cmd = { "sql-language-server", "up", "--method", "stdio" },
			filetypes = { "sql", "mysql", "postgresql" },
		},
		-- sourcekit must be installed via Xcode, not Mason
		-- Only configure if on macOS with Xcode installed
		sourcekit = vim.fn.has("mac") == 1 and {
			cmd = { "xcrun", "sourcekit-lsp" },
			filetypes = { "swift", "objc", "objcpp" },
			root_dir = function(fname)
				return lspconfig.util.root_pattern("Package.swift", ".git", "*.xcodeproj", "*.xcworkspace")(fname)
					or lspconfig.util.find_git_ancestor(fname)
					or vim.fn.getcwd()
			end,
		} or nil,
	}

	-- Setup all configured servers (skip if work override is active)
	if not vim.g.work_lsp_override then
		for server, config in pairs(servers) do
			-- Skip nil configurations (e.g., sourcekit on non-Mac systems)
			if config then
				-- Setup the server
				config.capabilities = capabilities
				config.on_attach = on_attach

				-- Use pcall to handle servers that might not be installed
				local ok, err = pcall(function()
					lspconfig[server].setup(config)
				end)
			end
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
