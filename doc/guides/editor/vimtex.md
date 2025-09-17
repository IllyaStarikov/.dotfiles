# VimTeX Guide

> **Professional LaTeX environment in Neovim** - Complete LaTeX editing with live preview, smart compilation, and powerful shortcuts.

## Overview

VimTeX transforms Neovim into a powerful LaTeX editor with features that rival dedicated LaTeX IDEs. This configuration provides:

- **Live compilation** - See changes in real-time with automatic PDF updates
- **Bidirectional sync** - Jump between source and PDF seamlessly
- **Smart completion** - Citations, references, commands, and environments
- **Error handling** - Clear error messages with quickfix integration
- **Text objects** - Navigate and edit LaTeX structures efficiently
- **Extensive snippets** - Fast document creation with LuaSnip integration

## Key Features

### Compilation System

- **latexmk backend** - Reliable, continuous compilation with dependency tracking
- **Shell escape** - Full support for TikZ, minted, and external tools
- **Smart errors** - Filters noise, shows only relevant compilation errors
- **Auto-rebuild** - Detects changes in included files and bibliography

### PDF Viewer Integration

- **macOS**: Skim (recommended) or Preview
- **Linux**: Zathura (recommended) or Evince
- **Windows**: SumatraPDF
- **Forward search**: Jump from source to PDF location
- **Reverse search**: Click PDF to jump to source

### Editing Features

- **Smart indentation** - Automatic environment indentation
- **Folding** - Collapse sections for document overview
- **Text objects** - `ic`/`ac` for commands, `ie`/`ae` for environments
- **Delimiter matching** - Highlights matching braces, brackets
- **Conceal** - Math symbols display as Unicode (optional)

## Essential Keybindings

### Compilation Control

| Key          | Action                        | Description                     |
| ------------ | ----------------------------- | ------------------------------- |
| `<leader>ll` | Toggle continuous compilation | Start/stop auto-compile on save |
| `<leader>lL` | Compile once                  | Single compilation run          |
| `<leader>lc` | Compile selection             | Compile selected text only      |
| `<leader>ls` | Stop compilation              | Stop current compilation        |
| `<leader>lS` | Stop all                      | Stop all VimTeX processes       |
| `<leader>le` | Show errors                   | Open quickfix with errors       |
| `<leader>lo` | View compiler output          | Full compilation log            |

### PDF Viewer

| Key          | Action            | Description                     |
| ------------ | ----------------- | ------------------------------- |
| `<leader>lv` | View PDF          | Open PDF in configured viewer   |
| `<leader>lr` | Reverse search    | Jump to current location in PDF |
| `<leader>lt` | Table of contents | Show document structure         |
| `<leader>lT` | Toggle TOC        | Open/close TOC window           |

### File Management

| Key          | Action                | Description                              |
| ------------ | --------------------- | ---------------------------------------- |
| `<leader>lk` | Clean auxiliary files | Remove .aux, .log, .out, etc.            |
| `<leader>lK` | Clean all outputs     | Remove all generated files including PDF |
| `<leader>lR` | Reload VimTeX         | Reload plugin configuration              |
| `<leader>la` | Context menu          | Show available VimTeX actions            |

### Document Navigation

| Key  | Action                   | Description                          |
| ---- | ------------------------ | ------------------------------------ |
| `]]` | Next section             | Jump to next \section                |
| `[[` | Previous section         | Jump to previous \section            |
| `][` | Next section end         | Jump to end of current section       |
| `[]` | Previous section end     | Jump to beginning of section         |
| `]m` | Next environment         | Jump to next \begin                  |
| `[m` | Previous environment     | Jump to previous \begin              |
| `]M` | Next environment end     | Jump to next \end                    |
| `[M` | Previous environment end | Jump to previous \end                |
| `%`  | Matching delimiter       | Jump between \begin/\end or brackets |

### Text Formatting (Visual Mode)

Select text first, then apply formatting:

| Key           | Command        | Result            |
| ------------- | -------------- | ----------------- |
| `<leader>lb`  | `\textbf{}`    | **Bold text**     |
| `<leader>li`  | `\textit{}`    | _Italic text_     |
| `<leader>lu`  | `\underline{}` | Underlined text   |
| `<leader>lf`  | `\texttt{}`    | `Monospace text`  |
| `<leader>le`  | `\emph{}`      | _Emphasized text_ |
| `<leader>lsc` | `\textsc{}`    | Small caps        |
| `<leader>lM`  | `\[ ... \]`    | Display math mode |
| `<leader>l$`  | `$ ... $`      | Inline math mode  |

**Tip**: These commands wrap selected text. In normal mode, they create empty commands with cursor inside.

### Document Structure

| Key           | Inserts    | LaTeX Command   |
| ------------- | ---------- | --------------- |
| `<leader>lsc` | Chapter    | `\chapter{}`    |
| `<leader>lss` | Section    | `\section{}`    |
| `<leader>lsS` | Subsection | `\subsection{}` |
| `<leader>lsp` | Paragraph  | `\paragraph{}`  |

### References & Citations

| Key           | Inserts      | Description            |
| ------------- | ------------ | ---------------------- |
| `<leader>lrl` | `\label{}`   | Create label at cursor |
| `<leader>lrr` | `\ref{}`     | Reference to label     |
| `<leader>lrp` | `\pageref{}` | Page reference         |
| `<leader>lrc` | `\cite{}`    | Bibliography citation  |
| `<leader>lrC` | `\citep{}`   | Parenthetical citation |
| `<leader>lrt` | `\citet{}`   | Textual citation       |

**Smart completion**: After typing `\ref{` or `\cite{`, press `<C-x><C-o>` for suggestions.

### Environment Templates

| Key           | Environment | Structure                               |
| ------------- | ----------- | --------------------------------------- |
| `<leader>lff` | Figure      | `\begin{figure}` with caption and label |
| `<leader>lft` | Table       | `\begin{table}` with tabular            |
| `<leader>lei` | Itemize     | Bullet list environment                 |
| `<leader>len` | Enumerate   | Numbered list environment               |
| `<leader>led` | Description | Description list                        |
| `<leader>leq` | Equation    | Numbered equation                       |
| `<leader>lea` | Align       | Multi-line aligned equations            |
| `<leader>lem` | Matrix      | Matrix environment                      |
| `<leader>lep` | Proof       | Proof environment                       |

**Quick surround**: Use `yse` to surround selection with environment.

## Text Objects & Motions

### LaTeX-Specific Text Objects

| Object    | Description               | Example                           |
| --------- | ------------------------- | --------------------------------- |
| `ic`/`ac` | Inside/around command     | `ci$` changes math content        |
| `id`/`ad` | Inside/around delimiter   | `di)` deletes inside parens       |
| `ie`/`ae` | Inside/around environment | `vie` selects environment content |
| `i$`/`a$` | Inside/around math        | `da$` deletes inline math         |
| `iP`/`aP` | Inside/around section     | `vaP` selects entire section      |

### Smart Motions

| Motion        | Description                      |
| ------------- | -------------------------------- |
| `%`           | Jump between matching delimiters |
| `]`/`[` + `m` | Next/previous environment        |
| `]`/`[` + `/` | Next/previous comment            |
| `]`/`[` + `*` | Next/previous section            |

## Advanced Features

### Multi-file Projects

**Main file detection**: VimTeX automatically detects the main `.tex` file:

- Looks for `.latexmain` file
- Checks for `\documentclass` in current/parent directories
- Uses `% !TEX root = main.tex` directive

**Project structure**:

```
project/
├── main.tex          % Main document
├── chapters/
│   ├── intro.tex
│   └── methods.tex
├── figures/
└── references.bib
```

### Compilation Options

**Quick compile current paragraph**:

```vim
vip<leader>lc  " Select paragraph and compile
```

**Change compiler on the fly**:

```vim
:VimtexCompilerSelected latexmk
:VimtexCompilerSelected tectonic
:VimtexCompilerSelected arara
```

### Error Handling

**Navigate errors**:

- `]e` - Next error
- `[e` - Previous error
- `<leader>le` - Open error window

**Common fixes**:

- Missing package: Check `\usepackage{}` statements
- Undefined reference: Run compilation twice
- Bibliography issues: Ensure `.bib` file exists

## Configuration Details

### Automatic Settings

When you open a `.tex` file, VimTeX automatically configures:

| Setting        | Value  | Purpose                 |
| -------------- | ------ | ----------------------- |
| `textwidth`    | 80     | Automatic line breaking |
| `wrap`         | On     | Visual line wrapping    |
| `spell`        | On     | Spell checking (en_us)  |
| `conceallevel` | 2      | Math symbols as Unicode |
| `indentexpr`   | VimTeX | Smart LaTeX indentation |
| `foldmethod`   | expr   | Section-based folding   |

### Performance Optimizations

- **Lazy loading**: VimTeX loads only when editing `.tex` files
- **Selective features**: Unused modules disabled for speed
- **Smart compilation**: Only recompiles changed content
- **Efficient previews**: PDF viewer stays open between compilations

### Customization

Add to your config to customize:

```lua
-- Change compiler
vim.g.vimtex_compiler_method = 'tectonic'  -- Faster alternative

-- Disable concealment
vim.g.vimtex_syntax_conceal_disable = 1

-- Custom PDF viewer
vim.g.vimtex_view_method = 'zathura'
vim.g.vimtex_view_general_viewer = 'okular'
```

## Typical Workflows

### Quick Document

```bash
# 1. Create new document
nvim report.tex

# 2. Use snippet for boilerplate
doc<Tab>  # Expands full document template

# 3. Start live compilation
<leader>ll

# 4. Open PDF viewer
<leader>lv

# 5. Write with live preview
# PDF updates automatically on save
```

### Research Paper

```bash
# Structure
paper/
├── main.tex
├── abstract.tex
├── introduction.tex
├── methodology.tex
├── results.tex
├── references.bib
└── figures/

# In main.tex
\input{abstract}
\input{introduction}
# etc.

# Compile from any file
<leader>ll  # VimTeX finds main.tex automatically
```

### Beamer Presentation

```latex
% Use beamer snippets
frame<Tab>   % New slide
block<Tab>   % Content block
columns<Tab> % Two-column layout

% Preview slides
<leader>lv   % Opens PDF
<leader>lr   % Jump to current slide
```

### Math-Heavy Document

```vim
" Quick math entry
eq<Tab>      " Equation environment
align<Tab>   " Aligned equations

" In insert mode
^^           " Superscript
__           " Subscript
//           " Fraction

" Unicode preview
:VimtexToggleConceal  " Toggle math symbols
```

## Pro Tips

### Efficiency Boosters

1. **Master text objects**: `cie` to change environment content saves time
2. **Use snippets**: Much faster than typing commands manually
3. **Continuous mode**: Set and forget - `<leader>ll` once per session
4. **Forward search**: `<leader>lr` to check formatting without scrolling PDF
5. **Quickfix navigation**: `]e`/`[e` to jump between errors quickly

### Best Practices

1. **Project structure**:
   - Keep main file in root
   - Use subdirectories for chapters/sections
   - Store figures in `figures/`
   - Single `references.bib` file

2. **Compilation**:
   - Use continuous mode for drafting
   - Single compile for final version
   - Clean auxiliary files before submission

3. **Collaboration**:
   - Use Git for version control
   - Define main file with `% !TEX root`
   - Consistent formatting with `src/editorconfig`

### Common Solutions

| Problem            | Solution                                  |
| ------------------ | ----------------------------------------- |
| PDF not updating   | Check `<leader>le` for errors             |
| Slow compilation   | Disable continuous mode, compile manually |
| Missing references | Compile twice or use `latexmk`            |
| Font issues        | Install `texlive-fonts-extra`             |
| Unicode errors     | Ensure `\usepackage[utf8]{inputenc}`      |

### Integration with Snippets

VimTeX works seamlessly with our LaTeX snippets:

- Type `fig<Tab>` for figure environment
- Type `eq<Tab>` for equation
- Type `sec<Tab>` for section
- See [Snippets Guide](./snippets_guide.md) for full list

## Troubleshooting

### Viewer Issues

**Skim not syncing (macOS)**:

```bash
# Enable Skim sync
defaults write -app Skim SKTeXEditorCommand "nvim"
defaults write -app Skim SKTeXEditorArguments "--headless -c 'VimtexInverseSearch %line %file'"
```

**Zathura not found (Linux)**:

```bash
sudo apt install zathura zathura-pdf-poppler
```

### Compilation Problems

**latexmk not found**:

```bash
# macOS
brew install texlive

# Linux
sudo apt install texlive-full

# Minimal installation
sudo apt install texlive-base texlive-latex-extra latexmk
```

**Shell escape not working**:

```vim
" Add to your LaTeX file
% !TEX options = --shell-escape
```

### Performance Issues

**Slow on large documents**:

```vim
" Disable syntax concealment
:VimtexToggleConceal

" Disable continuous compilation
<leader>ls

" Compile specific sections only
vip<leader>lc
```

---

> **Remember**: VimTeX makes LaTeX editing efficient and enjoyable. Take time to learn the keybindings and text objects - they'll become second nature and dramatically speed up your LaTeX workflow!
