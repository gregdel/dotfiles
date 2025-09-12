-- Colors
vim.opt.termguicolors = true

-- disable netrw
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Disable mouse
vim.opt.mouse = ""

-- Show the filename in the window titlebar
vim.opt.title = true

-- Search
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Backups, swap and undo files
vim.opt.backup = false
vim.opt.swapfile = false
vim.opt.undofile = false

-- Don't try to highlight lines longer than 800 characters.
vim.opt.synmaxcol = 800

-- Indentation
vim.opt.expandtab = true
vim.opt.smarttab = true
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.linebreak = true
vim.opt.autoindent = true

vim.opt.number = false
vim.opt.relativenumber = false
vim.opt.signcolumn = "yes"

-- Format options no automatic wraping, gq wrap to 80
vim.opt.textwidth = 0
vim.opt.formatoptions = "cq"
vim.opt.wrapmargin = 0
vim.opt.wrap = true

-- Scrolloff
vim.opt.scrolloff = 5

-- More natural splits
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.diffopt.extends = "vertical"

-- Conceal setup
vim.opt.conceallevel = 0

-- List
vim.opt.listchars="tab:▸\\ ,eol:¬,trail:·"

-- Colorizer
vim.g.colorizer_nomap = 1
vim.g.colorizer_startup = 0

-- vim-jsx
vim.g.jsx_ext_required = 0

-- vim-latex-live-preview
vim.g.livepreview_previewer = "zathura"
