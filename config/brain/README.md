# config/brain/

Configuration and runtime data for the Brain AI assistant system.

## Overview

This directory contains configuration files, logs, and runtime data for the Brain AI system - a local AI assistant that provides code completion, chat capabilities, and development assistance directly within your development environment.

## Directory Structure

```
brain/
└── logs/              # Runtime log files
    ├── server.log     # MLX server daemon logs
    ├── agent.log      # AI agent interaction logs
    ├── error.log      # Error and exception logs
    └── access.log     # API access logs
```

## Components

### Brain System

The Brain system is a local AI infrastructure that includes:
- **MLX Server**: Apple Silicon optimized ML inference server
- **Agent System**: AI assistant for code and chat
- **Model Management**: Local model storage and switching
- **API Gateway**: OpenAI-compatible API interface

### Log Files

#### logs/

Runtime logs for debugging and monitoring the Brain system.

**server.log**: MLX server daemon operations
- Model loading events
- Inference requests
- Performance metrics
- Memory usage

**agent.log**: AI agent interactions
- User queries
- Agent responses
- Context management
- Tool usage

**error.log**: System errors and exceptions
- Model loading failures
- Out of memory errors
- API errors
- Crash reports

**access.log**: API request logs
- Request timestamps
- Endpoints accessed
- Response codes
- Latency metrics

## Configuration

### Environment Variables

The Brain system uses these environment variables:
```bash
# Model selection
export BRAIN_MODEL="mlx-community/Qwen2.5-Coder-32B-Instruct-4bit"

# Server configuration  
export BRAIN_PORT=11434
export BRAIN_HOST="localhost"

# API compatibility
export OPENAI_API_BASE="http://localhost:11434/v1"
export OPENAI_API_KEY="mlx-local-no-key-needed"
```

### Model Configuration

Supported models (Apple Silicon optimized):
- `Qwen2.5-Coder-32B-Instruct-4bit`: Large coding model
- `Qwen2.5-Coder-7B-Instruct-4bit`: Smaller, faster model
- `Llama-3.2-3B-Instruct-4bit`: Lightweight chat model
- Custom models from mlx-community

### Integration Configuration

**Neovim Integration**:
```lua
-- Avante.nvim configuration
{
  provider = "openai",
  openai = {
    endpoint = "http://localhost:11434/v1",
    model = "mlx-community/Qwen2.5-Coder-32B-Instruct-4bit",
    api_key = "mlx-local-no-key-needed"
  }
}
```

**Shell Integration**:
```bash
# Brain CLI commands
brain status        # Check system status
brain start        # Start MLX server
brain stop         # Stop server
brain restart      # Restart server
brain model <name> # Switch model
brain chat         # Start interactive chat
```

## Usage

### Starting the Brain System

```bash
# Start the MLX server daemon
brain start

# Verify it's running
brain status

# Start with specific model
brain model mlx-community/Qwen2.5-Coder-7B-Instruct-4bit
brain restart
```

### Monitoring

Check logs for issues:
```bash
# View server logs
tail -f ~/.dotfiles/config/brain/logs/server.log

# Check for errors
tail -f ~/.dotfiles/config/brain/logs/error.log

# Monitor API access
tail -f ~/.dotfiles/config/brain/logs/access.log
```

### Log Rotation

Logs are automatically rotated:
- Maximum file size: 10MB
- Keep 5 historical files
- Compress old logs with gzip

Manual rotation:
```bash
# Rotate all logs
logrotate -f ~/.dotfiles/config/brain/logrotate.conf

# Clear old logs
find ~/.dotfiles/config/brain/logs -name "*.gz" -mtime +30 -delete
```

## Log Format

### Server Log Format
```
[2024-01-15 14:32:10] [INFO] Model loaded: Qwen2.5-Coder-32B
[2024-01-15 14:32:15] [INFO] Inference request: tokens=512, time=2.3s
[2024-01-15 14:32:20] [WARN] Memory usage high: 28GB/32GB
```

### Agent Log Format
```
[2024-01-15 14:33:00] [QUERY] User: "Write a Python function to..."
[2024-01-15 14:33:02] [RESPONSE] Agent: Generated 150 tokens
[2024-01-15 14:33:02] [CONTEXT] Tokens: 2048/4096
```

### Error Log Format
```
[2024-01-15 14:35:00] [ERROR] OOM: Model requires 35GB, available 30GB
[2024-01-15 14:35:00] [ERROR] Fallback to smaller model
[2024-01-15 14:35:05] [INFO] Loaded fallback: Qwen2.5-Coder-7B
```

## Performance Tuning

### Memory Management

Monitor memory usage:
```bash
# Check Brain memory usage
brain status --memory

# View in logs
grep "Memory" ~/.dotfiles/config/brain/logs/server.log
```

Optimize for available RAM:
- 32GB RAM: Use 32B quantized models
- 16GB RAM: Use 7B quantized models  
- 8GB RAM: Use 3B quantized models

### Response Time

Improve inference speed:
```bash
# Use smaller model for faster responses
brain model mlx-community/Qwen2.5-Coder-7B-Instruct-4bit

# Adjust generation parameters
export BRAIN_MAX_TOKENS=512  # Limit response length
export BRAIN_TEMPERATURE=0.7  # Reduce randomness
```

## Troubleshooting

### Server Won't Start

Check logs:
```bash
tail -n 50 ~/.dotfiles/config/brain/logs/error.log
```

Common issues:
- Port already in use
- Insufficient memory
- Model not found
- Python environment issues

### Slow Responses

1. Check model size vs RAM
2. Monitor swap usage
3. Consider smaller model
4. Reduce max tokens

### Connection Errors

Verify server is running:
```bash
brain status
curl http://localhost:11434/v1/models
```

Check firewall:
```bash
sudo lsof -i :11434
```

## Security

### Access Control

The Brain system is localhost-only by default:
- No external network access
- No authentication required locally
- API key is placeholder only

### Data Privacy

- All processing happens locally
- No data sent to external servers
- Logs contain queries (sanitize if needed)
- Models stored locally in `~/.mlx_models/`

### Log Sanitization

Remove sensitive data:
```bash
# Clean logs of sensitive patterns
sed -i '' 's/password=.*$/password=REDACTED/g' logs/*.log
```

## Maintenance

### Regular Tasks

Daily:
- Monitor log sizes
- Check error logs

Weekly:
- Rotate logs if needed
- Clear old compressed logs

Monthly:
- Update models
- Clean cache directories

### Backup

Important data to backup:
- Custom model configurations
- Fine-tuned models
- Configuration files

```bash
# Backup configuration
tar -czf brain-config-backup.tar.gz ~/.dotfiles/config/brain/
```

## Dependencies

Required:
- Python 3.10+
- mlx (Apple Silicon)
- mlx-lm package
- 8GB+ RAM (minimum)
- macOS 13+ (for MLX)

Installation:
```bash
pip install mlx mlx-lm
```

## See Also

- Brain Scripts: `src/scripts/brain`
- MLX Documentation: https://ml-explore.github.io/mlx/
- Model Hub: https://huggingface.co/mlx-community
- Main Dotfiles: `~/.dotfiles/README.md`