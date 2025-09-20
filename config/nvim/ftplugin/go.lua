vim.opt_local.expandtab = false
vim.opt_local.softtabstop = 4
vim.opt_local.tabstop = 4
vim.opt_local.shiftwidth = 4

-- LSP
vim.lsp.enable("gopls")

-- ALE
vim.b.ale_linters = {"go build", "gopls", "golangci-lint"}
vim.b.ale_fixers = {"goimports", "gofmt"}
vim.b.ale_go_golangci_lint_options = "--exclude-use-default=false -E godot -E revive -E gocritic"
vim.b.ale_go_golangci_lint_package = 1
