local fn = vim.fn

-- Automatically install packer
local install_path = fn.stdpath "data" .. "/site/pack/packer/start/packer.nvim"
if fn.empty(fn.glob(install_path)) > 0 then
  PACKER_BOOTSTRAP = fn.system {
    "git",
    "clone",
    "--depth",
    "1",
    "https://github.com/wbthomason/packer.nvim",
    install_path,
  }
  print "Installing packer close and reopen Neovim..."
  vim.cmd [[packadd packer.nvim]]
end

-- Autocommand that reloads neovim whenever you save the plugins.lua file
vim.cmd [[
  augroup packer_user_config
  autocmd!
  autocmd BufWritePost plugins.lua source <afile> | PackerSync
  augroup end
]]

-- Use a protected call so we don't error out on first use
local status_ok, packer = pcall(require, "packer")
if not status_ok then
  return
end

-- Have packer use a popup window
packer.init {
  display = {
    open_fn = function()
      return require("packer.util").float { border = "rounded" }
    end,
  },
}

return packer.startup(function(use)
  use "wbthomason/packer.nvim"

  use {
    "nvim-lualine/lualine.nvim",
    requires = { "kyazdani42/nvim-web-devicons", opt = true }
  }

  use {
    "folke/trouble.nvim",
    requires = "kyazdani42/nvim-web-devicons",
    require("trouble").setup({
      auto_close = true,
    })
  }

  use {
    'nvim-telescope/telescope.nvim',
    requires = { "nvim-lua/plenary.nvim" },
    config = function()
      require('telescope').setup{}
    end
  }

  use {
    "jose-elias-alvarez/null-ls.nvim",
    requires = { "nvim-lua/plenary.nvim" },
  }

  use {
    "norcalli/nvim-colorizer.lua",
    config = function()
      require("colorizer").setup {}
    end
  }

  use "~/dev/molokai"
  -- use "fatih/molokai"
  use "godlygeek/tabular"
  use "neovim/nvim-lspconfig"
  use "nvim-treesitter/nvim-treesitter"
  use "preservim/nerdtree"
  use "tpope/vim-dispatch"
  use "tpope/vim-fugitive"
  use "tpope/vim-repeat"
  use "tpope/vim-surround"
  use "tpope/vim-unimpaired"
  use 'Raimondi/delimitMate'
  use 'tpope/vim-commentary'

  use { "rust-lang/rust.vim",  ft = { "rust" }}
  use { "pearofducks/ansible-vim",  ft = { "yaml.ansible", "ansible_hosts" }}
  use { "nfnty/vim-nftables",  ft = { "nftables" }}
  use { "vim-latex/vim-latex",  ft = { "tex" }}
  use { "xuhdev/vim-latex-live-preview",  ft = { "tex" }}
  use { "vivien/vim-linux-coding-style",  ft = { "c" }}
  use { "chazy/cscope_maps",  ft = { "c" }}
  use { "brookhong/cscope.vim",  ft = { "c" }}
  use { "ekalinin/Dockerfile.vim",  ft = { "Dockerfile" }}
  use { "fatih/vim-go",  ft = { "go", "gomod" }}
  use { "kchmck/vim-coffee-script",  ft = { "coffee" }}
  use { "pangloss/vim-javascript",  ft = { "javascript", "javascript.jsx" }}
  use { "MaxMEllon/vim-jsx-pretty",  ft = { "javascript", "javascript.jsx" }}
  use { "tmhedberg/matchit",  ft = { "javascript" }}
  use { "tpope/vim-endwise",  ft = { "lua", "ruby", "sh", "zsh", "vim" }}
  use { "plasticboy/vim-markdown",  ft = { "markdown" }}
  use { "tpope/vim-rails",  ft = { "ruby" }}
  use { "ziglang/zig.vim",  ft = { "zig" }}
  use { "wannesm/wmgraphviz.vim",  ft = { "dot" }}
  use { "sirtaj/vim-openscad",  ft = { "openscad" }}

  if PACKER_BOOTSTRAP then
    require("packer").sync()
  end
end)
