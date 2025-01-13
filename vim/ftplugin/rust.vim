nnoremap gd :ALEGoToDefinition <CR>
nnoremap gs :ALEGoToDefinitionInVSplit <CR>
nnoremap K :ALEHover <CR>

" ALE
set omnifunc=ale#completion#OmniFunc
let b:ale_linters = ['cargo', 'analyzer']
let b:ale_fixers = ['rustfmt']
" let b:ale_rust_cargo_use_clippy = executable('cargo-clippy')
" let b:ale_rust_rls_config = {'rust': {'clippy_preference': 'on'}}
