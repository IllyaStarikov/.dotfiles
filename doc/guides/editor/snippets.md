# Snippets Guide

> **Code faster with intelligent snippets** - Smart templates that adapt to your context and boost productivity.

## Overview

This configuration uses LuaSnip, a powerful snippet engine that provides:
- **Context-aware snippets** - Smart defaults based on filename and content
- **Dynamic placeholders** - Tab through fields with intelligent suggestions
- **Choice nodes** - Multiple options at your fingertips
- **Auto-triggers** - Some snippets expand automatically
- **Custom snippets** - Easy to add your own

## How to Use Snippets

### Basic Usage

1. **Type the trigger** - In insert mode, type the snippet keyword
2. **Expand** - Press `Tab` to expand the snippet
3. **Navigate** - Use `Tab` to jump to next placeholder, `Shift+Tab` to go back
4. **Choose options** - Use `Ctrl+n`/`Ctrl+p` to cycle through choices
5. **Exit** - Press `Tab` at the last placeholder to exit

### Example Workflow

```python
# Type: def<Tab>
# Expands to:
def function_name(args):
    """Brief description."""
    pass

# Tab through placeholders to fill in:
# 1. function_name
# 2. args 
# 3. Brief description
# 4. function body
```

### Pro Tips

- **Visual mode snippets**: Select text, then type snippet trigger
- **Nested snippets**: You can use snippets inside other snippets
- **Quick skip**: Press `Ctrl+j` to jump out of a snippet
- **See available snippets**: `:Telescope luasnip` shows all snippets

## Python Snippets

### Essential Snippets

| Trigger | Description | Expands to |
|---------|-------------|------------|
| `main` | Main entry point | `def main():` with `if __name__ == '__main__'` |
| `def` | Function with docstring | Complete function with type hints and industry-standard docstring |
| `async` | Async function | `async def` with await support |
| `class` | Class definition | Class with `__init__` and docstring |
| `dataclass` | Modern dataclass | `@dataclass` with fields |
| `test` | Test function | pytest-style test with fixtures |

### Quick Snippets

| Trigger | Description | Expands to |
|---------|-------------|------------|
| `ifmain` | Main guard | `if __name__ == '__main__':` |
| `imp` | Import statement | `from module import name` |
| `pdb` | Debugger | `import pdb; pdb.set_trace()` |
| `ipdb` | IPython debugger | `import ipdb; ipdb.set_trace()` |
| `pp` | Pretty print | `from pprint import pprint; pprint()` |

### Advanced Snippets

| Trigger | Description | Features |
|---------|-------------|----------|
| `argparse` | CLI argument parser | Complete argparse setup with examples |
| `logging` | Logging setup | Logger configuration with proper formatting |
| `fixture` | pytest fixture | Fixture with yield and cleanup |
| `property` | Property decorator | Getter/setter with type hints |
| `context` | Context manager | `__enter__`/`__exit__` implementation |
| `abstract` | Abstract base class | ABC with abstract methods |

### Type Hints & Annotations

| Trigger | Description | Example |
|---------|-------------|---------||
| `-> None` | Return type none | Auto-suggested in functions |
| `-> int` | Return type int | Choose with `Ctrl+n/p` |
| `-> str` | Return type string | Available in choice nodes |
| `-> list` | Return type list | With generic support |
| `-> dict` | Return type dict | With key/value types |

## JavaScript/TypeScript Snippets

### Modern ES6+ Snippets

| Trigger | Description | Expands to |
|---------|-------------|------------|
| `imp` | ES6 import | `import { } from 'module'` |
| `exp` | ES6 export | `export { }` or `export default` |
| `cl` | Console log | `console.log()` with cursor inside |
| `fn` | Arrow function | `const name = () => {}` |
| `afn` | Async arrow function | `const name = async () => {}` |
| `des` | Destructuring | Object or array destructuring |
| `promise` | Promise constructor | `new Promise((resolve, reject) => {})` |
| `trycatch` | Try-catch block | With proper error handling |

### Array Methods

| Trigger | Description | Example |
|---------|-------------|---------||
| `map` | Array map | `.map((item) => {})` |
| `filter` | Array filter | `.filter((item) => {})` |
| `reduce` | Array reduce | `.reduce((acc, item) => {}, initial)` |
| `find` | Array find | `.find((item) => {})` |
| `forEach` | Array forEach | `.forEach((item) => {})` |

### React Snippets

| Trigger | Description | Features |
|---------|-------------|----------|
| `rfc` | Functional component | With props and return JSX |
| `hook` | Custom hook | `use` prefix, proper conventions |
| `useState` | State hook | With setter function |
| `useEffect` | Effect hook | With dependency array |
| `useContext` | Context hook | Context consumer setup |
| `useMemo` | Memoization hook | With dependencies |

### Node.js & Express

| Trigger | Description | Includes |
|---------|-------------|----------|
| `express` | Express route | GET/POST/PUT/DELETE with error handling |
| `middleware` | Express middleware | `(req, res, next) => {}` |
| `router` | Express router | Router setup with exports |
| `mongoose` | Mongoose schema | Model definition with validation |

### Testing

| Trigger | Description | Framework |
|---------|-------------|----------|
| `test` | Test case | Jest/Mocha compatible |
| `describe` | Test suite | With nested structure |
| `it` | Test spec | Individual test case |
| `expect` | Assertion | Jest expect syntax |
| `mock` | Mock function | `jest.fn()` setup |

## Markdown Snippets

### Document Templates

| Trigger | Description | Use Case |
|---------|-------------|----------|
| `readme` | README template | Project documentation with sections |
| `pr` | Pull request template | Standardized PR description |
| `issue` | Issue template | Bug report or feature request |
| `meeting` | Meeting notes | Agenda, attendees, action items |
| `adr` | Architecture Decision Record | Document technical decisions |
| `changelog` | Changelog entry | Version history documentation |

### Quick Formatting

| Trigger | Description | Result |
|---------|-------------|--------|
| `link` | Markdown link | `[text](url)` |
| `img` | Image | `![alt text](url "title")` |
| `code` | Code block | \`\`\`language\`\`\` with cursor |
| `task` | Task item | `- [ ] ` checkbox |
| `table` | Table structure | 3x3 table with headers |
| `details` | Collapsible section | `<details><summary>` block |
| `badge` | Status badge | Shield.io badge template |
| `toc` | Table of contents | Auto-generated TOC |

### Code Documentation

| Trigger | Description | Includes |
|---------|-------------|----------|
| `api` | API documentation | Endpoints, parameters, responses |
| `func` | Function documentation | Parameters, returns, examples |
| `class` | Class documentation | Methods, properties, usage |
| `install` | Installation guide | Requirements, steps, verification |

### GitHub Flavored Markdown

| Trigger | Description | Features |
|---------|-------------|----------|
| `alert` | GitHub alert | Note/Warning/Important boxes |
| `mermaid` | Mermaid diagram | Flowchart/sequence diagram |
| `diff` | Diff highlighting | `+` and `-` syntax |
| `kbd` | Keyboard key | `<kbd>` tag for keys |

## C/C++ Snippets

### C Snippets

| Trigger | Description | Expands to |
|---------|-------------|------------|
| `main` | Main function | `int main(int argc, char *argv[])` |
| `inc` | Include | `#include <>` or `#include ""` |
| `def` | Define macro | `#define MACRO value` |
| `ifdef` | Conditional compilation | `#ifdef`/`#endif` block |
| `struct` | Structure | `typedef struct` with fields |
| `func` | Function | With return type and parameters |
| `for` | For loop | `for (int i = 0; i < n; i++)` |
| `while` | While loop | `while (condition)` |
| `switch` | Switch statement | With cases and break |
| `enum` | Enumeration | `typedef enum` with values |

### C++ Snippets

| Trigger | Description | Features |
|---------|-------------|----------|
| `class` | Class definition | Constructor, destructor, private/public |
| `template` | Template class/function | Generic programming support |
| `namespace` | Namespace | `namespace name { }` |
| `try` | Try-catch | Exception handling |
| `unique` | Unique pointer | `std::unique_ptr<>` |
| `shared` | Shared pointer | `std::shared_ptr<>` |
| `vector` | Vector declaration | `std::vector<>` with initialization |
| `map` | Map declaration | `std::map<>` with key/value types |
| `lambda` | Lambda function | `[](){}` with captures |
| `auto` | Auto loop | Range-based for loop |

## HTML Snippets

### Document Structure

| Trigger | Description | Includes |
|---------|-------------|----------|
| `html5` | HTML5 boilerplate | DOCTYPE, head, body, meta tags |
| `viewport` | Viewport meta | Responsive viewport settings |
| `meta` | Meta tags | Description, keywords, author |
| `favicon` | Favicon link | Multiple icon sizes |

### Common Elements

| Trigger | Description | Attributes |
|---------|-------------|------------|
| `div` | Div with class | `class=""` with cursor |
| `span` | Span with class | Inline element |
| `a` | Anchor link | `href=""` and `title=""` |
| `img` | Image | `src=""`, `alt=""`, `loading="lazy"` |
| `button` | Button | `type="button"` with click handler |
| `section` | Section | Semantic HTML5 |
| `article` | Article | With header and content |
| `nav` | Navigation | Semantic navigation |

### Forms

| Trigger | Description | Features |
|---------|-------------|----------|
| `form` | Form structure | Action, method, validation |
| `input` | Input field | Type, name, placeholder |
| `select` | Select dropdown | With options |
| `textarea` | Text area | Rows, cols, placeholder |
| `label` | Form label | With `for` attribute |
| `fieldset` | Field group | With legend |

### Modern HTML

| Trigger | Description | Use Case |
|---------|-------------|----------|
| `canvas` | Canvas element | Graphics/animations |
| `video` | Video player | With controls and sources |
| `audio` | Audio player | Multiple format support |
| `details` | Details/summary | Collapsible content |
| `dialog` | Dialog modal | Native modal support |

## Java Snippets

### Class Structure

| Trigger | Description | Includes |
|---------|-------------|----------|
| `class` | Public class | Package, imports, constructor |
| `interface` | Interface | With default methods support |
| `enum` | Enumeration | With constructor and methods |
| `abstract` | Abstract class | Abstract methods |
| `main` | Main method | `public static void main` |

### Methods & Properties

| Trigger | Description | Features |
|---------|-------------|----------|
| `method` | Method with JavaDoc | Parameters, return, exceptions |
| `constructor` | Constructor | With parameters and super() |
| `getter` | Getter method | JavaBean convention |
| `setter` | Setter method | With validation |
| `toString` | toString override | StringBuilder implementation |
| `equals` | equals/hashCode | Proper implementation |

### Modern Java

| Trigger | Description | Version |
|---------|-------------|---------||
| `record` | Record class | Java 14+ |
| `var` | Local variable | Type inference |
| `stream` | Stream operation | Functional style |
| `optional` | Optional usage | Null safety |
| `lambda` | Lambda expression | Functional interface |

### Testing

| Trigger | Description | Framework |
|---------|-------------|----------|
| `test` | JUnit test | @Test annotation |
| `before` | Setup method | @BeforeEach |
| `after` | Teardown | @AfterEach |
| `mock` | Mockito mock | Mock creation |
| `assert` | Assertion | assertEquals, assertTrue |

## Shell Script Snippets

### Script Structure

| Trigger | Description | Features |
|---------|-------------|----------|
| `bash` | Bash shebang | `#!/bin/bash` with set options |
| `sh` | POSIX shebang | `#!/bin/sh` portable |
| `usage` | Usage function | Help text with examples |
| `args` | Argument parsing | getopts with validation |
| `main` | Main function | Script entry point |

### Control Flow

| Trigger | Description | Example |
|---------|-------------|---------||
| `if` | If statement | `if [[ condition ]]; then` |
| `elif` | Else if | `elif [[ condition ]]; then` |
| `for` | For loop | `for item in list; do` |
| `while` | While loop | `while condition; do` |
| `case` | Case statement | Pattern matching |
| `select` | Select menu | Interactive menu |

### Functions & Error Handling

| Trigger | Description | Includes |
|---------|-------------|----------|
| `func` | Function | Local variables, return |
| `trap` | Signal trap | Cleanup on exit |
| `error` | Error handler | Exit with message |
| `debug` | Debug mode | Conditional logging |
| `color` | Color output | ANSI escape codes |

### Common Patterns

| Trigger | Description | Use Case |
|---------|-------------|----------|
| `check` | Check command exists | `command -v` |
| `confirm` | Y/N confirmation | User prompt |
| `backup` | Backup file | With timestamp |
| `tmpfile` | Temporary file | Safe creation |
| `lockfile` | Lock file | Prevent multiple runs |

## LaTeX Snippets

### Document Structure

| Trigger | Description | Class Options |
|---------|-------------|---------------|
| `doc` | Document template | article/report/book |
| `preamble` | Common packages | Graphics, math, fonts |
| `sec` | Section | With label |
| `subsec` | Subsection | Auto-numbered |
| `subsubsec` | Subsubsection | Third level |
| `chap` | Chapter | For books/reports |

### Math Environment

| Trigger | Description | Usage |
|---------|-------------|-------|
| `eq` | Equation | `\begin{equation}` |
| `align` | Align environment | Multiple equations |
| `matrix` | Matrix | Various styles |
| `case` | Cases | Piecewise functions |
| `frac` | Fraction | `\frac{num}{den}` |
| `sum` | Summation | With limits |
| `int` | Integral | With bounds |
| `lim` | Limit | With subscript |

### Floats & References

| Trigger | Description | Features |
|---------|-------------|----------|
| `fig` | Figure | Caption, label, placement |
| `subfig` | Subfigures | Multiple images |
| `tab` | Table | With caption |
| `tabu` | Tabular | Column specification |
| `ref` | Reference | `\ref{label}` |
| `cite` | Citation | `\cite{key}` |
| `footnote` | Footnote | Bottom of page |

### Lists & Formatting

| Trigger | Description | Style |
|---------|-------------|-------|
| `item` | Itemize | Bullet points |
| `enum` | Enumerate | Numbered list |
| `desc` | Description | Term definitions |
| `verb` | Verbatim | Code/monospace |
| `quote` | Quote block | Indented text |
| `abstract` | Abstract | Article summary |

### Beamer Presentations

| Trigger | Description | Features |
|---------|-------------|----------|
| `frame` | Slide frame | Title and content |
| `block` | Block environment | Theorems, examples |
| `columns` | Two columns | Side-by-side content |
| `overlay` | Overlay spec | Animation `<1->` |

## Advanced Tips & Tricks

### Snippet Features

**Choice Nodes**
- When you see multiple options (like return types), use `Ctrl+n`/`Ctrl+p` to cycle
- Example: In Python `def`, cycle through `-> None`, `-> int`, `-> str`, etc.

**Smart Defaults**
- Class names default to filename (snake_case → PascalCase)
- Test files automatically get test-specific snippets
- Import paths are relative to current file

**Visual Mode Snippets**
1. Select text in visual mode
2. Press `Tab` (or your snippet trigger)
3. Type snippet name
4. Selected text becomes part of the snippet

**Regex Triggers**
- Some snippets trigger automatically
- Example: `()` after function name can trigger parameter hints

### Performance Tips

1. **Lazy Loading**: Snippets load per filetype for speed
2. **Caching**: Recently used snippets appear first
3. **Minimal Config**: Only essential snippets are loaded

### Creating Your Own Snippets

**Quick snippet creation**:
```vim
:lua require('luasnip.loaders').edit_snippet_files()
```

**Snippet file location**:
```
~/.dotfiles/src/snippets/[filetype].lua
```

**Basic snippet structure**:
```lua
s("trigger", {
  t("static text"),
  i(1, "placeholder"),
  c(2, { t("option1"), t("option2") }),
  f(function() return os.date("%Y") end),
})
```

## Customization Guide

### Adding Custom Snippets

1. **Create/edit snippet file**:
   ```bash
   nvim ~/.dotfiles/src/snippets/python.lua  # For Python snippets
   ```

2. **Add your snippet**:
   ```lua
   -- Add to the return table
   s("mysnip", {
     t("My custom snippet: "),
     i(1, "placeholder"),
     t({ "", "Second line" }),
     i(0)  -- Final cursor position
   })
   ```

3. **Reload snippets**:
   ```vim
   :lua require("luasnip.loaders.from_lua").load({paths = "~/.dotfiles/src/snippets"})
   ```

### Snippet Components

| Component | Function | Example |
|-----------|----------|---------||
| `t()` | Static text | `t("hello")` |
| `i()` | Insert node | `i(1, "default")` |
| `c()` | Choice node | `c(1, {t("opt1"), t("opt2")})` |
| `f()` | Function node | `f(function() return os.date() end)` |
| `d()` | Dynamic node | Complex logic |
| `sn()` | Snippet node | Nested snippets |

### Best Practices

1. **Naming**: Use descriptive, memorable triggers
2. **Order**: Number placeholders logically (1, 2, 3...)
3. **Defaults**: Provide sensible default values
4. **Documentation**: Add comments explaining complex snippets
5. **Testing**: Test snippets in actual code context

### Debugging Snippets

```vim
" List all available snippets
:lua print(vim.inspect(require('luasnip').available()))

" Check if snippet is loaded
:lua print(vim.inspect(require('luasnip').get_snippets("python")))

" Debug expansion
:lua require('luasnip').log.set_loglevel("info")
```

## Integration with Completion

Snippets integrate seamlessly with blink.cmp:
- Snippets appear in completion menu with `[Snippet]` label
- Press `Tab` to expand from completion menu
- Works alongside LSP completions
- Priority given to contextually relevant snippets

---

> **Pro tip**: The best snippets are the ones you create for your own repetitive patterns. Take note of code you type repeatedly and turn it into a snippet!