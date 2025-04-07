require "options"
require "keymaps"
require "plugins"
require "lsp"

vim.api.nvim_create_autocmd("BufWinEnter", {
    group = vim.api.nvim_create_augroup("vim_help", {}),
    pattern = { "*.txt" },
    callback = function()
        if vim.o.filetype == 'help' then vim.cmd.wincmd("L") end
    end
})

vim.api.nvim_create_autocmd("BufWrite", {
    group = vim.api.nvim_create_augroup("trim_trailing_whitespaces", {}),
    pattern = { "*" },
    callback = function()
      vim.cmd [[ %s/\s\+$//ge ]]
    end
})

vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
  pattern = "OTKfile",
  callback = function()
    vim.opt.filetype = "sh"
  end
})

-- TODO: handle this the neovim way
vim.cmd [[
  " Visual Mode */# from Scrooloose
  function! s:VSetSearch()
    let temp = @@
    norm! gvy
    let @/ = '\V' . substitute(escape(@@, '\'), '\n', '\\n', 'g')
    call histadd('/', substitute(@/, '[?/]', '\="\\%d".char2nr(submatch(0))', 'g'))
    let @@ = temp
  endfunction

  vnoremap * :<C-u>call <SID>VSetSearch()<CR>/<CR>
  vnoremap # :<C-u>call <SID>VSetSearch()<CR>?<CR>
]]
