# Modern Neovim Plugins Guide

This guide covers the modern Neovim plugin replacements and their usage.

## Plugin Migration

### Replaced Plugins

| Old Plugin | New Plugin | Reason |
|------------|------------|---------|
| vim-airline | mini.statusline | Lua-based, faster, lighter |
| tagbar | aerial.nvim | LSP/TreeSitter support, better integration |
| vim-commentary | Comment.nvim | Smart context-aware commenting |
| vim-surround | mini.surround | Part of mini.nvim ecosystem |
| vim-easy-align | mini.align | Simpler, more efficient |
| targets.vim | mini.ai | Better TreeSitter integration |
| vim-gitgutter | gitsigns.nvim | Already installed, more features |
| vim-grepper | Telescope grep | Built-in, more powerful |

## Mini.nvim Suite

Mini.nvim provides a collection of independent Lua modules for Neovim.

### mini.statusline

A minimal and fast statusline.

- Automatically configured
- Shows mode, file info, cursor position
- Git branch integration
- LSP status

### mini.surround

| Key | Action | Description |
|-----|--------|-------------|
| `ys{motion}{char}` | Add surrounding | Add surrounding characters |
| `ds{char}` | Delete surrounding | Delete surrounding characters |
| `cs{old}{new}` | Change surrounding | Change surrounding characters |

Examples:
- `ysiw"` - Surround word with quotes
- `ds'` - Delete surrounding single quotes
- `cs"'` - Change double quotes to single quotes

### mini.align

| Key | Action | Description |
|-----|--------|-------------|
| `ga` | Align | Start interactive alignment |
| `gA` | Align with preview | Start alignment with preview |

Usage:
1. Select text in visual mode
2. Press `ga`
3. Enter delimiter (e.g., `=`, `:`, `|`)

### mini.ai

Enhanced text objects with TreeSitter support.

| Text Object | Description |
|-------------|-------------|
| `if`/`af` | Function (inner/around) |
| `ic`/`ac` | Class (inner/around) |
| `io`/`ao` | Block/conditional/loop (inner/around) |

Plus all standard text objects with improvements.

## Aerial.nvim

Modern code outline window using LSP and TreeSitter.

| Key | Action | Description |
|-----|--------|-------------|
| `<leader>T` | Toggle Aerial | Open/close code outline |
| `<leader>at` | Toggle Aerial | Alternative binding |
| `<leader>an` | Aerial navigation | Toggle navigation window |

Inside Aerial window:
- `<CR>` - Jump to symbol
- `p` - Preview (scroll to symbol without jumping)
- `q` - Close
- `o`/`O` - Toggle fold / Toggle all folds
- `{`/`}` - Previous/next symbol

## Comment.nvim

Smart commenting with context awareness.

| Mode | Key | Action |
|------|-----|--------|
| Normal | `gcc` | Toggle line comment |
| Normal | `gbc` | Toggle block comment |
| Normal | `gc{motion}` | Toggle comment over motion |
| Visual | `gc` | Toggle comment for selection |
| Visual | `gb` | Toggle block comment for selection |

Examples:
- `gcc` - Comment current line
- `gc3j` - Comment current line and 3 lines below
- `gcip` - Comment inside paragraph

## Tips

1. **Statusline**: mini.statusline is automatically themed based on your colorscheme
2. **Text Objects**: mini.ai provides smarter text objects that understand code structure
3. **Aerial**: Use `<C-j>`/`<C-k>` for quick navigation in the outline
4. **Comments**: Comment.nvim detects filetype and uses appropriate comment style

## Performance Benefits

- All plugins are written in Lua (faster startup)
- Better integration with Neovim's built-in features
- Reduced memory footprint
- Modern async operations
- TreeSitter and LSP aware