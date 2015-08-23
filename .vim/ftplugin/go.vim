" Local conf
setlocal noexpandtab     " use tabs instead of spaces
setlocal tabstop=4       " use 4 tabs
setlocal shiftwidth=4    " autoindent with 4 tabs
setlocal softtabstop=4   " 4 spaces to represent a tab

" Ctrl-Space for completion
inoremap <Nul> <C-x><C-o>

" Jump to the beginning of the fucntion
noremap [[ ?func <CR>:noh<CR>$
noremap ]] ?func <CR>:noh<CR>$%

" Fold the current function
noremap <leader>f :call go#textobj#Function('i')<CR>zf

" Go dock in a vertical split
nmap K <Plug>(go-doc-vertical)
