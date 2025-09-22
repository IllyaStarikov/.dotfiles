--
-- config/codecompanion.lua
-- CodeCompanion configuration with MLX for macOS and Ollama for Linux
--

local M = {}

-- Detect operating system
local is_macos = vim.fn.has("mac") == 1 or vim.fn.has("macunix") == 1
local is_linux = vim.fn.has("unix") == 1 and not is_macos

-- MLX model configurations for macOS (optimized for Apple Silicon)
-- Using American tech company models only
local mlx_models = {
	-- Small models (1-3B) - Very fast on Apple Silicon
	small = {
		"mlx-community/Phi-3.5-mini-instruct-4bit", -- 3.8B, Microsoft's efficient model
		"mlx-community/Phi-3-mini-4k-instruct-4bit", -- 3.8B, Microsoft Phi-3
		"mlx-community/gemma-2b-it-4bit", -- 2B, Google's Gemma
		"mlx-community/starcoder2-3b-4bit", -- 3B, BigCode (Hugging Face/ServiceNow)
	},

	-- Medium models (7-8B) - Great balance on Apple Silicon
	medium = {
		"mlx-community/Meta-Llama-3.1-8B-Instruct-4bit", -- 8B, Meta's latest Llama
		"mlx-community/Meta-Llama-3-8B-Instruct-4bit", -- 8B, Meta's Llama 3
		"mlx-community/Mistral-7B-Instruct-v0.3-4bit", -- 7B, Mistral AI (French-American)
		"mlx-community/gemma-7b-it-4bit", -- 7B, Google's Gemma
		"mlx-community/codellama-7b-instruct-4bit", -- 7B, Meta's Code Llama
	},

	-- Large models (13B-70B) - High quality, still fast on M-series
	large = {
		"mlx-community/Meta-Llama-3.1-70B-Instruct-4bit", -- 70B, Meta's largest
		"mlx-community/codellama-34b-instruct-4bit", -- 34B, Meta's Code Llama
		"mlx-community/codellama-13b-instruct-4bit", -- 13B, Meta's Code Llama
		"mlx-community/Phi-3-medium-4k-instruct-4bit", -- 14B, Microsoft Phi-3
	},
}

-- Ollama model configurations for Linux
-- Using American tech company models only
local ollama_models = {
	-- Small models (1-3B) - Fast, good for quick completions
	small = {
		"llama3.2:latest", -- 3B, Meta's fast general purpose
		"phi3:mini", -- 3.8B, Microsoft's small model
		"phi3.5:latest", -- 3.8B, Microsoft's latest small model
		"gemma2:2b", -- 2B, Google's efficient model
		"starcoder2:3b", -- 3B, BigCode initiative
	},

	-- Medium models (7-14B) - Balanced performance
	medium = {
		"llama3.1:8b", -- 8B, Meta's Llama 3.1
		"llama3:8b", -- 8B, Meta's Llama 3
		"codellama:7b", -- 7B, Meta's code model
		"mistral:7b", -- 7B, Mistral AI (French-American)
		"gemma2:9b", -- 9B, Google's Gemma 2
		"phi3:medium", -- 14B, Microsoft's medium model
	},

	-- Large models (30B+) - Best quality, slower
	large = {
		"llama3.1:70b", -- 70B, Meta's highest quality
		"llama3.1:405b", -- 405B, Meta's largest (if available)
		"codellama:34b", -- 34B, Meta's powerful code model
		"codellama:70b", -- 70B, Meta's largest code model
		"mixtral:8x7b", -- 47B MoE, Mistral AI
		"gemma2:27b", -- 27B, Google's large model
	},
}

-- Select appropriate models based on OS
local model_configs = is_macos and mlx_models or ollama_models

-- Default model selection based on OS (American tech companies)
local default_model = is_macos and "mlx-community/Meta-Llama-3.1-8B-Instruct-4bit" -- Meta's Llama for macOS
	or "llama3.2:latest" -- Meta's Llama for Linux

-- Current active model (can be changed via commands)
vim.g.codecompanion_model = vim.g.codecompanion_model or default_model
vim.g.codecompanion_adapter = is_macos and "mlx" or "ollama"

function M.setup()
	local ok, codecompanion = pcall(require, "codecompanion")
	if not ok then
		vim.notify("Failed to load codecompanion", vim.log.levels.WARN)
		return
	end

	-- Configure adapters based on OS
	local adapters = {}

	if is_macos then
		-- MLX adapter for macOS (OpenAI-compatible API)
		adapters.mlx = function()
			return require("codecompanion.adapters").extend("openai_compatible", {
				name = "mlx",
				schema = {
					model = {
						default = vim.g.codecompanion_model,
					},
				},
				env = {
					url = "http://localhost:8080", -- MLX server default port
					api_key = "mlx-local", -- MLX doesn't need a real key
					chat_url = "/v1/chat/completions",
				},
				headers = {
					["Content-Type"] = "application/json",
					["Authorization"] = "Bearer mlx-local",
				},
			})
		end
	end

	-- Always include Ollama as fallback
	adapters.ollama = function()
		return require("codecompanion.adapters").extend("ollama", {
			name = "ollama",
			schema = {
				model = {
					default = vim.g.codecompanion_model,
				},
			},
			env = {
				url = "http://localhost:11434", -- Default Ollama URL
			},
			headers = {
				["Content-Type"] = "application/json",
			},
		})
	end

	codecompanion.setup({
		-- Adapter configuration
		adapters = adapters,

		-- Strategy configuration (use MLX on macOS, Ollama on Linux)
		strategies = {
			chat = {
				adapter = vim.g.codecompanion_adapter,
			},
			inline = {
				adapter = vim.g.codecompanion_adapter,
			},
			agent = {
				adapter = vim.g.codecompanion_adapter,
			},
		},

		-- Minimal display options
		display = {
			chat = {
				window = {
					layout = "vertical",
					width = 0.5,
					height = 0.8,
				},
			},
		},

		-- Options
		opts = {
			log_level = "ERROR", -- TRACE, DEBUG, ERROR, INFO
			send_code = true, -- Send code context to the LLM
			use_default_actions = true, -- Use the default actions in the action palette
			use_default_prompts = true, -- Use the default prompts from the plugin
			system_prompt = [[You are an AI programming assistant. Follow these guidelines:
- Be concise and direct in your responses
- Provide code examples when helpful
- Explain complex concepts clearly
- Focus on best practices and clean code
- Suggest improvements when you see potential issues]],
		},

		-- Use default prompts and slash commands
		use_default_prompts = true,
	})
end

-- Helper function to switch models
function M.switch_model(model_name, adapter)
	vim.g.codecompanion_model = model_name
	if adapter then
		vim.g.codecompanion_adapter = adapter
	end

	-- Reload CodeCompanion with new model
	local ok, codecompanion = pcall(require, "codecompanion")
	if ok then
		M.setup() -- Reinitialize with new model
		local adapter_str = adapter and (" (" .. adapter .. ")") or ""
		vim.notify("CodeCompanion switched to: " .. model_name .. adapter_str, vim.log.levels.INFO)
	end
end

-- Helper to start MLX server if on macOS
function M.start_mlx_server()
	if not is_macos then
		vim.notify("MLX server is only for macOS", vim.log.levels.WARN)
		return
	end

	-- Check if server is already running
	local handle = io.popen("curl -s http://localhost:8080/health 2>/dev/null")
	local result = handle:read("*a")
	handle:close()

	if result and result ~= "" then
		vim.notify("MLX server is already running", vim.log.levels.INFO)
		return
	end

	-- Start the server in background
	vim.notify("Starting MLX server...", vim.log.levels.INFO)
	vim.fn.jobstart({ "mlx_lm.server", "--model", vim.g.codecompanion_model }, {
		detach = true,
		on_exit = function(_, code)
			if code == 0 then
				vim.notify("MLX server started successfully", vim.log.levels.INFO)
			else
				vim.notify("Failed to start MLX server", vim.log.levels.ERROR)
			end
		end,
	})
end

-- Helper function to list available models
function M.list_models()
	local adapter = vim.g.codecompanion_adapter
	vim.notify("Current: " .. vim.g.codecompanion_model .. " (" .. adapter .. ")", vim.log.levels.INFO)

	local models_list = {}

	if is_macos then
		table.insert(models_list, "\nMLX Models (macOS - install with 'huggingface-cli download <model>'):")
	else
		table.insert(models_list, "\nOllama Models (Linux - install with 'ollama pull <model>'):")
	end

	table.insert(models_list, "\nSmall (Fast, 1-3B):")
	for _, model in ipairs(model_configs.small) do
		table.insert(models_list, "  - " .. model)
	end

	table.insert(models_list, "\nMedium (Balanced, 7-14B):")
	for _, model in ipairs(model_configs.medium) do
		table.insert(models_list, "  - " .. model)
	end

	table.insert(models_list, "\nLarge (Best Quality, 14B-32B on macOS, 30B+ on Linux):")
	for _, model in ipairs(model_configs.large) do
		table.insert(models_list, "  - " .. model)
	end

	vim.notify(table.concat(models_list, "\n"), vim.log.levels.INFO)
end

-- Quick model switchers (American tech companies)
function M.use_small_model()
	if is_macos then
		M.switch_model("mlx-community/Phi-3.5-mini-instruct-4bit", "mlx") -- Microsoft
	else
		M.switch_model("llama3.2:latest", "ollama") -- Meta
	end
end

function M.use_medium_model()
	if is_macos then
		M.switch_model("mlx-community/Meta-Llama-3.1-8B-Instruct-4bit", "mlx") -- Meta
	else
		M.switch_model("llama3.1:8b", "ollama") -- Meta
	end
end

function M.use_large_model()
	if is_macos then
		M.switch_model("mlx-community/Meta-Llama-3.1-70B-Instruct-4bit", "mlx") -- Meta
	else
		M.switch_model("llama3.1:70b", "ollama") -- Meta (you have this)
	end
end

-- Switch between MLX and Ollama on macOS
function M.use_ollama()
	if is_macos then
		vim.g.codecompanion_adapter = "ollama"
		M.switch_model("llama3.2:latest", "ollama")
	else
		vim.notify("Already using Ollama on Linux", vim.log.levels.INFO)
	end
end

function M.use_mlx()
	if is_macos then
		vim.g.codecompanion_adapter = "mlx"
		M.switch_model("mlx-community/Meta-Llama-3.1-8B-Instruct-4bit", "mlx") -- Meta's Llama
	else
		vim.notify("MLX is only available on macOS", vim.log.levels.WARN)
	end
end

return M
