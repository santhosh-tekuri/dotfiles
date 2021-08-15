set nocompatible " enter the current millenium
filetype plugin on

" search down into subfolders
"set path+=**

" display all matching files when we tab complete
set wildmenu

hi Pmenu ctermfg=Black ctermbg=White
hi PmenuSel ctermfg=White ctermbg=DarkBlue

hi LineNr ctermfg=8

"----------------------------------[ forgive uninteded caps ]--------------"
cnoreabbrev W w
cnoreabbrev Q q
cnoreabbrev WQ wq
cnoreabbrev Wq wq

cnoreabbrev wsudo w !sudo tee %

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

autocmd BufNewFile,BufRead *.go set filetype=go
au FileType go set noexpandtab
au FileType go set shiftwidth=4
au FileType go set softtabstop=4
au FileType go set tabstop=4

"----------------------------------------[ Searching Behavior ]--------------------------------------------------"

set hlsearch     " highlight search match
set incsearch    " search for text as you type
set ignorecase   " ignore case when searching
set smartcase    " if ignorecase is on, a search is case-insensitive if the search string is in lowercase

"-------------------------------[ undo history between sessions ] -----------------------"

if !isdirectory($HOME . "/.vim/undodir")
    call mkdir($HOME . "/.vim/undodir", "p")
endif
set undofile
set undodir=~/.vim/undodir

"---------------------------------------[ Highlight Trailing Whitespace ]---------------------------------------------"

highlight TrailingSpaces ctermbg=red guibg=red
match TrailingSpaces /\s\+$/

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


if $VIM_PRIVATE
    set history=0
    set nobackup
    set nomodeline
    set noshelltemp
    set noswapfile
    set noundofile
    set nowritebackup
    set secure
    set viminfo=""
endif

"---------------------------------------------[  vim gitgutter customization ]-----------------------------------"
set updatetime=100
set signcolumn=yes

highlight clear SignColumn
highlight GitGutterAdd guifg=#009900 ctermbg=Green ctermfg=Green
highlight GitGutterChange guifg=#bbbb00 ctermbg=Red ctermfg=Red
highlight GitGutterDelete guifg=#ff2222 ctermfg=Gray

let g:gitgutter_sign_removed = '▶'
let g:gitgutter_sign_removed_first_line = '▶'
let g:gitgutter_sign_removed_above_and_below = '▶'

nmap ) <Plug>(GitGutterNextHunk)
nmap ( <Plug>(GitGutterPrevHunk)
