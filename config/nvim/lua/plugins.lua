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
    "dense-analysis/ale",
    config = function()
      vim.g.ale_echo_msg_error_str = 'E'
      vim.g.ale_echo_msg_info_str = 'I'
      vim.g.ale_echo_msg_warning_str = 'W'
      vim.g.ale_echo_msg_format = '[%linter%:%type%] %code: %%s'
      vim.g.ale_sign_error = ''
      vim.g.ale_sign_warning = ''
      vim.g.ale_lint_on_text_changed = 'never'
      vim.g.ale_lint_on_insert_leave = 0
      vim.g.ale_fix_on_save = 1
      vim.g.ale_virtualtext_cursor = 1
    end
  },
  {
    "norcalli/nvim-colorizer.lua",
    dependencies = { "kyazdani42/nvim-web-devicons" },
    cmd = { "ColorizerToggle" },
  },
  {
    "scrooloose/nerdtree",
    config = function()
      vim.g.NERDChristmasTree=1
      vim.g.NERDTreeAutoDeleteBuffer=1
      vim.g.NERDTreeChDirMode=2
      vim.g.NERDTreeDirArrows=0
      vim.g.NERDTreeShowBookmarks=1
      vim.g.NERDTreeShowHidden=1
      vim.g.NERDTreeMinimalMenu=1
    end
  },
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    opts = {
        scope = { enabled = false },
    },
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
          "comment",
          "css",
          "dot",
          "go",
          "html",
          "json",
          "lua",
          "make",
          "markdown",
          "query", -- treesitter playground
          "rust",
          "vim",
          "vimdoc",
          "yaml",
          "zig",
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
        italics = false,
        palette = palette,
        custom_hlgroups = {
          Todo = { bg = palette.pink, fg = palette.base1 },
          NormalFloat = { fg = palette.white, bg = palette.base2 },
          FloatBorder = { fg = palette.orange, bg = palette.base2 },
          TelescopeNormal = { fg = palette.white, bg = palette.base2 },
          DiffChange = { fg = palette.orange, bg = palette.base2 },
          TelescopeTitle = { fg = palette.white, bg = palette.base2 },
          TelescopeBorder = { fg = palette.orange },
          NvimTreeCursorColumn = { bg = palette.base2 },
          NvimTreeCursorLine = { bg = palette.base2 },
          NERDTreeDir = { fg = palette.green },
          NERDTreeExecFile = { fg = palette.orange },
          -- SignColumn = { fg = palette.white, bg = palette.base3 },
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
      lsp.rust_analyzer.setup{}

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
    "olimorris/codecompanion.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    opts = {
      strategies = {
        chat = {
          adapter = "ollama",
        },
        inline = {
          adapter = "ollama",
        },
      },
      adapters = {
        ollama = function()
          return require("codecompanion.adapters").extend("ollama", {
            schema = {
              model = {
                -- default = "qwen2.5-coder:32b",
                default = "deepseek-coder-v2:latest",
              },
              num_ctx = {
                default = 16384,
              },
            },
            env = {
              url = "https://ollama.quimbo.fr",
              api_key = "your_key_here",
            },
            headers = {
              ["Content-Type"] = "application/json",
            },
            parameters = {
              sync = true,
            },
          })
        end,
      },
    },
  },
  {
    "nomnivore/ollama.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    cmd = { "Ollama" },
    keys = {
      -- Sample keybind for prompt menu. Note that the <c-u> is important for selections to work properly.
      {
        "<leader>oo",
        ":<c-u>lua require('ollama').prompt()<cr>",
        desc = "ollama prompt",
        mode = { "n", "v" },
      },

      -- Sample keybind for direct prompting. Note that the <c-u> is important for selections to work properly.
      {
        "<leader>oG",
        ":<c-u>lua require('ollama').prompt('Generate_Code')<cr>",
        desc = "ollama Generate Code",
        mode = { "n", "v" },
      },
    },

    ---@type Ollama.Config
    opts = {
      model = "phi4:14b",
      -- model = "codellama:7b",
      -- model = "deepseek-coder-v2:16b",
      url = "https://ollama.quimbo.fr",
      -- url = "http://127.0.0.1:11434",
      serve = { on_start = false },
      -- View the actual default prompts in ./lua/ollama/prompts.lua
    }
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
