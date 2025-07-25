" Dracula Theme for Vim
" https://draculatheme.com/vim

set background=dark
highlight clear
if exists("syntax_on")
  syntax reset
endif
let g:colors_name = "dracula"

" UI Components
hi Normal       guifg=#f8f8f2 guibg=#282a36 ctermfg=253 ctermbg=NONE
hi ColorColumn  guifg=NONE    guibg=#44475a ctermfg=NONE ctermbg=59
hi Cursor       guifg=#282a36 guibg=#f8f8f2 ctermfg=236 ctermbg=15
hi CursorLine   guifg=NONE    guibg=#44475a ctermfg=NONE ctermbg=59 cterm=NONE
hi CursorColumn guifg=NONE    guibg=#44475a ctermfg=NONE ctermbg=59
hi CursorLineNr guifg=#f8f8f2 guibg=#44475a ctermfg=253 ctermbg=59

" Syntax Highlighting
hi Comment      guifg=#6272a4 ctermfg=61 gui=italic cterm=italic
hi Constant     guifg=#bd93f9 ctermfg=141
hi String       guifg=#f1fa8c ctermfg=228
hi Character    guifg=#f1fa8c ctermfg=228
hi Number       guifg=#bd93f9 ctermfg=141
hi Boolean      guifg=#bd93f9 ctermfg=141
hi Float        guifg=#bd93f9 ctermfg=141

hi Identifier   guifg=#50fa7b ctermfg=84 cterm=NONE
hi Function     guifg=#50fa7b ctermfg=84

hi Statement    guifg=#ff79c6 ctermfg=212 cterm=NONE
hi Conditional  guifg=#ff79c6 ctermfg=212
hi Repeat       guifg=#ff79c6 ctermfg=212
hi Label        guifg=#ff79c6 ctermfg=212
hi Operator     guifg=#ff79c6 ctermfg=212
hi Keyword      guifg=#ff79c6 ctermfg=212
hi Exception    guifg=#ff79c6 ctermfg=212

hi PreProc      guifg=#ff79c6 ctermfg=212
hi Include      guifg=#ff79c6 ctermfg=212
hi Define       guifg=#ff79c6 ctermfg=212
hi Macro        guifg=#ff79c6 ctermfg=212
hi PreCondit    guifg=#ff79c6 ctermfg=212

hi Type         guifg=#8be9fd ctermfg=117 cterm=NONE
hi StorageClass guifg=#ff79c6 ctermfg=212
hi Structure    guifg=#ff79c6 ctermfg=212
hi Typedef      guifg=#ff79c6 ctermfg=212

hi Special      guifg=#f1fa8c ctermfg=228
hi SpecialChar  guifg=#f1fa8c ctermfg=228
hi Tag          guifg=#ff79c6 ctermfg=212
hi Delimiter    guifg=#f8f8f2 ctermfg=253
hi SpecialComment guifg=#6272a4 ctermfg=61
hi Debug        guifg=#ffb86c ctermfg=215

" UI Elements
hi LineNr       guifg=#6272a4 guibg=#282a36 ctermfg=61 ctermbg=NONE
hi VertSplit    guifg=#44475a guibg=#282a36 ctermfg=59 ctermbg=NONE
hi StatusLine   guifg=#f8f8f2 guibg=#44475a ctermfg=253 ctermbg=59
hi StatusLineNC guifg=#6272a4 guibg=#44475a ctermfg=61 ctermbg=59
hi Pmenu        guifg=#f8f8f2 guibg=#44475a ctermfg=253 ctermbg=59
hi PmenuSel     guifg=#f8f8f2 guibg=#bd93f9 ctermfg=253 ctermbg=141
hi PmenuSbar    guifg=NONE    guibg=#44475a ctermfg=NONE ctermbg=59
hi PmenuThumb   guifg=NONE    guibg=#6272a4 ctermfg=NONE ctermbg=61

" Search
hi Search       guifg=#282a36 guibg=#f1fa8c ctermfg=236 ctermbg=228
hi IncSearch    guifg=#282a36 guibg=#ffb86c ctermfg=236 ctermbg=215

" Diff
hi DiffAdd      guifg=#50fa7b guibg=NONE ctermfg=84 ctermbg=NONE
hi DiffChange   guifg=#ffb86c guibg=NONE ctermfg=215 ctermbg=NONE
hi DiffDelete   guifg=#ff5555 guibg=NONE ctermfg=203 ctermbg=NONE
hi DiffText     guifg=#8be9fd guibg=NONE ctermfg=117 ctermbg=NONE

" Errors
hi Error        guifg=#ff5555 guibg=NONE ctermfg=203 ctermbg=NONE
hi ErrorMsg     guifg=#ff5555 guibg=NONE ctermfg=203 ctermbg=NONE
hi WarningMsg   guifg=#ffb86c guibg=NONE ctermfg=215 ctermbg=NONE

" Visual Selection
hi Visual       guifg=NONE    guibg=#44475a ctermfg=NONE ctermbg=59
hi VisualNOS    guifg=NONE    guibg=#44475a ctermfg=NONE ctermbg=59

" Tabs
hi TabLine      guifg=#6272a4 guibg=#282a36 ctermfg=61 ctermbg=NONE
hi TabLineFill  guifg=#6272a4 guibg=#282a36 ctermfg=61 ctermbg=NONE
hi TabLineSel   guifg=#f8f8f2 guibg=#44475a ctermfg=253 ctermbg=59

" Folding
hi Folded       guifg=#6272a4 guibg=#282a36 ctermfg=61 ctermbg=NONE
hi FoldColumn   guifg=#6272a4 guibg=#282a36 ctermfg=61 ctermbg=NONE

" Spelling
hi SpellBad     guifg=#ff5555 gui=undercurl ctermfg=203 cterm=underline
hi SpellCap     guifg=#ffb86c gui=undercurl ctermfg=215 cterm=underline
hi SpellLocal   guifg=#8be9fd gui=undercurl ctermfg=117 cterm=underline
hi SpellRare    guifg=#bd93f9 gui=undercurl ctermfg=141 cterm=underline

" LSP/Diagnostics
hi DiagnosticError  guifg=#ff5555 ctermfg=203
hi DiagnosticWarn   guifg=#ffb86c ctermfg=215
hi DiagnosticInfo   guifg=#8be9fd ctermfg=117
hi DiagnosticHint   guifg=#6272a4 ctermfg=61

" Git
hi GitGutterAdd    guifg=#50fa7b ctermfg=84
hi GitGutterChange guifg=#ffb86c ctermfg=215
hi GitGutterDelete guifg=#ff5555 ctermfg=203

" ALE
hi ALEErrorSign   guifg=#ff5555 ctermfg=203
hi ALEWarningSign guifg=#ffb86c ctermfg=215

" Markview-specific highlight groups for proper symbol rendering
hi MarkviewTaskUnchecked guifg=#ff79c6 ctermfg=212
hi MarkviewTaskChecked guifg=#50fa7b ctermfg=84
hi MarkviewTaskPending guifg=#f1fa8c ctermfg=228
hi MarkviewListItemMinus guifg=#ffb86c ctermfg=215
hi MarkviewListItemStar guifg=#8be9fd ctermfg=117
hi MarkviewListItemPlus guifg=#50fa7b ctermfg=84
hi MarkviewLink guifg=#bd93f9 ctermfg=141 gui=underline cterm=underline
hi MarkviewImage guifg=#8be9fd ctermfg=117
hi MarkviewCode guifg=#f1fa8c guibg=#44475a ctermfg=228 ctermbg=59
hi MarkviewInlineCode guifg=#f1fa8c guibg=#44475a ctermfg=228 ctermbg=59
hi MarkviewCodeInfo guifg=#ffb86c guibg=#44475a ctermfg=215 ctermbg=59
hi MarkviewCodeBorder guifg=#6272a4 ctermfg=61
hi MarkviewHeading1 guifg=#bd93f9 ctermfg=141 gui=bold cterm=bold
hi MarkviewHeading2 guifg=#ff79c6 ctermfg=212 gui=bold cterm=bold
hi MarkviewHeading3 guifg=#8be9fd ctermfg=117 gui=bold cterm=bold
hi MarkviewHeading4 guifg=#50fa7b ctermfg=84 gui=bold cterm=bold
hi MarkviewHeading5 guifg=#f1fa8c ctermfg=228 gui=bold cterm=bold
hi MarkviewHeading6 guifg=#ffb86c ctermfg=215 gui=bold cterm=bold
hi MarkviewHeading1Sign guifg=#bd93f9 ctermfg=141
hi MarkviewHeading2Sign guifg=#ff79c6 ctermfg=212
hi MarkviewBlockQuoteDefault guifg=#8be9fd ctermfg=117 gui=italic cterm=italic
hi MarkviewBlockQuoteNote guifg=#8be9fd ctermfg=117
hi MarkviewBlockQuoteOk guifg=#50fa7b ctermfg=84
hi MarkviewBlockQuoteWarn guifg=#f1fa8c ctermfg=228
hi MarkviewBlockQuoteError guifg=#ff5555 ctermfg=203
hi MarkviewBlockQuoteSpecial guifg=#ff79c6 ctermfg=212
hi MarkviewRule guifg=#6272a4 ctermfg=61
hi MarkviewTable guifg=#f8f8f2 ctermfg=253
hi MarkviewTableBorder guifg=#6272a4 ctermfg=61
hi MarkviewCheckboxChecked guifg=#50fa7b ctermfg=84
hi MarkviewCheckboxUnchecked guifg=#ff79c6 ctermfg=212
hi MarkviewCheckboxProgress guifg=#f1fa8c ctermfg=228
hi MarkviewCheckboxImportant guifg=#bd93f9 ctermfg=141
hi MarkviewEmail guifg=#bd93f9 ctermfg=141
hi MarkviewBold guifg=#f8f8f2 ctermfg=253 gui=bold cterm=bold
hi MarkviewItalic guifg=#f8f8f2 ctermfg=253 gui=italic cterm=italic
hi MarkviewStrikethrough guifg=#6272a4 ctermfg=61 gui=strikethrough cterm=strikethrough
hi MarkviewDiffAdd guifg=#50fa7b ctermfg=84
hi MarkviewDiffDelete guifg=#ff5555 ctermfg=203

" Terminal colors for Neovim
if has('nvim')
  let g:terminal_color_0  = '#21222c'
  let g:terminal_color_1  = '#ff5555'
  let g:terminal_color_2  = '#50fa7b'
  let g:terminal_color_3  = '#f1fa8c'
  let g:terminal_color_4  = '#bd93f9'
  let g:terminal_color_5  = '#ff79c6'
  let g:terminal_color_6  = '#8be9fd'
  let g:terminal_color_7  = '#f8f8f2'
  let g:terminal_color_8  = '#6272a4'
  let g:terminal_color_9  = '#ff6e6e'
  let g:terminal_color_10 = '#69ff94'
  let g:terminal_color_11 = '#ffffa5'
  let g:terminal_color_12 = '#d6acff'
  let g:terminal_color_13 = '#ff92df'
  let g:terminal_color_14 = '#a4ffff'
  let g:terminal_color_15 = '#ffffff'
endif