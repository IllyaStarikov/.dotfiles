# brAIn - Unified AI Model Management System

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
pip install -e /Users/starikov/.dotfiles/src/brain
```

## Quick Start

```bash
# List all available models
brain list

# Set a model
brain model mlx-community/Meta-Llama-3.1-8B-Instruct-4bit

# Start the model server
brain start

# Chat with the model
brain chat

# Check status
brain status
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

Configuration files are stored in `~/.dotfiles/config/brain/`:
- `config.yaml` - Main configuration
- `brain.env` - Environment variables for shell integration
- `models.yaml` - Model metadata cache

API keys are stored securely in `~/.dotfiles/.dotfiles.private/`

## Neovim Integration

brAIn automatically sets environment variables that are picked up by CodeCompanion and Avante.nvim:
- `BRAIN_PROVIDER` - Current provider (mlx, ollama, etc.)
- `BRAIN_MODEL` - Current model name
- `BRAIN_ENDPOINT` - API endpoint URL

## System Requirements

- macOS (Apple Silicon recommended) or Linux
- Python 3.9+
- 8GB+ RAM (16GB+ recommended for larger models)
- MLX support on macOS for optimal performance