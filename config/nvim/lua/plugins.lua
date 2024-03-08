local fn = vim.fn

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

function close_lazy()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local config = vim.api.nvim_win_get_config(win)
    if config.relative ~= "" then  -- is_floating_window?
      vim.api.nvim_win_close(win, false)
    end
  end
end

local custom_symbols = {
  error = "",
  warning = "",
  hint = "",
  information = "",
}

require("lazy").setup({
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "kyazdani42/nvim-web-devicons" },
    event = "VimEnter",
    config = function ()
      local theme = require("lualine.themes.material")
      theme.normal.b.bg = "#303030"

      require("lualine").setup({
        options = {
          theme = theme,
        },
        sections = {
          lualine_x = {
            "encoding",
            { "filetype", icons_enabled = false },
          },
          lualine_b = {
            "branch", "diff",
            { "diagnostics", symbols = custom_symbols },
          },
        },
        extensions = {
          "lazy", "fugitive", "man",
          "quickfix", "toggleterm", "trouble",
        },
      })
    end
  },
  {
    "folke/zen-mode.nvim",
    opts = {
      plugins = {
        -- disable some global vim options (vim.o...)
        -- comment the lines to not apply the options
        options = {
          enabled = true,
          ruler = true, -- disables the ruler text in the cmd line area
          showcmd = true, -- disables the command in the last line of the screen
          -- you may turn on/off statusline in zen mode by setting 'laststatus'
          -- statusline will be shown only if 'laststatus' == 3
          laststatus = 0, -- turn off the statusline in zen mode
        },
      },
    },
  },
  {
    "folke/trouble.nvim",
    dependencies = { "kyazdani42/nvim-web-devicons" },
    opts = {
      auto_close = true,
      signs = custom_symbols,
    },
  },
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local actions = require("telescope.actions")
      require("telescope").setup({
        defaults = {
          mappings = {
            i = {
              ["<C-j>"] = actions.move_selection_next,
              ["<C-k>"] = actions.move_selection_previous,
              ["<C-h>"] = actions.close,
              ["<C-l>"] = actions.close,
            },
          },
        },
      })
    end,
  },
  {
    "nvim-telescope/telescope-ui-select.nvim",
    dependencies = { "nvim-telescope/telescope.nvim" },
    config = function()
      require("telescope").load_extension("ui-select")
    end,
  },
  {
    "nvimtools/none-ls.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local formatting = require("null-ls").builtins.formatting
      local diagnostics = require("null-ls").builtins.diagnostics
      local actions = require("null-ls").builtins.code_actions

      require("null-ls").setup({
        sources = {
          -- shell
          diagnostics.shellcheck,
          actions.shellcheck,
          -- go
          formatting.goimports,
          formatting.gofmt,
          diagnostics.golangci_lint,
          actions.gomodifytags,
          actions.impl,
          -- c
          diagnostics.clang_check,
          -- formatting.clang_format,
        },
      })
    end,
  },
  {
    "norcalli/nvim-colorizer.lua",
    dependencies = { "kyazdani42/nvim-web-devicons" },
    cmd = { "ColorizerToggle" },
  },
  {
    "nvim-tree/nvim-tree.lua",
    cmd = { "NvimTreeToggle" },
    opts = {
      view = {
        float = {
          enable = true,
          open_win_config = function()
            local screen_w = vim.opt.columns:get()
            local screen_h = vim.opt.lines:get() - vim.opt.cmdheight:get()

            local height_ratio = 0.6
            if screen_w < 80
              then width_ratio = 1
            elseif screen_w < 120
              then width_ratio = 0.8
            else
              width_ratio = 0.4
            end

            local window_w = screen_w * width_ratio
            local window_h = screen_h * height_ratio
            local window_w_int = math.floor(window_w)
            local window_h_int = math.floor(window_h)
            local center_x = (screen_w - window_w) / 2
            local center_y = ((vim.opt.lines:get() - window_h) / 2) - vim.opt.cmdheight:get()
            return {
              border = "rounded",
              relative = "editor",
              row = center_y,
              col = center_x,
              width = window_w_int,
              height = window_h_int,
            }
          end
        },
      },
      renderer = {
        icons = {
          glyphs = {
            git = {
              unstaged = "✗",
              staged = "✓",
              unmerged = "✗",
              renamed = "→",
              untracked = "…",
              deleted = "",
              ignored = "◌",
            },
          },
        },
      },
    },
  },
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function ()
      local configs = require("nvim-treesitter.configs")

      configs.setup({
        ensure_installed = {
          "c",
          "css",
          "dot",
          "go",
          "html",
          "json",
          "lua",
          "vim",
          "vimdoc",
          "yaml",
          "zig",
          "query", -- treesitter playground
        },
        sync_install = false,
        highlight = {
          enable = true,
        },
      })
    end,
  },
  {
    "nvim-treesitter/playground",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    cmd = { "TSPlaygroundToggle", "TSHighlightCapturesUnderCursor", "TSNodeUnderCursor" },
  },
  {
    "tanvirtin/monokai.nvim",
    priority = 1000,
    config = function()
      local monokai = require("monokai")
      local palette = monokai.classic
      palette.base1 = "#000000"
      palette.base2 = "#101010"
      palette.base3 = "#202020"
      palette.base4 = "#303030"
      palette.base5 = "#404040"
      palette.base6 = "#505050"
      palette.base7 = "#606060"
      palette.white = "#d0d0d0"
      monokai.setup({
        palette = palette,
        custom_hlgroups = {
          Todo = { fg = palette.pink, style = "underline" },
          NormalFloat = { fg = palette.white, bg = palette.base2 },
          FloatBorder = { fg = palette.orange, bg = palette.base2 },
          TelescopeNormal = { fg = palette.white, bg = palette.base2 },
          DiffChange = { fg = palette.orange, bg = palette.base2 },
          TelescopeTitle = { fg = palette.white, bg = palette.base2 },
          TelescopeBorder = { fg = palette.orange },
          NvimTreeCursorColumn = { bg = palette.base2 },
          NvimTreeCursorLine = { bg = palette.base2 },
        },
      })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    config = function()
      local lsp = require("lspconfig")
      lsp.clangd.setup{}
      lsp.gopls.setup{}

      -- Use LspAttach autocommand to only map the following keys
      -- after the language server attaches to the current buffer
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("UserLspConfig", {}),
        callback = function(ev)
          -- Enable completion triggered by <c-x><c-o>
          vim.bo[ev.buf].omnifunc = "v:lua.vim.lsp.omnifunc"

          -- Buffer local mappings.
          -- See `:help vim.lsp.*` for documentation on any of the below functions
          local opts = { buffer = ev.buf }
          vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
          vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
          vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
          vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
          vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, opts)
          vim.keymap.set("n", "<space>wa", vim.lsp.buf.add_workspace_folder, opts)
          vim.keymap.set("n", "<space>wr", vim.lsp.buf.remove_workspace_folder, opts)
          vim.keymap.set("n", "<space>wl", function()
            print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
          end, opts)
          vim.keymap.set("n", "<space>D", vim.lsp.buf.type_definition, opts)
          vim.keymap.set("n", "<space>rn", vim.lsp.buf.rename, opts)
          vim.keymap.set({ "n", "v" }, "<space>ca", vim.lsp.buf.code_action, opts)
          vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
          vim.keymap.set("n", "[a", vim.diagnostic.goto_prev, opts)
          vim.keymap.set("n", "]a", vim.diagnostic.goto_next, opts)
          vim.keymap.set("n", "<space>q", vim.diagnostic.setloclist, opts)
        end,
      })
    end
  },
  {
    "fatih/vim-go",
    ft = { "go", "gomod" },
    config = function()
      --- This is handled by nvim lsp
      vim.g.go_gopls_enabled = 0
      vim.g.go_code_completion_enabled = 0
      vim.g.go_fmt_autosave = 0
      vim.g.go_imports_autosave = 0
      vim.g.go_mod_fmt_autosave = 0
      vim.g.go_def_mapping_enabled = 0
      vim.g.go_doc_keywordprg_enabled = 0
      vim.g.go_metalinter_autosave = 0
      vim.g.go_textobj_enabled = 0
    end,
  },
  {
    "lewis6991/gitsigns.nvim",
    opts = {},
  },
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
      require("nvim-autopairs").setup()
    end,
  },
  {
    "kylechui/nvim-surround",
    event = "VeryLazy",
    config = function()
      require("nvim-surround").setup()
    end
  },
  { "numToStr/Comment.nvim", opts = {} },

  { "godlygeek/tabular"               },
  { "tpope/vim-fugitive"              },
  { "tpope/vim-repeat"                },

  { "rust-lang/rust.vim"            , ft = { "rust" }},
  { "pearofducks/ansible-vim"       , ft = { "yaml.ansible" , "ansible_hosts" }},
  { "nfnty/vim-nftables"            , ft = { "nftables" }},
  { "vim-latex/vim-latex"           , ft = { "tex" }},
  { "xuhdev/vim-latex-live-preview" , ft = { "tex" }},
  { "vivien/vim-linux-coding-style" , ft = { "c" }},
  { "chazy/cscope_maps"             , ft = { "c" }},
  { "brookhong/cscope.vim"          , ft = { "c" }},
  { "ekalinin/Dockerfile.vim"       , ft = { "Dockerfile" }},
  { "kchmck/vim-coffee-script"      , ft = { "coffee" }},
  { "pangloss/vim-javascript"       , ft = { "javascript", "javascript.jsx" }},
  { "MaxMEllon/vim-jsx-pretty"      , ft = { "javascript", "javascript.jsx" }},
  { "tmhedberg/matchit"             , ft = { "javascript" }} ,
  { "tpope/vim-endwise"             , ft = { "lua", "ruby", "sh", "zsh", "vim" }},
  { "plasticboy/vim-markdown"       , ft = { "markdown" }},
  { "tpope/vim-rails"               , ft = { "ruby" }},
  { "ziglang/zig.vim"               , ft = { "zig" }},
  { "wannesm/wmgraphviz.vim"        , ft = { "dot" }},
  { "sirtaj/vim-openscad"           , ft = { "openscad" }},
},
{
  ui = {
    border = require("utils/border"),
    custom_keys = {
      ["<C-h>"] = close_lazy,
      ["<C-l>"] = close_lazy,
      ["<C-j>"] = close_lazy,
      ["<C-k>"] = close_lazy,
    },
  },
})
