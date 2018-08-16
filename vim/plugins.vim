call plug#begin('~/.vim/plugged')

" Plugins
Plug 'fatih/molokai'
Plug 'Raimondi/delimitMate'
Plug 'godlygeek/tabular'
Plug 'scrooloose/nerdtree'
Plug 'jistr/vim-nerdtree-tabs'
Plug 'w0rp/ale'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-unimpaired'
Plug 'tpope/vim-dispatch'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'ctrlpvim/ctrlp.vim'
Plug 'mileszs/ack.vim'
Plug 'AndrewRadev/splitjoin.vim'
Plug 'ConradIrwin/vim-bracketed-paste'
Plug 'lilydjwg/colorizer'
Plug 'Valloric/ListToggle'
Plug 'junegunn/goyo.vim'
Plug 'vim-utils/vim-man'

Plug 'vim-latex/vim-latex', { 'for': 'tex' }
Plug 'xuhdev/vim-latex-live-preview', { 'for': 'tex' }
Plug 'vivien/vim-linux-coding-style', { 'for': 'c' }
Plug 'chazy/cscope_maps', { 'for': 'c' }
Plug 'brookhong/cscope.vim', { 'for': 'c' }
Plug 'hashivim/vim-terraform', { 'for': 'terraform' }
Plug 'ekalinin/Dockerfile.vim', { 'for': 'Dockerfile' }
Plug 'fatih/vim-go', { 'for': 'go' }
Plug 'sebdah/vim-delve', { 'for': 'go' }
Plug 'kchmck/vim-coffee-script', { 'for': 'coffee' }
Plug 'pangloss/vim-javascript', { 'for': 'javascript' }
Plug 'mxw/vim-jsx', { 'for': ['javascript', 'javascript.jsx'] }
Plug 'tmhedberg/matchit', { 'for': 'javascript' }
Plug 'tpope/vim-endwise', { 'for': ['lua', 'ruby', 'sh', 'zsh', 'vim'] }
Plug 'plasticboy/vim-markdown', { 'for': 'markdown' }
Plug 'tpope/vim-rails', { 'for': 'ruby' }
Plug 'wannesm/wmgraphviz.vim', { 'for': 'dot' }

call plug#end()
