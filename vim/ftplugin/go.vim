" Local conf
setlocal noexpandtab     " use tabs instead of spaces
setlocal tabstop=4       " use 4 tabs
setlocal shiftwidth=4    " autoindent with 4 tabs
setlocal softtabstop=4   " 4 spaces to represent a tab

" Jump to the beginning of the fucntion
noremap [[ ?func <CR>:noh<CR>$
noremap ]] ?func <CR>:noh<CR>$%

" Fold the current function
noremap <leader>f :call go#textobj#Function('i')<CR>zf

" Go dock in a vertical split
nmap K <Plug>(go-doc-vertical)

" Go to definition in a vertical split
nmap gD <Plug>(go-def-vertical)

" ALE
let b:ale_linters = ['go build', 'gopls', 'golangci-lint']
let b:ale_fixers = ["goimports", 'gofmt']
" let b:ale_go_golangci_lint_options = "--fast"
let b:ale_go_golangci_lint_options = "--exclude-use-default=false -E godot -E revive -E gocritic"
let b:ale_go_golangci_lint_package = 1

" Go vim - :help go-settings
let g:go_play_open_browser = 0
" let g:go_fmt_fail_silently = 1
let g:go_highlight_functions = 1
let g:go_highlight_methods = 1
