
set nocompatible

" Run pathogen
execute pathogen#infect()

" Change mapleader
let mapleader=","

" History
set history=1000    " much more history than base
set undolevels=1000 " much more undo

" Indentation
set expandtab       "Tabs to spaces
set smarttab
set shiftwidth=4
set tabstop=4
set lbr
set tw=500
set ai
set si
set wrap

" Set encoding
set encoding=utf-8 nobomb

" Show all kinds of stuff
set ruler           " Show the cursor position
set shortmess=atI   " Don’t show the intro message when starting Vim
set showmode        " Show the current mode
set title           " Show the filename in the window titlebar
set title           " Set the terminal title's
set showcmd         " Show the (partial) command as it’s being typed

" Search
set ignorecase      " Ignore case of searches
set smartcase       " Search with case only if needed
set hlsearch        " Highlight search while typing

" Don’t add empty newlines at the end of files
set binary
set noeol

" jk or kj to quit insert mode
imap jk <Esc>
imap kj <Esc>

" Delete spaces at the end of the lines on save
au BufWrite * %s/\s\+$//ge

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

" Navigate through tabs
nnoremap gk    :tabnext<CR>
nnoremap gj    :tabprev<CR>

" Insert mode paste toogle
set pastetoggle=<F9>
nnoremap <F10> :set nonumber!<CR>

" Open a new tab the easy way
nnoremap <leader>t :tabedit<Space>

" Set term
set term=xterm-256color

" Color scheme
set t_Co=256
syntax on
colorscheme molokai
filetype plugin indent on

" Indent properly
autocmd Filetype javascript setlocal ts=2 sts=2 sw=2

" Markdown
" Make vim more useful
set nocompatible

" Run pathogen
execute pathogen#infect()

" Change mapleader
let mapleader=","

" History
set history=1000    " much more history than base
set undolevels=1000 " much more undo

" Indentation
set expandtab       "Tabs to spaces
set smarttab
set shiftwidth=4
set tabstop=4
set lbr
set tw=500
set ai
set si
set wrap

" Set encoding
set encoding=utf-8 nobomb

" Show all kinds of stuff
set ruler           " Show the cursor position
set shortmess=atI   " Don’t show the intro message when starting Vim
set showmode        " Show the current mode
set title           " Show the filename in the window titlebar
set title           " Set the terminal title's
set showcmd         " Show the (partial) command as it’s being typed

" Search
set ignorecase      " Ignore case of searches
set smartcase       " Search with case only if needed
set hlsearch        " Highlight search while typing

" Don’t add empty newlines at the end of files
set binary
set noeol

" jk or kj to quit insert mode
imap jk <Esc>
imap kj <Esc>

" Delete spaces at the end of the lines on save
au BufWrite * %s/\s\+$//ge

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

" Navigate through tabs
nnoremap gk    :tabnext<CR>
nnoremap gj    :tabprev<CR>

" Insert mode paste toogle
set pastetoggle=<F9>
nnoremap <F10> :set nonumber!<CR>

" Open a new tab the easy way
nnoremap <leader>t :tabedit<Space>

" Redraw screen on demand
nnoremap <leader>r :redraw! <CR>

" Set term
set term=xterm-256color

" Color scheme
set t_Co=256
syntax on
colorscheme molokai
filetype plugin indent on

" Indent properly
autocmd Filetype javascript setlocal ts=2 sts=2 sw=2

" Markdown
au BufRead,BufNewFile *.md set filetype=markdown
" JSON
au BufRead,BufNewFile *.json set ft=json syntax=javascript

" Open NERDTree Tabs quick toogle
nmap <leader>n :NERDTreeTabsToggle<CR>

"Options for the NERDTree
let NERDTreeChDirMode=1
let NERDTreeShowHidden=1
let NERDTreeDirArrows=0
let NERDTreeShowBookmarks=1

" Start interactive EasyAlign in visual mode
vmap <Enter> <Plug>(EasyAlign)