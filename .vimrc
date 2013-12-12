" Make vim more useful
set nocompatible

" Run pathogen
execute pathogen#infect()

" Change mapleader
let mapleader=","

" History
set history=1000 " much more history than base
set undolevels=1000 " much more undo
set title " Set the terminal title's

set expandtab       "Tabs to spaces
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

" Press enter after search to clean highlighting
nnoremap <cr> :noh<CR><CR>:<backspace>

" Moves between splits the easy way
map <C-h> <C-w>h
map <C-j> <C-w>j
map <C-k> <C-w>k
map <C-l> <C-w>l

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
set encoding=utf-8 nobomb

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
nmap <leader>n :NERDTreeTabsToggle<CR>

"Options for the NERDTree
let NERDTreeChDirMode=1
let NERDTreeShowHidden=1
let NERDTreeDirArrows=0

" Start interactive EasyAlign in visual mode
vmap <Enter> <Plug>(EasyAlign)
nmap <Leader>a <Plug>(EasyAlign)
