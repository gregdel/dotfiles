" Make vim more capable
set nocompatible

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
call vundle#begin('~/.vim/bundle/vundle')

" Plugins
Plugin 'Raimondi/delimitMate'
Plugin 'ekalinin/Dockerfile.vim'
Plugin 'fatih/molokai'
Plugin 'fatih/vim-go'
Plugin 'godlygeek/tabular'
Plugin 'itchyny/lightline.vim'
Plugin 'jistr/vim-nerdtree-tabs'
Plugin 'kchmck/vim-coffee-script'
Plugin 'kien/ctrlp.vim'
Plugin 'majutsushi/tagbar'
Plugin 'mileszs/ack.vim'
Plugin 'msanders/snipmate.vim'
Plugin 'nathanaelkane/vim-indent-guides'
Plugin 'pangloss/vim-javascript'
Plugin 'scrooloose/nerdtree'
Plugin 'scrooloose/syntastic'
Plugin 'tmhedberg/matchit'
Plugin 'tpope/vim-commentary'
Plugin 'tpope/vim-endwise'
Plugin 'tpope/vim-fugitive'
Plugin 'tpope/vim-markdown'
Plugin 'tpope/vim-rails'
Plugin 'tpope/vim-repeat'
Plugin 'tpope/vim-surround'
Plugin 'tpope/vim-unimpaired'

" Done with vundle
call vundle#end()

" colors
if $TERM == "xterm-256color" || $TERM == "screen-256color" || $COLORTERM == "gnome-terminal"
	set t_Co=256
endif

filetype plugin indent on
syntax on

" Load the molokai theme if vundle has installed the bundle
if filereadable( expand("$HOME/.vim/bundle/vundle/molokai/colors/molokai.vim") )
    colorscheme molokai
else
    " Fallback to the desert colorscheme
    colorscheme desert
endif

" Remove bgc
set t_ut=

" Backspace
set backspace=indent,eol,start

" Change mapleader
let mapleader=","

" Easy qwerty
nnoremap ; :
vnoremap ; :

" History
set history=1000    " much more history than base
set undolevels=1000 " much more undo

" Don't try to highlight lines longer than 800 characters.
set synmaxcol=800

" Command completion
set wildmenu

" Indentation
set expandtab       "Tabs to spaces
set smarttab
set shiftwidth=4
set softtabstop=4
set linebreak
set autoindent

" Format options no automatic wraping, gq wrap to 80
set textwidth=0
set formatoptions=cq
set wrapmargin=0
set wrap

" Q => gq
map Q gq

" Menu completion
set wildmenu

" Scrolloff
set scrolloff=5

" Better indent
vmap > >gv
vmap < <gv

" Insert mode file name completion
inoremap <c-f> <c-x><c-f>

" Set encoding
set encoding=utf-8 nobomb

" Highlight VCS conflict markers
match ErrorMsg '^\(<\|=\|>\)\{7\}\([^=].\+\)\?$'

" statusline (fugtive + virtualenv)
" set statusline=%<%f\ %h%m%r%{fugitive#statusline()}%{virtualenv#statusline()}%=%-14.(%l,%c%V%)\ %P

" Show all kinds of stuff
set ruler           " Show the cursor position
set shortmess=atI   " Don’t show the intro message when starting Vim
set showmode        " Show the current mode
set title           " Show the filename in the window titlebar
set title           " Set the terminal title's
set showcmd         " Show the (partial) command as it’s being typed
set lazyredraw      " redraw only when we need to

" Search
set ignorecase      " Ignore case of searches
set smartcase       " Search with case only if needed
set hlsearch        " Highlight search while typing

" Don’t add empty newlines at the end of files
set noeol

" jk or kj to quit insert mode
imap jk <Esc>

" Better yank
noremap Y y$
vnoremap Y "zy
vnoremap P "zp

" Press enter after search to clean highlighting
nnoremap <cr> :noh<CR><CR>:<backspace>

" Moves between splits the easy way
map <C-h> <C-w>h
map <C-j> <C-w>j
map <C-k> <C-w>k
map <C-l> <C-w>l

" More natural splits
set splitright
set splitbelow
set diffopt+=vertical

" move the current line up or down with the Ctrl-arrow keys
nmap <C-Down> :<C-u>move .+1<CR>
nmap <C-Up>   :<C-u>move .-2<CR>
imap <C-Down> <C-o>:<C-u>move .+1<CR>
imap <C-Up>   <C-o>:<C-u>move .-2<CR>
vmap <C-Down> :move '>+1<CR>gv
vmap <C-Up> :move '<-2<CR>gv

" Backup / Undo
set backup
set noswapfile
set undodir=~/.vim/tmp/undo//     " undo files
set backupdir=~/.vim/tmp/backup// " backups
set directory=~/.vim/tmp/swap//   " swap files

" Make those folders automatically if they don't already exist.
if !isdirectory(expand(&undodir))
    call mkdir(expand(&undodir), "p")
endif
if !isdirectory(expand(&backupdir))
    call mkdir(expand(&backupdir), "p")
endif
if !isdirectory(expand(&directory))
    call mkdir(expand(&directory), "p")
endif"

" Navigate through tabs
nnoremap gl    :tabnext<CR>
nnoremap gh    :tabprev<CR>

" Insert mode paste toggle
set pastetoggle=<F9>
nnoremap <F10> :set nonumber!<CR>
nnoremap <F12> :set paste<CR>i
nnoremap <leader>i :set paste<CR>i

" Open a new tab the easy way
nnoremap <leader>t :tabedit<Space>

" Redraw screen on demand
nnoremap <leader>r :redraw! <CR>

" Shortcut to rapidly toggle `set list`
nmap <leader>l :set list!<CR>

" Toggle spell lang
nnoremap <leader>s :let &l:spelllang=( &l:spelllang == "en" ? "fr" : "en" )<CR>

" Choose the first spelling correction
nnoremap z- 1z=

" Correct the next word
nnoremap <Leader>c ]s1z=

" Use the same symbols as TextMate for tabstops and EOLs
set listchars=tab:▸\ ,eol:¬,trail:·

" Easy folding
noremap <Space> za
vnoremap <Space> zf

" autocmd filetype group
augroup filetype_set
    " Clear the autocmd
    autocmd!
    " Markdown filetype
    autocmd BufRead,BufNewFile *.md set filetype=markdown
    " Vagrantfile
    autocmd BufRead,BufNewFile Vagrantfile set filetype=ruby
    " JSON
    autocmd BufRead,BufNewFile *.json set filetype=json syntax=javascript
augroup END

" autocmd paste mode
augroup paste_helper
    " Clear the autocmd
    autocmd!
    " set not paste in normal mode
    autocmd InsertLeave * set nopaste
augroup END

" autocmd spell group
augroup spell_set
    " Clear the autocmd
    autocmd!
    " svn
    autocmd BufNewFile,BufRead svn-commit.tmp setlocal spell
augroup END

" autocmd vim help
augroup vim_help
    " Clear the autocmd
    autocmd!
    " open vim help in a right split
    au BufWinEnter *.txt if &ft == 'help' | wincmd L | endif
augroup END

" autocmd config group
augroup config
    " Clear the autocmd
    autocmd!
    " Source the vimrc on write
    autocmd bufwritepost .vimrc call Vimrc_update()
    " Delete spaces at the end of the lines on save
    autocmd BufWrite * %s/\s\+$//ge
augroup END

" Edit vimrc
nmap <leader>v :tabedit $MYVIMRC<CR>

" Open NERDTree Tabs quick toogle
nmap <leader>n :NERDTreeTabsToggle<CR>

" Open NERTree if vim start with no file
autocmd vimenter * if !argc() | let g:nerdtree_tabs_open_on_console_startup=1 | endif

" Open tagbar with a shortcut
nmap <leader>b :TagbarToggle<CR>

" Visual Mode */# from Scrooloose
function! s:VSetSearch()
  let temp = @@
  norm! gvy
  let @/ = '\V' . substitute(escape(@@, '\'), '\n', '\\n', 'g')
  let @@ = temp
endfunction

vnoremap * :<C-u>call <SID>VSetSearch()<CR>//<CR><c-o>
vnoremap # :<C-u>call <SID>VSetSearch()<CR>??<CR><c-o>

"Options for the NERDTree
let g:NERDChristmasTree=1
let g:NERDTreeAutoDeleteBuffer=1
let g:NERDTreeChDirMode=2
let g:NERDTreeDirArrows=0
let g:NERDTreeShowBookmarks=1
let g:NERDTreeShowHidden=1

" Syntastic
let g:syntastic_check_on_wq=0
let g:syntastic_error_symbol='✗'
let g:syntastic_warning_symbol='⚠'
let g:syntastic_enable_perl_checker = 1
let g:syntastic_ruby_checkers = ['mri', 'rubocop']
let g:syntastic_ruby_rubocop_args = "-R"
let g:syntastic_go_checkers = ['go', 'gofmt', 'golint' , 'govet']
noremap <leader>e :Errors<CR>

" Go vim - :help go-settings
let g:go_fmt_command = "goimports"
let g:go_play_open_browser = 0
let g:go_fmt_fail_silently = 1
let g:go_highlight_functions = 1
let g:go_highlight_methods = 1
let g:go_doc_command = "godoc"
let g:go_doc_keywordprg_enabled = 0 " handled by .vim/ftplugin/go.vim

" Delimate
let delimitMate_expand_cr = 2

" Start interactive EasyAlign in visual mode
vmap <Enter> :Tabularize /

" statusline old one commented / using light line now
set laststatus=2 "always visible
set noshowmode
" set statusline=%<%f\ %h%m%r%{fugitive#statusline()}%{virtualenv#statusline()}%=%-14.(%l,%c%V%)\ %P
" lightline
let g:lightline = {
      \ 'active': {
      \   'left': [ [ 'mode', 'paste' ],
      \             [ 'fugitive', 'readonly', 'filename', 'modified' ] ],
      \   'right': [ [ 'syntastic', 'lineinfo' ],
      \              ['percent'],
      \              [ 'fileformat', 'fileencoding', 'filetype', 'spell' ] ]
      \ },
      \ 'component': {
      \   'fugitive': '%{exists("*fugitive#head")?fugitive#head():""}'
      \ },
      \ 'component_visible_condition': {
      \   'readonly': '(&filetype!="help"&& &readonly)',
      \   'modified': '(&filetype!="help"&&(&modified||!&modifiable))',
      \   'fugitive': '(exists("*fugitive#head") && ""!=fugitive#head())'
      \ },
      \ }

" Reload conf
if !exists("*Vimrc_update()")
    function! Vimrc_update()
        source $MYVIMRC
        echom 'vimrc reloaded'
        call lightline#init()
        call lightline#colorscheme()
        call lightline#update()
    endfunction
endif

" Source local vimrc
if filereadable(glob("~/.vimrc.local"))
    source ~/.vimrc.local
endif
