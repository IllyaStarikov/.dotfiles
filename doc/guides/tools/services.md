# Services - Background Service Manager

> **Manage persistent background applications**

A lightweight service manager for personal applications that run persistently, with macOS LaunchAgent integration for auto-start on login.

## Quick Start

```bash
# Start all services
services start

# Check status
services status

# Start specific service
services start calibre-web

# Install auto-start on login
services install
```

## Commands

| Command                   | Description                      |
| ------------------------- | -------------------------------- |
| `services`                | Show status of all services      |
| `services start [name]`   | Start all or specific service    |
| `services stop [name]`    | Stop all or specific service     |
| `services restart [name]` | Restart all or specific service  |
| `services status [name]`  | Show detailed status             |
| `services list`           | List available services          |
| `services logs <name>`    | Show service logs                |
| `services install`        | Install LaunchAgent (auto-start) |
| `services uninstall`      | Remove LaunchAgent               |

## Usage Examples

### Managing Services

```bash
# Start all configured services
services start

# Start a specific service
services start calibre-web

# Stop all services
services stop

# Restart a misbehaving service
services restart calibre-web

# Check if services are running
services status
```

### Viewing Logs

```bash
# View logs for a service
services logs calibre-web

# Follow logs in real-time
services logs calibre-web --follow

# View last 50 lines
services logs calibre-web --lines 50
```

### Auto-Start Configuration

```bash
# Enable auto-start on login
services install

# Disable auto-start
services uninstall

# Check LaunchAgent status
launchctl list | grep services
```

## Creating Custom Services

### Service File Structure

Create a `.service` file in `~/.dotfiles/src/services/`:

```bash
#!/usr/bin/env zsh
# myservice.service - Description of your service

SERVICE_NAME="myservice"
SERVICE_DESC="Short description"

service_start() {
  # Your start logic here
  # Must run in foreground (use exec or don't background)
  exec /path/to/your/command --foreground
}

service_stop() {
  # Optional: custom stop logic
  # Default: SIGTERM is sent to the process
  :
}

service_status() {
  # Optional: custom status check
  # Default: checks if PID is running
  :
}
```

### Service Variables

| Variable          | Required | Description                              |
| ----------------- | -------- | ---------------------------------------- |
| `SERVICE_NAME`    | Yes      | Unique identifier (lowercase, no spaces) |
| `SERVICE_DESC`    | No       | Human-readable description               |
| `SERVICE_PIDFILE` | No       | Custom PID file path                     |
| `SERVICE_LOGFILE` | No       | Custom log file path                     |
| `SERVICE_USER`    | No       | Run as specific user                     |

### Example: Web Server Service

```bash
#!/usr/bin/env zsh
# mywebapp.service - Personal web application

SERVICE_NAME="mywebapp"
SERVICE_DESC="Personal web application on port 3000"

service_start() {
  cd ~/projects/mywebapp
  exec npm start
}

service_stop() {
  # Graceful shutdown
  curl -X POST http://localhost:3000/shutdown 2>/dev/null
}
```

### Example: Python Service

```bash
#!/usr/bin/env zsh
# mybot.service - Discord bot

SERVICE_NAME="mybot"
SERVICE_DESC="Personal Discord bot"

service_start() {
  cd ~/projects/mybot
  source venv/bin/activate
  exec python bot.py
}
```

## Available Services

### calibre-web

Calibre-Web ebook server for managing and reading ebooks:

- **Port**: 8083 (default)
- **URL**: http://localhost:8083
- **Requirements**: Python venv at `~/calibre-web/venv/`

```bash
# Start calibre-web
services start calibre-web

# Access in browser
open http://localhost:8083
```

## File Locations

| Purpose             | Location                                            |
| ------------------- | --------------------------------------------------- |
| Service definitions | `~/.dotfiles/src/services/*.service`                |
| Logs                | `~/.local/state/services/*.log`                     |
| PID files           | `~/.local/state/services/pids/*.pid`                |
| LaunchAgent         | `~/Library/LaunchAgents/io.starikov.services.plist` |

## LaunchAgent Integration

### How It Works

When you run `services install`, a LaunchAgent is created that:

1. Runs at user login
2. Starts all configured services
3. Restarts services if they crash
4. Logs output to service-specific log files

### LaunchAgent Configuration

```xml
<!-- ~/Library/LaunchAgents/io.starikov.services.plist -->
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" ...>
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>io.starikov.services</string>
  <key>ProgramArguments</key>
  <array>
    <string>/Users/starikov/.dotfiles/src/services/services</string>
    <string>start</string>
  </array>
  <key>RunAtLoad</key>
  <true/>
  <key>KeepAlive</key>
  <false/>
</dict>
</plist>
```

### Manual LaunchAgent Control

```bash
# Load (enable)
launchctl load ~/Library/LaunchAgents/io.starikov.services.plist

# Unload (disable)
launchctl unload ~/Library/LaunchAgents/io.starikov.services.plist

# Check status
launchctl list | grep services
```

## Troubleshooting

### Common Issues

| Issue               | Solution                                |
| ------------------- | --------------------------------------- |
| Service won't start | Check logs with `services logs <name>`  |
| Port already in use | Stop conflicting process or change port |
| Permission denied   | Check file permissions on service file  |
| Service crashes     | Check logs, ensure foreground execution |

### Debug Mode

```bash
# Run service manually to see output
~/.dotfiles/src/services/calibre-web.service

# Check PID file
cat ~/.local/state/services/pids/calibre-web.pid

# Verify process is running
ps aux | grep calibre
```

### Log Analysis

```bash
# View recent logs
services logs calibre-web

# Search for errors
services logs calibre-web | grep -i error

# Check service startup
head -50 ~/.local/state/services/calibre-web.log
```

## Best Practices

### Service Design

1. **Foreground execution** - Use `exec` to replace shell process
2. **Graceful shutdown** - Handle SIGTERM properly
3. **Logging** - Write to stdout/stderr (captured automatically)
4. **Health checks** - Implement custom `service_status` if needed

### Resource Management

1. **Memory limits** - Monitor service memory usage
2. **Port conflicts** - Use unique ports for each service
3. **Startup order** - Consider dependencies between services

### Security

1. **Minimal privileges** - Don't run as root
2. **Network binding** - Bind to localhost unless needed
3. **Credential storage** - Use environment variables or secure files

## Quick Reference

```bash
# Service management
services                  # Status overview
services start [name]     # Start service(s)
services stop [name]      # Stop service(s)
services restart [name]   # Restart service(s)
services status [name]    # Detailed status

# Logs and debugging
services logs <name>      # View logs
services list             # List available services

# Auto-start
services install          # Enable auto-start
services uninstall        # Disable auto-start

# File locations
~/.dotfiles/src/services/        # Service definitions
~/.local/state/services/         # Logs and PIDs
~/Library/LaunchAgents/          # macOS auto-start
```

---

<p align="center">
  <a href="README.md">← Back to Tool Guides</a>
</p>
