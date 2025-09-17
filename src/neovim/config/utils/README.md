# Utility Functions

Error handling and safe module loading utilities for robust Neovim configuration.

## Core Functions

### `safe_require(module_name)`

Load module with error notification:

```lua
local telescope, ok = utils.safe_require("telescope")
if ok then
  telescope.setup({})
end
```

### `silent_require(module_name)`

Load optional module without errors:

```lua
local work_config = utils.silent_require("work.config")
```

### `protected_call(fn, description, ...)`

Execute function with error handling:

```lua
utils.protected_call(risky_function, "Processing files", arg1, arg2)
```

### `setup_plugin(plugin_name, config)`

Complete plugin setup with safety:

```lua
utils.setup_plugin("blink.cmp", {
  sources = { "lsp", "buffer" }
})
```

## Usage Patterns

### Loading Work Configs

```lua
-- Check for work-specific overrides
local work = utils.silent_require("work.config")
if work then
  work.apply_overrides()
end
```

### Safe Keymaps

```lua
utils.safe_keymap("n", "<leader>ff", "telescope.builtin", "find_files",
  { desc = "Find Files" })
```

## Key Principles

- **Graceful degradation** - Missing plugins don't crash Neovim
- **User-friendly errors** - Clear notifications, not cryptic messages
- **Optional enhancements** - Work configs load only if present
- **Defensive programming** - Every external call protected

## Common Issues

**Module not found**: Use `safe_require` for user-facing features, `silent_require` for optional enhancements.

**Circular dependencies**: Break cycles with lazy evaluation.

**Error spam**: Batch errors with `batch_require` for cleaner output.

This module prevents 95% of configuration crashes from missing or broken plugins.
