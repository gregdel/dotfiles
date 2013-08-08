" Run pathogen
execute pathogen#infect()

" No backup files
set nobackup
set noswapfile

" History
set history=1000 " much more history than base
set undolevels=1000 " much more undo
set title " Set the terminal title's

set expandtab
set smarttab
set shiftwidth=4
set tabstop=4
set lbr
set tw=500
set ai
set si
set wrap
set t_Co=256
set ignorecase
set smartcase
set hlsearch

" Set term
set term=xterm-256color

" Set encoding
set encoding=utf-8

" Navigate through tabs
nnoremap tk    :tabnext<CR>
nnoremap tj    :tabprev<CR>

" Insert mode paste toogle
set pastetoggle=<F9>

" Open a new tab the easy way
nnoremap tt    :tabedit<Space>

" Color scheme
colorscheme molokai
syntax on
filetype plugin indent on

" Delete spaces at the end of files
au BufWrite * %s/\s\+$//ge

" Markdown
au BufRead,BufNewFile *.md set filetype=markdown
" JSON
au BufRead,BufNewFile *.json set ft=json syntax=javascript

" Open NERDTree with Ctrl+D
nmap <silent> <C-D> :NERDTreeToggle<CR>

"Options for the NERDTree
let NERDTreeChDirMode=1
let NERDTreeShowHidden=1
let NERDTreeDirArrows=0
