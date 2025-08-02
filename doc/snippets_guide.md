# Snippets Guide

## Usage
1. Type the snippet trigger in insert mode
2. Press `Tab` to expand the snippet
3. Use `Tab`/`Shift+Tab` to navigate placeholders
4. Type to replace placeholder text

## Python

**Core snippets**
- `header` - Module header with docstring
- `main` - Main function with argparse
- `class` - Google style class
- `def` - Function with full documentation
- `async` - Async function
- `dataclass` - Modern dataclass
- `property` - Property with setter
- `test` - Pytest test suite
- `cli` - CLI application
- `fastapi` - FastAPI endpoint
- `context` - Context manager

**Quick snippets**
- `ifmain` - if __name__ == '__main__'
- `import` - from module import function
- `pdb` - import pdb; pdb.set_trace()

## JavaScript/TypeScript

**React**
- `rfc` - React functional component
- `hook` - Custom React hook
- `slice` - Redux Toolkit slice

**Node.js**
- `express` - Express.js endpoint
- `test` - Jest test suite

**Quick snippets**
- `cl` - console.log()
- `imp` - import statement
- `exp` - export statement
- `arr` - array declaration
- `obj` - object declaration
- `des` - destructuring
- `promise` - new Promise()
- `map` - array.map()
- `filter` - array.filter()
- `reduce` - array.reduce()

## Markdown

**Documents**
- `design_doc` - Technical design document
- `readme` - Professional README
- `api_doc` - API documentation
- `pr_template` - Pull request template
- `meeting` - Meeting notes
- `blog` - Technical blog post
- `roadmap` - Project roadmap
- `review` - Code review checklist

**Quick snippets**
- `link` - [text](url)
- `img` - ![alt](url "title")
- `code` - ```language code block
- `task` - - [ ] task item
- `table` - markdown table
- `details` - collapsible section
- `badge` - shield/badge

## C/C++
- `main` - main function
- `inc` - #include statement
- `def` - #define macro
- `ifdef` - conditional compilation
- `struct` - structure definition
- `class` - C++ class
- `for` - for loop
- `while` - while loop
- `if` - if statement
- `func` - function definition

## HTML
- `html5` - HTML5 boilerplate
- `div` - div with class
- `a` - anchor tag
- `img` - image tag
- `form` - form structure
- `input` - input field
- `button` - button element
- `script` - script tag
- `style` - style tag
- `meta` - meta tags

## Java
- `main` - main method
- `class` - class definition
- `interface` - interface definition
- `method` - method with JavaDoc
- `constructor` - constructor
- `getter` - getter method
- `setter` - setter method
- `try` - try-catch block
- `for` - enhanced for loop
- `test` - JUnit test

## Shell Script
- `bash` - bash shebang
- `if` - if statement
- `elif` - elif statement
- `for` - for loop
- `while` - while loop
- `case` - case statement
- `func` - function definition
- `args` - argument parsing
- `trap` - trap signals
- `usage` - usage function

## LaTeX
- `doc` - document template
- `sec` - section
- `subsec` - subsection
- `eq` - equation
- `fig` - figure
- `tab` - table
- `item` - itemize
- `enum` - enumerate
- `ref` - reference
- `cite` - citation

## Tips
- **Nested snippets**: Some snippets can be used inside others
- **Smart defaults**: Auto-fills based on filename or context
- **Choice nodes**: Use `Ctrl+n/p` to cycle through options
- **Live updates**: Function nodes update as you type

## Customization
Add your own snippets:
1. Edit files in `~/.dotfiles/src/snippets/`
2. Follow LuaSnip syntax
3. Reload Neovim or run `:source %`