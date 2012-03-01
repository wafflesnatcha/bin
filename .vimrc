
set history=700

filetype on
filetype plugin on
filetype indent on

set autoread  "auto read when a file is changed from the outside

" With a map leader it's possible to do extra key combinations
" like <leader>w saves the current file
let mapleader = ","
let g:mapleader = ","

set so=1         " minimum visible lines when scrolling vertical..
set wildmenu     " turn on WiLd menu
set ruler        " show current position
set cmdheight=1  " command bar height
"set hid         "Change buffer - without saving

" backspace config
set backspace=eol,start,indent
set whichwrap+=<,>,h,l

set ignorecase    " ignore case when searching
set smartcase
set hlsearch      " highlight all search matches
set incsearch     " incremental search
set nolazyredraw  " no redraw while executing macros 
set magic         " set magic on, for regular expressions
set showmatch     " show matching braces when moving cursor over them
"set mat=2        " cursor blink rate (tenths of a second)

" No sound on errors
set noerrorbells
set novisualbell
set t_vb=
set tm=500

"set expandtab
set shiftwidth=4
set tabstop=4
"set shiftround
"set smarttab
"set autoindent
"set smartindent
set wrap

set lbr
set tw=500

set title
syntax enable

set laststatus=2  " good statusline is good
set statusline=%<%f\%h%m%r%=%-20.(%L\ %l:%v\ %)\ \ \%h%m%r%=\%P

" Key maps

nmap <leader>w :w!<cr>
nmap <leader>h :help<cr>
nmap <leader>q :q<cr>

imap <Esc>[H <Home>
map <Esc>[H <Home>
imap <Esc>[F <End>
map <Esc>[F <End>

" Bash like keys for the command line
cnoremap <C-H> <Home>
cnoremap <C-F> <End>
cnoremap <C-K> <C-U>

cnoremap <C-P> <Up>
cnoremap <C-N> <Down>

