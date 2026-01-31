# /src/neovim/snippets - Code Snippets

> **Language-specific code snippets** - Boost productivity with smart templates and expansions

This directory contains LuaSnip snippet definitions for various programming languages, providing quick code templates and boilerplate reduction.

## 📁 Directory Contents

```
snippets/
├── c.lua          # C language snippets (4.6KB)
├── cpp.lua        # C++ snippets (7.8KB)
├── html.lua       # HTML/Web snippets (4.4KB)
├── java.lua       # Java snippets (6.1KB)
├── javascript.lua # JavaScript/TypeScript (6.6KB)
├── markdown.lua   # Markdown snippets (3.7KB)
├── python.lua     # Python snippets (7.1KB)
├── sh.lua         # Shell/Bash snippets (4.1KB)
├── tex.lua        # LaTeX snippets (5.0KB)
└── todo.lua       # TODO/Comment snippets (1.4KB)
```

## 🚀 Snippet Categories

### C/C++ Snippets

**c.lua & cpp.lua**

- `main` - Main function template
- `inc` - Include statements
- `for` - For loop
- `while` - While loop
- `struct` - Structure definition
- `class` - Class template (C++)
- `printf` - Print statement
- `malloc` - Memory allocation

### Python Snippets

**python.lua**

- `main` - Main guard
- `class` - Class definition
- `def` - Function definition
- `defs` - Method with self
- `try` - Try/except block
- `with` - Context manager
- `list` - List comprehension
- `dict` - Dictionary comprehension
- `import` - Import statements

### JavaScript/TypeScript

**javascript.lua**

- `func` - Function declaration
- `arrow` - Arrow function
- `class` - ES6 class
- `promise` - Promise template
- `async` - Async function
- `fetch` - Fetch API call
- `useState` - React hook
- `component` - React component

### Shell/Bash

**sh.lua**

- `bash` - Bash shebang
- `if` - If statement
- `for` - For loop
- `while` - While loop
- `case` - Case statement
- `func` - Function definition
- `array` - Array operations
- `getopts` - Option parsing

### HTML

**html.lua**

- `html5` - HTML5 boilerplate
- `div` - Div with class
- `link` - Link tag
- `script` - Script tag
- `form` - Form template
- `input` - Input field
- `button` - Button element

### Markdown

**markdown.lua**

- `code` - Code block
- `link` - Markdown link
- `img` - Image
- `table` - Table template
- `task` - Task list item
- `details` - Collapsible section
- `badge` - Shield.io badge

### LaTeX

**tex.lua**

- `doc` - Document template
- `sec` - Section
- `eq` - Equation
- `fig` - Figure
- `table` - Table environment
- `cite` - Citation
- `ref` - Reference
- `enumerate` - List

### TODO Comments

**todo.lua**

- `TODO` - TODO comment
- `FIXME` - Fix me comment
- `NOTE` - Note comment
- `HACK` - Hack comment
- `WARNING` - Warning comment

## ⚙️ Snippet Structure

### Basic Snippet Format

```lua
local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

return {
  s("trigger", {
    t("Static text "),
    i(1, "placeholder"),
    t(" more text"),
    i(0),  -- Final cursor position
  }),
}
```

### Advanced Features

```lua
-- Choice node example
s("for", {
  t("for "),
  c(1, {
    t("i"),
    t("index"),
    i(nil, "var"),
  }),
  t(" in range("),
  i(2, "10"),
  t("):"),
  t({"", "\t"}),
  i(0),
}),
```

## 🎯 Usage

### Triggering Snippets

1. Type the trigger text
2. Press `Tab` to expand
3. Use `Tab`/`Shift+Tab` to navigate placeholders
4. Press `Ctrl+k` to jump to next placeholder

### Snippet Commands

```vim
:LuaSnipListAvailable  " List available snippets
:LuaSnipUnlinkCurrent  " Unlink from current snippet
:LuaSnipJump 1         " Jump forward
:LuaSnipJump -1        " Jump backward
```

### Visual Mode Snippets

1. Select text in visual mode
2. Press `Tab`
3. Type snippet trigger
4. Selected text becomes part of snippet

## 🔧 Customization

### Adding New Snippets

1. Create or edit language file
2. Add snippet definition
3. Reload with `:source %`

Example:

```lua
-- In python.lua
s("fastapi", {
  t({"from fastapi import FastAPI", "", ""}),
  t("app = FastAPI()", "", ""),
  t("@app.get(\"/\")"),
  t({"", "async def root():"}),
  t({"", "\treturn {\"message\": \""}),
  i(1, "Hello World"),
  t("\"}"),
  i(0),
}),
```

### Custom Snippet File

Create `~/.config/nvim/snippets/custom.lua`:

```lua
return {
  all = {  -- Snippets for all file types
    s("date", {
      f(function() return os.date("%Y-%m-%d") end),
    }),
  },
  lua = {  -- Lua-specific snippets
    s("req", {
      t("local "),
      i(1, "module"),
      t(" = require(\""),
      rep(1),
      t("\")"),
    }),
  },
}
```

## 🔌 Integration

### With Completion

Snippets integrate with blink.cmp:

- Appear in completion menu
- Show snippet preview
- Expand on selection

### With LSP

- LSP snippets also available
- Function signatures
- Parameter hints

### With Treesitter

- Context-aware snippets
- Syntax validation
- Smart indentation

## ⌨️ Key Bindings

| Key         | Mode   | Action                       |
| ----------- | ------ | ---------------------------- |
| `Tab`       | Insert | Expand/Jump forward          |
| `Shift+Tab` | Insert | Jump backward                |
| `Ctrl+k`    | Insert | Jump to next placeholder     |
| `Ctrl+j`    | Insert | Jump to previous placeholder |
| `Ctrl+l`    | Insert | Choose next option           |
| `Ctrl+h`    | Insert | Choose previous option       |

## 💡 Tips & Tricks

1. **Multi-cursor**: Use snippets with multiple cursors
2. **Regex Triggers**: Use patterns for triggers
3. **Dynamic Nodes**: Generate content dynamically
4. **Post-expand Actions**: Run commands after expansion
5. **Conditional Snippets**: Show based on context

### Useful Patterns

```lua
-- Date/time insertion
f(function() return os.date("%Y-%m-%d %H:%M") end)

-- Filename without extension
f(function() return vim.fn.expand("%:t:r") end)

-- Capitalize placeholder
f(function(args) return string.upper(args[1][1]) end, {1})
```

## 🐛 Troubleshooting

### Snippets Not Working

```vim
:checkhealth luasnip
:LuaSnipListAvailable
```

### Reload Snippets

```vim
:lua require("luasnip").cleanup()
:lua require("luasnip.loaders.from_lua").load({paths = "~/.config/nvim/snippets"})
```

### Debug Mode

```lua
-- In config
require("luasnip").config.set_config({
  history = true,
  updateevents = "TextChanged,TextChangedI",
  enable_autosnippets = true,
})
```

## 📚 Related Documentation

- [LuaSnip Documentation](https://github.com/L3MON4D3/LuaSnip)
- [Neovim Config](../README.md)
- [Completion Setup](../blink-setup.lua)
- [Keymaps](../keymaps/README.md)
