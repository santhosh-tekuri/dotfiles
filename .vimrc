set nocompatible " enter the current millenium
filetype plugin on

" search down into subfolders
"set path+=**

" display all matching files when we tab complete
set wildmenu

hi Pmenu ctermfg=Black ctermbg=White
hi PmenuSel ctermfg=White ctermbg=DarkBlue

hi LineNr ctermfg=8

"----------------------------------------[ UI ]--------------------------------------------------"
syntax on
set bg=dark
set number       " show line numbers
set showmode     " show current mode
set showcmd      " show partial commands
set showmatch    " show matching bracets when cursor is over them
set ruler        " shows statusline displaying current cursor position
set nowrap       " don't wrap lines
set scrolloff=3  " have 3 lines of offset when scrolling
set mouse=a      " enable mouse support

"----------------------------------------[ Indents and Tabs ]--------------------------------------------------"

set smartindent   " guess indent level based on the previous line
set expandtab     " expand tabs with spaces
set shiftwidth=4  " number of spaces to auto(indent)
set tabstop=4     " number of spaces used to display tab character
set smarttab      " tab and backspace are smart

"----------------------------------------[ Go Indentation ]--------------------------------------------------"
au FileType go set noexpandtab
au FileType go set shiftwidth=4
au FileType go set softtabstop=4
au FileType go set tabstop=4

"----------------------------------------[ Searching Behavior ]--------------------------------------------------"

set hlsearch     " highlight search match
set incsearch    " search for text as you type
set ignorecase   " ignore case when searching
set smartcase    " if ignorecase is on, a search is case-insensitive if the search string is in lowercase

"---------------------------------------[ Current Line Highlighting ]-------------------------------------------"

set cursorline   " highlight current line
" colors for current line highlighting
hi CursorLine cterm=NONE ctermbg=black
" typing \c will toggle current line highlight
nnoremap <Leader>c :set cursorline!<CR>

" treat json files as javascript (for syntax coloring)
autocmd BufNewFile,BufRead *.json set ft=javascript

" jump to last known position on reopening file (equaivalent to typing '")
if has("autocmd")
  au BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$")
    \| exe "normal! g'\"" | endif
endif

" move current line up/down
noremap <c-s-up> :m -2<CR>
noremap <c-s-down> :m +1<CR>

let g:go_fmt_command = "goimports"
let g:go_highlight_types = 1
let g:go_highlight_fields = 1
let g:go_highlight_functions = 1
let g:go_highlight_methods = 1
let g:go_highlight_operators = 1
inoremap <C-@> <C-x><C-o>