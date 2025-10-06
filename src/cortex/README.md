# Cortex - Unified AI Model Management System

A production-grade AI model management system that provides unified access to multiple AI providers (MLX, Ollama, Anthropic, OpenAI, Google, HuggingFace) with seamless integration for terminal usage and Neovim.

## Features

- **Dynamic Model Discovery**: Automatically fetches and lists available models from all major providers
- **Smart Recommendations**: Analyzes system specifications to recommend optimal models
- **Unified Interface**: Single command interface for all AI providers
- **Neovim Integration**: Seamlessly integrates with CodeCompanion and Avante.nvim
- **MLX Optimization**: Native Apple Silicon support with MLX for maximum performance
- **Ensemble Mode**: Run multiple models in parallel for comparison
- **Rich Statistics**: Track token usage, response times, and model performance

## Installation

```bash
pip install -e ~/.dotfiles/src/cortex
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

- `list` - List all available models organized by provider and capability
- `model` - Set the active model and configure environment variables
- `download` - Download models with progress tracking
- `start/stop` - Manage model servers (MLX, Ollama, etc.)
- `chat` - Interactive chat with the current model
- `logs` - View system logs
- `status` - Check current configuration and server status
- `chat --ensemble` - Run multiple models in parallel

## Configuration

Configuration files are stored in `~/.dotfiles/config/cortex/`:

- `config.yaml` - Main configuration
- `cortex.env` - Environment variables for shell integration
- `stats/` - Usage statistics and metrics

API keys are stored securely in `~/.dotfiles/.dotfiles.private/`

## Neovim Integration

Cortex automatically sets environment variables that are picked up by CodeCompanion and Avante.nvim:

- `CORTEX_PROVIDER` - Current provider (mlx, ollama, etc.)
- `CORTEX_MODEL` - Current model name
- `CORTEX_ENDPOINT` - API endpoint URL
- `AVANTE_PROVIDER`, `AVANTE_OPENAI_MODEL`, `AVANTE_OPENAI_ENDPOINT` - For Avante.nvim integration

## System Requirements

- macOS (Apple Silicon recommended) or Linux
- Python 3.9+
- 8GB+ RAM (16GB+ recommended for larger models)
- MLX support on macOS for optimal performance
