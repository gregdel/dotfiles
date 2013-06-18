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

colorscheme molokai
syntax on
filetype plugin indent on
execute pathogen#infect()

set backupdir=~/tmp

au BufWrite * %s/\s\+$//ge
au BufRead,BufNewFile *.md set filetype=markdown
