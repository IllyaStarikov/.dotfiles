# Services

Background service manager for personal applications that run persistently.

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

| Command                   | Description                        |
| ------------------------- | ---------------------------------- |
| `services`                | Show status of all services        |
| `services start [name]`   | Start all or specific service      |
| `services stop [name]`    | Stop all or specific service       |
| `services restart [name]` | Restart all or specific service    |
| `services status [name]`  | Show status                        |
| `services list`           | List available services            |
| `services logs <name>`    | Show service logs                  |
| `services install`        | Install LaunchAgent for auto-start |
| `services uninstall`      | Remove LaunchAgent                 |

## Creating a Service

Create a `.service` file in this directory:

```bash
#!/usr/bin/env zsh
# myservice.service - Description of your service

SERVICE_NAME="myservice"
SERVICE_DESC="Short description"

service_start() {
  # Your start logic here
  # Must run in foreground (use exec or don't background)
  exec /path/to/your/command
}

service_stop() {
  # Optional: custom stop logic
  # Default: SIGTERM is sent to the process
  :
}
```

## Service Variables

| Variable          | Required | Description                |
| ----------------- | -------- | -------------------------- |
| `SERVICE_NAME`    | Yes      | Unique identifier          |
| `SERVICE_DESC`    | No       | Human-readable description |
| `SERVICE_PIDFILE` | No       | Custom PID file path       |

## Available Services

### calibre-web

Calibre-Web ebook server for managing and reading ebooks.

- **Port**: 8083 (default)
- **URL**: http://localhost:8083
- **Requirements**: Python venv at `~/calibre-web/venv/`

## File Locations

- **Service definitions**: `~/.dotfiles/src/services/*.service`
- **Logs**: `~/.local/state/services/*.log`
- **PID files**: `~/.local/state/services/pids/*.pid`
- **LaunchAgent**: `~/Library/LaunchAgents/io.starikov.services.plist`
