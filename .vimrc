" Run pathogen
execute pathogen#infect()

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

" Backup / Undo
if has('persistent_undo')
    silent !mkdir ~/.vim/backup > /dev/null 2>&1
    set backupdir=~/.vim/backup
    set directory=~/.vim/backup
    set undodir=~/.vim/backup//
endif

" Set term
set term=xterm-256color

" Set encoding
set encoding=utf-8

" Navigate through tabs
nnoremap tk    :tabnext<CR>
nnoremap tj    :tabprev<CR>

" Insert mode paste toogle
set pastetoggle=<F9>
nnoremap <F10> :set nonumber!<CR>

" Open a new tab the easy way
nnoremap tt    :tabedit<Space>

" Color scheme
colorscheme molokai
syntax on
filetype plugin indent on

" Indent properly
autocmd Filetype javascript setlocal ts=2 sts=2 sw=2

" Delete spaces at the end of files
au BufWrite * %s/\s\+$//ge

" Markdown
au BufRead,BufNewFile *.md set filetype=markdown
" JSON
au BufRead,BufNewFile *.json set ft=json syntax=javascript

" Open NERDTree with F8
nmap <silent> <F8> :NERDTreeToggle<CR>

"Options for the NERDTree
let NERDTreeChDirMode=1
let NERDTreeShowHidden=1
let NERDTreeDirArrows=0
