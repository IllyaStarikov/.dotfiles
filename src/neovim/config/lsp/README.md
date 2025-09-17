# Language Server Protocol (LSP) Configuration

Provides IDE features for 20+ languages via Language Server Protocol.

## Files

- `init.lua` - Entry point
- `servers.lua` - Server configurations (17KB)

## Quick Start

```vim
:Mason              " Install/manage servers
:LspInfo           " Check server status
:LspRestart        " Restart servers
```

## Supported Languages

**Web**: TypeScript, JavaScript, HTML, CSS, Vue
**Systems**: C/C++, Rust, Go, Zig
**Scripting**: Python, Ruby, Lua, Bash
**Data**: JSON, YAML, TOML, SQL
**Other**: Java, LaTeX, Markdown, Docker

## Key Features

- **Auto-install** via Mason
- **Work overrides** for Google/Garmin environments
- **Optimized settings** per language
- **Blink.cmp integration** for completion

## Common Commands

| Key          | Action             |
| ------------ | ------------------ |
| `gd`         | Go to definition   |
| `gr`         | Find references    |
| `K`          | Show documentation |
| `<leader>rn` | Rename symbol      |
| `<leader>ca` | Code actions       |

## Troubleshooting

### Pyright using too much memory

```lua
-- In servers.lua, limit workspace scope:
python = {
  analysis = {
    diagnosticMode = "openFilesOnly"  -- Not "workspace"
  }
}
```

### Clangd can't find headers

Generate `compile_commands.json`:

```bash
cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=ON .
# or
bear -- make
```

### Work environment detection

The config checks `~/.dotfiles.private/lsp-override.lua` for work-specific servers (CiderLSP at Google, custom clangd at Garmin).

## Performance Notes

- SSH signing is 10x easier than GPG
- Disabled providers save 70ms startup
- Lazy loading prevents 500ms delay

See also: [Mason Registry](https://mason-registry.dev/) | [Neovim LSP Docs](https://neovim.io/doc/user/lsp.html)
