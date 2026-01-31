# Cortex - AI Model Management

> **Unified AI model management for terminal and Neovim**

Cortex is a production-grade system that provides unified access to multiple AI providers (MLX, Ollama, Anthropic, OpenAI, Google) with seamless integration for terminal usage and Neovim.

## Features

- **Dynamic Model Discovery** - Automatically fetches available models from all providers
- **Smart Recommendations** - Analyzes system specs to recommend optimal models
- **Unified Interface** - Single command for all AI providers
- **Neovim Integration** - Seamlessly integrates with CodeCompanion and Avante.nvim
- **MLX Optimization** - Native Apple Silicon support for maximum performance
- **Ensemble Mode** - Run multiple models in parallel for comparison
- **Usage Statistics** - Track token usage, response times, and performance

## Installation

```bash
# Install Cortex
pip install -e ~/.dotfiles/src/cortex

# Verify installation
cortex --version
```

## Quick Start

```bash
# List all available models
cortex list

# Set a model
cortex model mlx-community/Meta-Llama-3.1-8B-Instruct-4bit

# Start the model server
cortex start

# Chat with the model
cortex chat

# Check status
cortex status
```

## Commands

| Command                  | Description                           |
| ------------------------ | ------------------------------------- |
| `cortex list`            | List all available models by provider |
| `cortex model <name>`    | Set the active model                  |
| `cortex download <name>` | Download model with progress tracking |
| `cortex start`           | Start model server (MLX, Ollama)      |
| `cortex stop`            | Stop model server                     |
| `cortex chat`            | Interactive chat with current model   |
| `cortex status`          | Show current configuration and status |
| `cortex logs`            | View system logs                      |

### Model Selection

```bash
# List models by provider
cortex list

# List only local models
cortex list --local

# List by capability
cortex list --capability coding

# Set model
cortex model llama3.1:8b          # Ollama
cortex model mlx-community/...    # MLX
cortex model claude-3-opus        # Anthropic
cortex model gpt-4                # OpenAI
```

### Chat Mode

```bash
# Basic chat
cortex chat

# With specific model
cortex chat --model llama3.1:8b

# Ensemble mode (compare models)
cortex chat --ensemble

# With system prompt
cortex chat --system "You are a coding assistant"
```

## Supported Providers

### MLX (Apple Silicon)

Native Apple Silicon models via MLX framework:

```bash
# Download MLX model
cortex download mlx-community/Meta-Llama-3.1-8B-Instruct-4bit

# Start MLX server
cortex start --provider mlx

# Use in chat
cortex model mlx-community/Meta-Llama-3.1-8B-Instruct-4bit
cortex chat
```

**Recommended models:**

- `mlx-community/Meta-Llama-3.1-8B-Instruct-4bit` - Best balance
- `mlx-community/Mistral-7B-Instruct-v0.3-4bit` - Fast
- `mlx-community/CodeLlama-34b-Instruct-4bit` - Coding

### Ollama

Local model server:

```bash
# Ensure Ollama is running
ollama serve

# Pull model
cortex download llama3.1:8b

# Use model
cortex model llama3.1:8b
```

**Recommended models:**

- `llama3.1:8b` - General purpose
- `codellama:13b` - Coding
- `mistral:7b` - Fast responses

### Cloud Providers

API-based providers (require API keys):

```bash
# Anthropic
cortex model claude-3-opus
cortex model claude-3-sonnet

# OpenAI
cortex model gpt-4
cortex model gpt-4-turbo

# Google
cortex model gemini-pro
```

## Configuration

### File Locations

```
~/.dotfiles/config/cortex/
├── config.yaml        # Main configuration
├── cortex.env         # Environment variables
└── stats/             # Usage statistics

~/.dotfiles/.dotfiles.private/
└── api_keys.yaml      # API keys (private)
```

### Environment Variables

Cortex automatically sets environment variables for integration:

```bash
# Core variables
CORTEX_PROVIDER=mlx        # Current provider
CORTEX_MODEL=llama3.1      # Current model
CORTEX_ENDPOINT=http://... # API endpoint

# Avante.nvim integration
AVANTE_PROVIDER=openai
AVANTE_OPENAI_MODEL=llama3.1
AVANTE_OPENAI_ENDPOINT=http://localhost:8080/v1

# CodeCompanion integration
CODECOMPANION_ADAPTER=ollama
```

### Configuration File

```yaml
# ~/.dotfiles/config/cortex/config.yaml
default_provider: mlx
default_model: mlx-community/Meta-Llama-3.1-8B-Instruct-4bit

providers:
  mlx:
    enabled: true
    port: 8080
  ollama:
    enabled: true
    host: localhost
    port: 11434
  anthropic:
    enabled: true
  openai:
    enabled: true

preferences:
  auto_start: true
  stream_responses: true
  save_history: true
```

## Neovim Integration

### CodeCompanion

Cortex automatically configures CodeCompanion:

```lua
-- In Neovim, use AI commands:
-- <leader>ac - Chat
-- <leader>aa - Actions palette
-- <leader>ae - Explain code (visual)
```

The adapter is set based on `CORTEX_PROVIDER`:

```lua
-- Automatic configuration based on cortex
require("codecompanion").setup({
  adapters = {
    ollama = function()
      return require("codecompanion.adapters").extend("ollama", {
        env = {
          url = vim.env.CORTEX_ENDPOINT,
        },
        schema = {
          model = { default = vim.env.CORTEX_MODEL },
        },
      })
    end,
  },
})
```

### Avante.nvim

Environment variables are set for Avante:

```lua
-- Avante automatically picks up:
-- AVANTE_PROVIDER
-- AVANTE_OPENAI_MODEL
-- AVANTE_OPENAI_ENDPOINT
```

### Switching Models in Neovim

```bash
# From terminal
cortex model llama3.1:70b
cortex start

# Changes take effect in new Neovim instances
# Or reload in Neovim:
:lua vim.env.CORTEX_MODEL = "llama3.1:70b"
```

## Performance

### System Requirements

| Component | Minimum | Recommended            |
| --------- | ------- | ---------------------- |
| RAM       | 8GB     | 16GB+                  |
| Storage   | 10GB    | 50GB+                  |
| GPU       | -       | Apple Silicon / NVIDIA |
| Python    | 3.9+    | 3.11+                  |

### Model Size Guidelines

| Model Size | RAM Required | Speed     |
| ---------- | ------------ | --------- |
| 7B-4bit    | 6GB          | Fast      |
| 8B-4bit    | 8GB          | Fast      |
| 13B-4bit   | 10GB         | Medium    |
| 34B-4bit   | 20GB         | Slow      |
| 70B-4bit   | 40GB         | Very Slow |

### MLX Performance (Apple Silicon)

MLX provides best performance on Apple Silicon:

```bash
# Check MLX availability
python -c "import mlx; print('MLX available')"

# Start with MLX
cortex start --provider mlx

# Monitor performance
cortex status --verbose
```

## Usage Statistics

### View Statistics

```bash
# Overall stats
cortex stats

# By model
cortex stats --model llama3.1:8b

# By date range
cortex stats --from 2024-01-01 --to 2024-01-31
```

### Tracked Metrics

- Total tokens (input/output)
- Response times
- Requests per model
- Cost estimates (cloud providers)
- Error rates

## Troubleshooting

### Common Issues

| Issue              | Solution                                         |
| ------------------ | ------------------------------------------------ |
| Model not found    | Run `cortex list` to see available models        |
| Server won't start | Check port availability, try `cortex stop` first |
| Slow responses     | Try smaller model or check system resources      |
| API errors         | Verify API keys in private config                |

### Debug Mode

```bash
# Verbose output
cortex --debug status

# Check configuration
cortex config --show

# Test provider
cortex test --provider ollama
```

### Logs

```bash
# View logs
cortex logs

# Follow logs
cortex logs --follow

# Filter by level
cortex logs --level error
```

## Quick Reference

```bash
# Essential commands
cortex list              # Show available models
cortex model <name>      # Set active model
cortex start             # Start server
cortex stop              # Stop server
cortex chat              # Interactive chat
cortex status            # Check status

# Model management
cortex download <name>   # Download model
cortex list --local      # List local models

# Configuration
cortex config --show     # Show config
cortex stats             # Usage statistics

# Neovim integration
# Set model, then use <leader>a* keymaps
```

---

<p align="center">
  <a href="README.md">← Back to Editor Guides</a>
</p>
