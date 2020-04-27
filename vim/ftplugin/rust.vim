nnoremap gd :ALEGoToDefinition <CR>
nnoremap K :ALEHover <CR>

" ALE
set omnifunc=ale#completion#OmniFunc
let b:ale_linters = ['cargo', 'rls']
let b:ale_fixers = ['rustfmt']
