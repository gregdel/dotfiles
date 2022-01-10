local opts = { noremap = true, silent = false }
local opts_silent = { noremap = true, silent = true }

local term_opts = { silent = true }

-- Shorten function name
local keymap = vim.api.nvim_set_keymap

--Remap space as leader key
vim.g.mapleader = ","

-- Modes
--   normal_mode = "n",
--   insert_mode = "i",
--   visual_mode = "v",
--   visual_block_mode = "x",
--   term_mode = "t",
--   command_mode = "c",

-- jk to quit insert mode
keymap("i", "jk", "<Esc>", opts_silent)

-- Easy qwerty
keymap("n", ";", ":", opts)
keymap("v", ";", ":", opts)

-- Edit vimrc
keymap("v", "<Leader>v", ":tabedit $MYVIMRC<CR>", opts)

-- Window navigation
keymap("n", "<C-h>", "<C-w>h", opts)
keymap("n", "<C-j>", "<C-w>j", opts)
keymap("n", "<C-k>", "<C-w>k", opts)
keymap("n", "<C-l>", "<C-w>l", opts)

-- Better yank
keymap("n", "Y", "y$", opts)
keymap("v", "Y", '"zy', opts)
keymap("n", "P", '"zp', opts)

-- Easy folding with space
keymap("n", "<Space>", "za", opts)
keymap("v", "<Space>", "zf", opts)

-- Navigate tabs / buffers
keymap("n", "gl", ":tabnext<cr>", opts)
keymap("n", "gh", ":tabprev<cr>", opts)
keymap("n", "gL", ":bnext<cr>", opts)
keymap("n", "gH", ":bprev<cr>", opts)

-- Better indent
keymap("v", ">", ">gv", opts)
keymap("v", "<", "<gv", opts)

-- Insert mode file name completion
keymap("i", "<c-f>", "<c-x><x-f>", opts)

-- Paste mode
keymap("n", "<leader>i", ":set paste<CR>i", opts)

-- TODO: not silent
-- Open a new tab the easy way
keymap("n", "<leader>t", ":tabedit<Space>", opts)

-- Redraw screen on demand
keymap("n", "<leader>r", ":redraw! <CR>", opts)

-- Shortcut to rapidly toggle `set list`
keymap("n", "<leader>l", ":set list!<CR>", opts)

-- Toggle spell lang
-- nnoremap <leader>s :let &l:spelllang=( &l:spelllang == "en" ? "fr" : "en" )<CR>

-- Correct the next word
keymap("n", "<leader>c", "]s1z=", opts)

-- Use arrows for resizing windows
keymap("n", "<Left>", "<C-W><", opts)
keymap("n", "<Right>", "<C-W>>", opts)
keymap("n", "<Up>", "<C-W>+", opts)
keymap("n", "<Down>", "<C-W>-", opts)

-- Press enter after search to clean highlighting
keymap("n", "<cr>", ":noh<CR><CR>:<backspace>", opts)

-- Nvim tree
keymap("n", "<Leader>n", ":NvimTreeToggle<CR>", opts)

-- Nvim tree
keymap("n", "<Leader>d", ":TroubleToggle<CR>", opts_silent)

-- Tabular
keymap("v", "<Enter>", ":Tabularize /", opts)

-- Telescope
keymap("n", "<C-p>", ":Telescope find_files<CR>", opts_silent)
keymap("n", "<C-g>", ":Telescope git_files<CR>", opts_silent)
keymap("n", "<C-n>", ":Telescope buffers<CR>", opts_silent)
keymap("n", "<C-m>", ":Telescope live_grep<CR>", opts_silent)
