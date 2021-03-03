" TODO: check the latest default in vim 8
if !has("nvim")
    " Make vim more capable
    set nocompatible

    " Remove bgc
    set t_ut=

    " colors
    if $TERM == "xterm-256color" || $TERM == "screen-256color"
        set t_Co=256
    endif

    " Show all kinds of stuff
    set ruler           " Show the cursor position
    set shortmess=atI   " Don’t show the intro message when starting Vim
    set showmode        " Show the current mode
    set showcmd         " Show the (partial) command as it’s being typed
    set lazyredraw      " redraw only when we need to

    " statusline
    set laststatus=2 "always visible
    set noshowmode

    " History
    set history=1000    " much more history than base
    set undolevels=1000 " much more undo

    " No mouse
    set mouse=

    " Menu completion
    set wildmenu

    " Backspace
    set backspace=indent,eol,start

    " Format options no automatic wraping, gq wrap to 80
    set textwidth=0
    set formatoptions=cq
    set wrapmargin=0
    set wrap

    " Highlight search while typing
    set hlsearch

    " Don’t add empty newlines at the end of files
    set noeol
endif

" Load plugins
if filereadable(expand("~/.vim/plugins.vim"))
    source ~/.vim/plugins.vim
endif

filetype plugin indent on
syntax enable
set background=dark
colorscheme molokai

" Change mapleader
let mapleader=","

" Easy qwerty
nnoremap ; :
vnoremap ; :

" Backups, swap and undo files
set backup                                      " Enable backups
set backupdir=$HOME/.vim/files/backup/
set backupext=-vimbackup                        " Backup extention
set backupskip=                                 " Backup everything
set directory=$HOME/.vim/files/swap//
set undofile                                    " Keep the undo history
set undodir=$HOME/.vim/files/undo/

" Create files directory if it does not exist
if exists('*mkdir') && !isdirectory($HOME.'/.vim/files')
  call mkdir($HOME.'/.vim/files', "p")
  call mkdir($HOME.'/.vim/files/backup', "p")
  call mkdir($HOME.'/.vim/files/swap', "p")
  call mkdir($HOME.'/.vim/files/undo', "p")
endif

" Don't try to highlight lines longer than 800 characters.
set synmaxcol=800

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

" Highlight trailing spaces
highlight ExtraWhitespace term=reverse ctermbg=12
au BufNewFile,BufRead * :match ExtraWhitespace /\s\+$/

" Show the filename in the window titlebar
set title

" Search
set ignorecase      " Ignore case of searches
set smartcase       " Search with case only if needed

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

" Navigate through tabs / buffers
nnoremap gl    :tabnext<CR>
nnoremap gh    :tabprev<CR>
nnoremap gL    :bnext<CR>
nnoremap gH    :bprev<CR>

" Paste mode
nnoremap <leader>i :set paste<CR>i

" Open a new tab the easy way
nnoremap <leader>t :tabedit<Space>

" Redraw screen on demand
nnoremap <leader>r :redraw! <CR>

" Shortcut to rapidly toggle `set list`
nmap <leader>l :set list!<CR>

" Shortcut for :Ggrep
nnoremap <leader>g :Ggrep<Space>
cnoremap grep Ggrep

" Toggle spell lang
nnoremap <leader>s :let &l:spelllang=( &l:spelllang == "en" ? "fr" : "en" )<CR>

" Correct the next word
nnoremap <Leader>c ]s1z=

" Use the same symbols as TextMate for tabstops and EOLs
set listchars=tab:▸\ ,eol:¬,trail:·

" Easy folding with space
noremap <Space> za
vnoremap <Space> zf

" Use arrows for resizing windows
map <Left>  <C-W><
map <Right> <C-W>>
map <Up>    <C-W>+
map <Down>  <C-W>-

" Terminal mode in neovim
if has('nvim')
    tnoremap <Esc> <C-\><C-n>
endif

" autocmd paste mode
augroup paste_helper
    " Clear the autocmd
    autocmd!
    " set not paste in normal mode
    autocmd InsertLeave * set nopaste
augroup END

" autocmd vim help
augroup vim_help
    " Clear the autocmd
    autocmd!
    " open vim help in a right split
    au BufWinEnter *.txt if &ft == 'help' | wincmd L | endif
augroup END

" Delete spaces at the end of the lines on save
augroup trim_trailing_whitespaces
    autocmd!
    autocmd BufWrite * %s/\s\+$//ge
augroup END

" autocmd location list
augroup locationlist
    autocmd!
    autocmd QuickFixCmdPost *grep* cwindow
augroup END

" Edit vimrc
nmap <leader>v :tabedit $MYVIMRC<CR>

function! s:CustomVimEnter()
    if !argc()
        " Open NERTree if vim start with no file
        let g:nerdtree_tabs_open_on_console_startup=1
    endif
endfunction
autocmd vimenter * call s:CustomVimEnter()

" Edit *.gpg files
augroup encrypted
  au!
  autocmd BufReadPre,FileReadPre *.gpg set viminfo=
  autocmd BufReadPre,FileReadPre *.gpg set noswapfile noundofile nobackup
  autocmd BufReadPre,FileReadPre *.gpg set bin
  autocmd BufReadPre,FileReadPre *.gpg let ch_save = &ch|set ch=2
  autocmd BufReadPost,FileReadPost *.gpg '[,']!gpg --decrypt 2> /dev/null
  autocmd BufReadPost,FileReadPost *.gpg set nobin
  autocmd BufReadPost,FileReadPost *.gpg let &ch = ch_save|unlet ch_save
  autocmd BufReadPost,FileReadPost *.gpg execute ":doautocmd BufReadPost " . expand("%:r")
  autocmd BufWritePre,FileWritePre *.gpg '[,']!gpg --default-recipient-self -ae 2>/dev/null
  autocmd BufWritePost,FileWritePost *.gpg u
augroup END

" Open NERDTree Tabs quick toogle
nmap <leader>n :NERDTreeTabsToggle<CR>

" Visual Mode */# from Scrooloose
function! s:VSetSearch()
  let temp = @@
  norm! gvy
  let @/ = '\V' . substitute(escape(@@, '\'), '\n', '\\n', 'g')
  let @@ = temp
endfunction

vnoremap * :<C-u>call <SID>VSetSearch()<CR>//<CR><c-o>
vnoremap # :<C-u>call <SID>VSetSearch()<CR>??<CR><c-o>

" Colorizer
let g:colorizer_nomap = 1   " No key mapping
let g:colorizer_startup = 0 " Disabled by default

"Options for the NERDTree
let g:NERDChristmasTree=1
let g:NERDTreeAutoDeleteBuffer=1
let g:NERDTreeChDirMode=2
let g:NERDTreeDirArrows=0
let g:NERDTreeShowBookmarks=1
let g:NERDTreeShowHidden=1

" Go vim - :help go-settings
let g:go_fmt_command = "goimports"
let g:go_play_open_browser = 0
let g:go_fmt_fail_silently = 1
let g:go_highlight_functions = 1
let g:go_highlight_methods = 1
let g:go_doc_command = "godoc"
let g:go_doc_keywordprg_enabled = 0 " handled by .vim/ftplugin/go.vim
let g:go_fmt_command = "goimports"
let g:go_template_autocreate = 1

" Delimate
let delimitMate_expand_cr = 2

" Ale
let g:ale_sign_error = '✗'
let g:ale_sign_warning = '⚠'
let g:ale_lint_on_text_changed = 'never'
let g:ale_echo_msg_format = '[%linter%] %s [%severity%]'
let g:ale_lint_on_insert_leave = 0
let g:ale_fix_on_save = 1

nmap <silent> <leader>aj :ALENext<cr>
nmap <silent> <leader>ak :ALEPrevious<cr>

" Markdown
let g:vim_markdown_folding_disabled = 1
let g:vim_markdown_override_foldtext = 0

" Airline
let g:airline_theme='badwolf'
let g:airline_powerline_fonts=1
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#show_close_button = 0
let g:airline#extensions#ale#enabled = 1
function! GetSpelllang()
    return  &spelllang
endfunction
function! AirlineInit()
    call airline#parts#define_function('spelllang', 'GetSpelllang')
    call airline#parts#define_condition('spelllang', '&spell')
    let g:airline_section_a = airline#section#create_left(['mode', 'crypt', 'paste', 'spell','spelllang', 'iminsert'])
endfunction
autocmd User AirlineAfterInit call AirlineInit()

" CtrlP
nmap <leader>b :CtrlPBuffer<CR>
nmap <leader>m :CtrlPMRUFiles<CR>
let g:ctrlp_user_command = ['.git', 'cd %s && git ls-files . -co --exclude-standard', 'find %s -type f']

" Start interactive EasyAlign in visual mode
vmap <Enter> :Tabularize /

" vim-jsx
let g:jsx_ext_required = 0 " Allow JSX in normal JS files

" vim-latex-live-preview
let g:livepreview_previewer = 'zathura'

" SnipMate
let g:snipMate = { 'snippet_version' : 1 }

" Source local vimrc
if filereadable(glob("~/.vimrc.local"))
    source ~/.vimrc.local
endif
