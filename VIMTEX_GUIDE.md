# 📝 VimTeX LaTeX Integration Guide

## ✨ Features Enabled

### 🚀 **Compilation & Viewing**
- **Continuous compilation** with latexmk
- **Smart PDF viewer detection** (Skim on macOS, Zathura on Linux, Preview fallback)
- **Forward/Reverse sync** between LaTeX source and PDF
- **Shell-escape enabled** for advanced packages (PGF/TikZ, minted, etc.)
- **Automatic error detection** with quickfix integration

### 🎨 **Enhanced Editing Experience**
- **Smart syntax concealment** for cleaner editing (math symbols, sections, etc.)
- **LaTeX-aware text objects** for commands, environments, math blocks
- **Intelligent folding** based on LaTeX document structure
- **Citation & reference completion** with bibliography support
- **TOC navigation** with document outline

### ⚡ **Performance Optimizations**
- **File-type specific settings** (wrap, spell, textwidth=80)
- **Smart buffer filtering** for large documents
- **Persistent caching** for faster startup
- **Error filtering** (hides common LaTeX warnings)

## 🎯 **Key Bindings Reference**

### 📝 **Core Compilation**
| Key | Action | Description |
|-----|--------|-------------|
| `<leader>ll` | Toggle Compilation | Start/stop continuous compilation |
| `<leader>lc` | Compile Selection | Compile only selected text |
| `<leader>ls` | Stop Compilation | Stop current compilation |
| `<leader>lS` | Stop All | Stop all LaTeX processes |

### 📖 **PDF Viewing**
| Key | Action | Description |
|-----|--------|-------------|
| `<leader>lv` | View PDF | Open/focus PDF viewer |
| `<leader>lr` | Reverse Search | Jump from PDF to source |

### 🧹 **Cleanup & Maintenance**
| Key | Action | Description |
|-----|--------|-------------|
| `<leader>lk` | Clean Aux | Remove auxiliary files |
| `<leader>lK` | Clean All | Remove all generated files |
| `<leader>lR` | Reload VimTeX | Restart VimTeX |

### 📋 **Navigation & TOC**
| Key | Action | Description |
|-----|--------|-------------|
| `<leader>lt` | Toggle TOC | Show/hide table of contents |
| `<leader>lT` | Open TOC | Open TOC window |
| `]]` / `[[` | Next/Prev Section | Navigate between sections |
| `][` / `[]` | Section Boundaries | Jump to section ends |

### 🔍 **Information & Debugging**
| Key | Action | Description |
|-----|--------|-------------|
| `<leader>li` | VimTeX Info | Show configuration info |
| `<leader>lI` | Full Info | Detailed system info |
| `<leader>lq` | Show Log | Display compilation log |
| `<leader>le` | Show Errors | Open error/warning list |
| `<leader>lm` | Context Menu | Smart context actions |

## 🎨 **Text Formatting Shortcuts**

### 📝 **Visual Mode Formatting**
Select text, then use:
| Key | Result | LaTeX Command |
|-----|--------|---------------|
| `<leader>lb` | **Bold** | `\textbf{}` |
| `<leader>li` | *Italic* | `\textit{}` |
| `<leader>lu` | Underline | `\underline{}` |
| `<leader>lf` | `Monospace` | `\texttt{}` |
| `<leader>le` | *Emphasize* | `\emph{}` |

### 📐 **Math Mode**
| Key | Result | LaTeX Command |
|-----|--------|---------------|
| `<leader>lM` | Display Math | `\[ ... \]` |
| `<leader>l$` | Inline Math | `$ ... $` |

## 🏗️ **Document Structure**

### 📖 **Section Insertion**
| Key | Action | Command |
|-----|--------|---------|
| `<leader>lsc` | Insert Chapter | `\chapter{}` |
| `<leader>lss` | Insert Section | `\section{}` |
| `<leader>lsS` | Insert Subsection | `\subsection{}` |
| `<leader>lsp` | Insert Subsubsection | `\subsubsection{}` |

### 📚 **References & Citations**
| Key | Action | Command |
|-----|--------|---------|
| `<leader>lrl` | Insert Label | `\label{}` |
| `<leader>lrr` | Insert Reference | `\ref{}` |
| `<leader>lrc` | Insert Citation | `\cite{}` |
| `<leader>lrp` | Page Reference | `\pageref{}` |

### 🖼️ **Figures & Tables**
| Key | Action | Inserts |
|-----|--------|---------|
| `<leader>lff` | Figure Template | Complete figure environment |
| `<leader>lft` | Table Template | Complete table environment |

## ⚡ **Quick Environments**

| Key | Environment | Usage |
|-----|-------------|-------|
| `<leader>lei` | Itemize | Bullet point list |
| `<leader>len` | Enumerate | Numbered list |
| `<leader>lea` | Align | Multi-line equations |
| `<leader>leq` | Equation | Single equation |

## 🎯 **Insert Mode Shortcuts**

### 🔤 **Symbol Shortcuts**
| Type | Becomes | Symbol |
|------|---------|--------|
| `,,` | `\,` | Thin space |
| `..` | `\ldots` | Ellipsis (…) |
| `->` | `\rightarrow` | Right arrow (→) |
| `<-` | `\leftarrow` | Left arrow (←) |
| `<=` | `\leq` | Less than or equal (≤) |
| `>=` | `\geq` | Greater than or equal (≥) |
| `!=` | `\neq` | Not equal (≠) |
| `+-` | `\pm` | Plus minus (±) |
| `~=` | `\approx` | Approximately (≈) |

### 📐 **Math Shortcuts**
| Type | Becomes | Usage |
|------|---------|-------|
| `^^` | `^{}` | Superscript |
| `__` | `_{}` | Subscript |
| `//` | `\frac{}{}` | Fraction |
| `((` | `\left(\right)` | Parentheses |
| `[[` | `\left[\right]` | Brackets |
| `{{` | `\left\{\right\}` | Braces |

## 🖥️ **Viewer Configuration**

### 📱 **macOS**
- **Primary**: Skim (with sync support)
- **Fallback**: Preview.app
- **Forward/Reverse sync** enabled

### 🐧 **Linux**
- **Primary**: Zathura (lightweight, vim-like)
- **Fallback**: Evince or xdg-open
- **Reuse instance** for efficiency

### 🪟 **Windows**
- **Primary**: SumatraPDF
- **Inverse search** configured
- **Reuse instance** enabled

## 🛠️ **Compilation Setup**

### 📄 **Default Compiler: latexmk**
- **Continuous compilation** (watches file changes)
- **Shell escape** enabled (for TikZ, minted, etc.)
- **SyncTeX** for PDF sync
- **Verbose errors** with file-line info

### ⚡ **Alternative: Tectonic**
Uncomment in config for faster compilation:
```lua
vim.g.vimtex_compiler_method = 'tectonic'
```

## 🎨 **File-Specific Settings**

When editing `.tex` files, the following are automatically configured:
- **Text width**: 80 characters
- **Line wrapping** and soft breaks enabled
- **Spell checking** enabled (English US)
- **Concealment level**: 2 (hide LaTeX markup)
- **Smart indentation**: 2 spaces
- **Structure-based folding** enabled

## 🎭 **Context-Aware Menu**

Press `<C-t>` or `<leader>m` in LaTeX files for specialized menu with:
- **Compilation controls** (compile, view, clean)
- **Structure insertion** (sections, figures, tables)
- **Reference management** (labels, citations)
- **Environment templates** 
- **Debug tools** (log, errors, info)

## 💡 **Pro Tips**

1. **Continuous Compilation**: Use `<leader>ll` once, then edit - PDF updates automatically
2. **Quick Structure**: Use section shortcuts (`<leader>lss`) for rapid document outlining
3. **Smart Navigation**: Use `]]`/`[[` to jump between sections quickly
4. **Error Debugging**: `<leader>le` shows only relevant errors (common warnings filtered)
5. **PDF Sync**: Click in PDF viewer to jump to source location (reverse search)
6. **Bibliography**: Citation completion works with `.bib` files in same directory
7. **Large Documents**: Subfile support enabled for multi-file projects
8. **Performance**: Large files automatically get optimized settings

## 🚀 **Getting Started**

1. **Create a LaTeX file**: `touch document.tex`
2. **Start editing**: VimTeX loads automatically
3. **Begin compilation**: `<leader>ll`
4. **View PDF**: `<leader>lv`  
5. **Use templates**: `<leader>lff` for figures, `<leader>lft` for tables

Your LaTeX workflow is now fully optimized for professional document creation! 📝✨