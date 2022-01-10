require "options"
require "keymaps"
require "plugins"
require "theme"
require "plugins/lualine"
require "plugins/nvim-tree"
require "plugins/comment"
require "plugins/nvim-treesitter"
require "plugins/gitsigns"
require "plugins/telescope"
require "plugins/nvim-lspconfig"
require "plugins/null-ls"

-- TODO: handle this the neovim way
vim.cmd [[
  " Highlight VCS conflict markers
  match ErrorMsg '^\(<\|=\|>\)\{7\}\([^=].\+\)\?$'

  " Highlight trailing spaces
  highlight ExtraWhitespace term=reverse ctermbg=12
  au BufNewFile,BufRead * :match ExtraWhitespace /\s\+$/

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

  " Visual Mode */# from Scrooloose
  function! s:VSetSearch()
    let temp = @@
    norm! gvy
    let @/ = '\V' . substitute(escape(@@, '\'), '\n', '\\n', 'g')
    let @@ = temp
  endfunction

  vnoremap * :<C-u>call <SID>VSetSearch()<CR>//<CR><c-o>
  vnoremap # :<C-u>call <SID>VSetSearch()<CR>??<CR><c-o>
]]
