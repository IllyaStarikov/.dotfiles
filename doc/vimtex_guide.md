# VimTeX Guide

## Features
- **Continuous compilation** with latexmk
- **PDF sync** - Forward/reverse search between source and PDF
- **Smart viewers** - Skim (macOS), Zathura (Linux), SumatraPDF (Windows)
- **Shell-escape** for TikZ, minted, etc.
- **Error filtering** - Only shows relevant errors
- **LaTeX text objects** - Commands, environments, math blocks
- **Smart folding** - Structure-based document folding
- **Citation completion** - Works with .bib files

## Compilation

| Key | Action |
|-----|--------|
| `<leader>ll` | Toggle continuous compilation |
| `<leader>lc` | Compile selection |
| `<leader>ls` | Stop compilation |
| `<leader>lS` | Stop all processes |
| `<leader>lv` | View PDF |
| `<leader>lr` | Reverse search (PDF→source) |

## Cleanup

| Key | Action |
|-----|--------|
| `<leader>lk` | Clean auxiliary files |
| `<leader>lK` | Clean all generated files |
| `<leader>lR` | Reload VimTeX |

## Navigation

| Key | Action |
|-----|--------|
| `<leader>lt` | Toggle table of contents |
| `<leader>lT` | Open TOC window |
| `]]` / `[[` | Next/previous section |
| `][` / `[]` | Section boundaries |

## Formatting (Visual Mode)

| Key | Result |
|-----|--------|
| `<leader>lb` | **Bold** (`\textbf{}`) |
| `<leader>li` | *Italic* (`\textit{}`) |
| `<leader>lu` | Underline (`\underline{}`) |
| `<leader>lf` | `Monospace` (`\texttt{}`) |
| `<leader>le` | *Emphasize* (`\emph{}`) |
| `<leader>lM` | Display math (`\[ ... \]`) |
| `<leader>l$` | Inline math (`$ ... $`) |

## Structure

| Key | Inserts |
|-----|---------|
| `<leader>lsc` | Chapter |
| `<leader>lss` | Section |
| `<leader>lsS` | Subsection |
| `<leader>lsp` | Subsubsection |

## References

| Key | Inserts |
|-----|---------|
| `<leader>lrl` | Label |
| `<leader>lrr` | Reference |
| `<leader>lrc` | Citation |
| `<leader>lrp` | Page reference |

## Templates

| Key | Inserts |
|-----|---------|
| `<leader>lff` | Figure environment |
| `<leader>lft` | Table environment |
| `<leader>lei` | Itemize list |
| `<leader>len` | Enumerate list |
| `<leader>lea` | Align environment |
| `<leader>leq` | Equation environment |

## Insert Mode Shortcuts

**Symbols**
- `,,` → `\,` (thin space)
- `..` → `\ldots` (ellipsis)
- `->` → `\rightarrow`
- `<-` → `\leftarrow`
- `<=` → `\leq`
- `>=` → `\geq`
- `!=` → `\neq`
- `+-` → `\pm`
- `~=` → `\approx`

**Math**
- `^^` → `^{}` (superscript)
- `__` → `_{}` (subscript)
- `//` → `\frac{}{}` (fraction)
- `((` → `\left(\right)`
- `[[` → `\left[\right]`
- `{{` → `\left\{\right\}`

## File Settings
LaTeX files automatically get:
- Text width: 80 characters
- Line wrapping enabled
- Spell checking (en_us)
- Concealment level 2
- Smart indentation (2 spaces)

## Workflow
1. Create file: `touch document.tex`
2. Start compilation: `<leader>ll`
3. View PDF: `<leader>lv`
4. Edit with live updates
5. Use `<C-t>` for context menu

## Tips
- **Continuous mode**: Start once with `<leader>ll`, edit freely
- **PDF sync**: Click in PDF to jump to source
- **Errors**: `<leader>le` shows only relevant errors
- **Large docs**: Subfile support enabled
- **Bibliography**: Citation completion with .bib files