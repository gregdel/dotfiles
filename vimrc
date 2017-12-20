if !has("nvim")
    " Make vim more capable
    set nocompatible

    " Remove bgc
    set t_ut=

    " colors
    if $TERM == "xterm-256color" || $TERM == "screen-256color"
            set t_Co=256
    endif
endif

" Load plugins
if filereadable(expand("~/.vim/plugins.vim"))
    source ~/.vim/plugins.vim
endif

" No mouse
set mouse=

filetype plugin indent on
syntax on
colorscheme molokai

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

" Highlight trailing spaces
highlight ExtraWhitespace term=reverse ctermbg=12
au BufNewFile,BufRead * :match ExtraWhitespace /\s\+$/

" Spelling colors
hi clear SpellBad
hi SpellBad cterm=italic,bold,underline ctermfg=208
hi clear SpellCap
hi SpellCap cterm=italic ctermfg=208
hi clear SpellRare
hi SpellRare ctermfg=200

" Show all kinds of stuff
set ruler           " Show the cursor position
set shortmess=atI   " Don’t show the intro message when starting Vim
set showmode        " Show the current mode
set title           " Show the filename in the window titlebar
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
nmap <leader>g :Ggrep
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

" autocmd filetype group
augroup filetype_set
    " Clear the autocmd
    autocmd!
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
    " Delete spaces at the end of the lines on save
    autocmd BufWrite * %s/\s\+$//ge
augroup END

" autocmd location list
augroup locationlist
    autocmd!
    autocmd QuickFixCmdPost *grep* cwindow
augroup END

" Edit vimrc
nmap <leader>v :tabedit $MYVIMRC<CR>

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

" Syntastic
let g:syntastic_check_on_wq=0
let g:syntastic_error_symbol='✗'
let g:syntastic_warning_symbol='⚠'
let g:syntastic_enable_perl_checker = 1
let g:syntastic_ruby_checkers = ['mri', 'rubocop']
let g:syntastic_ruby_rubocop_args = "-R"
let g:syntastic_go_checkers = ['go', 'gofmt', 'golint' , 'govet']
let g:syntastic_lua_checkers = ["luac", "luacheck"]
let g:syntastic_lua_luacheck_args = "--no-unused-args"
let g:syntastic_javascript_eslint_exe='$(npm bin)/eslint'
let g:syntastic_javascript_checkers = ["eslint"]
let g:syntastic_always_populate_loc_list = 1
noremap <leader>e :Errors<CR>

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

" ListToggle
let g:lt_quickfix_list_toggle_map = '<leader>q'
let g:lt_location_list_toggle_map = '<leader>w'

" Ale
let g:ale_sign_error = '✗'
let g:ale_sign_warning = '⚠'
let g:ale_linters = {'go': ['go build', 'gofmt', 'golint', 'gosimple', 'go vet', 'staticcheck'] }
let g:ale_lint_on_text_changed = 'never'

" Deoplete
if has('nvim')
    let g:deoplete#enable_at_startup = 0
    nmap <leader>d :call deoplete#toggle()<CR>
endif

" Ultisnip
let g:UltiSnipsEditSplit    = 'vertical'
let g:UltiSnipsListSnippets = '<S-Tab>'

" Markdown
let g:vim_markdown_folding_disabled = 0
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

" statusline
set laststatus=2 "always visible
set noshowmode

" Source local vimrc
if filereadable(glob("~/.vimrc.local"))
    source ~/.vimrc.local
endif
