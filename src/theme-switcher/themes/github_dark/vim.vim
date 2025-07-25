" GitHub Dark Theme for Vim
" https://github.com/primer/github-vscode-theme

set background=dark
highlight clear
if exists("syntax_on")
  syntax reset
endif
let g:colors_name = "github_dark"

" UI Components
hi Normal guifg=#e6edf3 guibg=#0d1117 ctermfg=253 ctermbg=233
hi ColorColumn guifg=NONE guibg=#21262d ctermfg=NONE ctermbg=235
hi Cursor guifg=#0d1117 guibg=#e6edf3 ctermfg=233 ctermbg=253
hi CursorLine guifg=NONE guibg=#161b22 ctermfg=NONE ctermbg=234 cterm=NONE
hi CursorColumn guifg=NONE guibg=#161b22 ctermfg=NONE ctermbg=234
hi CursorLineNr guifg=#e6edf3 guibg=#161b22 ctermfg=253 ctermbg=234

" Syntax Highlighting
hi Comment guifg=#8b949e ctermfg=245 gui=italic cterm=italic
hi Constant guifg=#79c0ff ctermfg=111
hi String guifg=#a5d6ff ctermfg=153
hi Character guifg=#a5d6ff ctermfg=153
hi Number guifg=#79c0ff ctermfg=111
hi Boolean guifg=#79c0ff ctermfg=111
hi Float guifg=#79c0ff ctermfg=111

hi Identifier guifg=#ffa657 ctermfg=215 cterm=NONE
hi Function guifg=#d2a8ff ctermfg=183

hi Statement guifg=#ff7b72 ctermfg=209 cterm=NONE
hi Conditional guifg=#ff7b72 ctermfg=209
hi Repeat guifg=#ff7b72 ctermfg=209
hi Label guifg=#ff7b72 ctermfg=209
hi Operator guifg=#ff7b72 ctermfg=209
hi Keyword guifg=#ff7b72 ctermfg=209
hi Exception guifg=#ff7b72 ctermfg=209

hi PreProc guifg=#ff7b72 ctermfg=209
hi Include guifg=#ff7b72 ctermfg=209
hi Define guifg=#ff7b72 ctermfg=209
hi Macro guifg=#ff7b72 ctermfg=209
hi PreCondit guifg=#ff7b72 ctermfg=209

hi Type guifg=#79c0ff ctermfg=111 cterm=NONE
hi StorageClass guifg=#ff7b72 ctermfg=209
hi Structure guifg=#ff7b72 ctermfg=209
hi Typedef guifg=#ff7b72 ctermfg=209

hi Special guifg=#a5d6ff ctermfg=153
hi SpecialChar guifg=#a5d6ff ctermfg=153
hi Tag guifg=#ff7b72 ctermfg=209
hi Delimiter guifg=#e6edf3 ctermfg=253
hi SpecialComment guifg=#8b949e ctermfg=245
hi Debug guifg=#ffa657 ctermfg=215

" UI Elements
hi LineNr guifg=#6e7681 guibg=#0d1117 ctermfg=242 ctermbg=233
hi VertSplit guifg=#21262d guibg=#0d1117 ctermfg=235 ctermbg=233
hi StatusLine guifg=#e6edf3 guibg=#21262d ctermfg=253 ctermbg=235
hi StatusLineNC guifg=#8b949e guibg=#21262d ctermfg=245 ctermbg=235
hi Pmenu guifg=#e6edf3 guibg=#161b22 ctermfg=253 ctermbg=234
hi PmenuSel guifg=#e6edf3 guibg=#388bfd ctermfg=253 ctermbg=69
hi PmenuSbar guifg=NONE guibg=#21262d ctermfg=NONE ctermbg=235
hi PmenuThumb guifg=NONE guibg=#8b949e ctermfg=NONE ctermbg=245

" Search
hi Search guifg=#0d1117 guibg=#ffd93d ctermfg=233 ctermbg=220
hi IncSearch guifg=#0d1117 guibg=#ffa657 ctermfg=233 ctermbg=215

" Diff
hi DiffAdd guifg=#3fb950 guibg=NONE ctermfg=71 ctermbg=NONE
hi DiffChange guifg=#ffa657 guibg=NONE ctermfg=215 ctermbg=NONE
hi DiffDelete guifg=#f85149 guibg=NONE ctermfg=203 ctermbg=NONE
hi DiffText guifg=#79c0ff guibg=NONE ctermfg=111 ctermbg=NONE

" Errors
hi Error guifg=#f85149 guibg=NONE ctermfg=203 ctermbg=NONE
hi ErrorMsg guifg=#f85149 guibg=NONE ctermfg=203 ctermbg=NONE
hi WarningMsg guifg=#ffa657 guibg=NONE ctermfg=215 ctermbg=NONE

" Visual Selection
hi Visual guifg=NONE guibg=#264f78 ctermfg=NONE ctermbg=24
hi VisualNOS guifg=NONE guibg=#264f78 ctermfg=NONE ctermbg=24

" Tabs
hi TabLine guifg=#8b949e guibg=#0d1117 ctermfg=245 ctermbg=233
hi TabLineFill guifg=#8b949e guibg=#0d1117 ctermfg=245 ctermbg=233
hi TabLineSel guifg=#e6edf3 guibg=#21262d ctermfg=253 ctermbg=235

" Folding
hi Folded guifg=#8b949e guibg=#0d1117 ctermfg=245 ctermbg=233
hi FoldColumn guifg=#8b949e guibg=#0d1117 ctermfg=245 ctermbg=233

" Spelling
hi SpellBad guifg=#f85149 gui=undercurl ctermfg=203 cterm=underline
hi SpellCap guifg=#ffa657 gui=undercurl ctermfg=215 cterm=underline
hi SpellLocal guifg=#79c0ff gui=undercurl ctermfg=111 cterm=underline
hi SpellRare guifg=#d2a8ff gui=undercurl ctermfg=183 cterm=underline

" LSP/Diagnostics
hi DiagnosticError guifg=#f85149 ctermfg=203
hi DiagnosticWarn guifg=#ffa657 ctermfg=215
hi DiagnosticInfo guifg=#79c0ff ctermfg=111
hi DiagnosticHint guifg=#8b949e ctermfg=245

" Git
hi GitGutterAdd guifg=#3fb950 ctermfg=71
hi GitGutterChange guifg=#ffa657 ctermfg=215
hi GitGutterDelete guifg=#f85149 ctermfg=203

" ALE
hi ALEErrorSign guifg=#f85149 ctermfg=203
hi ALEWarningSign guifg=#ffa657 ctermfg=215

" Markview-specific highlight groups for proper symbol rendering
hi MarkviewTaskUnchecked guifg=#ff7b72 ctermfg=209
hi MarkviewTaskChecked guifg=#3fb950 ctermfg=71
hi MarkviewTaskPending guifg=#ffa657 ctermfg=215
hi MarkviewListItemMinus guifg=#ffa657 ctermfg=215
hi MarkviewListItemStar guifg=#79c0ff ctermfg=111
hi MarkviewListItemPlus guifg=#3fb950 ctermfg=71
hi MarkviewLink guifg=#58a6ff ctermfg=69 gui=underline cterm=underline
hi MarkviewImage guifg=#79c0ff ctermfg=111
hi MarkviewCode guifg=#a5d6ff guibg=#161b22 ctermfg=153 ctermbg=234
hi MarkviewInlineCode guifg=#a5d6ff guibg=#161b22 ctermfg=153 ctermbg=234
hi MarkviewCodeInfo guifg=#ffa657 guibg=#161b22 ctermfg=215 ctermbg=234
hi MarkviewCodeBorder guifg=#30363d ctermfg=236
hi MarkviewHeading1 guifg=#7c3aed ctermfg=98 gui=bold cterm=bold
hi MarkviewHeading2 guifg=#f85149 ctermfg=203 gui=bold cterm=bold
hi MarkviewHeading3 guifg=#79c0ff ctermfg=111 gui=bold cterm=bold
hi MarkviewHeading4 guifg=#3fb950 ctermfg=71 gui=bold cterm=bold
hi MarkviewHeading5 guifg=#ffa657 ctermfg=215 gui=bold cterm=bold
hi MarkviewHeading6 guifg=#d2a8ff ctermfg=183 gui=bold cterm=bold
hi MarkviewHeading1Sign guifg=#7c3aed ctermfg=98
hi MarkviewHeading2Sign guifg=#f85149 ctermfg=203
hi MarkviewBlockQuoteDefault guifg=#79c0ff ctermfg=111 gui=italic cterm=italic
hi MarkviewBlockQuoteNote guifg=#58a6ff ctermfg=69
hi MarkviewBlockQuoteOk guifg=#3fb950 ctermfg=71
hi MarkviewBlockQuoteWarn guifg=#ffa657 ctermfg=215
hi MarkviewBlockQuoteError guifg=#f85149 ctermfg=203
hi MarkviewBlockQuoteSpecial guifg=#d2a8ff ctermfg=183
hi MarkviewRule guifg=#30363d ctermfg=236
hi MarkviewTable guifg=#e6edf3 ctermfg=253
hi MarkviewTableBorder guifg=#30363d ctermfg=236
hi MarkviewCheckboxChecked guifg=#3fb950 ctermfg=71
hi MarkviewCheckboxUnchecked guifg=#ff7b72 ctermfg=209
hi MarkviewCheckboxProgress guifg=#ffa657 ctermfg=215
hi MarkviewCheckboxImportant guifg=#d2a8ff ctermfg=183
hi MarkviewEmail guifg=#58a6ff ctermfg=69
hi MarkviewBold guifg=#e6edf3 ctermfg=253 gui=bold cterm=bold
hi MarkviewItalic guifg=#e6edf3 ctermfg=253 gui=italic cterm=italic
hi MarkviewStrikethrough guifg=#8b949e ctermfg=245 gui=strikethrough cterm=strikethrough
hi MarkviewDiffAdd guifg=#3fb950 ctermfg=71
hi MarkviewDiffDelete guifg=#f85149 ctermfg=203

" Terminal colors for Neovim
if has('nvim')
  let g:terminal_color_0  = '#484f58'
  let g:terminal_color_1  = '#ff7b72'
  let g:terminal_color_2  = '#3fb950'
  let g:terminal_color_3  = '#d29922'
  let g:terminal_color_4  = '#58a6ff'
  let g:terminal_color_5  = '#bc8cff'
  let g:terminal_color_6  = '#39c5cf'
  let g:terminal_color_7  = '#b1bac4'
  let g:terminal_color_8  = '#6e7681'
  let g:terminal_color_9  = '#ffa198'
  let g:terminal_color_10 = '#56d364'
  let g:terminal_color_11 = '#e3b341'
  let g:terminal_color_12 = '#79c0ff'
  let g:terminal_color_13 = '#d2a8ff'
  let g:terminal_color_14 = '#56d4dd'
  let g:terminal_color_15 = '#ffffff'
endif