require("nvim-treesitter.configs").setup {
  ensure_installed = { 
    "bash",
    "c",
    "css",
    "dot",
    "go",
    "html",
    "json",
    "lua",
    "vim",
    "zig",
  },
  sync_install = false,
  highlight = {
    enable = true,
  },
}
