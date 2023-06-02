local opts = { noremap = true, silent = true }
local opts_verbose = { noremap = true, silent = false }

-- Remap space as leader key
vim.g.mapleader = ","

-- jk to quit insert mode
vim.keymap.set("i", "jk", "<Esc>", opts)

-- Easy qwerty
vim.keymap.set("n", ";", ":", opts_verbose)
vim.keymap.set("v", ";", ":", opts_verbose)

-- Window navigation
vim.keymap.set("n", "<C-h>", "<C-w>h", opts)
vim.keymap.set("n", "<C-j>", "<C-w>j", opts)
vim.keymap.set("n", "<C-k>", "<C-w>k", opts)
vim.keymap.set("n", "<C-l>", "<C-w>l", opts)

-- Better yank
vim.keymap.set("n", "Y", "y$", opts)
vim.keymap.set("v", "Y", '"zy', opts)
vim.keymap.set("v", "P", '"zp', opts)

-- Easy folding with space
-- vim.keymap.set("n", "<Space>", "za", opts)
-- vim.keymap.set("v", "<Space>", "zf", opts)

-- Bar
vim.keymap.set("n", "gl", "<Cmd>tabnext<CR>", opts)
vim.keymap.set("n", "gh", "<Cmd>tabprev<CR>", opts)
vim.keymap.set("n", "gL", "<Cmd>bnext<CR>", opts)
vim.keymap.set("n", "gH", "<Cmd>bprev<CR>", opts)

-- Better indent
vim.keymap.set("v", ">", ">gv", opts)
vim.keymap.set("v", "<", "<gv", opts)

-- Insert mode file name completion
vim.keymap.set("i", "<C-f>", "<C-x><C-f>", opts)

-- Paste mode
vim.keymap.set("n", "<leader>i", "<Cmd>set paste<CR>i", opts)

-- Open a new tab the easy way
vim.keymap.set("n", "<leader>t", ":tabedit<Space>", opts_verbose)

-- Redraw screen on demand
vim.keymap.set("n", "<leader>r", "<Cmd>redraw! <CR>", opts)

-- Shortcut to rapidly toggle `set list`
vim.keymap.set("n", "<leader>l", "<Cmd>set list!<CR>", opts)

-- Toggle spelllang
vim.keymap.set("n", "<leader>s", function()
  local conf = vim.opt.spelllang:get()
  local lang = "en"
  for _ , l in ipairs(conf) do
    if l == "en" then lang = "fr" end
  end

  vim.opt.spell = true
  vim.opt.spelllang = { lang }
  print("Spell lang set to", lang)
end, opts)

-- Correct the next word
vim.keymap.set("n", "<leader>c", "]s1z=", opts)

-- Use arrows for resizing windows
vim.keymap.set("n", "<Left>", "<C-W><", opts)
vim.keymap.set("n", "<Right>", "<C-W>>", opts)
vim.keymap.set("n", "<Up>", "<C-W>+", opts)
vim.keymap.set("n", "<Down>", "<C-W>-", opts)

-- Press enter after search to clean highlighting
vim.keymap.set("n", "<cr>", "<Cmd>noh<CR><CR><Cmd><backspace>", opts)

-- Nvim tree
vim.keymap.set("n", "<Leader>n", "<Cmd>NvimTreeToggle<CR>", opts)

-- Trouble
vim.keymap.set("n", "<Leader>d", "<Cmd>TroubleToggle<CR>", opts)

-- Tabular
vim.keymap.set("v", "<Enter>", "<Cmd>Tabularize /", opts)

-- Telescope
vim.keymap.set("n", "<C-p>", "<Cmd>Telescope find_files<CR>", opts)
vim.keymap.set("n", "<C-g>", "<Cmd>Telescope git_files<CR>", opts)
vim.keymap.set("n", "<C-b>", "<Cmd>Telescope buffers<CR>", opts)
vim.keymap.set("n", "<C-n>", "<Cmd>Telescope live_grep<CR>", opts)

-- Gitsigns
vim.keymap.set("n", "]g", "<Cmd>Gitsigns next_hunk<CR>", opts)
vim.keymap.set("n", "[g", "<Cmd>Gitsigns prev_hunk<CR>", opts)
vim.keymap.set("n", "<Leader>gd", "<Cmd>Gitsigns preview_hunk<CR>", opts)
vim.keymap.set("n", "<Leader>ga", "<Cmd>Gitsigns stage_hunk<CR>", opts)
vim.keymap.set("n", "<Leader>gu", "<Cmd>Gitsigns reset_hunk<CR>", opts)
