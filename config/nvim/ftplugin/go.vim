" Local conf
setlocal noexpandtab     " use tabs instead of spaces
setlocal tabstop=4       " use 4 tabs
setlocal shiftwidth=4    " autoindent with 4 tabs
setlocal softtabstop=4   " 4 spaces to represent a tab

" Jump to the beginning of the function
noremap [[ ?func <CR>:noh<CR>$
noremap ]] ?func <CR>:noh<CR>$%

" This is handled by vim-lsp
let g:go_fmt_autosave = 0
let g:go_imports_autosave = 0
let g:go_code_completion_enabled = 0
let g:go_mod_fmt_autosave = 0
let g:go_doc_keywordprg_enabled = 0
let g:go_metalinter_autosave = 0
let g:go_def_mapping_enabled = 0
let g:go_gopls_enabled = 0
