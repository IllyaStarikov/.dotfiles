# Fixy Integration for Neovim

## Overview

The Fixy formatter is integrated into Neovim to provide automatic code formatting on save using the powerful `fixy` script. This integration is async, non-blocking, and enabled by default.

## Commands

### `:Fixy`
Format the current file immediately using fixy. This runs asynchronously and reloads the buffer when complete.

### `:FixyAuto`
Toggle auto-formatting on save. This is a bit flip - if auto-format is on, it turns it off; if it's off, it turns it on.

### `:FixyAutoOn`
Explicitly enable auto-formatting on save.

### `:FixyAutoOff`
Explicitly disable auto-formatting on save.

### `:FixyStatus`
Show the current status of auto-formatting (enabled or disabled).

## Default Behavior

- **Auto-format is ENABLED by default** when you start Neovim
- Files are automatically formatted when you save them (`:w`)
- Formatting happens asynchronously (non-blocking)
- Your cursor position is preserved after formatting

## Key Bindings

- `<leader>cf` - Format current file with fixy (same as `:Fixy`)

## Supported File Types

Fixy automatically detects and formats many file types including:
- Python (.py)
- JavaScript/TypeScript (.js, .ts, .jsx, .tsx)
- Shell scripts (.sh, .bash, .zsh)
- Lua (.lua)
- Rust (.rs)
- Go (.go)
- C/C++ (.c, .cpp, .h)
- And many more...

## Configuration

The fixy integration can be customized by modifying `~/.dotfiles/src/neovim/config/fixy.lua`.

### Disable Notifications

To disable formatting notifications, edit the config:
```lua
local config = {
  notifications = false,  -- Set to false to disable
  -- ...
}
```

### Change Fixy Path

If fixy is installed elsewhere:
```lua
local config = {
  cmd = "/path/to/fixy",
  -- ...
}
```

## Skipped File Types

The following file types are automatically skipped:
- Git commits (`gitcommit`, `gitrebase`)
- File explorers (`oil`, `NvimTree`, `neo-tree`)
- Special buffers (`TelescopePrompt`, `dashboard`)

## Troubleshooting

### Fixy not found
If you see "Fixy not found" error, ensure the fixy script is executable:
```bash
chmod +x ~/.dotfiles/src/scripts/fixy
```

### Formatting not working
1. Check if auto-format is enabled: `:FixyStatus`
2. Verify fixy works on the command line: `~/.dotfiles/src/scripts/fixy <file>`
3. Check for errors in Neovim: `:messages`

### Disable for specific project
Add this to your project's `.nvimrc` or in a autocmd:
```vim
:FixyAutoOff
```

## Performance

- Formatting runs asynchronously and doesn't block the editor
- File is reloaded automatically after formatting completes
- Cursor position and view are preserved